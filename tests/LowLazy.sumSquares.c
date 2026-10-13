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
static int64_t t0(int m_11, int64_t p_1);
static int64_t t1(int m_23, int64_t p_2);
static int64_t t2(int m_27, int64_t p_3);
static int64_t j_1(int64_t v, int m_2) {
  int64_t x_1 = mhs_mem[v];
  int64_t r_0;
  switch ((x_1 == 7)) {
  case 0: {
  int64_t x_2 = mhs_mem[(v + 1)];
  int64_t x_3 = mhs_mem[(v + 2)];
  int64_t x_4 = mhs_mem[x_3];
  int64_t r_1;
  switch ((x_4 == 1)) {
  case 0: {
  int64_t x1 = t2(m_2, x_3);
  int64_t r_2;
  int64_t x3 = x1;
  int x4 = 0;
  mhs_mem[x_3] = 1;
  mhs_mem[(x_3 + 1)] = x3;
  r_2 = x3;
  r_1 = r_2; break; }
  case 1: {
  r_1 = mhs_mem[(x_3 + 1)]; break; }
  default: abort();
  }
  int64_t x1_1 = r_1;
  int64_t r_3;
  int64_t x3_1 = x1_1;
  int x4_1 = 0;
  int64_t x1_2 = f0(x4_1, x3_1);
  int64_t r_4;
  int64_t x3_2 = x1_2;
  int x4_2 = 0;
  int64_t x_5 = mhs_mem[x_2];
  int64_t r_5;
  switch ((x_5 == 1)) {
  case 0: {
  int64_t x1_3 = t1(x4_2, x_2);
  int64_t r_6;
  int64_t x3_3 = x1_3;
  int x4_3 = 0;
  mhs_mem[x_2] = 1;
  mhs_mem[(x_2 + 1)] = x3_3;
  r_6 = x3_3;
  r_5 = r_6; break; }
  case 1: {
  r_5 = mhs_mem[(x_2 + 1)]; break; }
  default: abort();
  }
  int64_t x1_4 = r_5;
  int64_t r_7;
  int64_t x3_4 = x1_4;
  int x4_4 = 0;
  int64_t x_6 = mhs_mem[(x3_4 + 1)];
  int64_t x_7 = (x_6 + x3_2);
  r_7 = x_7;
  r_4 = r_7;
  r_3 = r_4;
  r_0 = r_3; break; }
  case 1: {
  int64_t x_8 = mhs_mem[(v + 1)];
  r_0 = x_8; break; }
  default: abort();
  }
  return r_0;
}
static int64_t f0(int m_1, int64_t p) {
  int64_t x = mhs_mem[p];
  int64_t r_8;
  switch ((x == 8)) {
  case 0: {
  int64_t x_9 = mhs_mem[(p + 1)];
  int64_t x_10 = mhs_mem[(p + 2)];
  int64_t x_11 = mhs_mem[0];
  mhs_mem[0] = (x_11 + 3);
  int m_4 = 0;
  mhs_mem[x_11] = 9;
  int m_5 = 0;
  mhs_mem[(x_11 + 1)] = x_9;
  int m_6 = 0;
  mhs_mem[(x_11 + 2)] = x_10;
  int m_7 = 0;
  r_8 = j_1(x_11, m_7); break; }
  case 1: {
  int64_t x_12 = mhs_mem[0];
  mhs_mem[0] = (x_12 + 2);
  int m_8 = 0;
  mhs_mem[x_12] = 7;
  int m_9 = 0;
  mhs_mem[(x_12 + 1)] = 0;
  int m_10 = 0;
  r_8 = j_1(x_12, m_10); break; }
  default: abort();
  }
  return r_8;
}
static int64_t t0(int m_11, int64_t p_1) {
  int64_t x_13 = mhs_mem[(p_1 + 1)];
  int64_t x_14 = mhs_mem[(p_1 + 2)];
  int64_t x_15 = (x_13 + 1);
  int b = (x_15 > x_14);
  int64_t r_9;
  switch (b) {
  case 0: {
  int64_t x_16 = mhs_mem[0];
  mhs_mem[0] = (x_16 + 3);
  int m_13 = 0;
  mhs_mem[x_16] = 11;
  int m_14 = 0;
  mhs_mem[(x_16 + 1)] = x_15;
  int m_15 = 0;
  mhs_mem[(x_16 + 2)] = x_14;
  int m_16 = 0;
  int64_t x_17 = mhs_mem[0];
  mhs_mem[0] = (x_17 + 3);
  int m_17 = 0;
  mhs_mem[x_17] = 4;
  int m_18 = 0;
  mhs_mem[(x_17 + 1)] = x_15;
  int m_19 = 0;
  mhs_mem[(x_17 + 2)] = x_16;
  int m_20 = 0;
  r_9 = x_17; break; }
  case 1: {
  int64_t x_18 = mhs_mem[0];
  mhs_mem[0] = (x_18 + 1);
  int m_21 = 0;
  mhs_mem[x_18] = 6;
  int m_22 = 0;
  r_9 = x_18; break; }
  default: abort();
  }
  return r_9;
}
static int64_t t1(int m_23, int64_t p_2) {
  int64_t x_19 = mhs_mem[(p_2 + 1)];
  int64_t x_20 = (x_19 * x_19);
  int64_t x_21 = mhs_mem[0];
  mhs_mem[0] = (x_21 + 2);
  int m_24 = 0;
  mhs_mem[x_21] = 2;
  int m_25 = 0;
  mhs_mem[(x_21 + 1)] = x_20;
  int m_26 = 0;
  return x_21;
}
static int64_t j_4(int64_t v_3, int m_28) {
  int64_t x_25 = mhs_mem[v_3];
  int64_t r_13;
  switch ((x_25 == 3)) {
  case 0: {
  int64_t x_26 = mhs_mem[0];
  mhs_mem[0] = (x_26 + 1);
  int m_30 = 0;
  mhs_mem[x_26] = 8;
  int m_31 = 0;
  r_13 = x_26; break; }
  case 1: {
  int64_t x_27 = mhs_mem[(v_3 + 1)];
  int64_t x_28 = mhs_mem[(v_3 + 2)];
  int64_t x_29 = mhs_mem[0];
  mhs_mem[0] = (x_29 + 2);
  int m_32 = 0;
  mhs_mem[x_29] = 12;
  int m_33 = 0;
  mhs_mem[(x_29 + 1)] = x_27;
  int m_34 = 0;
  int64_t x_30 = mhs_mem[0];
  mhs_mem[0] = (x_30 + 2);
  int m_35 = 0;
  mhs_mem[x_30] = 13;
  int m_36 = 0;
  mhs_mem[(x_30 + 1)] = x_28;
  int m_37 = 0;
  int64_t x_31 = mhs_mem[0];
  mhs_mem[0] = (x_31 + 3);
  int m_38 = 0;
  mhs_mem[x_31] = 10;
  int m_39 = 0;
  mhs_mem[(x_31 + 1)] = x_29;
  int m_40 = 0;
  mhs_mem[(x_31 + 2)] = x_30;
  int m_41 = 0;
  r_13 = x_31; break; }
  default: abort();
  }
  return r_13;
}
static int64_t t2(int m_27, int64_t p_3) {
  int64_t x_22 = mhs_mem[(p_3 + 1)];
  int64_t x_23 = mhs_mem[x_22];
  int64_t r_10;
  switch ((x_23 == 1)) {
  case 0: {
  int64_t x1_5 = t0(m_27, x_22);
  int64_t r_11;
  int64_t x3_5 = x1_5;
  int x4_5 = 0;
  mhs_mem[x_22] = 1;
  mhs_mem[(x_22 + 1)] = x3_5;
  r_11 = x3_5;
  r_10 = r_11; break; }
  case 1: {
  r_10 = mhs_mem[(x_22 + 1)]; break; }
  default: abort();
  }
  int64_t x1_6 = r_10;
  int64_t r_12;
  int64_t x3_6 = x1_6;
  int x4_6 = 0;
  int64_t x_24 = mhs_mem[x3_6];
  int64_t r_14;
  switch ((x_24 == 4)) {
  case 0: {
  int64_t x_32 = mhs_mem[0];
  mhs_mem[0] = (x_32 + 1);
  int m_42 = 0;
  mhs_mem[x_32] = 5;
  int m_43 = 0;
  r_14 = j_4(x_32, m_43); break; }
  case 1: {
  int64_t x_33 = mhs_mem[(x3_6 + 1)];
  int64_t x_34 = mhs_mem[(x3_6 + 2)];
  int64_t x_35 = mhs_mem[0];
  mhs_mem[0] = (x_35 + 3);
  int m_44 = 0;
  mhs_mem[x_35] = 3;
  int m_45 = 0;
  mhs_mem[(x_35 + 1)] = x_33;
  int m_46 = 0;
  mhs_mem[(x_35 + 2)] = x_34;
  int m_47 = 0;
  r_14 = j_4(x_35, m_47); break; }
  default: abort();
  }
  r_12 = r_14;
  return r_12;
}
static int64_t j_5(int64_t v_7, int m_51) {
  int64_t x1_7 = f0(m_51, v_7);
  return x1_7;
}
static int64_t j_6(int64_t v_6, int m_50) {
  int64_t x_37 = mhs_mem[v_6];
  int64_t r_15;
  switch ((x_37 == 3)) {
  case 0: {
  int64_t x_38 = mhs_mem[0];
  mhs_mem[0] = (x_38 + 1);
  int m_52 = 0;
  mhs_mem[x_38] = 8;
  int m_53 = 0;
  r_15 = j_5(x_38, m_53); break; }
  case 1: {
  int64_t x_39 = mhs_mem[(v_6 + 1)];
  int64_t x_40 = mhs_mem[(v_6 + 2)];
  int64_t x_41 = mhs_mem[0];
  mhs_mem[0] = (x_41 + 2);
  int m_54 = 0;
  mhs_mem[x_41] = 12;
  int m_55 = 0;
  mhs_mem[(x_41 + 1)] = x_39;
  int m_56 = 0;
  int64_t x_42 = mhs_mem[0];
  mhs_mem[0] = (x_42 + 2);
  int m_57 = 0;
  mhs_mem[x_42] = 13;
  int m_58 = 0;
  mhs_mem[(x_42 + 1)] = x_40;
  int m_59 = 0;
  int64_t x_43 = mhs_mem[0];
  mhs_mem[0] = (x_43 + 3);
  int m_60 = 0;
  mhs_mem[x_43] = 10;
  int m_61 = 0;
  mhs_mem[(x_43 + 1)] = x_41;
  int m_62 = 0;
  mhs_mem[(x_43 + 2)] = x_42;
  int m_63 = 0;
  r_15 = j_5(x_43, m_63); break; }
  default: abort();
  }
  return r_15;
}
static int64_t j_7(int64_t v_5, int m_49) {
  int64_t x_36 = mhs_mem[v_5];
  int64_t r_16;
  switch ((x_36 == 4)) {
  case 0: {
  int64_t x_44 = mhs_mem[0];
  mhs_mem[0] = (x_44 + 1);
  int m_64 = 0;
  mhs_mem[x_44] = 5;
  int m_65 = 0;
  r_16 = j_6(x_44, m_65); break; }
  case 1: {
  int64_t x_45 = mhs_mem[(v_5 + 1)];
  int64_t x_46 = mhs_mem[(v_5 + 2)];
  int64_t x_47 = mhs_mem[0];
  mhs_mem[0] = (x_47 + 3);
  int m_66 = 0;
  mhs_mem[x_47] = 3;
  int m_67 = 0;
  mhs_mem[(x_47 + 1)] = x_45;
  int m_68 = 0;
  mhs_mem[(x_47 + 2)] = x_46;
  int m_69 = 0;
  r_16 = j_6(x_47, m_69); break; }
  default: abort();
  }
  return r_16;
}

