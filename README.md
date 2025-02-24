# Simple Hex Viewer

This is a terminal hex viewer that I made for myself.
Heavily insipired by [hexyl](https://github.com/sharkdp/hexyl)

## Build

Install [Odin](https://odin-lang.org/) and run these commands.

```
git clone https://github.com/sashamogus/hex-viewer
cd hex-viewer
odin build .
```

## Options

Currently hex-viewer supports two options

*-o N*: Stands for "offset".
When positive number is used, it will skip first bytes.
When negative number is used, it will read from last part of the file.
This will be floored to 16 bytes sections eg 15 => 0, 255 => 240.

*-n N*: Stands for "number".
This parameter simply specify the number of bytes to read.
This will be ceiled to 16 bytes sections eg 15 => 16, 255 => 256.

## Examples

```
# Display the entire file
hex-viewer data.dat

# Display first 256 bytes
hex-viewer data.dat -n 256

# Display last 256 bytes
hex-viewer data.dat -o -256

# Display 69 bytes starting from 420(416)
hex-viewer data.dat -n 69 -o 420

# You can also use hexadecimals
hex-viewer data.dat -n 0x4000 -o 0x1000

# Display last 4KiB
hex-viewer data.dat -o -0x1000
