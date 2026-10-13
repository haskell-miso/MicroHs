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
static int64_t t0(int m_27, int64_t p_2);
static int64_t t1(int m_35, int64_t p_3);
static int64_t t2(int m_46, int64_t p_4);
static int64_t t3(int m_60, int64_t p_5);
static int64_t t4(int m_133, int64_t p_6);
static int64_t gc(int m_141);
static int64_t j(int64_t x, int64_t v, int m_10) {
  mhs_mem[4] = x;
  int m_11 = 0;
  return v;
}
static int64_t f0(int m_1, int64_t p, int64_t p_1) {
  int64_t x = mhs_mem[4];
  mhs_mem[x] = p;
  int m_2 = 0;
  mhs_mem[(x + 1)] = p_1;
  int m_3 = 0;
  int r_0;
  switch (((x + 2) > 2064)) {
  case 0: {
  mhs_mem[4] = (x + 2);
  r_0 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_0 = 0; break; }
  default: abort();
  }
  int m_4 = r_0;
  int64_t x_1 = mhs_mem[x];
  int64_t x_2 = mhs_mem[x_1];
  int64_t r_1;
  switch ((x_2 < 0)) {
  case 0: {
  int64_t x1 = t3(m_4, x_1);
  int64_t r_2;
  int64_t x3 = x1;
  int x4 = 0;
  int64_t q = mhs_mem[x];
  mhs_mem[q] = -10;
  mhs_mem[(q + 1)] = x3;
  r_2 = x3;
  r_1 = r_2; break; }
  case 1: {
  r_1 = mhs_mem[(x_1 + 1)]; break; }
  default: abort();
  }
  int64_t x1_1 = r_1;
  int64_t r_3;
  int64_t x3_1 = x1_1;
  int x4_1 = 0;
  mhs_mem[(x + 2)] = x3_1;
  int m_5 = 0;
  int64_t x_3 = mhs_mem[(x + 2)];
  int64_t x_4 = mhs_mem[(x_3 + 1)];
  int64_t x_5 = mhs_mem[(x_3 + 2)];
  mhs_mem[(x + 3)] = x_4;
  int m_6 = 0;
  mhs_mem[(x + 4)] = x_5;
  int m_7 = 0;
  int r_4;
  switch (((x + 5) > 2064)) {
  case 0: {
  mhs_mem[4] = (x + 5);
  r_4 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_4 = 0; break; }
  default: abort();
  }
  int m_8 = r_4;
  int64_t x_6 = mhs_mem[(x + 1)];
  int64_t x_7 = mhs_mem[x_6];
  int64_t r_5;
  switch ((x_7 < 0)) {
  case 0: {
  int64_t x1_2 = t4(m_8, x_6);
  int64_t r_6;
  int64_t x3_2 = x1_2;
  int x4_2 = 0;
  int64_t q_1 = mhs_mem[(x + 1)];
  mhs_mem[q_1] = -11;
  mhs_mem[(q_1 + 1)] = x3_2;
  r_6 = x3_2;
  r_5 = r_6; break; }
  case 1: {
  r_5 = mhs_mem[(x_6 + 1)]; break; }
  default: abort();
  }
  int64_t x1_3 = r_5;
  int64_t r_7;
  int64_t x3_3 = x1_3;
  int x4_3 = 0;
  mhs_mem[(x + 5)] = x3_3;
  int m_9 = 0;
  int64_t x_8 = mhs_mem[(x + 5)];
  int64_t x_9 = mhs_mem[(x_8 + 1)];
  int b = (x_9 == 0);
  int64_t r_8;
  switch (b) {
  case 0: {
  int r_9;
  switch (((x + 6) > 2064)) {
  case 0: {
  mhs_mem[4] = (x + 6);
  r_9 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_9 = 0; break; }
  default: abort();
  }
  int m_12 = r_9;
  int64_t x_10 = mhs_mem[(x + 4)];
  int64_t x_11 = mhs_mem[x_10];
  int64_t r_10;
  switch ((x_11 < 0)) {
  case 0: {
  int64_t x1_4 = t3(m_12, x_10);
  int64_t r_11;
  int64_t x3_4 = x1_4;
  int x4_4 = 0;
  int64_t q_2 = mhs_mem[(x + 4)];
  mhs_mem[q_2] = -10;
  mhs_mem[(q_2 + 1)] = x3_4;
  r_11 = x3_4;
  r_10 = r_11; break; }
  case 1: {
  r_10 = mhs_mem[(x_10 + 1)]; break; }
  default: abort();
  }
  int64_t x1_5 = r_10;
  int64_t r_12;
  int64_t x3_5 = x1_5;
  int x4_5 = 0;
  mhs_mem[(x + 6)] = x3_5;
  int m_13 = 0;
  int64_t x_12 = mhs_mem[(x + 6)];
  int64_t x_13 = mhs_mem[(x_12 + 1)];
  int64_t x_14 = mhs_mem[(x_12 + 2)];
  mhs_mem[(x + 7)] = x_13;
  int m_14 = 0;
  mhs_mem[(x + 8)] = x_14;
  int m_15 = 0;
  int64_t x_15 = mhs_mem[(x + 5)];
  int64_t x_16 = mhs_mem[(x_15 + 1)];
  int64_t x_17 = (x_16 - 1);
  int b_1 = (x_17 == 0);
  int64_t r_13;
  switch (b_1) {
  case 0: {
  int r_14;
  switch (((x + 9) > 2064)) {
  case 0: {
  mhs_mem[4] = (x + 9);
  r_14 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_14 = 0; break; }
  default: abort();
  }
  int m_17 = r_14;
  int64_t x_18 = mhs_mem[0];
  int64_t x_19 = mhs_mem[1];
  int64_t r_15;
  switch (((x_18 + 2) > x_19)) {
  case 0: {
  r_15 = x_18; break; }
  case 1: {
  int64_t x1_6 = gc(m_17);
  int64_t r_16;
  int64_t x3_6 = x1_6;
  int x4_6 = 0;
  int64_t r_17;
  switch (((x3_6 + 2) > mhs_mem[1])) {
  case 0: {
  r_17 = x3_6; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_17 = 0; break; }
  default: abort();
  }
  r_16 = r_17;
  r_15 = r_16; break; }
  default: abort();
  }
  int64_t x1_7 = r_15;
  int64_t r_18;
  int64_t x3_7 = x1_7;
  int x4_7 = 0;
  mhs_mem[0] = (x3_7 + 2);
  int m_18 = 0;
  mhs_mem[(x + 9)] = x3_7;
  int m_19 = 0;
  mhs_mem[x3_7] = 11;
  int m_20 = 0;
  int64_t x_20 = mhs_mem[(x + 9)];
  mhs_mem[(x_20 + 1)] = x_17;
  int m_21 = 0;
  int64_t x_21 = mhs_mem[(x + 8)];
  int64_t x_22 = mhs_mem[(x + 9)];
  mhs_mem[4] = x;
  int m_22 = 0;
  int64_t x1_8 = f0(m_22, x_21, x_22);
  int64_t r_19;
  int64_t x3_8 = x1_8;
  int x4_8 = 0;
  r_19 = j(x, x3_8, x4_8);
  r_18 = r_19;
  r_13 = r_18; break; }
  case 1: {
  int r_20;
  switch (((x + 9) > 2064)) {
  case 0: {
  mhs_mem[4] = (x + 9);
  r_20 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_20 = 0; break; }
  default: abort();
  }
  int m_23 = r_20;
  int64_t x_23 = mhs_mem[(x + 7)];
  int64_t x_24 = mhs_mem[x_23];
  int64_t r_21;
  switch ((x_24 < 0)) {
  case 0: {
  int64_t r_22;
  switch ((x_24 == 7)) {
  case 0: {
  int64_t r_23;
  switch ((x_24 == 8)) {
  case 0: {
  int64_t x1_9 = t2(m_23, x_23);
  int64_t r_24;
  int64_t x3_9 = x1_9;
  int x4_9 = 0;
  int64_t q_3 = mhs_mem[(x + 7)];
  mhs_mem[q_3] = -9;
  mhs_mem[(q_3 + 1)] = x3_9;
  r_24 = x3_9;
  r_23 = r_24; break; }
  case 1: {
  int64_t x1_10 = t1(m_23, x_23);
  int64_t r_25;
  int64_t x3_10 = x1_10;
  int x4_10 = 0;
  int64_t q_4 = mhs_mem[(x + 7)];
  mhs_mem[q_4] = -8;
  mhs_mem[(q_4 + 1)] = x3_10;
  r_25 = x3_10;
  r_23 = r_25; break; }
  default: abort();
  }
  r_22 = r_23; break; }
  case 1: {
  int64_t x1_11 = t0(m_23, x_23);
  int64_t r_26;
  int64_t x3_11 = x1_11;
  int x4_11 = 0;
  int64_t q_5 = mhs_mem[(x + 7)];
  mhs_mem[q_5] = -7;
  mhs_mem[(q_5 + 1)] = x3_11;
  r_26 = x3_11;
  r_22 = r_26; break; }
  default: abort();
  }
  r_21 = r_22; break; }
  case 1: {
  r_21 = mhs_mem[(x_23 + 1)]; break; }
  default: abort();
  }
  int64_t x1_12 = r_21;
  int64_t r_27;
  int64_t x3_12 = x1_12;
  int x4_12 = 0;
  mhs_mem[(x + 9)] = x3_12;
  int m_24 = 0;
  int64_t x_25 = mhs_mem[(x + 9)];
  int64_t x_26 = mhs_mem[(x_25 + 1)];
  r_27 = j(x, x_26, m_24);
  r_13 = r_27; break; }
  default: abort();
  }
  r_12 = r_13;
  r_8 = r_12; break; }
  case 1: {
  int r_28;
  switch (((x + 6) > 2064)) {
  case 0: {
  mhs_mem[4] = (x + 6);
  r_28 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_28 = 0; break; }
  default: abort();
  }
  int m_25 = r_28;
  int64_t x_27 = mhs_mem[(x + 3)];
  int64_t x_28 = mhs_mem[x_27];
  int64_t r_29;
  switch ((x_28 < 0)) {
  case 0: {
  int64_t r_30;
  switch ((x_28 == 7)) {
  case 0: {
  int64_t r_31;
  switch ((x_28 == 8)) {
  case 0: {
  int64_t x1_13 = t2(m_25, x_27);
  int64_t r_32;
  int64_t x3_13 = x1_13;
  int x4_13 = 0;
  int64_t q_6 = mhs_mem[(x + 3)];
  mhs_mem[q_6] = -9;
  mhs_mem[(q_6 + 1)] = x3_13;
  r_32 = x3_13;
  r_31 = r_32; break; }
  case 1: {
  int64_t x1_14 = t1(m_25, x_27);
  int64_t r_33;
  int64_t x3_14 = x1_14;
  int x4_14 = 0;
  int64_t q_7 = mhs_mem[(x + 3)];
  mhs_mem[q_7] = -8;
  mhs_mem[(q_7 + 1)] = x3_14;
  r_33 = x3_14;
  r_31 = r_33; break; }
  default: abort();
  }
  r_30 = r_31; break; }
  case 1: {
  int64_t x1_15 = t0(m_25, x_27);
  int64_t r_34;
  int64_t x3_15 = x1_15;
  int x4_15 = 0;
  int64_t q_8 = mhs_mem[(x + 3)];
  mhs_mem[q_8] = -7;
  mhs_mem[(q_8 + 1)] = x3_15;
  r_34 = x3_15;
  r_30 = r_34; break; }
  default: abort();
  }
  r_29 = r_30; break; }
  case 1: {
  r_29 = mhs_mem[(x_27 + 1)]; break; }
  default: abort();
  }
  int64_t x1_16 = r_29;
  int64_t r_35;
  int64_t x3_16 = x1_16;
  int x4_16 = 0;
  mhs_mem[(x + 6)] = x3_16;
  int m_26 = 0;
  int64_t x_29 = mhs_mem[(x + 6)];
  int64_t x_30 = mhs_mem[(x_29 + 1)];
  r_35 = j(x, x_30, m_26);
  r_8 = r_35; break; }
  default: abort();
  }
  r_7 = r_8;
  r_3 = r_7;
  return r_3;
}
static int64_t t0(int m_27, int64_t p_2) {
  int64_t x_31 = mhs_mem[4];
  mhs_mem[x_31] = p_2;
  int m_28 = 0;
  int64_t x_32 = mhs_mem[x_31];
  int64_t x_33 = mhs_mem[(x_32 + 1)];
  int64_t x_34 = mhs_mem[(x_32 + 2)];
  int64_t x_35 = (x_33 + x_34);
  int r_36;
  switch (((x_31 + 1) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_31 + 1);
  r_36 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_36 = 0; break; }
  default: abort();
  }
  int m_29 = r_36;
  int64_t x_36 = mhs_mem[0];
  int64_t x_37 = mhs_mem[1];
  int64_t r_37;
  switch (((x_36 + 2) > x_37)) {
  case 0: {
  r_37 = x_36; break; }
  case 1: {
  int64_t x1_17 = gc(m_29);
  int64_t r_38;
  int64_t x3_17 = x1_17;
  int x4_17 = 0;
  int64_t r_39;
  switch (((x3_17 + 2) > mhs_mem[1])) {
  case 0: {
  r_39 = x3_17; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_39 = 0; break; }
  default: abort();
  }
  r_38 = r_39;
  r_37 = r_38; break; }
  default: abort();
  }
  int64_t x1_18 = r_37;
  int64_t r_40;
  int64_t x3_18 = x1_18;
  int x4_18 = 0;
  mhs_mem[0] = (x3_18 + 2);
  int m_30 = 0;
  mhs_mem[(x_31 + 1)] = x3_18;
  int m_31 = 0;
  mhs_mem[x3_18] = 2;
  int m_32 = 0;
  mhs_mem[(x3_18 + 1)] = x_35;
  int m_33 = 0;
  int64_t x_38 = mhs_mem[(x_31 + 1)];
  mhs_mem[4] = x_31;
  int m_34 = 0;
  r_40 = x_38;
  return r_40;
}
static int64_t t1(int m_35, int64_t p_3) {
  int64_t x_39 = mhs_mem[4];
  mhs_mem[x_39] = p_3;
  int m_36 = 0;
  int64_t x_40 = mhs_mem[x_39];
  int64_t x_41 = mhs_mem[(x_40 + 1)];
  int64_t x_42 = mhs_mem[(x_40 + 2)];
  mhs_mem[(x_39 + 1)] = x_42;
  int m_37 = 0;
  int r_41;
  switch (((x_39 + 2) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_39 + 2);
  r_41 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_41 = 0; break; }
  default: abort();
  }
  int m_38 = r_41;
  int64_t x_43 = mhs_mem[(x_39 + 1)];
  int64_t x_44 = mhs_mem[x_43];
  int64_t r_42;
  switch ((x_44 < 0)) {
  case 0: {
  int64_t r_43;
  switch ((x_44 == 7)) {
  case 0: {
  int64_t r_44;
  switch ((x_44 == 8)) {
  case 0: {
  int64_t x1_19 = t2(m_38, x_43);
  int64_t r_45;
  int64_t x3_19 = x1_19;
  int x4_19 = 0;
  int64_t q_9 = mhs_mem[(x_39 + 1)];
  mhs_mem[q_9] = -9;
  mhs_mem[(q_9 + 1)] = x3_19;
  r_45 = x3_19;
  r_44 = r_45; break; }
  case 1: {
  int64_t x1_20 = t1(m_38, x_43);
  int64_t r_46;
  int64_t x3_20 = x1_20;
  int x4_20 = 0;
  int64_t q_10 = mhs_mem[(x_39 + 1)];
  mhs_mem[q_10] = -8;
  mhs_mem[(q_10 + 1)] = x3_20;
  r_46 = x3_20;
  r_44 = r_46; break; }
  default: abort();
  }
  r_43 = r_44; break; }
  case 1: {
  int64_t x1_21 = t0(m_38, x_43);
  int64_t r_47;
  int64_t x3_21 = x1_21;
  int x4_21 = 0;
  int64_t q_11 = mhs_mem[(x_39 + 1)];
  mhs_mem[q_11] = -7;
  mhs_mem[(q_11 + 1)] = x3_21;
  r_47 = x3_21;
  r_43 = r_47; break; }
  default: abort();
  }
  r_42 = r_43; break; }
  case 1: {
  r_42 = mhs_mem[(x_43 + 1)]; break; }
  default: abort();
  }
  int64_t x1_22 = r_42;
  int64_t r_48;
  int64_t x3_22 = x1_22;
  int x4_22 = 0;
  mhs_mem[(x_39 + 2)] = x3_22;
  int m_39 = 0;
  int64_t x_45 = mhs_mem[(x_39 + 2)];
  int64_t x_46 = mhs_mem[(x_45 + 1)];
  int64_t x_47 = (x_41 + x_46);
  int r_49;
  switch (((x_39 + 3) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_39 + 3);
  r_49 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_49 = 0; break; }
  default: abort();
  }
  int m_40 = r_49;
  int64_t x_48 = mhs_mem[0];
  int64_t x_49 = mhs_mem[1];
  int64_t r_50;
  switch (((x_48 + 2) > x_49)) {
  case 0: {
  r_50 = x_48; break; }
  case 1: {
  int64_t x1_23 = gc(m_40);
  int64_t r_51;
  int64_t x3_23 = x1_23;
  int x4_23 = 0;
  int64_t r_52;
  switch (((x3_23 + 2) > mhs_mem[1])) {
  case 0: {
  r_52 = x3_23; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_52 = 0; break; }
  default: abort();
  }
  r_51 = r_52;
  r_50 = r_51; break; }
  default: abort();
  }
  int64_t x1_24 = r_50;
  int64_t r_53;
  int64_t x3_24 = x1_24;
  int x4_24 = 0;
  mhs_mem[0] = (x3_24 + 2);
  int m_41 = 0;
  mhs_mem[(x_39 + 3)] = x3_24;
  int m_42 = 0;
  mhs_mem[x3_24] = 2;
  int m_43 = 0;
  mhs_mem[(x3_24 + 1)] = x_47;
  int m_44 = 0;
  int64_t x_50 = mhs_mem[(x_39 + 3)];
  mhs_mem[4] = x_39;
  int m_45 = 0;
  r_53 = x_50;
  r_48 = r_53;
  return r_48;
}
static int64_t t2(int m_46, int64_t p_4) {
  int64_t x_51 = mhs_mem[4];
  mhs_mem[x_51] = p_4;
  int m_47 = 0;
  int64_t x_52 = mhs_mem[x_51];
  int64_t x_53 = mhs_mem[(x_52 + 1)];
  int64_t x_54 = mhs_mem[(x_52 + 2)];
  mhs_mem[(x_51 + 1)] = x_53;
  int m_48 = 0;
  mhs_mem[(x_51 + 2)] = x_54;
  int m_49 = 0;
  int r_54;
  switch (((x_51 + 3) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_51 + 3);
  r_54 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_54 = 0; break; }
  default: abort();
  }
  int m_50 = r_54;
  int64_t x_55 = mhs_mem[(x_51 + 2)];
  int64_t x_56 = mhs_mem[x_55];
  int64_t r_55;
  switch ((x_56 < 0)) {
  case 0: {
  int64_t r_56;
  switch ((x_56 == 7)) {
  case 0: {
  int64_t r_57;
  switch ((x_56 == 8)) {
  case 0: {
  int64_t x1_25 = t2(m_50, x_55);
  int64_t r_58;
  int64_t x3_25 = x1_25;
  int x4_25 = 0;
  int64_t q_12 = mhs_mem[(x_51 + 2)];
  mhs_mem[q_12] = -9;
  mhs_mem[(q_12 + 1)] = x3_25;
  r_58 = x3_25;
  r_57 = r_58; break; }
  case 1: {
  int64_t x1_26 = t1(m_50, x_55);
  int64_t r_59;
  int64_t x3_26 = x1_26;
  int x4_26 = 0;
  int64_t q_13 = mhs_mem[(x_51 + 2)];
  mhs_mem[q_13] = -8;
  mhs_mem[(q_13 + 1)] = x3_26;
  r_59 = x3_26;
  r_57 = r_59; break; }
  default: abort();
  }
  r_56 = r_57; break; }
  case 1: {
  int64_t x1_27 = t0(m_50, x_55);
  int64_t r_60;
  int64_t x3_27 = x1_27;
  int x4_27 = 0;
  int64_t q_14 = mhs_mem[(x_51 + 2)];
  mhs_mem[q_14] = -7;
  mhs_mem[(q_14 + 1)] = x3_27;
  r_60 = x3_27;
  r_56 = r_60; break; }
  default: abort();
  }
  r_55 = r_56; break; }
  case 1: {
  r_55 = mhs_mem[(x_55 + 1)]; break; }
  default: abort();
  }
  int64_t x1_28 = r_55;
  int64_t r_61;
  int64_t x3_28 = x1_28;
  int x4_28 = 0;
  mhs_mem[(x_51 + 3)] = x3_28;
  int m_51 = 0;
  int r_62;
  switch (((x_51 + 4) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_51 + 4);
  r_62 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_62 = 0; break; }
  default: abort();
  }
  int m_52 = r_62;
  int64_t x_57 = mhs_mem[(x_51 + 1)];
  int64_t x_58 = mhs_mem[x_57];
  int64_t r_63;
  switch ((x_58 < 0)) {
  case 0: {
  int64_t r_64;
  switch ((x_58 == 7)) {
  case 0: {
  int64_t r_65;
  switch ((x_58 == 8)) {
  case 0: {
  int64_t x1_29 = t2(m_52, x_57);
  int64_t r_66;
  int64_t x3_29 = x1_29;
  int x4_29 = 0;
  int64_t q_15 = mhs_mem[(x_51 + 1)];
  mhs_mem[q_15] = -9;
  mhs_mem[(q_15 + 1)] = x3_29;
  r_66 = x3_29;
  r_65 = r_66; break; }
  case 1: {
  int64_t x1_30 = t1(m_52, x_57);
  int64_t r_67;
  int64_t x3_30 = x1_30;
  int x4_30 = 0;
  int64_t q_16 = mhs_mem[(x_51 + 1)];
  mhs_mem[q_16] = -8;
  mhs_mem[(q_16 + 1)] = x3_30;
  r_67 = x3_30;
  r_65 = r_67; break; }
  default: abort();
  }
  r_64 = r_65; break; }
  case 1: {
  int64_t x1_31 = t0(m_52, x_57);
  int64_t r_68;
  int64_t x3_31 = x1_31;
  int x4_31 = 0;
  int64_t q_17 = mhs_mem[(x_51 + 1)];
  mhs_mem[q_17] = -7;
  mhs_mem[(q_17 + 1)] = x3_31;
  r_68 = x3_31;
  r_64 = r_68; break; }
  default: abort();
  }
  r_63 = r_64; break; }
  case 1: {
  r_63 = mhs_mem[(x_57 + 1)]; break; }
  default: abort();
  }
  int64_t x1_32 = r_63;
  int64_t r_69;
  int64_t x3_32 = x1_32;
  int x4_32 = 0;
  mhs_mem[(x_51 + 4)] = x3_32;
  int m_53 = 0;
  int64_t x_59 = mhs_mem[(x_51 + 4)];
  int64_t x_60 = mhs_mem[(x_59 + 1)];
  int64_t x_61 = mhs_mem[(x_51 + 3)];
  int64_t x_62 = mhs_mem[(x_61 + 1)];
  int64_t x_63 = (x_60 + x_62);
  int r_70;
  switch (((x_51 + 5) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_51 + 5);
  r_70 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_70 = 0; break; }
  default: abort();
  }
  int m_54 = r_70;
  int64_t x_64 = mhs_mem[0];
  int64_t x_65 = mhs_mem[1];
  int64_t r_71;
  switch (((x_64 + 2) > x_65)) {
  case 0: {
  r_71 = x_64; break; }
  case 1: {
  int64_t x1_33 = gc(m_54);
  int64_t r_72;
  int64_t x3_33 = x1_33;
  int x4_33 = 0;
  int64_t r_73;
  switch (((x3_33 + 2) > mhs_mem[1])) {
  case 0: {
  r_73 = x3_33; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_73 = 0; break; }
  default: abort();
  }
  r_72 = r_73;
  r_71 = r_72; break; }
  default: abort();
  }
  int64_t x1_34 = r_71;
  int64_t r_74;
  int64_t x3_34 = x1_34;
  int x4_34 = 0;
  mhs_mem[0] = (x3_34 + 2);
  int m_55 = 0;
  mhs_mem[(x_51 + 5)] = x3_34;
  int m_56 = 0;
  mhs_mem[x3_34] = 2;
  int m_57 = 0;
  mhs_mem[(x3_34 + 1)] = x_63;
  int m_58 = 0;
  int64_t x_66 = mhs_mem[(x_51 + 5)];
  mhs_mem[4] = x_51;
  int m_59 = 0;
  r_74 = x_66;
  r_69 = r_74;
  r_61 = r_69;
  return r_61;
}
static int64_t j_2(int64_t x_67, int64_t v_3, int m_68) {
  mhs_mem[(x_67 + 5)] = v_3;
  int m_69 = 0;
  int64_t x_77 = mhs_mem[(x_67 + 5)];
  mhs_mem[4] = x_67;
  int m_70 = 0;
  return x_77;
}
static int64_t j_3(int64_t x_67, int64_t v_2, int m_66) {
  mhs_mem[(x_67 + 4)] = v_2;
  int m_67 = 0;
  int64_t x_75 = mhs_mem[(x_67 + 4)];
  int64_t x_76 = mhs_mem[x_75];
  int64_t r_80;
  switch ((x_76 == 3)) {
  case 0: {
  int64_t x_78 = mhs_mem[(x_67 + 4)];
  int64_t x_79 = mhs_mem[(x_78 + 1)];
  int64_t x_80 = mhs_mem[(x_78 + 2)];
  mhs_mem[(x_67 + 5)] = x_80;
  int m_71 = 0;
  int r_81;
  switch (((x_67 + 6) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_67 + 6);
  r_81 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_81 = 0; break; }
  default: abort();
  }
  int m_72 = r_81;
  int64_t x_81 = mhs_mem[(x_67 + 2)];
  int64_t x_82 = mhs_mem[x_81];
  int64_t r_82;
  switch ((x_82 < 0)) {
  case 0: {
  int64_t r_83;
  switch ((x_82 == 10)) {
  case 0: {
  r_83 = x_81; break; }
  case 1: {
  int64_t x1_37 = t3(m_72, x_81);
  int64_t r_84;
  int64_t x3_37 = x1_37;
  int x4_37 = 0;
  int64_t q_19 = mhs_mem[(x_67 + 2)];
  mhs_mem[q_19] = -10;
  mhs_mem[(q_19 + 1)] = x3_37;
  r_84 = x3_37;
  r_83 = r_84; break; }
  default: abort();
  }
  r_82 = r_83; break; }
  case 1: {
  r_82 = mhs_mem[(x_81 + 1)]; break; }
  default: abort();
  }
  int64_t x1_38 = r_82;
  int64_t r_85;
  int64_t x3_38 = x1_38;
  int x4_38 = 0;
  mhs_mem[(x_67 + 6)] = x3_38;
  int m_73 = 0;
  int64_t x_83 = mhs_mem[(x_67 + 6)];
  int64_t x_84 = mhs_mem[(x_83 + 1)];
  int64_t x_85 = mhs_mem[(x_83 + 2)];
  mhs_mem[(x_67 + 7)] = x_84;
  int m_74 = 0;
  mhs_mem[(x_67 + 8)] = x_85;
  int m_75 = 0;
  int r_86;
  switch (((x_67 + 9) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_67 + 9);
  r_86 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_86 = 0; break; }
  default: abort();
  }
  int m_76 = r_86;
  int64_t x_86 = mhs_mem[0];
  int64_t x_87 = mhs_mem[1];
  int64_t r_87;
  switch (((x_86 + 3) > x_87)) {
  case 0: {
  r_87 = x_86; break; }
  case 1: {
  int64_t x1_39 = gc(m_76);
  int64_t r_88;
  int64_t x3_39 = x1_39;
  int x4_39 = 0;
  int64_t r_89;
  switch (((x3_39 + 3) > mhs_mem[1])) {
  case 0: {
  r_89 = x3_39; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_89 = 0; break; }
  default: abort();
  }
  r_88 = r_89;
  r_87 = r_88; break; }
  default: abort();
  }
  int64_t x1_40 = r_87;
  int64_t r_90;
  int64_t x3_40 = x1_40;
  int x4_40 = 0;
  mhs_mem[0] = (x3_40 + 3);
  int m_77 = 0;
  mhs_mem[(x_67 + 9)] = x3_40;
  int m_78 = 0;
  mhs_mem[x3_40] = 8;
  int m_79 = 0;
  int64_t x_88 = mhs_mem[(x_67 + 7)];
  int64_t x_89 = mhs_mem[(x_67 + 9)];
  mhs_mem[(x_89 + 1)] = x_79;
  int m_80 = 0;
  mhs_mem[(x_89 + 2)] = x_88;
  int m_81 = 0;
  int r_91;
  switch (((x_67 + 10) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_67 + 10);
  r_91 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_91 = 0; break; }
  default: abort();
  }
  int m_82 = r_91;
  int64_t x_90 = mhs_mem[0];
  int64_t x_91 = mhs_mem[1];
  int64_t r_92;
  switch (((x_90 + 3) > x_91)) {
  case 0: {
  r_92 = x_90; break; }
  case 1: {
  int64_t x1_41 = gc(m_82);
  int64_t r_93;
  int64_t x3_41 = x1_41;
  int x4_41 = 0;
  int64_t r_94;
  switch (((x3_41 + 3) > mhs_mem[1])) {
  case 0: {
  r_94 = x3_41; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_94 = 0; break; }
  default: abort();
  }
  r_93 = r_94;
  r_92 = r_93; break; }
  default: abort();
  }
  int64_t x1_42 = r_92;
  int64_t r_95;
  int64_t x3_42 = x1_42;
  int x4_42 = 0;
  mhs_mem[0] = (x3_42 + 3);
  int m_83 = 0;
  mhs_mem[(x_67 + 10)] = x3_42;
  int m_84 = 0;
  mhs_mem[x3_42] = 10;
  int m_85 = 0;
  int64_t x_92 = mhs_mem[(x_67 + 5)];
  int64_t x_93 = mhs_mem[(x_67 + 8)];
  int64_t x_94 = mhs_mem[(x_67 + 10)];
  mhs_mem[(x_94 + 1)] = x_92;
  int m_86 = 0;
  mhs_mem[(x_94 + 2)] = x_93;
  int m_87 = 0;
  int r_96;
  switch (((x_67 + 11) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_67 + 11);
  r_96 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_96 = 0; break; }
  default: abort();
  }
  int m_88 = r_96;
  int64_t x_95 = mhs_mem[0];
  int64_t x_96 = mhs_mem[1];
  int64_t r_97;
  switch (((x_95 + 3) > x_96)) {
  case 0: {
  r_97 = x_95; break; }
  case 1: {
  int64_t x1_43 = gc(m_88);
  int64_t r_98;
  int64_t x3_43 = x1_43;
  int x4_43 = 0;
  int64_t r_99;
  switch (((x3_43 + 3) > mhs_mem[1])) {
  case 0: {
  r_99 = x3_43; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_99 = 0; break; }
  default: abort();
  }
  r_98 = r_99;
  r_97 = r_98; break; }
  default: abort();
  }
  int64_t x1_44 = r_97;
  int64_t r_100;
  int64_t x3_44 = x1_44;
  int x4_44 = 0;
  mhs_mem[0] = (x3_44 + 3);
  int m_89 = 0;
  mhs_mem[(x_67 + 11)] = x3_44;
  int m_90 = 0;
  mhs_mem[x3_44] = 4;
  int m_91 = 0;
  int64_t x_97 = mhs_mem[(x_67 + 9)];
  int64_t x_98 = mhs_mem[(x_67 + 10)];
  mhs_mem[(x3_44 + 1)] = x_97;
  int m_92 = 0;
  mhs_mem[(x3_44 + 2)] = x_98;
  int m_93 = 0;
  int64_t x_99 = mhs_mem[(x_67 + 11)];
  r_100 = j_2(x_67, x_99, m_93);
  r_95 = r_100;
  r_90 = r_95;
  r_85 = r_90;
  r_80 = r_85; break; }
  case 1: {
  int64_t x_100 = mhs_mem[(x_67 + 4)];
  int64_t x_101 = mhs_mem[(x_100 + 1)];
  int64_t x_102 = mhs_mem[(x_100 + 2)];
  mhs_mem[(x_67 + 5)] = x_101;
  int m_94 = 0;
  mhs_mem[(x_67 + 6)] = x_102;
  int m_95 = 0;
  int r_101;
  switch (((x_67 + 7) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_67 + 7);
  r_101 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_101 = 0; break; }
  default: abort();
  }
  int m_96 = r_101;
  int64_t x_103 = mhs_mem[(x_67 + 2)];
  int64_t x_104 = mhs_mem[x_103];
  int64_t r_102;
  switch ((x_104 < 0)) {
  case 0: {
  int64_t r_103;
  switch ((x_104 == 10)) {
  case 0: {
  r_103 = x_103; break; }
  case 1: {
  int64_t x1_45 = t3(m_96, x_103);
  int64_t r_104;
  int64_t x3_45 = x1_45;
  int x4_45 = 0;
  int64_t q_20 = mhs_mem[(x_67 + 2)];
  mhs_mem[q_20] = -10;
  mhs_mem[(q_20 + 1)] = x3_45;
  r_104 = x3_45;
  r_103 = r_104; break; }
  default: abort();
  }
  r_102 = r_103; break; }
  case 1: {
  r_102 = mhs_mem[(x_103 + 1)]; break; }
  default: abort();
  }
  int64_t x1_46 = r_102;
  int64_t r_105;
  int64_t x3_46 = x1_46;
  int x4_46 = 0;
  mhs_mem[(x_67 + 7)] = x3_46;
  int m_97 = 0;
  int64_t x_105 = mhs_mem[(x_67 + 7)];
  int64_t x_106 = mhs_mem[(x_105 + 1)];
  int64_t x_107 = mhs_mem[(x_105 + 2)];
  mhs_mem[(x_67 + 8)] = x_106;
  int m_98 = 0;
  mhs_mem[(x_67 + 9)] = x_107;
  int m_99 = 0;
  int r_106;
  switch (((x_67 + 10) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_67 + 10);
  r_106 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_106 = 0; break; }
  default: abort();
  }
  int m_100 = r_106;
  int64_t x_108 = mhs_mem[0];
  int64_t x_109 = mhs_mem[1];
  int64_t r_107;
  switch (((x_108 + 3) > x_109)) {
  case 0: {
  r_107 = x_108; break; }
  case 1: {
  int64_t x1_47 = gc(m_100);
  int64_t r_108;
  int64_t x3_47 = x1_47;
  int x4_47 = 0;
  int64_t r_109;
  switch (((x3_47 + 3) > mhs_mem[1])) {
  case 0: {
  r_109 = x3_47; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_109 = 0; break; }
  default: abort();
  }
  r_108 = r_109;
  r_107 = r_108; break; }
  default: abort();
  }
  int64_t x1_48 = r_107;
  int64_t r_110;
  int64_t x3_48 = x1_48;
  int x4_48 = 0;
  mhs_mem[0] = (x3_48 + 3);
  int m_101 = 0;
  mhs_mem[(x_67 + 10)] = x3_48;
  int m_102 = 0;
  mhs_mem[x3_48] = 9;
  int m_103 = 0;
  int64_t x_110 = mhs_mem[(x_67 + 5)];
  int64_t x_111 = mhs_mem[(x_67 + 8)];
  int64_t x_112 = mhs_mem[(x_67 + 10)];
  mhs_mem[(x_112 + 1)] = x_110;
  int m_104 = 0;
  mhs_mem[(x_112 + 2)] = x_111;
  int m_105 = 0;
  int r_111;
  switch (((x_67 + 11) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_67 + 11);
  r_111 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_111 = 0; break; }
  default: abort();
  }
  int m_106 = r_111;
  int64_t x_113 = mhs_mem[0];
  int64_t x_114 = mhs_mem[1];
  int64_t r_112;
  switch (((x_113 + 3) > x_114)) {
  case 0: {
  r_112 = x_113; break; }
  case 1: {
  int64_t x1_49 = gc(m_106);
  int64_t r_113;
  int64_t x3_49 = x1_49;
  int x4_49 = 0;
  int64_t r_114;
  switch (((x3_49 + 3) > mhs_mem[1])) {
  case 0: {
  r_114 = x3_49; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_114 = 0; break; }
  default: abort();
  }
  r_113 = r_114;
  r_112 = r_113; break; }
  default: abort();
  }
  int64_t x1_50 = r_112;
  int64_t r_115;
  int64_t x3_50 = x1_50;
  int x4_50 = 0;
  mhs_mem[0] = (x3_50 + 3);
  int m_107 = 0;
  mhs_mem[(x_67 + 11)] = x3_50;
  int m_108 = 0;
  mhs_mem[x3_50] = 10;
  int m_109 = 0;
  int64_t x_115 = mhs_mem[(x_67 + 6)];
  int64_t x_116 = mhs_mem[(x_67 + 9)];
  int64_t x_117 = mhs_mem[(x_67 + 11)];
  mhs_mem[(x_117 + 1)] = x_115;
  int m_110 = 0;
  mhs_mem[(x_117 + 2)] = x_116;
  int m_111 = 0;
  int r_116;
  switch (((x_67 + 12) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_67 + 12);
  r_116 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_116 = 0; break; }
  default: abort();
  }
  int m_112 = r_116;
  int64_t x_118 = mhs_mem[0];
  int64_t x_119 = mhs_mem[1];
  int64_t r_117;
  switch (((x_118 + 3) > x_119)) {
  case 0: {
  r_117 = x_118; break; }
  case 1: {
  int64_t x1_51 = gc(m_112);
  int64_t r_118;
  int64_t x3_51 = x1_51;
  int x4_51 = 0;
  int64_t r_119;
  switch (((x3_51 + 3) > mhs_mem[1])) {
  case 0: {
  r_119 = x3_51; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_119 = 0; break; }
  default: abort();
  }
  r_118 = r_119;
  r_117 = r_118; break; }
  default: abort();
  }
  int64_t x1_52 = r_117;
  int64_t r_120;
  int64_t x3_52 = x1_52;
  int x4_52 = 0;
  mhs_mem[0] = (x3_52 + 3);
  int m_113 = 0;
  mhs_mem[(x_67 + 12)] = x3_52;
  int m_114 = 0;
  mhs_mem[x3_52] = 4;
  int m_115 = 0;
  int64_t x_120 = mhs_mem[(x_67 + 10)];
  int64_t x_121 = mhs_mem[(x_67 + 11)];
  mhs_mem[(x3_52 + 1)] = x_120;
  int m_116 = 0;
  mhs_mem[(x3_52 + 2)] = x_121;
  int m_117 = 0;
  int64_t x_122 = mhs_mem[(x_67 + 12)];
  r_120 = j_2(x_67, x_122, m_117);
  r_115 = r_120;
  r_110 = r_115;
  r_105 = r_110;
  r_80 = r_105; break; }
  default: abort();
  }
  return r_80;
}
static int64_t t3(int m_60, int64_t p_5) {
  int64_t x_67 = mhs_mem[4];
  mhs_mem[x_67] = p_5;
  int m_61 = 0;
  int64_t x_68 = mhs_mem[x_67];
  int64_t x_69 = mhs_mem[(x_68 + 1)];
  int64_t x_70 = mhs_mem[(x_68 + 2)];
  mhs_mem[(x_67 + 1)] = x_69;
  int m_62 = 0;
  mhs_mem[(x_67 + 2)] = x_70;
  int m_63 = 0;
  int r_75;
  switch (((x_67 + 3) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_67 + 3);
  r_75 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_75 = 0; break; }
  default: abort();
  }
  int m_64 = r_75;
  int64_t x_71 = mhs_mem[(x_67 + 1)];
  int64_t x_72 = mhs_mem[x_71];
  int64_t r_76;
  switch ((x_72 < 0)) {
  case 0: {
  int64_t r_77;
  switch ((x_72 == 10)) {
  case 0: {
  r_77 = x_71; break; }
  case 1: {
  int64_t x1_35 = t3(m_64, x_71);
  int64_t r_78;
  int64_t x3_35 = x1_35;
  int x4_35 = 0;
  int64_t q_18 = mhs_mem[(x_67 + 1)];
  mhs_mem[q_18] = -10;
  mhs_mem[(q_18 + 1)] = x3_35;
  r_78 = x3_35;
  r_77 = r_78; break; }
  default: abort();
  }
  r_76 = r_77; break; }
  case 1: {
  r_76 = mhs_mem[(x_71 + 1)]; break; }
  default: abort();
  }
  int64_t x1_36 = r_76;
  int64_t r_79;
  int64_t x3_36 = x1_36;
  int x4_36 = 0;
  mhs_mem[(x_67 + 3)] = x3_36;
  int m_65 = 0;
  int64_t x_73 = mhs_mem[(x_67 + 3)];
  int64_t x_74 = mhs_mem[x_73];
  int64_t r_121;
  switch ((x_74 == 4)) {
  case 0: {
  int64_t x_123 = mhs_mem[(x_67 + 3)];
  int64_t x_124 = mhs_mem[(x_123 + 1)];
  int64_t x_125 = mhs_mem[(x_123 + 2)];
  mhs_mem[(x_67 + 4)] = x_125;
  int m_118 = 0;
  int r_122;
  switch (((x_67 + 5) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_67 + 5);
  r_122 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_122 = 0; break; }
  default: abort();
  }
  int m_119 = r_122;
  int64_t x_126 = mhs_mem[0];
  int64_t x_127 = mhs_mem[1];
  int64_t r_123;
  switch (((x_126 + 3) > x_127)) {
  case 0: {
  r_123 = x_126; break; }
  case 1: {
  int64_t x1_53 = gc(m_119);
  int64_t r_124;
  int64_t x3_53 = x1_53;
  int x4_53 = 0;
  int64_t r_125;
  switch (((x3_53 + 3) > mhs_mem[1])) {
  case 0: {
  r_125 = x3_53; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_125 = 0; break; }
  default: abort();
  }
  r_124 = r_125;
  r_123 = r_124; break; }
  default: abort();
  }
  int64_t x1_54 = r_123;
  int64_t r_126;
  int64_t x3_54 = x1_54;
  int x4_54 = 0;
  mhs_mem[0] = (x3_54 + 3);
  int m_120 = 0;
  mhs_mem[(x_67 + 5)] = x3_54;
  int m_121 = 0;
  mhs_mem[x3_54] = 5;
  int m_122 = 0;
  int64_t x_128 = mhs_mem[(x_67 + 4)];
  mhs_mem[(x3_54 + 1)] = x_124;
  int m_123 = 0;
  mhs_mem[(x3_54 + 2)] = x_128;
  int m_124 = 0;
  int64_t x_129 = mhs_mem[(x_67 + 5)];
  r_126 = j_3(x_67, x_129, m_124);
  r_121 = r_126; break; }
  case 1: {
  int64_t x_130 = mhs_mem[(x_67 + 3)];
  int64_t x_131 = mhs_mem[(x_130 + 1)];
  int64_t x_132 = mhs_mem[(x_130 + 2)];
  mhs_mem[(x_67 + 4)] = x_131;
  int m_125 = 0;
  mhs_mem[(x_67 + 5)] = x_132;
  int m_126 = 0;
  int r_127;
  switch (((x_67 + 6) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_67 + 6);
  r_127 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_127 = 0; break; }
  default: abort();
  }
  int m_127 = r_127;
  int64_t x_133 = mhs_mem[0];
  int64_t x_134 = mhs_mem[1];
  int64_t r_128;
  switch (((x_133 + 3) > x_134)) {
  case 0: {
  r_128 = x_133; break; }
  case 1: {
  int64_t x1_55 = gc(m_127);
  int64_t r_129;
  int64_t x3_55 = x1_55;
  int x4_55 = 0;
  int64_t r_130;
  switch (((x3_55 + 3) > mhs_mem[1])) {
  case 0: {
  r_130 = x3_55; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_130 = 0; break; }
  default: abort();
  }
  r_129 = r_130;
  r_128 = r_129; break; }
  default: abort();
  }
  int64_t x1_56 = r_128;
  int64_t r_131;
  int64_t x3_56 = x1_56;
  int x4_56 = 0;
  mhs_mem[0] = (x3_56 + 3);
  int m_128 = 0;
  mhs_mem[(x_67 + 6)] = x3_56;
  int m_129 = 0;
  mhs_mem[x3_56] = 3;
  int m_130 = 0;
  int64_t x_135 = mhs_mem[(x_67 + 4)];
  int64_t x_136 = mhs_mem[(x_67 + 5)];
  mhs_mem[(x3_56 + 1)] = x_135;
  int m_131 = 0;
  mhs_mem[(x3_56 + 2)] = x_136;
  int m_132 = 0;
  int64_t x_137 = mhs_mem[(x_67 + 6)];
  r_131 = j_3(x_67, x_137, m_132);
  r_121 = r_131; break; }
  default: abort();
  }
  r_79 = r_121;
  return r_79;
}
static int64_t t4(int m_133, int64_t p_6) {
  int64_t x_138 = mhs_mem[4];
  mhs_mem[x_138] = p_6;
  int m_134 = 0;
  int64_t x_139 = mhs_mem[x_138];
  int64_t x_140 = mhs_mem[(x_139 + 1)];
  int64_t x_141 = (x_140 - 1);
  int r_132;
  switch (((x_138 + 1) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_138 + 1);
  r_132 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_132 = 0; break; }
  default: abort();
  }
  int m_135 = r_132;
  int64_t x_142 = mhs_mem[0];
  int64_t x_143 = mhs_mem[1];
  int64_t r_133;
  switch (((x_142 + 2) > x_143)) {
  case 0: {
  r_133 = x_142; break; }
  case 1: {
  int64_t x1_57 = gc(m_135);
  int64_t r_134;
  int64_t x3_57 = x1_57;
  int x4_57 = 0;
  int64_t r_135;
  switch (((x3_57 + 2) > mhs_mem[1])) {
  case 0: {
  r_135 = x3_57; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_135 = 0; break; }
  default: abort();
  }
  r_134 = r_135;
  r_133 = r_134; break; }
  default: abort();
  }
  int64_t x1_58 = r_133;
  int64_t r_136;
  int64_t x3_58 = x1_58;
  int x4_58 = 0;
  mhs_mem[0] = (x3_58 + 2);
  int m_136 = 0;
  mhs_mem[(x_138 + 1)] = x3_58;
  int m_137 = 0;
  mhs_mem[x3_58] = 2;
  int m_138 = 0;
  mhs_mem[(x3_58 + 1)] = x_141;
  int m_139 = 0;
  int64_t x_144 = mhs_mem[(x_138 + 1)];
  mhs_mem[4] = x_138;
  int m_140 = 0;
  r_136 = x_144;
  return r_136;
}
static int copyWords(int m_142, int64_t src, int64_t dst, int64_t n_1);
static int copyWords(int m_142, int64_t src, int64_t dst, int64_t n_1) {
  int r_137;
  switch ((n_1 == 0)) {
  case 0: {
  mhs_mem[dst] = mhs_mem[src];
  r_137 = copyWords(0, (src + 1), (dst + 1), (n_1 - 1)); break; }
  case 1: {
  r_137 = m_142; break; }
  default: abort();
  }
  return r_137;
}
static int64_t copy(int m_143, int64_t p_7) {
  int64_t t = mhs_mem[p_7];
  int64_t r_138;
  switch ((t == 0)) {
  case 0: {
  int64_t r_139;
  switch ((t < 0)) {
  case 0: {
  r_139 = t; break; }
  case 1: {
  r_139 = (0 - t); break; }
  default: abort();
  }
  int64_t u = r_139;
  int64_t r_140;
  switch ((u == 2)) {
  case 0: {
  int64_t r_141;
  switch ((u == 3)) {
  case 0: {
  int64_t r_142;
  switch ((u == 4)) {
  case 0: {
  int64_t r_143;
  switch ((u == 5)) {
  case 0: {
  int64_t r_144;
  switch ((u == 6)) {
  case 0: {
  int64_t r_145;
  switch ((u == 7)) {
  case 0: {
  int64_t r_146;
  switch ((u == 8)) {
  case 0: {
  int64_t r_147;
  switch ((u == 9)) {
  case 0: {
  int64_t r_148;
  switch ((u == 10)) {
  case 0: {
  int64_t r_149;
  switch ((u == 11)) {
  case 0: {
  r_149 = 2; break; }
  case 1: {
  r_149 = 2; break; }
  default: abort();
  }
  r_148 = r_149; break; }
  case 1: {
  r_148 = 3; break; }
  default: abort();
  }
  r_147 = r_148; break; }
  case 1: {
  r_147 = 3; break; }
  default: abort();
  }
  r_146 = r_147; break; }
  case 1: {
  r_146 = 3; break; }
  default: abort();
  }
  r_145 = r_146; break; }
  case 1: {
  r_145 = 3; break; }
  default: abort();
  }
  r_144 = r_145; break; }
  case 1: {
  r_144 = 3; break; }
  default: abort();
  }
  r_143 = r_144; break; }
  case 1: {
  r_143 = 3; break; }
  default: abort();
  }
  r_142 = r_143; break; }
  case 1: {
  r_142 = 3; break; }
  default: abort();
  }
  r_141 = r_142; break; }
  case 1: {
  r_141 = 3; break; }
  default: abort();
  }
  r_140 = r_141; break; }
  case 1: {
  r_140 = 2; break; }
  default: abort();
  }
  int64_t n_2 = r_140;
  int64_t free = mhs_mem[6];
  int m1_1 = copyWords(m_143, p_7, free, n_2);
  mhs_mem[p_7] = 0;
  mhs_mem[(p_7 + 1)] = free;
  mhs_mem[6] = (free + n_2);
  r_138 = free; break; }
  case 1: {
  r_138 = mhs_mem[(p_7 + 1)]; break; }
  default: abort();
  }
  return r_138;
}
static int scan(int m_144);
static int scan(int m_144) {
  int64_t s = mhs_mem[7];
  int64_t f = mhs_mem[6];
  int r_150;
  switch ((s >= f)) {
  case 0: {
  int64_t t_1 = mhs_mem[s];
  int r_151;
  switch ((t_1 < 0)) {
  case 0: {
  int r_152;
  switch ((t_1 == 2)) {
  case 0: {
  int r_153;
  switch ((t_1 == 3)) {
  case 0: {
  int r_154;
  switch ((t_1 == 4)) {
  case 0: {
  int r_155;
  switch ((t_1 == 5)) {
  case 0: {
  int r_156;
  switch ((t_1 == 6)) {
  case 0: {
  int r_157;
  switch ((t_1 == 7)) {
  case 0: {
  int r_158;
  switch ((t_1 == 8)) {
  case 0: {
  int r_159;
  switch ((t_1 == 9)) {
  case 0: {
  int r_160;
  switch ((t_1 == 10)) {
  case 0: {
  int r_161;
  switch ((t_1 == 11)) {
  case 0: {
  r_161 = m_144; break; }
  case 1: {
  r_161 = m_144; break; }
  default: abort();
  }
  r_160 = r_161; break; }
  case 1: {
  int64_t x1_59 = copy(m_144, mhs_mem[(s + 1)]);
  int r_162;
  int64_t a0_1 = x1_59;
  int x4_59 = 0;
  mhs_mem[(s + 1)] = a0_1;
  int m2 = 0;
  int64_t x1_60 = copy(m2, mhs_mem[(s + 2)]);
  int r_163;
  int64_t a0_3 = x1_60;
  int x4_60 = 0;
  mhs_mem[(s + 2)] = a0_3;
  int m2_1 = 0;
  r_163 = m2_1;
  r_162 = r_163;
  r_160 = r_162; break; }
  default: abort();
  }
  r_159 = r_160; break; }
  case 1: {
  int64_t x1_61 = copy(m_144, mhs_mem[(s + 1)]);
  int r_164;
  int64_t a0_5 = x1_61;
  int x4_61 = 0;
  mhs_mem[(s + 1)] = a0_5;
  int m2_2 = 0;
  int64_t x1_62 = copy(m2_2, mhs_mem[(s + 2)]);
  int r_165;
  int64_t a0_7 = x1_62;
  int x4_62 = 0;
  mhs_mem[(s + 2)] = a0_7;
  int m2_3 = 0;
  r_165 = m2_3;
  r_164 = r_165;
  r_159 = r_164; break; }
  default: abort();
  }
  r_158 = r_159; break; }
  case 1: {
  int64_t x1_63 = copy(m_144, mhs_mem[(s + 2)]);
  int r_166;
  int64_t a0_9 = x1_63;
  int x4_63 = 0;
  mhs_mem[(s + 2)] = a0_9;
  int m2_4 = 0;
  r_166 = m2_4;
  r_158 = r_166; break; }
  default: abort();
  }
  r_157 = r_158; break; }
  case 1: {
  r_157 = m_144; break; }
  default: abort();
  }
  r_156 = r_157; break; }
  case 1: {
  int64_t x1_64 = copy(m_144, mhs_mem[(s + 2)]);
  int r_167;
  int64_t a0_11 = x1_64;
  int x4_64 = 0;
  mhs_mem[(s + 2)] = a0_11;
  int m2_5 = 0;
  r_167 = m2_5;
  r_156 = r_167; break; }
  default: abort();
  }
  r_155 = r_156; break; }
  case 1: {
  int64_t x1_65 = copy(m_144, mhs_mem[(s + 2)]);
  int r_168;
  int64_t a0_13 = x1_65;
  int x4_65 = 0;
  mhs_mem[(s + 2)] = a0_13;
  int m2_6 = 0;
  r_168 = m2_6;
  r_155 = r_168; break; }
  default: abort();
  }
  r_154 = r_155; break; }
  case 1: {
  int64_t x1_66 = copy(m_144, mhs_mem[(s + 1)]);
  int r_169;
  int64_t a0_15 = x1_66;
  int x4_66 = 0;
  mhs_mem[(s + 1)] = a0_15;
  int m2_7 = 0;
  int64_t x1_67 = copy(m2_7, mhs_mem[(s + 2)]);
  int r_170;
  int64_t a0_17 = x1_67;
  int x4_67 = 0;
  mhs_mem[(s + 2)] = a0_17;
  int m2_8 = 0;
  r_170 = m2_8;
  r_169 = r_170;
  r_154 = r_169; break; }
  default: abort();
  }
  r_153 = r_154; break; }
  case 1: {
  int64_t x1_68 = copy(m_144, mhs_mem[(s + 1)]);
  int r_171;
  int64_t a0_19 = x1_68;
  int x4_68 = 0;
  mhs_mem[(s + 1)] = a0_19;
  int m2_9 = 0;
  int64_t x1_69 = copy(m2_9, mhs_mem[(s + 2)]);
  int r_172;
  int64_t a0_21 = x1_69;
  int x4_69 = 0;
  mhs_mem[(s + 2)] = a0_21;
  int m2_10 = 0;
  r_172 = m2_10;
  r_171 = r_172;
  r_153 = r_171; break; }
  default: abort();
  }
  r_152 = r_153; break; }
  case 1: {
  r_152 = m_144; break; }
  default: abort();
  }
  r_151 = r_152; break; }
  case 1: {
  int64_t x1_70 = copy(m_144, mhs_mem[(s + 1)]);
  int r_173;
  int64_t a0_23 = x1_70;
  int x4_70 = 0;
  mhs_mem[(s + 1)] = a0_23;
  int m2_11 = 0;
  r_173 = m2_11;
  r_151 = r_173; break; }
  default: abort();
  }
  int m1_2 = r_151;
  int64_t r_174;
  switch ((t_1 < 0)) {
  case 0: {
  r_174 = t_1; break; }
  case 1: {
  r_174 = (0 - t_1); break; }
  default: abort();
  }
  int64_t u_1 = r_174;
  int64_t r_175;
  switch ((u_1 == 2)) {
  case 0: {
  int64_t r_176;
  switch ((u_1 == 3)) {
  case 0: {
  int64_t r_177;
  switch ((u_1 == 4)) {
  case 0: {
  int64_t r_178;
  switch ((u_1 == 5)) {
  case 0: {
  int64_t r_179;
  switch ((u_1 == 6)) {
  case 0: {
  int64_t r_180;
  switch ((u_1 == 7)) {
  case 0: {
  int64_t r_181;
  switch ((u_1 == 8)) {
  case 0: {
  int64_t r_182;
  switch ((u_1 == 9)) {
  case 0: {
  int64_t r_183;
  switch ((u_1 == 10)) {
  case 0: {
  int64_t r_184;
  switch ((u_1 == 11)) {
  case 0: {
  r_184 = 2; break; }
  case 1: {
  r_184 = 2; break; }
  default: abort();
  }
  r_183 = r_184; break; }
  case 1: {
  r_183 = 3; break; }
  default: abort();
  }
  r_182 = r_183; break; }
  case 1: {
  r_182 = 3; break; }
  default: abort();
  }
  r_181 = r_182; break; }
  case 1: {
  r_181 = 3; break; }
  default: abort();
  }
  r_180 = r_181; break; }
  case 1: {
  r_180 = 3; break; }
  default: abort();
  }
  r_179 = r_180; break; }
  case 1: {
  r_179 = 3; break; }
  default: abort();
  }
  r_178 = r_179; break; }
  case 1: {
  r_178 = 3; break; }
  default: abort();
  }
  r_177 = r_178; break; }
  case 1: {
  r_177 = 3; break; }
  default: abort();
  }
  r_176 = r_177; break; }
  case 1: {
  r_176 = 3; break; }
  default: abort();
  }
  r_175 = r_176; break; }
  case 1: {
  r_175 = 2; break; }
  default: abort();
  }
  mhs_mem[7] = (s + r_175);
  r_150 = scan(0); break; }
  case 1: {
  r_150 = m_144; break; }
  default: abort();
  }
  return r_150;
}
static int roots(int64_t sp, int m_145, int64_t i);
static int roots(int64_t sp, int m_145, int64_t i) {
  int r_185;
  switch ((i >= sp)) {
  case 0: {
  int64_t x1_71 = copy(m_145, mhs_mem[i]);
  int r_186;
  int64_t x3_59 = x1_71;
  int x4_71 = 0;
  mhs_mem[i] = x3_59;
  r_186 = roots(sp, 0, (i + 1));
  r_185 = r_186; break; }
  case 1: {
  r_185 = m_145; break; }
  default: abort();
  }
  return r_185;
}
static int64_t gc(int m_141) {
  int64_t to = mhs_mem[3];
  int64_t sp = mhs_mem[4];
  int64_t semi = mhs_mem[5];
  mhs_mem[6] = to;
  mhs_mem[7] = to;
  int m1 = 0;
  int64_t gcs = mhs_mem[8];
  int64_t from = mhs_mem[2];
  int m2_12 = scan(roots(sp, m1, 16));
  int64_t free_1 = mhs_mem[6];
  mhs_mem[0] = free_1;
  mhs_mem[1] = (to + semi);
  mhs_mem[2] = to;
  mhs_mem[3] = from;
  mhs_mem[8] = (gcs + 1);
  return free_1;
}
static int64_t j_4(int64_t x_145, int64_t v_4, int m_153) {
  mhs_mem[4] = x_145;
  int m_154 = 0;
  return v_4;
}

