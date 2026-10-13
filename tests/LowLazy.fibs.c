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

static int64_t f0(int m_1, int64_t p, int64_t p_1);
static int64_t t0(int m_7, int64_t p_2);
static int64_t t1(int m_11, int64_t p_3);
static int64_t t2(int m_15, int64_t p_4);
static int64_t t3(int m_19, int64_t p_5);
static int64_t t4(int m_54, int64_t p_6);
static int64_t f0(int m_1, int64_t p, int64_t p_1) {
  int64_t x = mhs_mem[p];
  int64_t r_0;
  switch ((x == 1)) {
  case 0: {
  int64_t x1 = t3(m_1, p);
  int64_t r_1;
  int64_t x3 = x1;
  int x4 = 0;
  mhs_mem[p] = 1;
  mhs_mem[(p + 1)] = x3;
  r_1 = x3;
  r_0 = r_1; break; }
  case 1: {
  r_0 = mhs_mem[(p + 1)]; break; }
  default: abort();
  }
  int64_t x1_1 = r_0;
  int64_t r_2;
  int64_t x3_1 = x1_1;
  int x4_1 = 0;
  int64_t x_1 = mhs_mem[(x3_1 + 1)];
  int64_t x_2 = mhs_mem[(x3_1 + 2)];
  int64_t x_3 = mhs_mem[p_1];
  int64_t r_3;
  switch ((x_3 == 1)) {
  case 0: {
  int64_t x1_2 = t4(x4_1, p_1);
  int64_t r_4;
  int64_t x3_2 = x1_2;
  int x4_2 = 0;
  mhs_mem[p_1] = 1;
  mhs_mem[(p_1 + 1)] = x3_2;
  r_4 = x3_2;
  r_3 = r_4; break; }
  case 1: {
  r_3 = mhs_mem[(p_1 + 1)]; break; }
  default: abort();
  }
  int64_t x1_3 = r_3;
  int64_t r_5;
  int64_t x3_3 = x1_3;
  int x4_3 = 0;
  int64_t x_4 = mhs_mem[(x3_3 + 1)];
  int b = (x_4 == 0);
  int64_t r_6;
  switch (b) {
  case 0: {
  int64_t x_5 = mhs_mem[x_2];
  int64_t r_7;
  switch ((x_5 == 1)) {
  case 0: {
  int64_t x1_4 = t3(x4_3, x_2);
  int64_t r_8;
  int64_t x3_4 = x1_4;
  int x4_4 = 0;
  mhs_mem[x_2] = 1;
  mhs_mem[(x_2 + 1)] = x3_4;
  r_8 = x3_4;
  r_7 = r_8; break; }
  case 1: {
  r_7 = mhs_mem[(x_2 + 1)]; break; }
  default: abort();
  }
  int64_t x1_5 = r_7;
  int64_t r_9;
  int64_t x3_5 = x1_5;
  int x4_5 = 0;
  int64_t x_6 = mhs_mem[(x3_5 + 1)];
  int64_t x_7 = mhs_mem[(x3_5 + 2)];
  int64_t x_8 = mhs_mem[(x3_3 + 1)];
  int64_t x_9 = (x_8 - 1);
  int b_1 = (x_9 == 0);
  int64_t r_10;
  switch (b_1) {
  case 0: {
  int64_t x_10 = mhs_mem[0];
  mhs_mem[0] = (x_10 + 2);
  int m_4 = 0;
  mhs_mem[x_10] = 11;
  int m_5 = 0;
  mhs_mem[(x_10 + 1)] = x_9;
  int m_6 = 0;
  int64_t x1_6 = f0(m_6, x_7, x_10);
  r_10 = x1_6; break; }
  case 1: {
  int64_t x_11 = mhs_mem[x_6];
  int64_t r_11;
  switch ((x_11 == 1)) {
  case 0: {
  int64_t r_12;
  switch ((x_11 == 7)) {
  case 0: {
  int64_t r_13;
  switch ((x_11 == 8)) {
  case 0: {
  int64_t x1_7 = t2(x4_5, x_6);
  int64_t r_14;
  int64_t x3_7 = x1_7;
  int x4_7 = 0;
  mhs_mem[x_6] = 1;
  mhs_mem[(x_6 + 1)] = x3_7;
  r_14 = x3_7;
  r_13 = r_14; break; }
  case 1: {
  int64_t x1_8 = t1(x4_5, x_6);
  int64_t r_15;
  int64_t x3_8 = x1_8;
  int x4_8 = 0;
  mhs_mem[x_6] = 1;
  mhs_mem[(x_6 + 1)] = x3_8;
  r_15 = x3_8;
  r_13 = r_15; break; }
  default: abort();
  }
  r_12 = r_13; break; }
  case 1: {
  int64_t x1_9 = t0(x4_5, x_6);
  int64_t r_16;
  int64_t x3_9 = x1_9;
  int x4_9 = 0;
  mhs_mem[x_6] = 1;
  mhs_mem[(x_6 + 1)] = x3_9;
  r_16 = x3_9;
  r_12 = r_16; break; }
  default: abort();
  }
  r_11 = r_12; break; }
  case 1: {
  r_11 = mhs_mem[(x_6 + 1)]; break; }
  default: abort();
  }
  int64_t x1_10 = r_11;
  int64_t r_17;
  int64_t x3_10 = x1_10;
  int x4_10 = 0;
  int64_t x_12 = mhs_mem[(x3_10 + 1)];
  r_17 = x_12;
  r_10 = r_17; break; }
  default: abort();
  }
  r_9 = r_10;
  r_6 = r_9; break; }
  case 1: {
  int64_t x_13 = mhs_mem[x_1];
  int64_t r_18;
  switch ((x_13 == 1)) {
  case 0: {
  int64_t r_19;
  switch ((x_13 == 7)) {
  case 0: {
  int64_t r_20;
  switch ((x_13 == 8)) {
  case 0: {
  int64_t x1_11 = t2(x4_3, x_1);
  int64_t r_21;
  int64_t x3_11 = x1_11;
  int x4_11 = 0;
  mhs_mem[x_1] = 1;
  mhs_mem[(x_1 + 1)] = x3_11;
  r_21 = x3_11;
  r_20 = r_21; break; }
  case 1: {
  int64_t x1_12 = t1(x4_3, x_1);
  int64_t r_22;
  int64_t x3_12 = x1_12;
  int x4_12 = 0;
  mhs_mem[x_1] = 1;
  mhs_mem[(x_1 + 1)] = x3_12;
  r_22 = x3_12;
  r_20 = r_22; break; }
  default: abort();
  }
  r_19 = r_20; break; }
  case 1: {
  int64_t x1_13 = t0(x4_3, x_1);
  int64_t r_23;
  int64_t x3_13 = x1_13;
  int x4_13 = 0;
  mhs_mem[x_1] = 1;
  mhs_mem[(x_1 + 1)] = x3_13;
  r_23 = x3_13;
  r_19 = r_23; break; }
  default: abort();
  }
  r_18 = r_19; break; }
  case 1: {
  r_18 = mhs_mem[(x_1 + 1)]; break; }
  default: abort();
  }
  int64_t x1_14 = r_18;
  int64_t r_24;
  int64_t x3_14 = x1_14;
  int x4_14 = 0;
  int64_t x_14 = mhs_mem[(x3_14 + 1)];
  r_24 = x_14;
  r_6 = r_24; break; }
  default: abort();
  }
  r_5 = r_6;
  r_2 = r_5;
  return r_2;
}
static int64_t t0(int m_7, int64_t p_2) {
  int64_t x_15 = mhs_mem[(p_2 + 1)];
  int64_t x_16 = mhs_mem[(p_2 + 2)];
  int64_t x_17 = (x_15 + x_16);
  int64_t x_18 = mhs_mem[0];
  mhs_mem[0] = (x_18 + 2);
  int m_8 = 0;
  mhs_mem[x_18] = 2;
  int m_9 = 0;
  mhs_mem[(x_18 + 1)] = x_17;
  int m_10 = 0;
  return x_18;
}
static int64_t t1(int m_11, int64_t p_3) {
  int64_t x_19 = mhs_mem[(p_3 + 1)];
  int64_t x_20 = mhs_mem[(p_3 + 2)];
  int64_t x_21 = mhs_mem[x_20];
  int64_t r_25;
  switch ((x_21 == 1)) {
  case 0: {
  int64_t r_26;
  switch ((x_21 == 7)) {
  case 0: {
  int64_t r_27;
  switch ((x_21 == 8)) {
  case 0: {
  int64_t x1_15 = t2(m_11, x_20);
  int64_t r_28;
  int64_t x3_15 = x1_15;
  int x4_15 = 0;
  mhs_mem[x_20] = 1;
  mhs_mem[(x_20 + 1)] = x3_15;
  r_28 = x3_15;
  r_27 = r_28; break; }
  case 1: {
  int64_t x1_16 = t1(m_11, x_20);
  int64_t r_29;
  int64_t x3_16 = x1_16;
  int x4_16 = 0;
  mhs_mem[x_20] = 1;
  mhs_mem[(x_20 + 1)] = x3_16;
  r_29 = x3_16;
  r_27 = r_29; break; }
  default: abort();
  }
  r_26 = r_27; break; }
  case 1: {
  int64_t x1_17 = t0(m_11, x_20);
  int64_t r_30;
  int64_t x3_17 = x1_17;
  int x4_17 = 0;
  mhs_mem[x_20] = 1;
  mhs_mem[(x_20 + 1)] = x3_17;
  r_30 = x3_17;
  r_26 = r_30; break; }
  default: abort();
  }
  r_25 = r_26; break; }
  case 1: {
  r_25 = mhs_mem[(x_20 + 1)]; break; }
  default: abort();
  }
  int64_t x1_18 = r_25;
  int64_t r_31;
  int64_t x3_18 = x1_18;
  int x4_18 = 0;
  int64_t x_22 = mhs_mem[(x3_18 + 1)];
  int64_t x_23 = (x_19 + x_22);
  int64_t x_24 = mhs_mem[0];
  mhs_mem[0] = (x_24 + 2);
  int m_12 = 0;
  mhs_mem[x_24] = 2;
  int m_13 = 0;
  mhs_mem[(x_24 + 1)] = x_23;
  int m_14 = 0;
  r_31 = x_24;
  return r_31;
}
static int64_t t2(int m_15, int64_t p_4) {
  int64_t x_25 = mhs_mem[(p_4 + 1)];
  int64_t x_26 = mhs_mem[(p_4 + 2)];
  int64_t x_27 = mhs_mem[x_26];
  int64_t r_32;
  switch ((x_27 == 1)) {
  case 0: {
  int64_t r_33;
  switch ((x_27 == 7)) {
  case 0: {
  int64_t r_34;
  switch ((x_27 == 8)) {
  case 0: {
  int64_t x1_19 = t2(m_15, x_26);
  int64_t r_35;
  int64_t x3_19 = x1_19;
  int x4_19 = 0;
  mhs_mem[x_26] = 1;
  mhs_mem[(x_26 + 1)] = x3_19;
  r_35 = x3_19;
  r_34 = r_35; break; }
  case 1: {
  int64_t x1_20 = t1(m_15, x_26);
  int64_t r_36;
  int64_t x3_20 = x1_20;
  int x4_20 = 0;
  mhs_mem[x_26] = 1;
  mhs_mem[(x_26 + 1)] = x3_20;
  r_36 = x3_20;
  r_34 = r_36; break; }
  default: abort();
  }
  r_33 = r_34; break; }
  case 1: {
  int64_t x1_21 = t0(m_15, x_26);
  int64_t r_37;
  int64_t x3_21 = x1_21;
  int x4_21 = 0;
  mhs_mem[x_26] = 1;
  mhs_mem[(x_26 + 1)] = x3_21;
  r_37 = x3_21;
  r_33 = r_37; break; }
  default: abort();
  }
  r_32 = r_33; break; }
  case 1: {
  r_32 = mhs_mem[(x_26 + 1)]; break; }
  default: abort();
  }
  int64_t x1_22 = r_32;
  int64_t r_38;
  int64_t x3_22 = x1_22;
  int x4_22 = 0;
  int64_t x_28 = mhs_mem[x_25];
  int64_t r_39;
  switch ((x_28 == 1)) {
  case 0: {
  int64_t r_40;
  switch ((x_28 == 7)) {
  case 0: {
  int64_t r_41;
  switch ((x_28 == 8)) {
  case 0: {
  int64_t x1_23 = t2(x4_22, x_25);
  int64_t r_42;
  int64_t x3_23 = x1_23;
  int x4_23 = 0;
  mhs_mem[x_25] = 1;
  mhs_mem[(x_25 + 1)] = x3_23;
  r_42 = x3_23;
  r_41 = r_42; break; }
  case 1: {
  int64_t x1_24 = t1(x4_22, x_25);
  int64_t r_43;
  int64_t x3_24 = x1_24;
  int x4_24 = 0;
  mhs_mem[x_25] = 1;
  mhs_mem[(x_25 + 1)] = x3_24;
  r_43 = x3_24;
  r_41 = r_43; break; }
  default: abort();
  }
  r_40 = r_41; break; }
  case 1: {
  int64_t x1_25 = t0(x4_22, x_25);
  int64_t r_44;
  int64_t x3_25 = x1_25;
  int x4_25 = 0;
  mhs_mem[x_25] = 1;
  mhs_mem[(x_25 + 1)] = x3_25;
  r_44 = x3_25;
  r_40 = r_44; break; }
  default: abort();
  }
  r_39 = r_40; break; }
  case 1: {
  r_39 = mhs_mem[(x_25 + 1)]; break; }
  default: abort();
  }
  int64_t x1_26 = r_39;
  int64_t r_45;
  int64_t x3_26 = x1_26;
  int x4_26 = 0;
  int64_t x_29 = mhs_mem[(x3_26 + 1)];
  int64_t x_30 = mhs_mem[(x3_22 + 1)];
  int64_t x_31 = (x_29 + x_30);
  int64_t x_32 = mhs_mem[0];
  mhs_mem[0] = (x_32 + 2);
  int m_16 = 0;
  mhs_mem[x_32] = 2;
  int m_17 = 0;
  mhs_mem[(x_32 + 1)] = x_31;
  int m_18 = 0;
  r_45 = x_32;
  r_38 = r_45;
  return r_38;
}
static int64_t j_3(int64_t x_34, int64_t v_2, int m_20) {
  int64_t x_37 = mhs_mem[v_2];
  int64_t r_50;
  switch ((x_37 == 3)) {
  case 0: {
  int64_t x_38 = mhs_mem[(v_2 + 1)];
  int64_t x_39 = mhs_mem[(v_2 + 2)];
  int64_t x_40 = mhs_mem[x_34];
  int64_t r_51;
  switch ((x_40 == 1)) {
  case 0: {
  int64_t r_52;
  switch ((x_40 == 10)) {
  case 0: {
  r_52 = x_34; break; }
  case 1: {
  int64_t x1_29 = t3(m_20, x_34);
  int64_t r_53;
  int64_t x3_29 = x1_29;
  int x4_29 = 0;
  mhs_mem[x_34] = 1;
  mhs_mem[(x_34 + 1)] = x3_29;
  r_53 = x3_29;
  r_52 = r_53; break; }
  default: abort();
  }
  r_51 = r_52; break; }
  case 1: {
  r_51 = mhs_mem[(x_34 + 1)]; break; }
  default: abort();
  }
  int64_t x1_30 = r_51;
  int64_t r_54;
  int64_t x3_30 = x1_30;
  int x4_30 = 0;
  int64_t x_41 = mhs_mem[(x3_30 + 1)];
  int64_t x_42 = mhs_mem[(x3_30 + 2)];
  int64_t x_43 = mhs_mem[0];
  mhs_mem[0] = (x_43 + 3);
  int m_22 = 0;
  mhs_mem[x_43] = 8;
  int m_23 = 0;
  mhs_mem[(x_43 + 1)] = x_38;
  int m_24 = 0;
  mhs_mem[(x_43 + 2)] = x_41;
  int m_25 = 0;
  int64_t x_44 = mhs_mem[0];
  mhs_mem[0] = (x_44 + 3);
  int m_26 = 0;
  mhs_mem[x_44] = 10;
  int m_27 = 0;
  mhs_mem[(x_44 + 1)] = x_39;
  int m_28 = 0;
  mhs_mem[(x_44 + 2)] = x_42;
  int m_29 = 0;
  int64_t x_45 = mhs_mem[0];
  mhs_mem[0] = (x_45 + 3);
  int m_30 = 0;
  mhs_mem[x_45] = 4;
  int m_31 = 0;
  mhs_mem[(x_45 + 1)] = x_43;
  int m_32 = 0;
  mhs_mem[(x_45 + 2)] = x_44;
  int m_33 = 0;
  r_54 = x_45;
  r_50 = r_54; break; }
  case 1: {
  int64_t x_46 = mhs_mem[(v_2 + 1)];
  int64_t x_47 = mhs_mem[(v_2 + 2)];
  int64_t x_48 = mhs_mem[x_34];
  int64_t r_55;
  switch ((x_48 == 1)) {
  case 0: {
  int64_t r_56;
  switch ((x_48 == 10)) {
  case 0: {
  r_56 = x_34; break; }
  case 1: {
  int64_t x1_31 = t3(m_20, x_34);
  int64_t r_57;
  int64_t x3_31 = x1_31;
  int x4_31 = 0;
  mhs_mem[x_34] = 1;
  mhs_mem[(x_34 + 1)] = x3_31;
  r_57 = x3_31;
  r_56 = r_57; break; }
  default: abort();
  }
  r_55 = r_56; break; }
  case 1: {
  r_55 = mhs_mem[(x_34 + 1)]; break; }
  default: abort();
  }
  int64_t x1_32 = r_55;
  int64_t r_58;
  int64_t x3_32 = x1_32;
  int x4_32 = 0;
  int64_t x_49 = mhs_mem[(x3_32 + 1)];
  int64_t x_50 = mhs_mem[(x3_32 + 2)];
  int64_t x_51 = mhs_mem[0];
  mhs_mem[0] = (x_51 + 3);
  int m_34 = 0;
  mhs_mem[x_51] = 9;
  int m_35 = 0;
  mhs_mem[(x_51 + 1)] = x_46;
  int m_36 = 0;
  mhs_mem[(x_51 + 2)] = x_49;
  int m_37 = 0;
  int64_t x_52 = mhs_mem[0];
  mhs_mem[0] = (x_52 + 3);
  int m_38 = 0;
  mhs_mem[x_52] = 10;
  int m_39 = 0;
  mhs_mem[(x_52 + 1)] = x_47;
  int m_40 = 0;
  mhs_mem[(x_52 + 2)] = x_50;
  int m_41 = 0;
  int64_t x_53 = mhs_mem[0];
  mhs_mem[0] = (x_53 + 3);
  int m_42 = 0;
  mhs_mem[x_53] = 4;
  int m_43 = 0;
  mhs_mem[(x_53 + 1)] = x_51;
  int m_44 = 0;
  mhs_mem[(x_53 + 2)] = x_52;
  int m_45 = 0;
  r_58 = x_53;
  r_50 = r_58; break; }
  default: abort();
  }
  return r_50;
}
static int64_t t3(int m_19, int64_t p_5) {
  int64_t x_33 = mhs_mem[(p_5 + 1)];
  int64_t x_34 = mhs_mem[(p_5 + 2)];
  int64_t x_35 = mhs_mem[x_33];
  int64_t r_46;
  switch ((x_35 == 1)) {
  case 0: {
  int64_t r_47;
  switch ((x_35 == 10)) {
  case 0: {
  r_47 = x_33; break; }
  case 1: {
  int64_t x1_27 = t3(m_19, x_33);
  int64_t r_48;
  int64_t x3_27 = x1_27;
  int x4_27 = 0;
  mhs_mem[x_33] = 1;
  mhs_mem[(x_33 + 1)] = x3_27;
  r_48 = x3_27;
  r_47 = r_48; break; }
  default: abort();
  }
  r_46 = r_47; break; }
  case 1: {
  r_46 = mhs_mem[(x_33 + 1)]; break; }
  default: abort();
  }
  int64_t x1_28 = r_46;
  int64_t r_49;
  int64_t x3_28 = x1_28;
  int x4_28 = 0;
  int64_t x_36 = mhs_mem[x3_28];
  int64_t r_59;
  switch ((x_36 == 4)) {
  case 0: {
  int64_t x_54 = mhs_mem[(x3_28 + 1)];
  int64_t x_55 = mhs_mem[(x3_28 + 2)];
  int64_t x_56 = mhs_mem[0];
  mhs_mem[0] = (x_56 + 3);
  int m_46 = 0;
  mhs_mem[x_56] = 5;
  int m_47 = 0;
  mhs_mem[(x_56 + 1)] = x_54;
  int m_48 = 0;
  mhs_mem[(x_56 + 2)] = x_55;
  int m_49 = 0;
  r_59 = j_3(x_34, x_56, m_49); break; }
  case 1: {
  int64_t x_57 = mhs_mem[(x3_28 + 1)];
  int64_t x_58 = mhs_mem[(x3_28 + 2)];
  int64_t x_59 = mhs_mem[0];
  mhs_mem[0] = (x_59 + 3);
  int m_50 = 0;
  mhs_mem[x_59] = 3;
  int m_51 = 0;
  mhs_mem[(x_59 + 1)] = x_57;
  int m_52 = 0;
  mhs_mem[(x_59 + 2)] = x_58;
  int m_53 = 0;
  r_59 = j_3(x_34, x_59, m_53); break; }
  default: abort();
  }
  r_49 = r_59;
  return r_49;
}
static int64_t t4(int m_54, int64_t p_6) {
  int64_t x_60 = mhs_mem[(p_6 + 1)];
  int64_t x_61 = (x_60 - 1);
  int64_t x_62 = mhs_mem[0];
  mhs_mem[0] = (x_62 + 2);
  int m_55 = 0;
  mhs_mem[x_62] = 2;
  int m_56 = 0;
  mhs_mem[(x_62 + 1)] = x_61;
  int m_57 = 0;
  return x_62;
}

