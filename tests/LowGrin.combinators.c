#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>



int64_t combinators(int64_t n) {
  int64_t x = (100 - n);
  return x;
}
int main(int argc, char **argv) {
  for (int i = 1; i < argc; i++) printf("%lld\n", (long long)combinators(atoll(argv[i])));
  return 0;
}
