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
static int64_t gc(int m_5);
static int64_t j(int64_t x, int64_t v, int m_2) {
  mhs_mem[4] = x;
  int m_3 = 0;
  return v;
}
static int64_t f0(int m_1, int64_t p) {
  int64_t x = mhs_mem[4];
  int b = (p == 0);
  int64_t r_0;
  switch (b) {
  case 0: {
  int64_t x_1 = (p - 1);
  int r_1;
  switch ((x > 2064)) {
  case 0: {
  mhs_mem[4] = x;
  r_1 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_1 = 0; break; }
  default: abort();
  }
  int m_4 = r_1;
  int64_t x1 = f0(m_4, x_1);
  int64_t r_2;
  int64_t x3 = x1;
  int x4 = 0;
  int64_t x_2 = (p * x3);
  r_2 = j(x, x_2, x4);
  r_0 = r_2; break; }
  case 1: {
  r_0 = j(x, 1, m_1); break; }
  default: abort();
  }
  return r_0;
}
static int copyWords(int m_6, int64_t src, int64_t dst, int64_t n_1);
static int copyWords(int m_6, int64_t src, int64_t dst, int64_t n_1) {
  int r_3;
  switch ((n_1 == 0)) {
  case 0: {
  mhs_mem[dst] = mhs_mem[src];
  r_3 = copyWords(0, (src + 1), (dst + 1), (n_1 - 1)); break; }
  case 1: {
  r_3 = m_6; break; }
  default: abort();
  }
  return r_3;
}
static int64_t copy(int m_7, int64_t p_1) {
  int64_t t = mhs_mem[p_1];
  int64_t r_4;
  switch ((t == 0)) {
  case 0: {
  int64_t r_5;
  switch ((t < 0)) {
  case 0: {
  r_5 = t; break; }
  case 1: {
  r_5 = (0 - t); break; }
  default: abort();
  }
  int64_t u = r_5;
  int64_t n_2 = 2;
  int64_t free = mhs_mem[6];
  int m1_1 = copyWords(m_7, p_1, free, n_2);
  mhs_mem[p_1] = 0;
  mhs_mem[(p_1 + 1)] = free;
  mhs_mem[6] = (free + n_2);
  r_4 = free; break; }
  case 1: {
  r_4 = mhs_mem[(p_1 + 1)]; break; }
  default: abort();
  }
  return r_4;
}
static int scan(int m_8);
static int scan(int m_8) {
  int64_t s = mhs_mem[7];
  int64_t f = mhs_mem[6];
  int r_6;
  switch ((s >= f)) {
  case 0: {
  int64_t t_1 = mhs_mem[s];
  int r_7;
  switch ((t_1 < 0)) {
  case 0: {
  r_7 = m_8; break; }
  case 1: {
  int64_t x1_1 = copy(m_8, mhs_mem[(s + 1)]);
  int r_8;
  int64_t a0_1 = x1_1;
  int x4_1 = 0;
  mhs_mem[(s + 1)] = a0_1;
  int m2 = 0;
  r_8 = m2;
  r_7 = r_8; break; }
  default: abort();
  }
  int m1_2 = r_7;
  int64_t r_9;
  switch ((t_1 < 0)) {
  case 0: {
  r_9 = t_1; break; }
  case 1: {
  r_9 = (0 - t_1); break; }
  default: abort();
  }
  int64_t u_1 = r_9;
  mhs_mem[7] = (s + 2);
  r_6 = scan(0); break; }
  case 1: {
  r_6 = m_8; break; }
  default: abort();
  }
  return r_6;
}
static int roots(int64_t sp, int m_9, int64_t i);
static int roots(int64_t sp, int m_9, int64_t i) {
  int r_10;
  switch ((i >= sp)) {
  case 0: {
  int64_t x1_2 = copy(m_9, mhs_mem[i]);
  int r_11;
  int64_t x3_1 = x1_2;
  int x4_2 = 0;
  mhs_mem[i] = x3_1;
  r_11 = roots(sp, 0, (i + 1));
  r_10 = r_11; break; }
  case 1: {
  r_10 = m_9; break; }
  default: abort();
  }
  return r_10;
}
static int64_t gc(int m_5) {
  int64_t to = mhs_mem[3];
  int64_t sp = mhs_mem[4];
  int64_t semi = mhs_mem[5];
  mhs_mem[6] = to;
  mhs_mem[7] = to;
  int m1 = 0;
  int64_t gcs = mhs_mem[8];
  int64_t from = mhs_mem[2];
  int m2_1 = scan(roots(sp, m1, 16));
  int64_t free_1 = mhs_mem[6];
  mhs_mem[0] = free_1;
  mhs_mem[1] = (to + semi);
  mhs_mem[2] = to;
  mhs_mem[3] = from;
  mhs_mem[8] = (gcs + 1);
  return free_1;
}
static int64_t j_1(int64_t x_3, int64_t v_1, int m_17) {
  mhs_mem[4] = x_3;
  int m_18 = 0;
  return v_1;
}

int64_t factorial(int m, int64_t n) {
  mhs_mem[2] = 2064;
  int m_10 = 0;
  mhs_mem[3] = 5128;
  int m_11 = 0;
  mhs_mem[5] = 3064;
  int m_12 = 0;
  mhs_mem[0] = 2064;
  int m_13 = 0;
  mhs_mem[1] = 5128;
  int m_14 = 0;
  mhs_mem[4] = 16;
  int m_15 = 0;
  mhs_mem[8] = 0;
  int m_16 = 0;
  int64_t x_3 = mhs_mem[4];
  int b_1 = (n == 0);
  int64_t r_12;
  switch (b_1) {
  case 0: {
  int64_t x_4 = (n - 1);
  int r_13;
  switch ((x_3 > 2064)) {
  case 0: {
  mhs_mem[4] = x_3;
  r_13 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_13 = 0; break; }
  default: abort();
  }
  int m_19 = r_13;
  int64_t x1_3 = f0(m_19, x_4);
  int64_t r_14;
  int64_t x3_2 = x1_3;
  int x4_3 = 0;
  int64_t x_5 = (n * x3_2);
  r_14 = j_1(x_3, x_5, x4_3);
  r_12 = r_14; break; }
  case 1: {
  r_12 = j_1(x_3, 1, m_16); break; }
  default: abort();
  }
  int64_t x1_4 = r_12;
  int64_t r_15;
  int64_t x3_3 = x1_4;
  int x4_4 = 0;
  r_15 = x3_3;
  return r_15;
}
int main(int argc, char **argv) {
  for (int i = 1; i < argc; i++) {
    printf("%lld\n", (long long)factorial(0, atoll(argv[i])));
    fprintf(stderr, "%s %s: %lld collections\n", "factorial", argv[i], (long long)mhs_mem[8]);
  }
  return 0;
}
