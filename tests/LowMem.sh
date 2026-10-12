#!/bin/sh
# Compile and run the C that LowMem.hs generates: the sum of the squares
# 0 .. n-1 for a few n (the memory of the program is a global array).
CC=${CC:-cc}
$CC -O2 -w -o LowMem.squares.exe LowMem.squares.c || exit 1
got=$(./LowMem.squares.exe 0 1 2 10 100 | tr '\n' ' ')
expect="0 0 1 285 328350 "
if [ "$got" != "$expect" ]; then echo "LowMem.squares.c: $got, expected $expect"; exit 1; fi
rm -f LowMem.squares.exe
