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
/* Data.Bool_Type.Bool: False=0, True=1 */

static int64_t f0(int m_1, int64_t p);
static int64_t f0(int m_1, int64_t p) {
  int b = (p == 0);
  int64_t r_0;
  switch (b) {
  case 0: {
  int64_t x = (p - 1);
  int64_t x1 = f0(m_1, x);
  int64_t r_1;
  int64_t x3 = x1;
  int x4 = 0;
  int64_t x_1 = (p * x3);
  r_1 = x_1;
  r_0 = r_1; break; }
  case 1: {
  r_0 = 1; break; }
  default: abort();
  }
  return r_0;
}

int64_t factorial(int m, int64_t n) {
  mhs_mem[0] = 1;
  int m_3 = 0;
  int b_1 = (n == 0);
  int64_t r_2;
  switch (b_1) {
  case 0: {
  int64_t x_2 = (n - 1);
  int64_t x1_1 = f0(m_3, x_2);
  int64_t r_3;
  int64_t x3_1 = x1_1;
  int x4_1 = 0;
  int64_t x_3 = (n * x3_1);
  r_3 = x_3;
  r_2 = r_3; break; }
  case 1: {
  r_2 = 1; break; }
  default: abort();
  }
  int64_t x1_2 = r_2;
  int64_t r_4;
  int64_t x3_2 = x1_2;
  int x4_2 = 0;
  r_4 = x3_2;
  return r_4;
}
int main(int argc, char **argv) {
  for (int i = 1; i < argc; i++) printf("%lld\n", (long long)factorial(0, atoll(argv[i])));
  return 0;
}
