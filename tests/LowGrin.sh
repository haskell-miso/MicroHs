#!/bin/sh
# Compile and run the C that LowGrin.hs generates (LowGrin.<name>.c), and
# compare with the reference interpreter (the results in LowGrin.ref).
CC=${CC:-cc}
check() {
  name=$1; expect=$2; shift 2
  $CC -O2 -w -o LowGrin.$name.exe LowGrin.$name.c || exit 1
  got=$(./LowGrin.$name.exe "$@" | tr '\n' ' ')
  if [ "$got" != "$expect " ]; then
    echo "LowGrin.$name.c: $got, expected $expect"
    exit 1
  fi
}
check factorial "1 1 120 3628800 2432902008176640000" 0 1 5 10 20
check fibs "0 1 1 55 102334155" 0 1 2 10 40
check sumSquares "0 1 385 338350" 0 1 10 100
check combinators "100 93" 0 7
rm -f LowGrin.*.exe
