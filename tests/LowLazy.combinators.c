#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

/* the memory of the program (Staged.Low.Mem) */
#ifndef MHS_MEM_WORDS
#define MHS_MEM_WORDS (1 << 20)
#endif
static int64_t mhs_mem[MHS_MEM_WORDS];

/* Staged.Low.Mem: Mem=0 */
struct c { int tag; union { struct { void* f0; void* f1; } c; } u; };


int64_t combinators(int m, int64_t n) {
  mhs_mem[0] = 1;
  int m_1 = 0;
  int64_t x = (100 - n);
  int64_t x1 = x;
  int64_t r_0;
  int64_t x3 = x1;
  int x4 = 0;
  r_0 = x3;
  return r_0;
}
int main(int argc, char **argv) {
  for (int i = 1; i < argc; i++) printf("%lld\n", (long long)combinators(0, atoll(argv[i])));
  return 0;
}
