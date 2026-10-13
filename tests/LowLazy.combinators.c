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
  mhs_mem[2] = 2064;
  int m_6 = 0;
  mhs_mem[3] = 5128;
  int m_7 = 0;
  mhs_mem[5] = 3064;
  int m_8 = 0;
  mhs_mem[0] = 2064;
  int m_9 = 0;
  mhs_mem[1] = 5128;
  int m_10 = 0;
  mhs_mem[4] = 16;
  int m_11 = 0;
  mhs_mem[8] = 0;
  int m_12 = 0;
  int64_t x = mhs_mem[4];
  int64_t x_1 = (100 - n);
  int64_t x1_2 = x_1;
  int64_t r_0;
  int64_t x3_1 = x1_2;
  int x4_2 = 0;
  r_0 = x3_1;
  return r_0;
}
int main(int argc, char **argv) {
  for (int i = 1; i < argc; i++) {
    printf("%lld\n", (long long)combinators(0, atoll(argv[i])));
    fprintf(stderr, "%s %s: %lld collections\n", "combinators", argv[i], (long long)mhs_mem[8]);
  }
  return 0;
}
