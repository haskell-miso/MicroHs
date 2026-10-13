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
static int64_t t0(int m_24, int64_t p_2);
static int64_t t1(int m_44, int64_t p_3);
static int64_t t2(int m_51, int64_t p_4);
static int64_t gc(int m_92);
static int64_t j_1(int64_t x, int64_t p_1, int64_t v, int m_5) {
  mhs_mem[(x + 2)] = v;
  int m_6 = 0;
  int64_t x_5 = mhs_mem[(x + 2)];
  int64_t x_6 = mhs_mem[x_5];
  int64_t r_4;
  switch ((x_6 == 7)) {
  case 0: {
  int64_t x_7 = mhs_mem[(x + 2)];
  int64_t x_8 = mhs_mem[(x_7 + 1)];
  int64_t x_9 = mhs_mem[(x_7 + 2)];
  mhs_mem[(x + 3)] = x_8;
  int m_8 = 0;
  mhs_mem[(x + 4)] = x_9;
  int m_9 = 0;
  int64_t x_10 = (p_1 + 1);
  int64_t x_11 = mhs_mem[(x + 4)];
  mhs_mem[4] = x;
  int m_10 = 0;
  int64_t x1_2 = f0(m_10, x_11, x_10);
  r_4 = x1_2; break; }
  case 1: {
  int64_t x_12 = mhs_mem[(x + 2)];
  int64_t x_13 = mhs_mem[(x_12 + 1)];
  r_4 = x_13; break; }
  default: abort();
  }
  return r_4;
}
static int64_t f0(int m_1, int64_t p, int64_t p_1) {
  int64_t x = mhs_mem[4];
  mhs_mem[x] = p;
  int m_2 = 0;
  int r_0;
  switch (((x + 1) > 2064)) {
  case 0: {
  mhs_mem[4] = (x + 1);
  r_0 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_0 = 0; break; }
  default: abort();
  }
  int m_3 = r_0;
  int64_t x_1 = mhs_mem[x];
  int64_t x_2 = mhs_mem[x_1];
  int64_t r_1;
  switch ((x_2 < 0)) {
  case 0: {
  int64_t x1 = t2(m_3, x_1);
  int64_t r_2;
  int64_t x3 = x1;
  int x4 = 0;
  int64_t q = mhs_mem[x];
  mhs_mem[q] = -13;
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
  mhs_mem[(x + 1)] = x3_1;
  int m_4 = 0;
  int64_t x_3 = mhs_mem[(x + 1)];
  int64_t x_4 = mhs_mem[x_3];
  int64_t r_5;
  switch ((x_4 == 8)) {
  case 0: {
  int64_t x_14 = mhs_mem[(x + 1)];
  int64_t x_15 = mhs_mem[(x_14 + 1)];
  int64_t x_16 = mhs_mem[(x_14 + 2)];
  mhs_mem[(x + 2)] = x_15;
  int m_11 = 0;
  mhs_mem[(x + 3)] = x_16;
  int m_12 = 0;
  int r_6;
  switch (((x + 4) > 2064)) {
  case 0: {
  mhs_mem[4] = (x + 4);
  r_6 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_6 = 0; break; }
  default: abort();
  }
  int m_13 = r_6;
  int64_t x_17 = mhs_mem[0];
  int64_t x_18 = mhs_mem[1];
  int64_t r_7;
  switch (((x_17 + 3) > x_18)) {
  case 0: {
  r_7 = x_17; break; }
  case 1: {
  int64_t x1_3 = gc(m_13);
  int64_t r_8;
  int64_t x3_3 = x1_3;
  int x4_3 = 0;
  int64_t r_9;
  switch (((x3_3 + 3) > mhs_mem[1])) {
  case 0: {
  r_9 = x3_3; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_9 = 0; break; }
  default: abort();
  }
  r_8 = r_9;
  r_7 = r_8; break; }
  default: abort();
  }
  int64_t x1_4 = r_7;
  int64_t r_10;
  int64_t x3_4 = x1_4;
  int x4_4 = 0;
  mhs_mem[0] = (x3_4 + 3);
  int m_14 = 0;
  mhs_mem[(x + 4)] = x3_4;
  int m_15 = 0;
  mhs_mem[x3_4] = 9;
  int m_16 = 0;
  int64_t x_19 = mhs_mem[(x + 2)];
  int64_t x_20 = mhs_mem[(x + 3)];
  mhs_mem[(x3_4 + 1)] = x_19;
  int m_17 = 0;
  mhs_mem[(x3_4 + 2)] = x_20;
  int m_18 = 0;
  int64_t x_21 = mhs_mem[(x + 4)];
  r_10 = j_1(x, p_1, x_21, m_18);
  r_5 = r_10; break; }
  case 1: {
  int64_t x_22 = mhs_mem[(x + 1)];
  int r_11;
  switch (((x + 2) > 2064)) {
  case 0: {
  mhs_mem[4] = (x + 2);
  r_11 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_11 = 0; break; }
  default: abort();
  }
  int m_19 = r_11;
  int64_t x_23 = mhs_mem[0];
  int64_t x_24 = mhs_mem[1];
  int64_t r_12;
  switch (((x_23 + 2) > x_24)) {
  case 0: {
  r_12 = x_23; break; }
  case 1: {
  int64_t x1_5 = gc(m_19);
  int64_t r_13;
  int64_t x3_5 = x1_5;
  int x4_5 = 0;
  int64_t r_14;
  switch (((x3_5 + 2) > mhs_mem[1])) {
  case 0: {
  r_14 = x3_5; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_14 = 0; break; }
  default: abort();
  }
  r_13 = r_14;
  r_12 = r_13; break; }
  default: abort();
  }
  int64_t x1_6 = r_12;
  int64_t r_15;
  int64_t x3_6 = x1_6;
  int x4_6 = 0;
  mhs_mem[0] = (x3_6 + 2);
  int m_20 = 0;
  mhs_mem[(x + 2)] = x3_6;
  int m_21 = 0;
  mhs_mem[x3_6] = 7;
  int m_22 = 0;
  mhs_mem[(x3_6 + 1)] = p_1;
  int m_23 = 0;
  int64_t x_25 = mhs_mem[(x + 2)];
  r_15 = j_1(x, p_1, x_25, m_23);
  r_5 = r_15; break; }
  default: abort();
  }
  r_3 = r_5;
  return r_3;
}
static int64_t j_2(int64_t x_26, int64_t v_2, int m_26) {
  mhs_mem[(x_26 + 1)] = v_2;
  int m_27 = 0;
  int64_t x_31 = mhs_mem[(x_26 + 1)];
  return x_31;
}
static int64_t t0(int m_24, int64_t p_2) {
  int64_t x_26 = mhs_mem[4];
  mhs_mem[x_26] = p_2;
  int m_25 = 0;
  int64_t x_27 = mhs_mem[x_26];
  int64_t x_28 = mhs_mem[(x_27 + 1)];
  int64_t x_29 = mhs_mem[(x_27 + 2)];
  int64_t x_30 = (x_28 + 1);
  int b = (x_30 > x_29);
  int64_t r_16;
  switch (b) {
  case 0: {
  int r_17;
  switch (((x_26 + 1) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_26 + 1);
  r_17 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_17 = 0; break; }
  default: abort();
  }
  int m_28 = r_17;
  int64_t x_32 = mhs_mem[0];
  int64_t x_33 = mhs_mem[1];
  int64_t r_18;
  switch (((x_32 + 3) > x_33)) {
  case 0: {
  r_18 = x_32; break; }
  case 1: {
  int64_t x1_7 = gc(m_28);
  int64_t r_19;
  int64_t x3_7 = x1_7;
  int x4_7 = 0;
  int64_t r_20;
  switch (((x3_7 + 3) > mhs_mem[1])) {
  case 0: {
  r_20 = x3_7; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_20 = 0; break; }
  default: abort();
  }
  r_19 = r_20;
  r_18 = r_19; break; }
  default: abort();
  }
  int64_t x1_8 = r_18;
  int64_t r_21;
  int64_t x3_8 = x1_8;
  int x4_8 = 0;
  mhs_mem[0] = (x3_8 + 3);
  int m_29 = 0;
  mhs_mem[(x_26 + 1)] = x3_8;
  int m_30 = 0;
  mhs_mem[x3_8] = 11;
  int m_31 = 0;
  int64_t x_34 = mhs_mem[(x_26 + 1)];
  mhs_mem[(x_34 + 1)] = x_30;
  int m_32 = 0;
  mhs_mem[(x_34 + 2)] = x_29;
  int m_33 = 0;
  int r_22;
  switch (((x_26 + 2) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_26 + 2);
  r_22 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_22 = 0; break; }
  default: abort();
  }
  int m_34 = r_22;
  int64_t x_35 = mhs_mem[0];
  int64_t x_36 = mhs_mem[1];
  int64_t r_23;
  switch (((x_35 + 3) > x_36)) {
  case 0: {
  r_23 = x_35; break; }
  case 1: {
  int64_t x1_9 = gc(m_34);
  int64_t r_24;
  int64_t x3_9 = x1_9;
  int x4_9 = 0;
  int64_t r_25;
  switch (((x3_9 + 3) > mhs_mem[1])) {
  case 0: {
  r_25 = x3_9; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_25 = 0; break; }
  default: abort();
  }
  r_24 = r_25;
  r_23 = r_24; break; }
  default: abort();
  }
  int64_t x1_10 = r_23;
  int64_t r_26;
  int64_t x3_10 = x1_10;
  int x4_10 = 0;
  mhs_mem[0] = (x3_10 + 3);
  int m_35 = 0;
  mhs_mem[(x_26 + 2)] = x3_10;
  int m_36 = 0;
  mhs_mem[x3_10] = 4;
  int m_37 = 0;
  int64_t x_37 = mhs_mem[(x_26 + 1)];
  mhs_mem[(x3_10 + 1)] = x_30;
  int m_38 = 0;
  mhs_mem[(x3_10 + 2)] = x_37;
  int m_39 = 0;
  int64_t x_38 = mhs_mem[(x_26 + 2)];
  r_26 = j_2(x_26, x_38, m_39);
  r_21 = r_26;
  r_16 = r_21; break; }
  case 1: {
  int r_27;
  switch (((x_26 + 1) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_26 + 1);
  r_27 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_27 = 0; break; }
  default: abort();
  }
  int m_40 = r_27;
  int64_t x_39 = mhs_mem[0];
  int64_t x_40 = mhs_mem[1];
  int64_t r_28;
  switch (((x_39 + 2) > x_40)) {
  case 0: {
  r_28 = x_39; break; }
  case 1: {
  int64_t x1_11 = gc(m_40);
  int64_t r_29;
  int64_t x3_11 = x1_11;
  int x4_11 = 0;
  int64_t r_30;
  switch (((x3_11 + 2) > mhs_mem[1])) {
  case 0: {
  r_30 = x3_11; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_30 = 0; break; }
  default: abort();
  }
  r_29 = r_30;
  r_28 = r_29; break; }
  default: abort();
  }
  int64_t x1_12 = r_28;
  int64_t r_31;
  int64_t x3_12 = x1_12;
  int x4_12 = 0;
  mhs_mem[0] = (x3_12 + 2);
  int m_41 = 0;
  mhs_mem[(x_26 + 1)] = x3_12;
  int m_42 = 0;
  mhs_mem[x3_12] = 6;
  int m_43 = 0;
  int64_t x_41 = mhs_mem[(x_26 + 1)];
  r_31 = j_2(x_26, x_41, m_43);
  r_16 = r_31; break; }
  default: abort();
  }
  return r_16;
}
static int64_t t1(int m_44, int64_t p_3) {
  int64_t x_42 = mhs_mem[4];
  mhs_mem[x_42] = p_3;
  int m_45 = 0;
  int64_t x_43 = mhs_mem[x_42];
  int64_t x_44 = mhs_mem[(x_43 + 1)];
  int64_t x_45 = (x_44 * x_44);
  int r_32;
  switch (((x_42 + 1) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_42 + 1);
  r_32 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_32 = 0; break; }
  default: abort();
  }
  int m_46 = r_32;
  int64_t x_46 = mhs_mem[0];
  int64_t x_47 = mhs_mem[1];
  int64_t r_33;
  switch (((x_46 + 2) > x_47)) {
  case 0: {
  r_33 = x_46; break; }
  case 1: {
  int64_t x1_13 = gc(m_46);
  int64_t r_34;
  int64_t x3_13 = x1_13;
  int x4_13 = 0;
  int64_t r_35;
  switch (((x3_13 + 2) > mhs_mem[1])) {
  case 0: {
  r_35 = x3_13; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_35 = 0; break; }
  default: abort();
  }
  r_34 = r_35;
  r_33 = r_34; break; }
  default: abort();
  }
  int64_t x1_14 = r_33;
  int64_t r_36;
  int64_t x3_14 = x1_14;
  int x4_14 = 0;
  mhs_mem[0] = (x3_14 + 2);
  int m_47 = 0;
  mhs_mem[(x_42 + 1)] = x3_14;
  int m_48 = 0;
  mhs_mem[x3_14] = 2;
  int m_49 = 0;
  mhs_mem[(x3_14 + 1)] = x_45;
  int m_50 = 0;
  int64_t x_48 = mhs_mem[(x_42 + 1)];
  r_36 = x_48;
  return r_36;
}
static int64_t j_3(int64_t x_49, int64_t v_4, int m_58) {
  mhs_mem[(x_49 + 4)] = v_4;
  int m_59 = 0;
  int64_t x_58 = mhs_mem[(x_49 + 4)];
  return x_58;
}
static int64_t j_4(int64_t x_49, int64_t v_3, int m_56) {
  mhs_mem[(x_49 + 3)] = v_3;
  int m_57 = 0;
  int64_t x_56 = mhs_mem[(x_49 + 3)];
  int64_t x_57 = mhs_mem[x_56];
  int64_t r_41;
  switch ((x_57 == 3)) {
  case 0: {
  int64_t x_59 = mhs_mem[(x_49 + 3)];
  int r_42;
  switch (((x_49 + 4) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_49 + 4);
  r_42 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_42 = 0; break; }
  default: abort();
  }
  int m_60 = r_42;
  int64_t x_60 = mhs_mem[0];
  int64_t x_61 = mhs_mem[1];
  int64_t r_43;
  switch (((x_60 + 2) > x_61)) {
  case 0: {
  r_43 = x_60; break; }
  case 1: {
  int64_t x1_17 = gc(m_60);
  int64_t r_44;
  int64_t x3_17 = x1_17;
  int x4_17 = 0;
  int64_t r_45;
  switch (((x3_17 + 2) > mhs_mem[1])) {
  case 0: {
  r_45 = x3_17; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_45 = 0; break; }
  default: abort();
  }
  r_44 = r_45;
  r_43 = r_44; break; }
  default: abort();
  }
  int64_t x1_18 = r_43;
  int64_t r_46;
  int64_t x3_18 = x1_18;
  int x4_18 = 0;
  mhs_mem[0] = (x3_18 + 2);
  int m_61 = 0;
  mhs_mem[(x_49 + 4)] = x3_18;
  int m_62 = 0;
  mhs_mem[x3_18] = 8;
  int m_63 = 0;
  int64_t x_62 = mhs_mem[(x_49 + 4)];
  r_46 = j_3(x_49, x_62, m_63);
  r_41 = r_46; break; }
  case 1: {
  int64_t x_63 = mhs_mem[(x_49 + 3)];
  int64_t x_64 = mhs_mem[(x_63 + 1)];
  int64_t x_65 = mhs_mem[(x_63 + 2)];
  mhs_mem[(x_49 + 4)] = x_65;
  int m_64 = 0;
  int r_47;
  switch (((x_49 + 5) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_49 + 5);
  r_47 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_47 = 0; break; }
  default: abort();
  }
  int m_65 = r_47;
  int64_t x_66 = mhs_mem[0];
  int64_t x_67 = mhs_mem[1];
  int64_t r_48;
  switch (((x_66 + 2) > x_67)) {
  case 0: {
  r_48 = x_66; break; }
  case 1: {
  int64_t x1_19 = gc(m_65);
  int64_t r_49;
  int64_t x3_19 = x1_19;
  int x4_19 = 0;
  int64_t r_50;
  switch (((x3_19 + 2) > mhs_mem[1])) {
  case 0: {
  r_50 = x3_19; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_50 = 0; break; }
  default: abort();
  }
  r_49 = r_50;
  r_48 = r_49; break; }
  default: abort();
  }
  int64_t x1_20 = r_48;
  int64_t r_51;
  int64_t x3_20 = x1_20;
  int x4_20 = 0;
  mhs_mem[0] = (x3_20 + 2);
  int m_66 = 0;
  mhs_mem[(x_49 + 5)] = x3_20;
  int m_67 = 0;
  mhs_mem[x3_20] = 12;
  int m_68 = 0;
  int64_t x_68 = mhs_mem[(x_49 + 5)];
  mhs_mem[(x_68 + 1)] = x_64;
  int m_69 = 0;
  int r_52;
  switch (((x_49 + 6) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_49 + 6);
  r_52 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_52 = 0; break; }
  default: abort();
  }
  int m_70 = r_52;
  int64_t x_69 = mhs_mem[0];
  int64_t x_70 = mhs_mem[1];
  int64_t r_53;
  switch (((x_69 + 2) > x_70)) {
  case 0: {
  r_53 = x_69; break; }
  case 1: {
  int64_t x1_21 = gc(m_70);
  int64_t r_54;
  int64_t x3_21 = x1_21;
  int x4_21 = 0;
  int64_t r_55;
  switch (((x3_21 + 2) > mhs_mem[1])) {
  case 0: {
  r_55 = x3_21; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_55 = 0; break; }
  default: abort();
  }
  r_54 = r_55;
  r_53 = r_54; break; }
  default: abort();
  }
  int64_t x1_22 = r_53;
  int64_t r_56;
  int64_t x3_22 = x1_22;
  int x4_22 = 0;
  mhs_mem[0] = (x3_22 + 2);
  int m_71 = 0;
  mhs_mem[(x_49 + 6)] = x3_22;
  int m_72 = 0;
  mhs_mem[x3_22] = 13;
  int m_73 = 0;
  int64_t x_71 = mhs_mem[(x_49 + 4)];
  int64_t x_72 = mhs_mem[(x_49 + 6)];
  mhs_mem[(x_72 + 1)] = x_71;
  int m_74 = 0;
  int r_57;
  switch (((x_49 + 7) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_49 + 7);
  r_57 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_57 = 0; break; }
  default: abort();
  }
  int m_75 = r_57;
  int64_t x_73 = mhs_mem[0];
  int64_t x_74 = mhs_mem[1];
  int64_t r_58;
  switch (((x_73 + 3) > x_74)) {
  case 0: {
  r_58 = x_73; break; }
  case 1: {
  int64_t x1_23 = gc(m_75);
  int64_t r_59;
  int64_t x3_23 = x1_23;
  int x4_23 = 0;
  int64_t r_60;
  switch (((x3_23 + 3) > mhs_mem[1])) {
  case 0: {
  r_60 = x3_23; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_60 = 0; break; }
  default: abort();
  }
  r_59 = r_60;
  r_58 = r_59; break; }
  default: abort();
  }
  int64_t x1_24 = r_58;
  int64_t r_61;
  int64_t x3_24 = x1_24;
  int x4_24 = 0;
  mhs_mem[0] = (x3_24 + 3);
  int m_76 = 0;
  mhs_mem[(x_49 + 7)] = x3_24;
  int m_77 = 0;
  mhs_mem[x3_24] = 10;
  int m_78 = 0;
  int64_t x_75 = mhs_mem[(x_49 + 5)];
  int64_t x_76 = mhs_mem[(x_49 + 6)];
  mhs_mem[(x3_24 + 1)] = x_75;
  int m_79 = 0;
  mhs_mem[(x3_24 + 2)] = x_76;
  int m_80 = 0;
  int64_t x_77 = mhs_mem[(x_49 + 7)];
  r_61 = j_3(x_49, x_77, m_80);
  r_56 = r_61;
  r_51 = r_56;
  r_41 = r_51; break; }
  default: abort();
  }
  return r_41;
}
static int64_t t2(int m_51, int64_t p_4) {
  int64_t x_49 = mhs_mem[4];
  mhs_mem[x_49] = p_4;
  int m_52 = 0;
  int64_t x_50 = mhs_mem[x_49];
  int64_t x_51 = mhs_mem[(x_50 + 1)];
  mhs_mem[(x_49 + 1)] = x_51;
  int m_53 = 0;
  int r_37;
  switch (((x_49 + 2) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_49 + 2);
  r_37 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_37 = 0; break; }
  default: abort();
  }
  int m_54 = r_37;
  int64_t x_52 = mhs_mem[(x_49 + 1)];
  int64_t x_53 = mhs_mem[x_52];
  int64_t r_38;
  switch ((x_53 < 0)) {
  case 0: {
  int64_t x1_15 = t0(m_54, x_52);
  int64_t r_39;
  int64_t x3_15 = x1_15;
  int x4_15 = 0;
  int64_t q_1 = mhs_mem[(x_49 + 1)];
  mhs_mem[q_1] = -11;
  mhs_mem[(q_1 + 1)] = x3_15;
  r_39 = x3_15;
  r_38 = r_39; break; }
  case 1: {
  r_38 = mhs_mem[(x_52 + 1)]; break; }
  default: abort();
  }
  int64_t x1_16 = r_38;
  int64_t r_40;
  int64_t x3_16 = x1_16;
  int x4_16 = 0;
  mhs_mem[(x_49 + 2)] = x3_16;
  int m_55 = 0;
  int64_t x_54 = mhs_mem[(x_49 + 2)];
  int64_t x_55 = mhs_mem[x_54];
  int64_t r_62;
  switch ((x_55 == 4)) {
  case 0: {
  int64_t x_78 = mhs_mem[(x_49 + 2)];
  int r_63;
  switch (((x_49 + 3) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_49 + 3);
  r_63 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_63 = 0; break; }
  default: abort();
  }
  int m_81 = r_63;
  int64_t x_79 = mhs_mem[0];
  int64_t x_80 = mhs_mem[1];
  int64_t r_64;
  switch (((x_79 + 2) > x_80)) {
  case 0: {
  r_64 = x_79; break; }
  case 1: {
  int64_t x1_25 = gc(m_81);
  int64_t r_65;
  int64_t x3_25 = x1_25;
  int x4_25 = 0;
  int64_t r_66;
  switch (((x3_25 + 2) > mhs_mem[1])) {
  case 0: {
  r_66 = x3_25; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_66 = 0; break; }
  default: abort();
  }
  r_65 = r_66;
  r_64 = r_65; break; }
  default: abort();
  }
  int64_t x1_26 = r_64;
  int64_t r_67;
  int64_t x3_26 = x1_26;
  int x4_26 = 0;
  mhs_mem[0] = (x3_26 + 2);
  int m_82 = 0;
  mhs_mem[(x_49 + 3)] = x3_26;
  int m_83 = 0;
  mhs_mem[x3_26] = 5;
  int m_84 = 0;
  int64_t x_81 = mhs_mem[(x_49 + 3)];
  r_67 = j_4(x_49, x_81, m_84);
  r_62 = r_67; break; }
  case 1: {
  int64_t x_82 = mhs_mem[(x_49 + 2)];
  int64_t x_83 = mhs_mem[(x_82 + 1)];
  int64_t x_84 = mhs_mem[(x_82 + 2)];
  mhs_mem[(x_49 + 3)] = x_84;
  int m_85 = 0;
  int r_68;
  switch (((x_49 + 4) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_49 + 4);
  r_68 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_68 = 0; break; }
  default: abort();
  }
  int m_86 = r_68;
  int64_t x_85 = mhs_mem[0];
  int64_t x_86 = mhs_mem[1];
  int64_t r_69;
  switch (((x_85 + 3) > x_86)) {
  case 0: {
  r_69 = x_85; break; }
  case 1: {
  int64_t x1_27 = gc(m_86);
  int64_t r_70;
  int64_t x3_27 = x1_27;
  int x4_27 = 0;
  int64_t r_71;
  switch (((x3_27 + 3) > mhs_mem[1])) {
  case 0: {
  r_71 = x3_27; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_71 = 0; break; }
  default: abort();
  }
  r_70 = r_71;
  r_69 = r_70; break; }
  default: abort();
  }
  int64_t x1_28 = r_69;
  int64_t r_72;
  int64_t x3_28 = x1_28;
  int x4_28 = 0;
  mhs_mem[0] = (x3_28 + 3);
  int m_87 = 0;
  mhs_mem[(x_49 + 4)] = x3_28;
  int m_88 = 0;
  mhs_mem[x3_28] = 3;
  int m_89 = 0;
  int64_t x_87 = mhs_mem[(x_49 + 3)];
  mhs_mem[(x3_28 + 1)] = x_83;
  int m_90 = 0;
  mhs_mem[(x3_28 + 2)] = x_87;
  int m_91 = 0;
  int64_t x_88 = mhs_mem[(x_49 + 4)];
  r_72 = j_4(x_49, x_88, m_91);
  r_62 = r_72; break; }
  default: abort();
  }
  r_40 = r_62;
  return r_40;
}
static int copyWords(int m_93, int64_t src, int64_t dst, int64_t n_1);
static int copyWords(int m_93, int64_t src, int64_t dst, int64_t n_1) {
  for (;;) {
    int r_73;
    switch ((n_1 == 0)) {
    case 0: {
    mhs_mem[dst] = mhs_mem[src];
    int t_74 = 0;
    int64_t t_75 = (src + 1);
    int64_t t_76 = (dst + 1);
    int64_t t_77 = (n_1 - 1);
    m_93 = t_74;
    src = t_75;
    dst = t_76;
    n_1 = t_77;
    continue;
    break; }
    case 1: {
    r_73 = m_93;
    break; }
    default: abort();
    }
    return r_73;
  }
}
static int64_t copy(int m_94, int64_t p_5) {
  int64_t t = mhs_mem[p_5];
  int64_t r_78;
  switch ((t == 0)) {
  case 0: {
  int64_t r_79;
  switch ((t < 0)) {
  case 0: {
  r_79 = t; break; }
  case 1: {
  r_79 = (0 - t); break; }
  default: abort();
  }
  int64_t u = r_79;
  int64_t r_80;
  switch ((u == 2)) {
  case 0: {
  int64_t r_81;
  switch ((u == 3)) {
  case 0: {
  int64_t r_82;
  switch ((u == 4)) {
  case 0: {
  int64_t r_83;
  switch ((u == 5)) {
  case 0: {
  int64_t r_84;
  switch ((u == 6)) {
  case 0: {
  int64_t r_85;
  switch ((u == 7)) {
  case 0: {
  int64_t r_86;
  switch ((u == 8)) {
  case 0: {
  int64_t r_87;
  switch ((u == 9)) {
  case 0: {
  int64_t r_88;
  switch ((u == 10)) {
  case 0: {
  int64_t r_89;
  switch ((u == 11)) {
  case 0: {
  int64_t r_90;
  switch ((u == 12)) {
  case 0: {
  int64_t r_91;
  switch ((u == 13)) {
  case 0: {
  r_91 = 2; break; }
  case 1: {
  r_91 = 2; break; }
  default: abort();
  }
  r_90 = r_91; break; }
  case 1: {
  r_90 = 2; break; }
  default: abort();
  }
  r_89 = r_90; break; }
  case 1: {
  r_89 = 3; break; }
  default: abort();
  }
  r_88 = r_89; break; }
  case 1: {
  r_88 = 3; break; }
  default: abort();
  }
  r_87 = r_88; break; }
  case 1: {
  r_87 = 3; break; }
  default: abort();
  }
  r_86 = r_87; break; }
  case 1: {
  r_86 = 2; break; }
  default: abort();
  }
  r_85 = r_86; break; }
  case 1: {
  r_85 = 2; break; }
  default: abort();
  }
  r_84 = r_85; break; }
  case 1: {
  r_84 = 2; break; }
  default: abort();
  }
  r_83 = r_84; break; }
  case 1: {
  r_83 = 2; break; }
  default: abort();
  }
  r_82 = r_83; break; }
  case 1: {
  r_82 = 3; break; }
  default: abort();
  }
  r_81 = r_82; break; }
  case 1: {
  r_81 = 3; break; }
  default: abort();
  }
  r_80 = r_81; break; }
  case 1: {
  r_80 = 2; break; }
  default: abort();
  }
  int64_t n_2 = r_80;
  int64_t free = mhs_mem[6];
  int m1_1 = copyWords(m_94, p_5, free, n_2);
  mhs_mem[p_5] = 0;
  mhs_mem[(p_5 + 1)] = free;
  mhs_mem[6] = (free + n_2);
  r_78 = free; break; }
  case 1: {
  r_78 = mhs_mem[(p_5 + 1)]; break; }
  default: abort();
  }
  return r_78;
}
static int scan(int m_95);
static int scan(int m_95) {
  for (;;) {
    int64_t s = mhs_mem[7];
    int64_t f = mhs_mem[6];
    int r_92;
    switch ((s >= f)) {
    case 0: {
    int64_t t_1 = mhs_mem[s];
    int r_93;
    switch ((t_1 < 0)) {
    case 0: {
    int r_94;
    switch ((t_1 == 2)) {
    case 0: {
    int r_95;
    switch ((t_1 == 3)) {
    case 0: {
    int r_96;
    switch ((t_1 == 4)) {
    case 0: {
    int r_97;
    switch ((t_1 == 5)) {
    case 0: {
    int r_98;
    switch ((t_1 == 6)) {
    case 0: {
    int r_99;
    switch ((t_1 == 7)) {
    case 0: {
    int r_100;
    switch ((t_1 == 8)) {
    case 0: {
    int r_101;
    switch ((t_1 == 9)) {
    case 0: {
    int r_102;
    switch ((t_1 == 10)) {
    case 0: {
    int r_103;
    switch ((t_1 == 11)) {
    case 0: {
    int r_104;
    switch ((t_1 == 12)) {
    case 0: {
    int r_105;
    switch ((t_1 == 13)) {
    case 0: {
    r_105 = m_95; break; }
    case 1: {
    int64_t x1_29 = copy(m_95, mhs_mem[(s + 1)]);
    int r_106;
    int64_t a0_1 = x1_29;
    int x4_29 = 0;
    mhs_mem[(s + 1)] = a0_1;
    int m2 = 0;
    r_106 = m2;
    r_105 = r_106; break; }
    default: abort();
    }
    r_104 = r_105; break; }
    case 1: {
    r_104 = m_95; break; }
    default: abort();
    }
    r_103 = r_104; break; }
    case 1: {
    r_103 = m_95; break; }
    default: abort();
    }
    r_102 = r_103; break; }
    case 1: {
    int64_t x1_30 = copy(m_95, mhs_mem[(s + 1)]);
    int r_107;
    int64_t a0_3 = x1_30;
    int x4_30 = 0;
    mhs_mem[(s + 1)] = a0_3;
    int m2_1 = 0;
    int64_t x1_31 = copy(m2_1, mhs_mem[(s + 2)]);
    int r_108;
    int64_t a0_5 = x1_31;
    int x4_31 = 0;
    mhs_mem[(s + 2)] = a0_5;
    int m2_2 = 0;
    r_108 = m2_2;
    r_107 = r_108;
    r_102 = r_107; break; }
    default: abort();
    }
    r_101 = r_102; break; }
    case 1: {
    int64_t x1_32 = copy(m_95, mhs_mem[(s + 1)]);
    int r_109;
    int64_t a0_7 = x1_32;
    int x4_32 = 0;
    mhs_mem[(s + 1)] = a0_7;
    int m2_3 = 0;
    int64_t x1_33 = copy(m2_3, mhs_mem[(s + 2)]);
    int r_110;
    int64_t a0_9 = x1_33;
    int x4_33 = 0;
    mhs_mem[(s + 2)] = a0_9;
    int m2_4 = 0;
    r_110 = m2_4;
    r_109 = r_110;
    r_101 = r_109; break; }
    default: abort();
    }
    r_100 = r_101; break; }
    case 1: {
    r_100 = m_95; break; }
    default: abort();
    }
    r_99 = r_100; break; }
    case 1: {
    r_99 = m_95; break; }
    default: abort();
    }
    r_98 = r_99; break; }
    case 1: {
    r_98 = m_95; break; }
    default: abort();
    }
    r_97 = r_98; break; }
    case 1: {
    r_97 = m_95; break; }
    default: abort();
    }
    r_96 = r_97; break; }
    case 1: {
    int64_t x1_34 = copy(m_95, mhs_mem[(s + 2)]);
    int r_111;
    int64_t a0_11 = x1_34;
    int x4_34 = 0;
    mhs_mem[(s + 2)] = a0_11;
    int m2_5 = 0;
    r_111 = m2_5;
    r_96 = r_111; break; }
    default: abort();
    }
    r_95 = r_96; break; }
    case 1: {
    int64_t x1_35 = copy(m_95, mhs_mem[(s + 2)]);
    int r_112;
    int64_t a0_13 = x1_35;
    int x4_35 = 0;
    mhs_mem[(s + 2)] = a0_13;
    int m2_6 = 0;
    r_112 = m2_6;
    r_95 = r_112; break; }
    default: abort();
    }
    r_94 = r_95; break; }
    case 1: {
    r_94 = m_95; break; }
    default: abort();
    }
    r_93 = r_94; break; }
    case 1: {
    int64_t x1_36 = copy(m_95, mhs_mem[(s + 1)]);
    int r_113;
    int64_t a0_15 = x1_36;
    int x4_36 = 0;
    mhs_mem[(s + 1)] = a0_15;
    int m2_7 = 0;
    r_113 = m2_7;
    r_93 = r_113; break; }
    default: abort();
    }
    int m1_2 = r_93;
    int64_t r_114;
    switch ((t_1 < 0)) {
    case 0: {
    r_114 = t_1; break; }
    case 1: {
    r_114 = (0 - t_1); break; }
    default: abort();
    }
    int64_t u_1 = r_114;
    int64_t r_115;
    switch ((u_1 == 2)) {
    case 0: {
    int64_t r_116;
    switch ((u_1 == 3)) {
    case 0: {
    int64_t r_117;
    switch ((u_1 == 4)) {
    case 0: {
    int64_t r_118;
    switch ((u_1 == 5)) {
    case 0: {
    int64_t r_119;
    switch ((u_1 == 6)) {
    case 0: {
    int64_t r_120;
    switch ((u_1 == 7)) {
    case 0: {
    int64_t r_121;
    switch ((u_1 == 8)) {
    case 0: {
    int64_t r_122;
    switch ((u_1 == 9)) {
    case 0: {
    int64_t r_123;
    switch ((u_1 == 10)) {
    case 0: {
    int64_t r_124;
    switch ((u_1 == 11)) {
    case 0: {
    int64_t r_125;
    switch ((u_1 == 12)) {
    case 0: {
    int64_t r_126;
    switch ((u_1 == 13)) {
    case 0: {
    r_126 = 2; break; }
    case 1: {
    r_126 = 2; break; }
    default: abort();
    }
    r_125 = r_126; break; }
    case 1: {
    r_125 = 2; break; }
    default: abort();
    }
    r_124 = r_125; break; }
    case 1: {
    r_124 = 3; break; }
    default: abort();
    }
    r_123 = r_124; break; }
    case 1: {
    r_123 = 3; break; }
    default: abort();
    }
    r_122 = r_123; break; }
    case 1: {
    r_122 = 3; break; }
    default: abort();
    }
    r_121 = r_122; break; }
    case 1: {
    r_121 = 2; break; }
    default: abort();
    }
    r_120 = r_121; break; }
    case 1: {
    r_120 = 2; break; }
    default: abort();
    }
    r_119 = r_120; break; }
    case 1: {
    r_119 = 2; break; }
    default: abort();
    }
    r_118 = r_119; break; }
    case 1: {
    r_118 = 2; break; }
    default: abort();
    }
    r_117 = r_118; break; }
    case 1: {
    r_117 = 3; break; }
    default: abort();
    }
    r_116 = r_117; break; }
    case 1: {
    r_116 = 3; break; }
    default: abort();
    }
    r_115 = r_116; break; }
    case 1: {
    r_115 = 2; break; }
    default: abort();
    }
    mhs_mem[7] = (s + r_115);
    int t_127 = 0;
    m_95 = t_127;
    continue;
    break; }
    case 1: {
    r_92 = m_95;
    break; }
    default: abort();
    }
    return r_92;
  }
}
static int roots(int64_t sp, int m_96, int64_t i);
static int roots(int64_t sp, int m_96, int64_t i) {
  for (;;) {
    int r_128;
    switch ((i >= sp)) {
    case 0: {
    int64_t x1_37 = copy(m_96, mhs_mem[i]);
    int r_129;
    int64_t x3_29 = x1_37;
    int x4_37 = 0;
    mhs_mem[i] = x3_29;
    int64_t t_130 = sp;
    int t_131 = 0;
    int64_t t_132 = (i + 1);
    sp = t_130;
    m_96 = t_131;
    i = t_132;
    continue;
    r_128 = r_129;
    break; }
    case 1: {
    r_128 = m_96;
    break; }
    default: abort();
    }
    return r_128;
  }
}
static int64_t gc(int m_92) {
  int64_t to = mhs_mem[3];
  int64_t sp = mhs_mem[4];
  int64_t semi = mhs_mem[5];
  mhs_mem[6] = to;
  mhs_mem[7] = to;
  int m1 = 0;
  int64_t gcs = mhs_mem[8];
  int64_t from = mhs_mem[2];
  int m2_8 = scan(roots(sp, m1, 16));
  int64_t free_1 = mhs_mem[6];
  mhs_mem[0] = free_1;
  mhs_mem[1] = (to + semi);
  mhs_mem[2] = to;
  mhs_mem[3] = from;
  mhs_mem[8] = (gcs + 1);
  return free_1;
}
static int64_t j_8(int64_t x_89, int64_t v_12, int m_124) {
  mhs_mem[(x_89 + 11)] = v_12;
  int m_125 = 0;
  int64_t x_114 = mhs_mem[(x_89 + 11)];
  int64_t x_115 = mhs_mem[x_114];
  int64_t r_143;
  switch ((x_115 == 7)) {
  case 0: {
  int64_t x_116 = mhs_mem[(x_89 + 11)];
  int64_t x_117 = mhs_mem[(x_116 + 1)];
  int64_t x_118 = mhs_mem[(x_116 + 2)];
  mhs_mem[(x_89 + 12)] = x_117;
  int m_127 = 0;
  mhs_mem[(x_89 + 13)] = x_118;
  int m_128 = 0;
  int64_t x_119 = mhs_mem[(x_89 + 13)];
  mhs_mem[4] = x_89;
  int m_129 = 0;
  int64_t x1_42 = f0(m_129, x_119, 3);
  r_143 = x1_42; break; }
  case 1: {
  int64_t x_120 = mhs_mem[(x_89 + 11)];
  int64_t x_121 = mhs_mem[(x_120 + 1)];
  r_143 = x_121; break; }
  default: abort();
  }
  return r_143;
}
static int64_t j_9(int64_t x_89, int64_t v_10, int m_117) {
  mhs_mem[(x_89 + 7)] = v_10;
  int m_118 = 0;
  int64_t x_105 = mhs_mem[(x_89 + 7)];
  int64_t x_106 = mhs_mem[x_105];
  int64_t r_138;
  switch ((x_106 == 7)) {
  case 0: {
  int64_t x_107 = mhs_mem[(x_89 + 7)];
  int64_t x_108 = mhs_mem[(x_107 + 1)];
  int64_t x_109 = mhs_mem[(x_107 + 2)];
  mhs_mem[(x_89 + 8)] = x_108;
  int m_120 = 0;
  mhs_mem[(x_89 + 9)] = x_109;
  int m_121 = 0;
  int r_139;
  switch (((x_89 + 10) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 10);
  r_139 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_139 = 0; break; }
  default: abort();
  }
  int m_122 = r_139;
  int64_t x_110 = mhs_mem[(x_89 + 9)];
  int64_t x_111 = mhs_mem[x_110];
  int64_t r_140;
  switch ((x_111 < 0)) {
  case 0: {
  int64_t x1_40 = t2(m_122, x_110);
  int64_t r_141;
  int64_t x3_32 = x1_40;
  int x4_40 = 0;
  int64_t q_3 = mhs_mem[(x_89 + 9)];
  mhs_mem[q_3] = -13;
  mhs_mem[(q_3 + 1)] = x3_32;
  r_141 = x3_32;
  r_140 = r_141; break; }
  case 1: {
  r_140 = mhs_mem[(x_110 + 1)]; break; }
  default: abort();
  }
  int64_t x1_41 = r_140;
  int64_t r_142;
  int64_t x3_33 = x1_41;
  int x4_41 = 0;
  mhs_mem[(x_89 + 10)] = x3_33;
  int m_123 = 0;
  int64_t x_112 = mhs_mem[(x_89 + 10)];
  int64_t x_113 = mhs_mem[x_112];
  int64_t r_144;
  switch ((x_113 == 8)) {
  case 0: {
  int64_t x_122 = mhs_mem[(x_89 + 10)];
  int64_t x_123 = mhs_mem[(x_122 + 1)];
  int64_t x_124 = mhs_mem[(x_122 + 2)];
  mhs_mem[(x_89 + 11)] = x_123;
  int m_130 = 0;
  mhs_mem[(x_89 + 12)] = x_124;
  int m_131 = 0;
  int r_145;
  switch (((x_89 + 13) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 13);
  r_145 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_145 = 0; break; }
  default: abort();
  }
  int m_132 = r_145;
  int64_t x_125 = mhs_mem[0];
  int64_t x_126 = mhs_mem[1];
  int64_t r_146;
  switch (((x_125 + 3) > x_126)) {
  case 0: {
  r_146 = x_125; break; }
  case 1: {
  int64_t x1_43 = gc(m_132);
  int64_t r_147;
  int64_t x3_35 = x1_43;
  int x4_43 = 0;
  int64_t r_148;
  switch (((x3_35 + 3) > mhs_mem[1])) {
  case 0: {
  r_148 = x3_35; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_148 = 0; break; }
  default: abort();
  }
  r_147 = r_148;
  r_146 = r_147; break; }
  default: abort();
  }
  int64_t x1_44 = r_146;
  int64_t r_149;
  int64_t x3_36 = x1_44;
  int x4_44 = 0;
  mhs_mem[0] = (x3_36 + 3);
  int m_133 = 0;
  mhs_mem[(x_89 + 13)] = x3_36;
  int m_134 = 0;
  mhs_mem[x3_36] = 9;
  int m_135 = 0;
  int64_t x_127 = mhs_mem[(x_89 + 11)];
  int64_t x_128 = mhs_mem[(x_89 + 12)];
  mhs_mem[(x3_36 + 1)] = x_127;
  int m_136 = 0;
  mhs_mem[(x3_36 + 2)] = x_128;
  int m_137 = 0;
  int64_t x_129 = mhs_mem[(x_89 + 13)];
  r_149 = j_8(x_89, x_129, m_137);
  r_144 = r_149; break; }
  case 1: {
  int64_t x_130 = mhs_mem[(x_89 + 10)];
  int r_150;
  switch (((x_89 + 11) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 11);
  r_150 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_150 = 0; break; }
  default: abort();
  }
  int m_138 = r_150;
  int64_t x_131 = mhs_mem[0];
  int64_t x_132 = mhs_mem[1];
  int64_t r_151;
  switch (((x_131 + 2) > x_132)) {
  case 0: {
  r_151 = x_131; break; }
  case 1: {
  int64_t x1_45 = gc(m_138);
  int64_t r_152;
  int64_t x3_37 = x1_45;
  int x4_45 = 0;
  int64_t r_153;
  switch (((x3_37 + 2) > mhs_mem[1])) {
  case 0: {
  r_153 = x3_37; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_153 = 0; break; }
  default: abort();
  }
  r_152 = r_153;
  r_151 = r_152; break; }
  default: abort();
  }
  int64_t x1_46 = r_151;
  int64_t r_154;
  int64_t x3_38 = x1_46;
  int x4_46 = 0;
  mhs_mem[0] = (x3_38 + 2);
  int m_139 = 0;
  mhs_mem[(x_89 + 11)] = x3_38;
  int m_140 = 0;
  mhs_mem[x3_38] = 7;
  int m_141 = 0;
  mhs_mem[(x3_38 + 1)] = 2;
  int m_142 = 0;
  int64_t x_133 = mhs_mem[(x_89 + 11)];
  r_154 = j_8(x_89, x_133, m_142);
  r_144 = r_154; break; }
  default: abort();
  }
  r_142 = r_144;
  r_138 = r_142; break; }
  case 1: {
  int64_t x_134 = mhs_mem[(x_89 + 7)];
  int64_t x_135 = mhs_mem[(x_134 + 1)];
  r_138 = x_135; break; }
  default: abort();
  }
  return r_138;
}
static int64_t j_10(int64_t x_89, int64_t v_8, int m_110) {
  mhs_mem[(x_89 + 3)] = v_8;
  int m_111 = 0;
  int64_t x_96 = mhs_mem[(x_89 + 3)];
  int64_t x_97 = mhs_mem[x_96];
  int64_t r_133;
  switch ((x_97 == 7)) {
  case 0: {
  int64_t x_98 = mhs_mem[(x_89 + 3)];
  int64_t x_99 = mhs_mem[(x_98 + 1)];
  int64_t x_100 = mhs_mem[(x_98 + 2)];
  mhs_mem[(x_89 + 4)] = x_99;
  int m_113 = 0;
  mhs_mem[(x_89 + 5)] = x_100;
  int m_114 = 0;
  int r_134;
  switch (((x_89 + 6) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 6);
  r_134 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_134 = 0; break; }
  default: abort();
  }
  int m_115 = r_134;
  int64_t x_101 = mhs_mem[(x_89 + 5)];
  int64_t x_102 = mhs_mem[x_101];
  int64_t r_135;
  switch ((x_102 < 0)) {
  case 0: {
  int64_t x1_38 = t2(m_115, x_101);
  int64_t r_136;
  int64_t x3_30 = x1_38;
  int x4_38 = 0;
  int64_t q_2 = mhs_mem[(x_89 + 5)];
  mhs_mem[q_2] = -13;
  mhs_mem[(q_2 + 1)] = x3_30;
  r_136 = x3_30;
  r_135 = r_136; break; }
  case 1: {
  r_135 = mhs_mem[(x_101 + 1)]; break; }
  default: abort();
  }
  int64_t x1_39 = r_135;
  int64_t r_137;
  int64_t x3_31 = x1_39;
  int x4_39 = 0;
  mhs_mem[(x_89 + 6)] = x3_31;
  int m_116 = 0;
  int64_t x_103 = mhs_mem[(x_89 + 6)];
  int64_t x_104 = mhs_mem[x_103];
  int64_t r_155;
  switch ((x_104 == 8)) {
  case 0: {
  int64_t x_136 = mhs_mem[(x_89 + 6)];
  int64_t x_137 = mhs_mem[(x_136 + 1)];
  int64_t x_138 = mhs_mem[(x_136 + 2)];
  mhs_mem[(x_89 + 7)] = x_137;
  int m_143 = 0;
  mhs_mem[(x_89 + 8)] = x_138;
  int m_144 = 0;
  int r_156;
  switch (((x_89 + 9) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 9);
  r_156 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_156 = 0; break; }
  default: abort();
  }
  int m_145 = r_156;
  int64_t x_139 = mhs_mem[0];
  int64_t x_140 = mhs_mem[1];
  int64_t r_157;
  switch (((x_139 + 3) > x_140)) {
  case 0: {
  r_157 = x_139; break; }
  case 1: {
  int64_t x1_47 = gc(m_145);
  int64_t r_158;
  int64_t x3_39 = x1_47;
  int x4_47 = 0;
  int64_t r_159;
  switch (((x3_39 + 3) > mhs_mem[1])) {
  case 0: {
  r_159 = x3_39; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_159 = 0; break; }
  default: abort();
  }
  r_158 = r_159;
  r_157 = r_158; break; }
  default: abort();
  }
  int64_t x1_48 = r_157;
  int64_t r_160;
  int64_t x3_40 = x1_48;
  int x4_48 = 0;
  mhs_mem[0] = (x3_40 + 3);
  int m_146 = 0;
  mhs_mem[(x_89 + 9)] = x3_40;
  int m_147 = 0;
  mhs_mem[x3_40] = 9;
  int m_148 = 0;
  int64_t x_141 = mhs_mem[(x_89 + 7)];
  int64_t x_142 = mhs_mem[(x_89 + 8)];
  mhs_mem[(x3_40 + 1)] = x_141;
  int m_149 = 0;
  mhs_mem[(x3_40 + 2)] = x_142;
  int m_150 = 0;
  int64_t x_143 = mhs_mem[(x_89 + 9)];
  r_160 = j_9(x_89, x_143, m_150);
  r_155 = r_160; break; }
  case 1: {
  int64_t x_144 = mhs_mem[(x_89 + 6)];
  int r_161;
  switch (((x_89 + 7) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 7);
  r_161 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_161 = 0; break; }
  default: abort();
  }
  int m_151 = r_161;
  int64_t x_145 = mhs_mem[0];
  int64_t x_146 = mhs_mem[1];
  int64_t r_162;
  switch (((x_145 + 2) > x_146)) {
  case 0: {
  r_162 = x_145; break; }
  case 1: {
  int64_t x1_49 = gc(m_151);
  int64_t r_163;
  int64_t x3_41 = x1_49;
  int x4_49 = 0;
  int64_t r_164;
  switch (((x3_41 + 2) > mhs_mem[1])) {
  case 0: {
  r_164 = x3_41; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_164 = 0; break; }
  default: abort();
  }
  r_163 = r_164;
  r_162 = r_163; break; }
  default: abort();
  }
  int64_t x1_50 = r_162;
  int64_t r_165;
  int64_t x3_42 = x1_50;
  int x4_50 = 0;
  mhs_mem[0] = (x3_42 + 2);
  int m_152 = 0;
  mhs_mem[(x_89 + 7)] = x3_42;
  int m_153 = 0;
  mhs_mem[x3_42] = 7;
  int m_154 = 0;
  mhs_mem[(x3_42 + 1)] = 1;
  int m_155 = 0;
  int64_t x_147 = mhs_mem[(x_89 + 7)];
  r_165 = j_9(x_89, x_147, m_155);
  r_155 = r_165; break; }
  default: abort();
  }
  r_137 = r_155;
  r_133 = r_137; break; }
  case 1: {
  int64_t x_148 = mhs_mem[(x_89 + 3)];
  int64_t x_149 = mhs_mem[(x_148 + 1)];
  r_133 = x_149; break; }
  default: abort();
  }
  return r_133;
}
static int64_t j_11(int64_t x_89, int64_t v_7, int m_108) {
  mhs_mem[(x_89 + 2)] = v_7;
  int m_109 = 0;
  int64_t x_94 = mhs_mem[(x_89 + 2)];
  int64_t x_95 = mhs_mem[x_94];
  int64_t r_166;
  switch ((x_95 == 8)) {
  case 0: {
  int64_t x_150 = mhs_mem[(x_89 + 2)];
  int64_t x_151 = mhs_mem[(x_150 + 1)];
  int64_t x_152 = mhs_mem[(x_150 + 2)];
  mhs_mem[(x_89 + 3)] = x_151;
  int m_156 = 0;
  mhs_mem[(x_89 + 4)] = x_152;
  int m_157 = 0;
  int r_167;
  switch (((x_89 + 5) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 5);
  r_167 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_167 = 0; break; }
  default: abort();
  }
  int m_158 = r_167;
  int64_t x_153 = mhs_mem[0];
  int64_t x_154 = mhs_mem[1];
  int64_t r_168;
  switch (((x_153 + 3) > x_154)) {
  case 0: {
  r_168 = x_153; break; }
  case 1: {
  int64_t x1_51 = gc(m_158);
  int64_t r_169;
  int64_t x3_43 = x1_51;
  int x4_51 = 0;
  int64_t r_170;
  switch (((x3_43 + 3) > mhs_mem[1])) {
  case 0: {
  r_170 = x3_43; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_170 = 0; break; }
  default: abort();
  }
  r_169 = r_170;
  r_168 = r_169; break; }
  default: abort();
  }
  int64_t x1_52 = r_168;
  int64_t r_171;
  int64_t x3_44 = x1_52;
  int x4_52 = 0;
  mhs_mem[0] = (x3_44 + 3);
  int m_159 = 0;
  mhs_mem[(x_89 + 5)] = x3_44;
  int m_160 = 0;
  mhs_mem[x3_44] = 9;
  int m_161 = 0;
  int64_t x_155 = mhs_mem[(x_89 + 3)];
  int64_t x_156 = mhs_mem[(x_89 + 4)];
  mhs_mem[(x3_44 + 1)] = x_155;
  int m_162 = 0;
  mhs_mem[(x3_44 + 2)] = x_156;
  int m_163 = 0;
  int64_t x_157 = mhs_mem[(x_89 + 5)];
  r_171 = j_10(x_89, x_157, m_163);
  r_166 = r_171; break; }
  case 1: {
  int64_t x_158 = mhs_mem[(x_89 + 2)];
  int r_172;
  switch (((x_89 + 3) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 3);
  r_172 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_172 = 0; break; }
  default: abort();
  }
  int m_164 = r_172;
  int64_t x_159 = mhs_mem[0];
  int64_t x_160 = mhs_mem[1];
  int64_t r_173;
  switch (((x_159 + 2) > x_160)) {
  case 0: {
  r_173 = x_159; break; }
  case 1: {
  int64_t x1_53 = gc(m_164);
  int64_t r_174;
  int64_t x3_45 = x1_53;
  int x4_53 = 0;
  int64_t r_175;
  switch (((x3_45 + 2) > mhs_mem[1])) {
  case 0: {
  r_175 = x3_45; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_175 = 0; break; }
  default: abort();
  }
  r_174 = r_175;
  r_173 = r_174; break; }
  default: abort();
  }
  int64_t x1_54 = r_173;
  int64_t r_176;
  int64_t x3_46 = x1_54;
  int x4_54 = 0;
  mhs_mem[0] = (x3_46 + 2);
  int m_165 = 0;
  mhs_mem[(x_89 + 3)] = x3_46;
  int m_166 = 0;
  mhs_mem[x3_46] = 7;
  int m_167 = 0;
  mhs_mem[(x3_46 + 1)] = 0;
  int m_168 = 0;
  int64_t x_161 = mhs_mem[(x_89 + 3)];
  r_176 = j_10(x_89, x_161, m_168);
  r_166 = r_176; break; }
  default: abort();
  }
  return r_166;
}
static int64_t j_12(int64_t x_89, int64_t v_6, int m_106) {
  mhs_mem[(x_89 + 1)] = v_6;
  int m_107 = 0;
  int64_t x_92 = mhs_mem[(x_89 + 1)];
  int64_t x_93 = mhs_mem[x_92];
  int64_t r_177;
  switch ((x_93 == 3)) {
  case 0: {
  int64_t x_162 = mhs_mem[(x_89 + 1)];
  int r_178;
  switch (((x_89 + 2) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 2);
  r_178 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_178 = 0; break; }
  default: abort();
  }
  int m_169 = r_178;
  int64_t x_163 = mhs_mem[0];
  int64_t x_164 = mhs_mem[1];
  int64_t r_179;
  switch (((x_163 + 2) > x_164)) {
  case 0: {
  r_179 = x_163; break; }
  case 1: {
  int64_t x1_55 = gc(m_169);
  int64_t r_180;
  int64_t x3_47 = x1_55;
  int x4_55 = 0;
  int64_t r_181;
  switch (((x3_47 + 2) > mhs_mem[1])) {
  case 0: {
  r_181 = x3_47; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_181 = 0; break; }
  default: abort();
  }
  r_180 = r_181;
  r_179 = r_180; break; }
  default: abort();
  }
  int64_t x1_56 = r_179;
  int64_t r_182;
  int64_t x3_48 = x1_56;
  int x4_56 = 0;
  mhs_mem[0] = (x3_48 + 2);
  int m_170 = 0;
  mhs_mem[(x_89 + 2)] = x3_48;
  int m_171 = 0;
  mhs_mem[x3_48] = 8;
  int m_172 = 0;
  int64_t x_165 = mhs_mem[(x_89 + 2)];
  r_182 = j_11(x_89, x_165, m_172);
  r_177 = r_182; break; }
  case 1: {
  int64_t x_166 = mhs_mem[(x_89 + 1)];
  int64_t x_167 = mhs_mem[(x_166 + 1)];
  int64_t x_168 = mhs_mem[(x_166 + 2)];
  mhs_mem[(x_89 + 2)] = x_168;
  int m_173 = 0;
  int r_183;
  switch (((x_89 + 3) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 3);
  r_183 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_183 = 0; break; }
  default: abort();
  }
  int m_174 = r_183;
  int64_t x_169 = mhs_mem[0];
  int64_t x_170 = mhs_mem[1];
  int64_t r_184;
  switch (((x_169 + 2) > x_170)) {
  case 0: {
  r_184 = x_169; break; }
  case 1: {
  int64_t x1_57 = gc(m_174);
  int64_t r_185;
  int64_t x3_49 = x1_57;
  int x4_57 = 0;
  int64_t r_186;
  switch (((x3_49 + 2) > mhs_mem[1])) {
  case 0: {
  r_186 = x3_49; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_186 = 0; break; }
  default: abort();
  }
  r_185 = r_186;
  r_184 = r_185; break; }
  default: abort();
  }
  int64_t x1_58 = r_184;
  int64_t r_187;
  int64_t x3_50 = x1_58;
  int x4_58 = 0;
  mhs_mem[0] = (x3_50 + 2);
  int m_175 = 0;
  mhs_mem[(x_89 + 3)] = x3_50;
  int m_176 = 0;
  mhs_mem[x3_50] = 12;
  int m_177 = 0;
  int64_t x_171 = mhs_mem[(x_89 + 3)];
  mhs_mem[(x_171 + 1)] = x_167;
  int m_178 = 0;
  int r_188;
  switch (((x_89 + 4) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 4);
  r_188 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_188 = 0; break; }
  default: abort();
  }
  int m_179 = r_188;
  int64_t x_172 = mhs_mem[0];
  int64_t x_173 = mhs_mem[1];
  int64_t r_189;
  switch (((x_172 + 2) > x_173)) {
  case 0: {
  r_189 = x_172; break; }
  case 1: {
  int64_t x1_59 = gc(m_179);
  int64_t r_190;
  int64_t x3_51 = x1_59;
  int x4_59 = 0;
  int64_t r_191;
  switch (((x3_51 + 2) > mhs_mem[1])) {
  case 0: {
  r_191 = x3_51; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_191 = 0; break; }
  default: abort();
  }
  r_190 = r_191;
  r_189 = r_190; break; }
  default: abort();
  }
  int64_t x1_60 = r_189;
  int64_t r_192;
  int64_t x3_52 = x1_60;
  int x4_60 = 0;
  mhs_mem[0] = (x3_52 + 2);
  int m_180 = 0;
  mhs_mem[(x_89 + 4)] = x3_52;
  int m_181 = 0;
  mhs_mem[x3_52] = 13;
  int m_182 = 0;
  int64_t x_174 = mhs_mem[(x_89 + 2)];
  int64_t x_175 = mhs_mem[(x_89 + 4)];
  mhs_mem[(x_175 + 1)] = x_174;
  int m_183 = 0;
  int r_193;
  switch (((x_89 + 5) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 5);
  r_193 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_193 = 0; break; }
  default: abort();
  }
  int m_184 = r_193;
  int64_t x_176 = mhs_mem[0];
  int64_t x_177 = mhs_mem[1];
  int64_t r_194;
  switch (((x_176 + 3) > x_177)) {
  case 0: {
  r_194 = x_176; break; }
  case 1: {
  int64_t x1_61 = gc(m_184);
  int64_t r_195;
  int64_t x3_53 = x1_61;
  int x4_61 = 0;
  int64_t r_196;
  switch (((x3_53 + 3) > mhs_mem[1])) {
  case 0: {
  r_196 = x3_53; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_196 = 0; break; }
  default: abort();
  }
  r_195 = r_196;
  r_194 = r_195; break; }
  default: abort();
  }
  int64_t x1_62 = r_194;
  int64_t r_197;
  int64_t x3_54 = x1_62;
  int x4_62 = 0;
  mhs_mem[0] = (x3_54 + 3);
  int m_185 = 0;
  mhs_mem[(x_89 + 5)] = x3_54;
  int m_186 = 0;
  mhs_mem[x3_54] = 10;
  int m_187 = 0;
  int64_t x_178 = mhs_mem[(x_89 + 3)];
  int64_t x_179 = mhs_mem[(x_89 + 4)];
  mhs_mem[(x3_54 + 1)] = x_178;
  int m_188 = 0;
  mhs_mem[(x3_54 + 2)] = x_179;
  int m_189 = 0;
  int64_t x_180 = mhs_mem[(x_89 + 5)];
  r_197 = j_11(x_89, x_180, m_189);
  r_192 = r_197;
  r_187 = r_192;
  r_177 = r_187; break; }
  default: abort();
  }
  return r_177;
}
static int64_t j_13(int64_t x_89, int64_t v_5, int m_104) {
  mhs_mem[x_89] = v_5;
  int m_105 = 0;
  int64_t x_90 = mhs_mem[x_89];
  int64_t x_91 = mhs_mem[x_90];
  int64_t r_198;
  switch ((x_91 == 4)) {
  case 0: {
  int64_t x_181 = mhs_mem[x_89];
  int r_199;
  switch (((x_89 + 1) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 1);
  r_199 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_199 = 0; break; }
  default: abort();
  }
  int m_190 = r_199;
  int64_t x_182 = mhs_mem[0];
  int64_t x_183 = mhs_mem[1];
  int64_t r_200;
  switch (((x_182 + 2) > x_183)) {
  case 0: {
  r_200 = x_182; break; }
  case 1: {
  int64_t x1_63 = gc(m_190);
  int64_t r_201;
  int64_t x3_55 = x1_63;
  int x4_63 = 0;
  int64_t r_202;
  switch (((x3_55 + 2) > mhs_mem[1])) {
  case 0: {
  r_202 = x3_55; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_202 = 0; break; }
  default: abort();
  }
  r_201 = r_202;
  r_200 = r_201; break; }
  default: abort();
  }
  int64_t x1_64 = r_200;
  int64_t r_203;
  int64_t x3_56 = x1_64;
  int x4_64 = 0;
  mhs_mem[0] = (x3_56 + 2);
  int m_191 = 0;
  mhs_mem[(x_89 + 1)] = x3_56;
  int m_192 = 0;
  mhs_mem[x3_56] = 5;
  int m_193 = 0;
  int64_t x_184 = mhs_mem[(x_89 + 1)];
  r_203 = j_12(x_89, x_184, m_193);
  r_198 = r_203; break; }
  case 1: {
  int64_t x_185 = mhs_mem[x_89];
  int64_t x_186 = mhs_mem[(x_185 + 1)];
  int64_t x_187 = mhs_mem[(x_185 + 2)];
  mhs_mem[(x_89 + 1)] = x_187;
  int m_194 = 0;
  int r_204;
  switch (((x_89 + 2) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 2);
  r_204 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_204 = 0; break; }
  default: abort();
  }
  int m_195 = r_204;
  int64_t x_188 = mhs_mem[0];
  int64_t x_189 = mhs_mem[1];
  int64_t r_205;
  switch (((x_188 + 3) > x_189)) {
  case 0: {
  r_205 = x_188; break; }
  case 1: {
  int64_t x1_65 = gc(m_195);
  int64_t r_206;
  int64_t x3_57 = x1_65;
  int x4_65 = 0;
  int64_t r_207;
  switch (((x3_57 + 3) > mhs_mem[1])) {
  case 0: {
  r_207 = x3_57; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_207 = 0; break; }
  default: abort();
  }
  r_206 = r_207;
  r_205 = r_206; break; }
  default: abort();
  }
  int64_t x1_66 = r_205;
  int64_t r_208;
  int64_t x3_58 = x1_66;
  int x4_66 = 0;
  mhs_mem[0] = (x3_58 + 3);
  int m_196 = 0;
  mhs_mem[(x_89 + 2)] = x3_58;
  int m_197 = 0;
  mhs_mem[x3_58] = 3;
  int m_198 = 0;
  int64_t x_190 = mhs_mem[(x_89 + 1)];
  mhs_mem[(x3_58 + 1)] = x_186;
  int m_199 = 0;
  mhs_mem[(x3_58 + 2)] = x_190;
  int m_200 = 0;
  int64_t x_191 = mhs_mem[(x_89 + 2)];
  r_208 = j_12(x_89, x_191, m_200);
  r_198 = r_208; break; }
  default: abort();
  }
  return r_198;
}