int64_t fibs(int m, int64_t n) {
  mhs_mem[2] = 2064;
  int m_146 = 0;
  mhs_mem[3] = 5128;
  int m_147 = 0;
  mhs_mem[5] = 3064;
  int m_148 = 0;
  mhs_mem[0] = 2064;
  int m_149 = 0;
  mhs_mem[1] = 5128;
  int m_150 = 0;
  mhs_mem[4] = 16;
  int m_151 = 0;
  mhs_mem[8] = 0;
  int m_152 = 0;
  int64_t x_145 = mhs_mem[4];
  int b_2 = (n == 0);
  int64_t r_187;
  switch (b_2) {
  case 0: {
  int64_t x_146 = (n - 1);
  int b_3 = (x_146 == 0);
  int64_t r_188;
  switch (b_3) {
  case 0: {
  int64_t x_147 = (x_146 - 1);
  int b_4 = (x_147 == 0);
  int64_t r_189;
  switch (b_4) {
  case 0: {
  int r_190;
  switch ((x_145 > 2064)) {
  case 0: {
  mhs_mem[4] = x_145;
  r_190 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_190 = 0; break; }
  default: abort();
  }
  int m_157 = r_190;
  int64_t x_148 = mhs_mem[0];
  int64_t x_149 = mhs_mem[1];
  int64_t r_191;
  switch (((x_148 + 3) > x_149)) {
  case 0: {
  r_191 = x_148; break; }
  case 1: {
  int64_t x1_72 = gc(m_157);
  int64_t r_192;
  int64_t x3_60 = x1_72;
  int x4_72 = 0;
  int64_t r_193;
  switch (((x3_60 + 3) > mhs_mem[1])) {
  case 0: {
  r_193 = x3_60; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_193 = 0; break; }
  default: abort();
  }
  r_192 = r_193;
  r_191 = r_192; break; }
  default: abort();
  }
  int64_t x1_73 = r_191;
  int64_t r_194;
  int64_t x3_61 = x1_73;
  int x4_73 = 0;
  mhs_mem[0] = (x3_61 + 3);
  int m_158 = 0;
  mhs_mem[x_145] = x3_61;
  int m_159 = 0;
  mhs_mem[x3_61] = 10;
  int m_160 = 0;
  int r_195;
  switch (((x_145 + 1) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_145 + 1);
  r_195 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_195 = 0; break; }
  default: abort();
  }
  int m_161 = r_195;
  int64_t x_150 = mhs_mem[0];
  int64_t x_151 = mhs_mem[1];
  int64_t r_196;
  switch (((x_150 + 3) > x_151)) {
  case 0: {
  r_196 = x_150; break; }
  case 1: {
  int64_t x1_74 = gc(m_161);
  int64_t r_197;
  int64_t x3_62 = x1_74;
  int x4_74 = 0;
  int64_t r_198;
  switch (((x3_62 + 3) > mhs_mem[1])) {
  case 0: {
  r_198 = x3_62; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_198 = 0; break; }
  default: abort();
  }
  r_197 = r_198;
  r_196 = r_197; break; }
  default: abort();
  }
  int64_t x1_75 = r_196;
  int64_t r_199;
  int64_t x3_63 = x1_75;
  int x4_75 = 0;
  mhs_mem[0] = (x3_63 + 3);
  int m_162 = 0;
  mhs_mem[(x_145 + 1)] = x3_63;
  int m_163 = 0;
  mhs_mem[x3_63] = 6;
  int m_164 = 0;
  int r_200;
  switch (((x_145 + 2) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_145 + 2);
  r_200 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_200 = 0; break; }
  default: abort();
  }
  int m_165 = r_200;
  int64_t x_152 = mhs_mem[0];
  int64_t x_153 = mhs_mem[1];
  int64_t r_201;
  switch (((x_152 + 3) > x_153)) {
  case 0: {
  r_201 = x_152; break; }
  case 1: {
  int64_t x1_76 = gc(m_165);
  int64_t r_202;
  int64_t x3_64 = x1_76;
  int x4_76 = 0;
  int64_t r_203;
  switch (((x3_64 + 3) > mhs_mem[1])) {
  case 0: {
  r_203 = x3_64; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_203 = 0; break; }
  default: abort();
  }
  r_202 = r_203;
  r_201 = r_202; break; }
  default: abort();
  }
  int64_t x1_77 = r_201;
  int64_t r_204;
  int64_t x3_65 = x1_77;
  int x4_77 = 0;
  mhs_mem[0] = (x3_65 + 3);
  int m_166 = 0;
  mhs_mem[(x_145 + 2)] = x3_65;
  int m_167 = 0;
  mhs_mem[x3_65] = 4;
  int m_168 = 0;
  int r_205;
  switch (((x_145 + 3) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_145 + 3);
  r_205 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_205 = 0; break; }
  default: abort();
  }
  int m_169 = r_205;
  int64_t x_154 = mhs_mem[0];
  int64_t x_155 = mhs_mem[1];
  int64_t r_206;
  switch (((x_154 + 3) > x_155)) {
  case 0: {
  r_206 = x_154; break; }
  case 1: {
  int64_t x1_78 = gc(m_169);
  int64_t r_207;
  int64_t x3_66 = x1_78;
  int x4_78 = 0;
  int64_t r_208;
  switch (((x3_66 + 3) > mhs_mem[1])) {
  case 0: {
  r_208 = x3_66; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_208 = 0; break; }
  default: abort();
  }
  r_207 = r_208;
  r_206 = r_207; break; }
  default: abort();
  }
  int64_t x1_79 = r_206;
  int64_t r_209;
  int64_t x3_67 = x1_79;
  int x4_79 = 0;
  mhs_mem[0] = (x3_67 + 3);
  int m_170 = 0;
  mhs_mem[(x_145 + 3)] = x3_67;
  int m_171 = 0;
  mhs_mem[x3_67] = 7;
  int m_172 = 0;
  int64_t x_156 = mhs_mem[(x_145 + 3)];
  mhs_mem[(x_156 + 1)] = 0;
  int m_173 = 0;
  mhs_mem[(x_156 + 2)] = 1;
  int m_174 = 0;
  int r_210;
  switch (((x_145 + 4) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_145 + 4);
  r_210 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_210 = 0; break; }
  default: abort();
  }
  int m_175 = r_210;
  int64_t x_157 = mhs_mem[0];
  int64_t x_158 = mhs_mem[1];
  int64_t r_211;
  switch (((x_157 + 3) > x_158)) {
  case 0: {
  r_211 = x_157; break; }
  case 1: {
  int64_t x1_80 = gc(m_175);
  int64_t r_212;
  int64_t x3_68 = x1_80;
  int x4_80 = 0;
  int64_t r_213;
  switch (((x3_68 + 3) > mhs_mem[1])) {
  case 0: {
  r_213 = x3_68; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_213 = 0; break; }
  default: abort();
  }
  r_212 = r_213;
  r_211 = r_212; break; }
  default: abort();
  }
  int64_t x1_81 = r_211;
  int64_t r_214;
  int64_t x3_69 = x1_81;
  int x4_81 = 0;
  mhs_mem[0] = (x3_69 + 3);
  int m_176 = 0;
  mhs_mem[(x_145 + 4)] = x3_69;
  int m_177 = 0;
  mhs_mem[x3_69] = 10;
  int m_178 = 0;
  int64_t x_159 = mhs_mem[(x_145 + 1)];
  int64_t x_160 = mhs_mem[(x_145 + 2)];
  int64_t x_161 = mhs_mem[(x_145 + 4)];
  mhs_mem[(x_161 + 1)] = x_159;
  int m_179 = 0;
  mhs_mem[(x_161 + 2)] = x_160;
  int m_180 = 0;
  int64_t x_162 = mhs_mem[(x_145 + 3)];
  int64_t x_163 = mhs_mem[(x_145 + 4)];
  int64_t x_164 = mhs_mem[(x_145 + 2)];
  mhs_mem[(x_164 + 1)] = x_162;
  int m_181 = 0;
  mhs_mem[(x_164 + 2)] = x_163;
  int m_182 = 0;
  int64_t x_165 = mhs_mem[(x_145 + 2)];
  int64_t x_166 = mhs_mem[(x_145 + 1)];
  mhs_mem[(x_166 + 1)] = 1;
  int m_183 = 0;
  mhs_mem[(x_166 + 2)] = x_165;
  int m_184 = 0;
  int64_t x_167 = mhs_mem[(x_145 + 1)];
  int64_t x_168 = mhs_mem[(x_145 + 2)];
  int64_t x_169 = mhs_mem[x_145];
  mhs_mem[(x_169 + 1)] = x_167;
  int m_185 = 0;
  mhs_mem[(x_169 + 2)] = x_168;
  int m_186 = 0;
  int r_215;
  switch (((x_145 + 5) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_145 + 5);
  r_215 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_215 = 0; break; }
  default: abort();
  }
  int m_187 = r_215;
  int64_t x_170 = mhs_mem[0];
  int64_t x_171 = mhs_mem[1];
  int64_t r_216;
  switch (((x_170 + 2) > x_171)) {
  case 0: {
  r_216 = x_170; break; }
  case 1: {
  int64_t x1_82 = gc(m_187);
  int64_t r_217;
  int64_t x3_70 = x1_82;
  int x4_82 = 0;
  int64_t r_218;
  switch (((x3_70 + 2) > mhs_mem[1])) {
  case 0: {
  r_218 = x3_70; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_218 = 0; break; }
  default: abort();
  }
  r_217 = r_218;
  r_216 = r_217; break; }
  default: abort();
  }
  int64_t x1_83 = r_216;
  int64_t r_219;
  int64_t x3_71 = x1_83;
  int x4_83 = 0;
  mhs_mem[0] = (x3_71 + 2);
  int m_188 = 0;
  mhs_mem[(x_145 + 5)] = x3_71;
  int m_189 = 0;
  mhs_mem[x3_71] = 11;
  int m_190 = 0;
  int64_t x_172 = mhs_mem[(x_145 + 5)];
  mhs_mem[(x_172 + 1)] = x_147;
  int m_191 = 0;
  int64_t x_173 = mhs_mem[x_145];
  int64_t x_174 = mhs_mem[(x_145 + 5)];
  mhs_mem[4] = x_145;
  int m_192 = 0;
  int64_t x1_84 = f0(m_192, x_173, x_174);
  int64_t r_220;
  int64_t x3_72 = x1_84;
  int x4_84 = 0;
  r_220 = j_4(x_145, x3_72, x4_84);
  r_219 = r_220;
  r_214 = r_219;
  r_209 = r_214;
  r_204 = r_209;
  r_199 = r_204;
  r_194 = r_199;
  r_189 = r_194; break; }
  case 1: {
  r_189 = j_4(x_145, 1, m_152); break; }
  default: abort();
  }
  r_188 = r_189; break; }
  case 1: {
  r_188 = j_4(x_145, 1, m_152); break; }
  default: abort();
  }
  r_187 = r_188; break; }
  case 1: {
  r_187 = j_4(x_145, 0, m_152); break; }
  default: abort();
  }
  int64_t x1_85 = r_187;
  int64_t r_221;
  int64_t x3_73 = x1_85;
  int x4_85 = 0;
  r_221 = x3_73;
  return r_221;
}
int main(int argc, char **argv) {
  for (int i = 1; i < argc; i++) {
    printf("%lld\n", (long long)fibs(0, atoll(argv[i])));
    fprintf(stderr, "%s %s: %lld collections\n", "fibs", argv[i], (long long)mhs_mem[8]);
  }
  return 0;
}
