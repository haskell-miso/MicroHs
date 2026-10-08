#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

/* Data.Bool_Type.Bool: False=0, True=1 */

static int64_t f0(int64_t p);
static int64_t f0(int64_t p) {
  int b = (p == 0);
  int64_t r_0;
  switch (b) {
  case 0: {
  int64_t x = (p - 1);
  int64_t x_1 = f0(x);
  int64_t x_2 = (p * x_1);
  r_0 = x_2; break; }
  case 1: {
  r_0 = 1; break; }
  default: abort();
  }
  return r_0;
}

int64_t factorial(int64_t n) {
  int b_1 = (n == 0);
  int64_t r_1;
  switch (b_1) {
  case 0: {
  int64_t x_3 = (n - 1);
  int64_t x_4 = f0(x_3);
  int64_t x_5 = (n * x_4);
  r_1 = x_5; break; }
  case 1: {
  r_1 = 1; break; }
  default: abort();
  }
  return r_1;
}
int main(int argc, char **argv) {
  for (int i = 1; i < argc; i++) printf("%lld\n", (long long)factorial(atoll(argv[i])));
  return 0;
}
