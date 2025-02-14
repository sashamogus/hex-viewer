odin build .
del hv.exe
rename "hex-viewer.exe" "hv.exe"
copy "hv.exe" "c:\my_tools\hv.exe"
hv.exe KosugiMaru-Regular.ttf -n 256 -o -16