int64_t fibs(int m, int64_t n) {
  mhs_mem[0] = 1;
  int m_58 = 0;
  int b_2 = (n == 0);
  int64_t r_60;
  switch (b_2) {
  case 0: {
  int64_t x_63 = (n - 1);
  int b_3 = (x_63 == 0);
  int64_t r_61;
  switch (b_3) {
  case 0: {
  int64_t x_64 = (x_63 - 1);
  int b_4 = (x_64 == 0);
  int64_t r_62;
  switch (b_4) {
  case 0: {
  int64_t x_65 = mhs_mem[0];
  mhs_mem[0] = (x_65 + 3);
  int m_62 = 0;
  mhs_mem[x_65] = 10;
  int m_63 = 0;
  int64_t x_66 = mhs_mem[0];
  mhs_mem[0] = (x_66 + 3);
  int m_64 = 0;
  mhs_mem[x_66] = 6;
  int m_65 = 0;
  int64_t x_67 = mhs_mem[0];
  mhs_mem[0] = (x_67 + 3);
  int m_66 = 0;
  mhs_mem[x_67] = 4;
  int m_67 = 0;
  int64_t x_68 = mhs_mem[0];
  mhs_mem[0] = (x_68 + 3);
  int m_68 = 0;
  mhs_mem[x_68] = 7;
  int m_69 = 0;
  mhs_mem[(x_68 + 1)] = 0;
  int m_70 = 0;
  mhs_mem[(x_68 + 2)] = 1;
  int m_71 = 0;
  int64_t x_69 = mhs_mem[0];
  mhs_mem[0] = (x_69 + 3);
  int m_72 = 0;
  mhs_mem[x_69] = 10;
  int m_73 = 0;
  mhs_mem[(x_69 + 1)] = x_66;
  int m_74 = 0;
  mhs_mem[(x_69 + 2)] = x_67;
  int m_75 = 0;
  mhs_mem[(x_67 + 1)] = x_68;
  int m_76 = 0;
  mhs_mem[(x_67 + 2)] = x_69;
  int m_77 = 0;
  mhs_mem[(x_66 + 1)] = 1;
  int m_78 = 0;
  mhs_mem[(x_66 + 2)] = x_67;
  int m_79 = 0;
  mhs_mem[(x_65 + 1)] = x_66;
  int m_80 = 0;
  mhs_mem[(x_65 + 2)] = x_67;
  int m_81 = 0;
  int64_t x_70 = mhs_mem[0];
  mhs_mem[0] = (x_70 + 2);
  int m_82 = 0;
  mhs_mem[x_70] = 11;
  int m_83 = 0;
  mhs_mem[(x_70 + 1)] = x_64;
  int m_84 = 0;
  int64_t x1_33 = f0(m_84, x_65, x_70);
  r_62 = x1_33; break; }
  case 1: {
  r_62 = 1; break; }
  default: abort();
  }
  r_61 = r_62; break; }
  case 1: {
  r_61 = 1; break; }
  default: abort();
  }
  r_60 = r_61; break; }
  case 1: {
  r_60 = 0; break; }
  default: abort();
  }
  int64_t x1_34 = r_60;
  int64_t r_63;
  int64_t x3_34 = x1_34;
  int x4_34 = 0;
  r_63 = x3_34;
  return r_63;
}
int main(int argc, char **argv) {
  for (int i = 1; i < argc; i++) printf("%lld\n", (long long)fibs(0, atoll(argv[i])));
  return 0;
}
