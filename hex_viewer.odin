package hex_viewer

import "base:intrinsics"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:os"

Options :: struct {
	file_name: string,
	n: int, // Number of bytes to display
	o: int, // Offset
}

Byte_Category :: enum {
	Zero,
	Control,
	Ascii,
	Non_Ascii,
}

@(rodata)
category_symbol := [Byte_Category]rune {
	.Zero      = '⋄',
	.Control   = '•',
	.Ascii     = ' ', // Unused
	.Non_Ascii = '×',
}

default_color := "\e[0;37m"
default_dark  := "\e[0;90m"

@(rodata)
category_color := [Byte_Category]string {
	.Zero      = "\e[0;90m",
	.Control   = "\e[0;92m",
	.Ascii     = "\e[0;96m", // Unused
	.Non_Ascii = "\e[0;93m",
}


parse_int_param :: proc(options: ^Options, args: ^[]string, param_name: string) -> int {
	if len(args) == 0 {
		fmt.eprintfln("You must provide a parameter for option %s", param_name)
		os.exit(1)
	}
	num_str := args[0]
	args^ = args[1:]
	num, ok := strconv.parse_int(num_str)
	if !ok {
		fmt.eprintfln("Parameter %s must be a integer", param_name)
		os.exit(1)
	}
	return num
}

parse_options :: proc(options: ^Options, args: []string) {
	options^ = {}
	
	args := args
	for len(args) > 0 {
		arg := args[0]
		args = args[1:]
		switch arg {
		case "-n":
			n := parse_int_param(options, &args, arg)
			if n < 0 {
				fmt.eprintfln("Parameter -n must be a positive integer")
			}
			options.n = n
		case "-o":
			n := parse_int_param(options, &args, arg)
			options.o = n
		case:
			if strings.has_prefix(arg, "-") {
				fmt.eprintfln("Unknown option %s", arg)
				os.exit(1)
			}
			if options.file_name != "" {
				fmt.eprintln("File name provided twice")
				os.exit(1)
			}
			options.file_name = arg
		}
	}
	if options.file_name == "" {
		fmt.eprintln("File name not provided")
		os.exit(1)
	}
}

get_byte_category :: proc(b: u8) -> Byte_Category {
	switch b {
	case 0:
		return .Zero
	case 1..<0x20:
		return .Control
	case 0x20..<0x80:
		return .Ascii
	}
	return .Non_Ascii
}

main :: proc() {
	options: Options
	parse_options(&options, os.args[1:])

	data, data_ok := os.read_entire_file(options.file_name)
	if !data_ok || data == nil {
		fmt.eprintln("Failed to read file")
		os.exit(1)
	}

	start := options.o
	if start < 0 {
		start = len(data) + start
	}
	start -= start & 0xF
	
	end := len(data)
	if options.n != 0 {
		end = min(len(data), start + options.n)
	}
	
	first_line := true
	for line := start; line < end; line += 16 {
		free_all(context.temp_allocator)
		
		fmt.print(default_color)
		if line % 256 == 0 || first_line {
			fmt.println("┌────────┬─────────────────────────┬─────────────────────────┬────────┬────────┐")
			first_line = false
		}
		
		address_str := fmt.tprintf("%08x", line) // NOTE: Assumes the file is smaller than 32-bit limit
		fmt.print("│")
		fmt.print(default_dark)
		fmt.print(address_str)
		fmt.print(default_color)
		fmt.print("│")
		
		for i in 0..<16 {
			if i == 8 {
				fmt.print(default_color)
				fmt.print(" ┊")
			}
			b := data[line + i]
			c := get_byte_category(b)
			fmt.print(category_color[c])
			fmt.printf(" %02x", data[line + i])
		}
		fmt.print(default_color)
		fmt.print(" │")
		for i in 0..<16 {
			if i == 8 {
				fmt.print("┊")
			}
			b := data[line + i]
			c := get_byte_category(b)
			fmt.print(category_color[c])
			if c == .Ascii {
				fmt.print(rune(b))
			} else {
				fmt.print(category_symbol[c])
			}
		}
		fmt.print(default_color)
		fmt.print("│")
		fmt.println()
		
		if line % 256 == 240 || end - line <= 16 {
			fmt.print(default_color)
			fmt.println("└────────┴─────────────────────────┴─────────────────────────┴────────┴────────┘")
		}
	}

}

