#!/bin/sh
# Run the tests of tests/Makefile that need no arguments or input with
# mhs -wpo, and compare with the .ref files.
#   tests/wpo.sh [MHS] [TEST ...]
# Prints one line per test (PASS, DIFF, COMPILE: the error, CC: C compiler
# error, RUN: exit status) and the number of tests that pass.
MHS=${1:-bin/mhs}
[ $# -gt 0 ] && shift
CC=${CC:-cc}
OUT=${OUT:-tests/wpo-out}
mkdir -p $OUT
if [ $# -gt 0 ]; then
  TESTS="$*"
else
  TESTS=$(sed -n 's/^\t$(TMHS) \([A-Za-z0-9]*\) *&& $(EVAL) > \1.out *&& diff \1.ref \1.out$/\1/p' tests/Makefile)
fi
pass=0; total=0
for t in $TESTS; do
  total=$((total + 1))
  if ! timeout 60 $MHS -itests -ilib -CR -wpo -o$OUT/$t.c $t > $OUT/$t.log 2>&1; then
    echo "$t: COMPILE: $(grep -o 'mhs -wpo: .*' $OUT/$t.log | head -1 | cut -c1-100)"
  elif ! $CC -O2 -w -o $OUT/$t.exe $OUT/$t.c >> $OUT/$t.log 2>&1; then
    echo "$t: CC"
  elif ! timeout 60 $OUT/$t.exe > $OUT/$t.out 2>&1; then
    echo "$t: RUN: $?"
  elif diff -q tests/$t.ref $OUT/$t.out > /dev/null; then
    echo "$t: PASS"; pass=$((pass + 1))
  else
    echo "$t: DIFF"
  fi
done
echo "wpo: $pass of $total tests pass"
