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

*-o <Int>*: Stands for "offset".
When positive number is used, it will skip first bytes.
When negative number is used, it will read from last part of the file.
This will be floored to 16 bytes sections eg 15 => 0, 255 => 240.

*-n <Uint>*: Stands for "number".
This parameter simply specify the number of bytes to read.

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