int64_t count(int m, int64_t n) {
  mhs_mem[2] = 2064;
  int m_97 = 0;
  mhs_mem[3] = 5128;
  int m_98 = 0;
  mhs_mem[5] = 3064;
  int m_99 = 0;
  mhs_mem[0] = 2064;
  int m_100 = 0;
  mhs_mem[1] = 5128;
  int m_101 = 0;
  mhs_mem[4] = 16;
  int m_102 = 0;
  mhs_mem[8] = 0;
  int m_103 = 0;
  int64_t x_89 = mhs_mem[4];
  int b_1 = (1 > n);
  int64_t r_209;
  switch (b_1) {
  case 0: {
  int r_210;
  switch ((x_89 > 2064)) {
  case 0: {
  mhs_mem[4] = x_89;
  r_210 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_210 = 0; break; }
  default: abort();
  }
  int m_201 = r_210;
  int64_t x_192 = mhs_mem[0];
  int64_t x_193 = mhs_mem[1];
  int64_t r_211;
  switch (((x_192 + 3) > x_193)) {
  case 0: {
  r_211 = x_192; break; }
  case 1: {
  int64_t x1_67 = gc(m_201);
  int64_t r_212;
  int64_t x3_59 = x1_67;
  int x4_67 = 0;
  int64_t r_213;
  switch (((x3_59 + 3) > mhs_mem[1])) {
  case 0: {
  r_213 = x3_59; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_213 = 0; break; }
  default: abort();
  }
  r_212 = r_213;
  r_211 = r_212; break; }
  default: abort();
  }
  int64_t x1_68 = r_211;
  int64_t r_214;
  int64_t x3_60 = x1_68;
  int x4_68 = 0;
  mhs_mem[0] = (x3_60 + 3);
  int m_202 = 0;
  mhs_mem[x_89] = x3_60;
  int m_203 = 0;
  mhs_mem[x3_60] = 11;
  int m_204 = 0;
  int64_t x_194 = mhs_mem[x_89];
  mhs_mem[(x_194 + 1)] = 1;
  int m_205 = 0;
  mhs_mem[(x_194 + 2)] = n;
  int m_206 = 0;
  int r_215;
  switch (((x_89 + 1) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 1);
  r_215 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_215 = 0; break; }
  default: abort();
  }
  int m_207 = r_215;
  int64_t x_195 = mhs_mem[0];
  int64_t x_196 = mhs_mem[1];
  int64_t r_216;
  switch (((x_195 + 3) > x_196)) {
  case 0: {
  r_216 = x_195; break; }
  case 1: {
  int64_t x1_69 = gc(m_207);
  int64_t r_217;
  int64_t x3_61 = x1_69;
  int x4_69 = 0;
  int64_t r_218;
  switch (((x3_61 + 3) > mhs_mem[1])) {
  case 0: {
  r_218 = x3_61; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_218 = 0; break; }
  default: abort();
  }
  r_217 = r_218;
  r_216 = r_217; break; }
  default: abort();
  }
  int64_t x1_70 = r_216;
  int64_t r_219;
  int64_t x3_62 = x1_70;
  int x4_70 = 0;
  mhs_mem[0] = (x3_62 + 3);
  int m_208 = 0;
  mhs_mem[(x_89 + 1)] = x3_62;
  int m_209 = 0;
  mhs_mem[x3_62] = 4;
  int m_210 = 0;
  int64_t x_197 = mhs_mem[x_89];
  mhs_mem[(x3_62 + 1)] = 1;
  int m_211 = 0;
  mhs_mem[(x3_62 + 2)] = x_197;
  int m_212 = 0;
  int64_t x_198 = mhs_mem[(x_89 + 1)];
  r_219 = j_13(x_89, x_198, m_212);
  r_214 = r_219;
  r_209 = r_214; break; }
  case 1: {
  int r_220;
  switch ((x_89 > 2064)) {
  case 0: {
  mhs_mem[4] = x_89;
  r_220 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_220 = 0; break; }
  default: abort();
  }
  int m_213 = r_220;
  int64_t x_199 = mhs_mem[0];
  int64_t x_200 = mhs_mem[1];
  int64_t r_221;
  switch (((x_199 + 2) > x_200)) {
  case 0: {
  r_221 = x_199; break; }
  case 1: {
  int64_t x1_71 = gc(m_213);
  int64_t r_222;
  int64_t x3_63 = x1_71;
  int x4_71 = 0;
  int64_t r_223;
  switch (((x3_63 + 2) > mhs_mem[1])) {
  case 0: {
  r_223 = x3_63; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_223 = 0; break; }
  default: abort();
  }
  r_222 = r_223;
  r_221 = r_222; break; }
  default: abort();
  }
  int64_t x1_72 = r_221;
  int64_t r_224;
  int64_t x3_64 = x1_72;
  int x4_72 = 0;
  mhs_mem[0] = (x3_64 + 2);
  int m_214 = 0;
  mhs_mem[x_89] = x3_64;
  int m_215 = 0;
  mhs_mem[x3_64] = 6;
  int m_216 = 0;
  int64_t x_201 = mhs_mem[x_89];
  r_224 = j_13(x_89, x_201, m_216);
  r_209 = r_224; break; }
  default: abort();
  }
  int64_t x1_73 = r_209;
  int64_t r_225;
  int64_t x3_65 = x1_73;
  int x4_73 = 0;
  r_225 = x3_65;
  return r_225;
}
int main(int argc, char **argv) {
  for (int i = 1; i < argc; i++) {
    printf("%lld\n", (long long)count(0, atoll(argv[i])));
    fprintf(stderr, "%s %s: %lld collections\n", "count", argv[i], (long long)mhs_mem[8]);
  }
  return 0;
}