int64_t sumSquares(int m, int64_t n) {
  mhs_mem[0] = 1;
  int m_48 = 0;
  int b_1 = (1 > n);
  int64_t r_17;
  switch (b_1) {
  case 0: {
  int64_t x_48 = mhs_mem[0];
  mhs_mem[0] = (x_48 + 3);
  int m_70 = 0;
  mhs_mem[x_48] = 11;
  int m_71 = 0;
  mhs_mem[(x_48 + 1)] = 1;
  int m_72 = 0;
  mhs_mem[(x_48 + 2)] = n;
  int m_73 = 0;
  int64_t x_49 = mhs_mem[0];
  mhs_mem[0] = (x_49 + 3);
  int m_74 = 0;
  mhs_mem[x_49] = 4;
  int m_75 = 0;
  mhs_mem[(x_49 + 1)] = 1;
  int m_76 = 0;
  mhs_mem[(x_49 + 2)] = x_48;
  int m_77 = 0;
  r_17 = j_7(x_49, m_77); break; }
  case 1: {
  int64_t x_50 = mhs_mem[0];
  mhs_mem[0] = (x_50 + 1);
  int m_78 = 0;
  mhs_mem[x_50] = 6;
  int m_79 = 0;
  r_17 = j_7(x_50, m_79); break; }
  default: abort();
  }
  int64_t x1_8 = r_17;
  int64_t r_18;
  int64_t x3_8 = x1_8;
  int x4_8 = 0;
  r_18 = x3_8;
  return r_18;
}
int main(int argc, char **argv) {
  for (int i = 1; i < argc; i++) printf("%lld\n", (long long)sumSquares(0, atoll(argv[i])));
  return 0;
}
