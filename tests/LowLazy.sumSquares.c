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
static int64_t t0(int m_26, int64_t p_1);
static int64_t t1(int m_46, int64_t p_2);
static int64_t t2(int m_53, int64_t p_3);
static int64_t gc(int m_94);
static int64_t j_1(int64_t x, int64_t v, int m_3) {
  mhs_mem[(x + 1)] = v;
  int m_4 = 0;
  int64_t x_3 = mhs_mem[(x + 1)];
  int64_t x_4 = mhs_mem[x_3];
  int64_t r_0;
  switch ((x_4 == 7)) {
  case 0: {
  int64_t x_5 = mhs_mem[(x + 1)];
  int64_t x_6 = mhs_mem[(x_5 + 1)];
  int64_t x_7 = mhs_mem[(x_5 + 2)];
  mhs_mem[(x + 2)] = x_6;
  int m_6 = 0;
  mhs_mem[(x + 3)] = x_7;
  int m_7 = 0;
  int r_1;
  switch (((x + 4) > 2064)) {
  case 0: {
  mhs_mem[4] = (x + 4);
  r_1 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_1 = 0; break; }
  default: abort();
  }
  int m_8 = r_1;
  int64_t x_8 = mhs_mem[(x + 3)];
  int64_t x_9 = mhs_mem[x_8];
  int64_t r_2;
  switch ((x_9 < 0)) {
  case 0: {
  int64_t x1 = t2(m_8, x_8);
  int64_t r_3;
  int64_t x3 = x1;
  int x4 = 0;
  int64_t q = mhs_mem[(x + 3)];
  mhs_mem[q] = -13;
  mhs_mem[(q + 1)] = x3;
  r_3 = x3;
  r_2 = r_3; break; }
  case 1: {
  r_2 = mhs_mem[(x_8 + 1)]; break; }
  default: abort();
  }
  int64_t x1_1 = r_2;
  int64_t r_4;
  int64_t x3_1 = x1_1;
  int x4_1 = 0;
  mhs_mem[(x + 4)] = x3_1;
  int m_9 = 0;
  int64_t x_10 = mhs_mem[(x + 4)];
  int r_5;
  switch (((x + 5) > 2064)) {
  case 0: {
  mhs_mem[4] = (x + 5);
  r_5 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_5 = 0; break; }
  default: abort();
  }
  int m_10 = r_5;
  int64_t x1_2 = f0(m_10, x_10);
  int64_t r_6;
  int64_t x3_2 = x1_2;
  int x4_2 = 0;
  int r_7;
  switch (((x + 5) > 2064)) {
  case 0: {
  mhs_mem[4] = (x + 5);
  r_7 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_7 = 0; break; }
  default: abort();
  }
  int m_11 = r_7;
  int64_t x_11 = mhs_mem[(x + 2)];
  int64_t x_12 = mhs_mem[x_11];
  int64_t r_8;
  switch ((x_12 < 0)) {
  case 0: {
  int64_t x1_3 = t1(m_11, x_11);
  int64_t r_9;
  int64_t x3_3 = x1_3;
  int x4_3 = 0;
  int64_t q_1 = mhs_mem[(x + 2)];
  mhs_mem[q_1] = -12;
  mhs_mem[(q_1 + 1)] = x3_3;
  r_9 = x3_3;
  r_8 = r_9; break; }
  case 1: {
  r_8 = mhs_mem[(x_11 + 1)]; break; }
  default: abort();
  }
  int64_t x1_4 = r_8;
  int64_t r_10;
  int64_t x3_4 = x1_4;
  int x4_4 = 0;
  mhs_mem[(x + 5)] = x3_4;
  int m_12 = 0;
  int64_t x_13 = mhs_mem[(x + 5)];
  int64_t x_14 = mhs_mem[(x_13 + 1)];
  int64_t x_15 = (x_14 + x3_2);
  r_10 = x_15;
  r_6 = r_10;
  r_4 = r_6;
  r_0 = r_4; break; }
  case 1: {
  int64_t x_16 = mhs_mem[(x + 1)];
  int64_t x_17 = mhs_mem[(x_16 + 1)];
  r_0 = x_17; break; }
  default: abort();
  }
  return r_0;
}
static int64_t f0(int m_1, int64_t p) {
  int64_t x = mhs_mem[4];
  mhs_mem[x] = p;
  int m_2 = 0;
  int64_t x_1 = mhs_mem[x];
  int64_t x_2 = mhs_mem[x_1];
  int64_t r_11;
  switch ((x_2 == 8)) {
  case 0: {
  int64_t x_18 = mhs_mem[x];
  int64_t x_19 = mhs_mem[(x_18 + 1)];
  int64_t x_20 = mhs_mem[(x_18 + 2)];
  mhs_mem[(x + 1)] = x_19;
  int m_13 = 0;
  mhs_mem[(x + 2)] = x_20;
  int m_14 = 0;
  int r_12;
  switch (((x + 3) > 2064)) {
  case 0: {
  mhs_mem[4] = (x + 3);
  r_12 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_12 = 0; break; }
  default: abort();
  }
  int m_15 = r_12;
  int64_t x_21 = mhs_mem[0];
  int64_t x_22 = mhs_mem[1];
  int64_t r_13;
  switch (((x_21 + 3) > x_22)) {
  case 0: {
  r_13 = x_21; break; }
  case 1: {
  int64_t x1_5 = gc(m_15);
  int64_t r_14;
  int64_t x3_5 = x1_5;
  int x4_5 = 0;
  int64_t r_15;
  switch (((x3_5 + 3) > mhs_mem[1])) {
  case 0: {
  r_15 = x3_5; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_15 = 0; break; }
  default: abort();
  }
  r_14 = r_15;
  r_13 = r_14; break; }
  default: abort();
  }
  int64_t x1_6 = r_13;
  int64_t r_16;
  int64_t x3_6 = x1_6;
  int x4_6 = 0;
  mhs_mem[0] = (x3_6 + 3);
  int m_16 = 0;
  mhs_mem[(x + 3)] = x3_6;
  int m_17 = 0;
  mhs_mem[x3_6] = 9;
  int m_18 = 0;
  int64_t x_23 = mhs_mem[(x + 1)];
  int64_t x_24 = mhs_mem[(x + 2)];
  mhs_mem[(x3_6 + 1)] = x_23;
  int m_19 = 0;
  mhs_mem[(x3_6 + 2)] = x_24;
  int m_20 = 0;
  int64_t x_25 = mhs_mem[(x + 3)];
  r_16 = j_1(x, x_25, m_20);
  r_11 = r_16; break; }
  case 1: {
  int64_t x_26 = mhs_mem[x];
  int r_17;
  switch (((x + 1) > 2064)) {
  case 0: {
  mhs_mem[4] = (x + 1);
  r_17 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_17 = 0; break; }
  default: abort();
  }
  int m_21 = r_17;
  int64_t x_27 = mhs_mem[0];
  int64_t x_28 = mhs_mem[1];
  int64_t r_18;
  switch (((x_27 + 2) > x_28)) {
  case 0: {
  r_18 = x_27; break; }
  case 1: {
  int64_t x1_7 = gc(m_21);
  int64_t r_19;
  int64_t x3_7 = x1_7;
  int x4_7 = 0;
  int64_t r_20;
  switch (((x3_7 + 2) > mhs_mem[1])) {
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
  mhs_mem[0] = (x3_8 + 2);
  int m_22 = 0;
  mhs_mem[(x + 1)] = x3_8;
  int m_23 = 0;
  mhs_mem[x3_8] = 7;
  int m_24 = 0;
  mhs_mem[(x3_8 + 1)] = 0;
  int m_25 = 0;
  int64_t x_29 = mhs_mem[(x + 1)];
  r_21 = j_1(x, x_29, m_25);
  r_11 = r_21; break; }
  default: abort();
  }
  return r_11;
}
static int64_t j_2(int64_t x_30, int64_t v_2, int m_28) {
  mhs_mem[(x_30 + 1)] = v_2;
  int m_29 = 0;
  int64_t x_35 = mhs_mem[(x_30 + 1)];
  return x_35;
}
static int64_t t0(int m_26, int64_t p_1) {
  int64_t x_30 = mhs_mem[4];
  mhs_mem[x_30] = p_1;
  int m_27 = 0;
  int64_t x_31 = mhs_mem[x_30];
  int64_t x_32 = mhs_mem[(x_31 + 1)];
  int64_t x_33 = mhs_mem[(x_31 + 2)];
  int64_t x_34 = (x_32 + 1);
  int b = (x_34 > x_33);
  int64_t r_22;
  switch (b) {
  case 0: {
  int r_23;
  switch (((x_30 + 1) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_30 + 1);
  r_23 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_23 = 0; break; }
  default: abort();
  }
  int m_30 = r_23;
  int64_t x_36 = mhs_mem[0];
  int64_t x_37 = mhs_mem[1];
  int64_t r_24;
  switch (((x_36 + 3) > x_37)) {
  case 0: {
  r_24 = x_36; break; }
  case 1: {
  int64_t x1_9 = gc(m_30);
  int64_t r_25;
  int64_t x3_9 = x1_9;
  int x4_9 = 0;
  int64_t r_26;
  switch (((x3_9 + 3) > mhs_mem[1])) {
  case 0: {
  r_26 = x3_9; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_26 = 0; break; }
  default: abort();
  }
  r_25 = r_26;
  r_24 = r_25; break; }
  default: abort();
  }
  int64_t x1_10 = r_24;
  int64_t r_27;
  int64_t x3_10 = x1_10;
  int x4_10 = 0;
  mhs_mem[0] = (x3_10 + 3);
  int m_31 = 0;
  mhs_mem[(x_30 + 1)] = x3_10;
  int m_32 = 0;
  mhs_mem[x3_10] = 11;
  int m_33 = 0;
  int64_t x_38 = mhs_mem[(x_30 + 1)];
  mhs_mem[(x_38 + 1)] = x_34;
  int m_34 = 0;
  mhs_mem[(x_38 + 2)] = x_33;
  int m_35 = 0;
  int r_28;
  switch (((x_30 + 2) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_30 + 2);
  r_28 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_28 = 0; break; }
  default: abort();
  }
  int m_36 = r_28;
  int64_t x_39 = mhs_mem[0];
  int64_t x_40 = mhs_mem[1];
  int64_t r_29;
  switch (((x_39 + 3) > x_40)) {
  case 0: {
  r_29 = x_39; break; }
  case 1: {
  int64_t x1_11 = gc(m_36);
  int64_t r_30;
  int64_t x3_11 = x1_11;
  int x4_11 = 0;
  int64_t r_31;
  switch (((x3_11 + 3) > mhs_mem[1])) {
  case 0: {
  r_31 = x3_11; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_31 = 0; break; }
  default: abort();
  }
  r_30 = r_31;
  r_29 = r_30; break; }
  default: abort();
  }
  int64_t x1_12 = r_29;
  int64_t r_32;
  int64_t x3_12 = x1_12;
  int x4_12 = 0;
  mhs_mem[0] = (x3_12 + 3);
  int m_37 = 0;
  mhs_mem[(x_30 + 2)] = x3_12;
  int m_38 = 0;
  mhs_mem[x3_12] = 4;
  int m_39 = 0;
  int64_t x_41 = mhs_mem[(x_30 + 1)];
  mhs_mem[(x3_12 + 1)] = x_34;
  int m_40 = 0;
  mhs_mem[(x3_12 + 2)] = x_41;
  int m_41 = 0;
  int64_t x_42 = mhs_mem[(x_30 + 2)];
  r_32 = j_2(x_30, x_42, m_41);
  r_27 = r_32;
  r_22 = r_27; break; }
  case 1: {
  int r_33;
  switch (((x_30 + 1) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_30 + 1);
  r_33 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_33 = 0; break; }
  default: abort();
  }
  int m_42 = r_33;
  int64_t x_43 = mhs_mem[0];
  int64_t x_44 = mhs_mem[1];
  int64_t r_34;
  switch (((x_43 + 2) > x_44)) {
  case 0: {
  r_34 = x_43; break; }
  case 1: {
  int64_t x1_13 = gc(m_42);
  int64_t r_35;
  int64_t x3_13 = x1_13;
  int x4_13 = 0;
  int64_t r_36;
  switch (((x3_13 + 2) > mhs_mem[1])) {
  case 0: {
  r_36 = x3_13; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_36 = 0; break; }
  default: abort();
  }
  r_35 = r_36;
  r_34 = r_35; break; }
  default: abort();
  }
  int64_t x1_14 = r_34;
  int64_t r_37;
  int64_t x3_14 = x1_14;
  int x4_14 = 0;
  mhs_mem[0] = (x3_14 + 2);
  int m_43 = 0;
  mhs_mem[(x_30 + 1)] = x3_14;
  int m_44 = 0;
  mhs_mem[x3_14] = 6;
  int m_45 = 0;
  int64_t x_45 = mhs_mem[(x_30 + 1)];
  r_37 = j_2(x_30, x_45, m_45);
  r_22 = r_37; break; }
  default: abort();
  }
  return r_22;
}
static int64_t t1(int m_46, int64_t p_2) {
  int64_t x_46 = mhs_mem[4];
  mhs_mem[x_46] = p_2;
  int m_47 = 0;
  int64_t x_47 = mhs_mem[x_46];
  int64_t x_48 = mhs_mem[(x_47 + 1)];
  int64_t x_49 = (x_48 * x_48);
  int r_38;
  switch (((x_46 + 1) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_46 + 1);
  r_38 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_38 = 0; break; }
  default: abort();
  }
  int m_48 = r_38;
  int64_t x_50 = mhs_mem[0];
  int64_t x_51 = mhs_mem[1];
  int64_t r_39;
  switch (((x_50 + 2) > x_51)) {
  case 0: {
  r_39 = x_50; break; }
  case 1: {
  int64_t x1_15 = gc(m_48);
  int64_t r_40;
  int64_t x3_15 = x1_15;
  int x4_15 = 0;
  int64_t r_41;
  switch (((x3_15 + 2) > mhs_mem[1])) {
  case 0: {
  r_41 = x3_15; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_41 = 0; break; }
  default: abort();
  }
  r_40 = r_41;
  r_39 = r_40; break; }
  default: abort();
  }
  int64_t x1_16 = r_39;
  int64_t r_42;
  int64_t x3_16 = x1_16;
  int x4_16 = 0;
  mhs_mem[0] = (x3_16 + 2);
  int m_49 = 0;
  mhs_mem[(x_46 + 1)] = x3_16;
  int m_50 = 0;
  mhs_mem[x3_16] = 2;
  int m_51 = 0;
  mhs_mem[(x3_16 + 1)] = x_49;
  int m_52 = 0;
  int64_t x_52 = mhs_mem[(x_46 + 1)];
  r_42 = x_52;
  return r_42;
}
static int64_t j_3(int64_t x_53, int64_t v_4, int m_60) {
  mhs_mem[(x_53 + 4)] = v_4;
  int m_61 = 0;
  int64_t x_62 = mhs_mem[(x_53 + 4)];
  return x_62;
}
static int64_t j_4(int64_t x_53, int64_t v_3, int m_58) {
  mhs_mem[(x_53 + 3)] = v_3;
  int m_59 = 0;
  int64_t x_60 = mhs_mem[(x_53 + 3)];
  int64_t x_61 = mhs_mem[x_60];
  int64_t r_47;
  switch ((x_61 == 3)) {
  case 0: {
  int64_t x_63 = mhs_mem[(x_53 + 3)];
  int r_48;
  switch (((x_53 + 4) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_53 + 4);
  r_48 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_48 = 0; break; }
  default: abort();
  }
  int m_62 = r_48;
  int64_t x_64 = mhs_mem[0];
  int64_t x_65 = mhs_mem[1];
  int64_t r_49;
  switch (((x_64 + 2) > x_65)) {
  case 0: {
  r_49 = x_64; break; }
  case 1: {
  int64_t x1_19 = gc(m_62);
  int64_t r_50;
  int64_t x3_19 = x1_19;
  int x4_19 = 0;
  int64_t r_51;
  switch (((x3_19 + 2) > mhs_mem[1])) {
  case 0: {
  r_51 = x3_19; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_51 = 0; break; }
  default: abort();
  }
  r_50 = r_51;
  r_49 = r_50; break; }
  default: abort();
  }
  int64_t x1_20 = r_49;
  int64_t r_52;
  int64_t x3_20 = x1_20;
  int x4_20 = 0;
  mhs_mem[0] = (x3_20 + 2);
  int m_63 = 0;
  mhs_mem[(x_53 + 4)] = x3_20;
  int m_64 = 0;
  mhs_mem[x3_20] = 8;
  int m_65 = 0;
  int64_t x_66 = mhs_mem[(x_53 + 4)];
  r_52 = j_3(x_53, x_66, m_65);
  r_47 = r_52; break; }
  case 1: {
  int64_t x_67 = mhs_mem[(x_53 + 3)];
  int64_t x_68 = mhs_mem[(x_67 + 1)];
  int64_t x_69 = mhs_mem[(x_67 + 2)];
  mhs_mem[(x_53 + 4)] = x_69;
  int m_66 = 0;
  int r_53;
  switch (((x_53 + 5) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_53 + 5);
  r_53 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_53 = 0; break; }
  default: abort();
  }
  int m_67 = r_53;
  int64_t x_70 = mhs_mem[0];
  int64_t x_71 = mhs_mem[1];
  int64_t r_54;
  switch (((x_70 + 2) > x_71)) {
  case 0: {
  r_54 = x_70; break; }
  case 1: {
  int64_t x1_21 = gc(m_67);
  int64_t r_55;
  int64_t x3_21 = x1_21;
  int x4_21 = 0;
  int64_t r_56;
  switch (((x3_21 + 2) > mhs_mem[1])) {
  case 0: {
  r_56 = x3_21; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_56 = 0; break; }
  default: abort();
  }
  r_55 = r_56;
  r_54 = r_55; break; }
  default: abort();
  }
  int64_t x1_22 = r_54;
  int64_t r_57;
  int64_t x3_22 = x1_22;
  int x4_22 = 0;
  mhs_mem[0] = (x3_22 + 2);
  int m_68 = 0;
  mhs_mem[(x_53 + 5)] = x3_22;
  int m_69 = 0;
  mhs_mem[x3_22] = 12;
  int m_70 = 0;
  int64_t x_72 = mhs_mem[(x_53 + 5)];
  mhs_mem[(x_72 + 1)] = x_68;
  int m_71 = 0;
  int r_58;
  switch (((x_53 + 6) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_53 + 6);
  r_58 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_58 = 0; break; }
  default: abort();
  }
  int m_72 = r_58;
  int64_t x_73 = mhs_mem[0];
  int64_t x_74 = mhs_mem[1];
  int64_t r_59;
  switch (((x_73 + 2) > x_74)) {
  case 0: {
  r_59 = x_73; break; }
  case 1: {
  int64_t x1_23 = gc(m_72);
  int64_t r_60;
  int64_t x3_23 = x1_23;
  int x4_23 = 0;
  int64_t r_61;
  switch (((x3_23 + 2) > mhs_mem[1])) {
  case 0: {
  r_61 = x3_23; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_61 = 0; break; }
  default: abort();
  }
  r_60 = r_61;
  r_59 = r_60; break; }
  default: abort();
  }
  int64_t x1_24 = r_59;
  int64_t r_62;
  int64_t x3_24 = x1_24;
  int x4_24 = 0;
  mhs_mem[0] = (x3_24 + 2);
  int m_73 = 0;
  mhs_mem[(x_53 + 6)] = x3_24;
  int m_74 = 0;
  mhs_mem[x3_24] = 13;
  int m_75 = 0;
  int64_t x_75 = mhs_mem[(x_53 + 4)];
  int64_t x_76 = mhs_mem[(x_53 + 6)];
  mhs_mem[(x_76 + 1)] = x_75;
  int m_76 = 0;
  int r_63;
  switch (((x_53 + 7) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_53 + 7);
  r_63 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_63 = 0; break; }
  default: abort();
  }
  int m_77 = r_63;
  int64_t x_77 = mhs_mem[0];
  int64_t x_78 = mhs_mem[1];
  int64_t r_64;
  switch (((x_77 + 3) > x_78)) {
  case 0: {
  r_64 = x_77; break; }
  case 1: {
  int64_t x1_25 = gc(m_77);
  int64_t r_65;
  int64_t x3_25 = x1_25;
  int x4_25 = 0;
  int64_t r_66;
  switch (((x3_25 + 3) > mhs_mem[1])) {
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
  mhs_mem[0] = (x3_26 + 3);
  int m_78 = 0;
  mhs_mem[(x_53 + 7)] = x3_26;
  int m_79 = 0;
  mhs_mem[x3_26] = 10;
  int m_80 = 0;
  int64_t x_79 = mhs_mem[(x_53 + 5)];
  int64_t x_80 = mhs_mem[(x_53 + 6)];
  mhs_mem[(x3_26 + 1)] = x_79;
  int m_81 = 0;
  mhs_mem[(x3_26 + 2)] = x_80;
  int m_82 = 0;
  int64_t x_81 = mhs_mem[(x_53 + 7)];
  r_67 = j_3(x_53, x_81, m_82);
  r_62 = r_67;
  r_57 = r_62;
  r_47 = r_57; break; }
  default: abort();
  }
  return r_47;
}
static int64_t t2(int m_53, int64_t p_3) {
  int64_t x_53 = mhs_mem[4];
  mhs_mem[x_53] = p_3;
  int m_54 = 0;
  int64_t x_54 = mhs_mem[x_53];
  int64_t x_55 = mhs_mem[(x_54 + 1)];
  mhs_mem[(x_53 + 1)] = x_55;
  int m_55 = 0;
  int r_43;
  switch (((x_53 + 2) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_53 + 2);
  r_43 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_43 = 0; break; }
  default: abort();
  }
  int m_56 = r_43;
  int64_t x_56 = mhs_mem[(x_53 + 1)];
  int64_t x_57 = mhs_mem[x_56];
  int64_t r_44;
  switch ((x_57 < 0)) {
  case 0: {
  int64_t x1_17 = t0(m_56, x_56);
  int64_t r_45;
  int64_t x3_17 = x1_17;
  int x4_17 = 0;
  int64_t q_2 = mhs_mem[(x_53 + 1)];
  mhs_mem[q_2] = -11;
  mhs_mem[(q_2 + 1)] = x3_17;
  r_45 = x3_17;
  r_44 = r_45; break; }
  case 1: {
  r_44 = mhs_mem[(x_56 + 1)]; break; }
  default: abort();
  }
  int64_t x1_18 = r_44;
  int64_t r_46;
  int64_t x3_18 = x1_18;
  int x4_18 = 0;
  mhs_mem[(x_53 + 2)] = x3_18;
  int m_57 = 0;
  int64_t x_58 = mhs_mem[(x_53 + 2)];
  int64_t x_59 = mhs_mem[x_58];
  int64_t r_68;
  switch ((x_59 == 4)) {
  case 0: {
  int64_t x_82 = mhs_mem[(x_53 + 2)];
  int r_69;
  switch (((x_53 + 3) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_53 + 3);
  r_69 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_69 = 0; break; }
  default: abort();
  }
  int m_83 = r_69;
  int64_t x_83 = mhs_mem[0];
  int64_t x_84 = mhs_mem[1];
  int64_t r_70;
  switch (((x_83 + 2) > x_84)) {
  case 0: {
  r_70 = x_83; break; }
  case 1: {
  int64_t x1_27 = gc(m_83);
  int64_t r_71;
  int64_t x3_27 = x1_27;
  int x4_27 = 0;
  int64_t r_72;
  switch (((x3_27 + 2) > mhs_mem[1])) {
  case 0: {
  r_72 = x3_27; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_72 = 0; break; }
  default: abort();
  }
  r_71 = r_72;
  r_70 = r_71; break; }
  default: abort();
  }
  int64_t x1_28 = r_70;
  int64_t r_73;
  int64_t x3_28 = x1_28;
  int x4_28 = 0;
  mhs_mem[0] = (x3_28 + 2);
  int m_84 = 0;
  mhs_mem[(x_53 + 3)] = x3_28;
  int m_85 = 0;
  mhs_mem[x3_28] = 5;
  int m_86 = 0;
  int64_t x_85 = mhs_mem[(x_53 + 3)];
  r_73 = j_4(x_53, x_85, m_86);
  r_68 = r_73; break; }
  case 1: {
  int64_t x_86 = mhs_mem[(x_53 + 2)];
  int64_t x_87 = mhs_mem[(x_86 + 1)];
  int64_t x_88 = mhs_mem[(x_86 + 2)];
  mhs_mem[(x_53 + 3)] = x_88;
  int m_87 = 0;
  int r_74;
  switch (((x_53 + 4) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_53 + 4);
  r_74 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_74 = 0; break; }
  default: abort();
  }
  int m_88 = r_74;
  int64_t x_89 = mhs_mem[0];
  int64_t x_90 = mhs_mem[1];
  int64_t r_75;
  switch (((x_89 + 3) > x_90)) {
  case 0: {
  r_75 = x_89; break; }
  case 1: {
  int64_t x1_29 = gc(m_88);
  int64_t r_76;
  int64_t x3_29 = x1_29;
  int x4_29 = 0;
  int64_t r_77;
  switch (((x3_29 + 3) > mhs_mem[1])) {
  case 0: {
  r_77 = x3_29; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_77 = 0; break; }
  default: abort();
  }
  r_76 = r_77;
  r_75 = r_76; break; }
  default: abort();
  }
  int64_t x1_30 = r_75;
  int64_t r_78;
  int64_t x3_30 = x1_30;
  int x4_30 = 0;
  mhs_mem[0] = (x3_30 + 3);
  int m_89 = 0;
  mhs_mem[(x_53 + 4)] = x3_30;
  int m_90 = 0;
  mhs_mem[x3_30] = 3;
  int m_91 = 0;
  int64_t x_91 = mhs_mem[(x_53 + 3)];
  mhs_mem[(x3_30 + 1)] = x_87;
  int m_92 = 0;
  mhs_mem[(x3_30 + 2)] = x_91;
  int m_93 = 0;
  int64_t x_92 = mhs_mem[(x_53 + 4)];
  r_78 = j_4(x_53, x_92, m_93);
  r_68 = r_78; break; }
  default: abort();
  }
  r_46 = r_68;
  return r_46;
}
static int copyWords(int m_95, int64_t src, int64_t dst, int64_t n_1);
static int copyWords(int m_95, int64_t src, int64_t dst, int64_t n_1) {
  for (;;) {
    int r_79;
    switch ((n_1 == 0)) {
    case 0: {
    mhs_mem[dst] = mhs_mem[src];
    int t_80 = 0;
    int64_t t_81 = (src + 1);
    int64_t t_82 = (dst + 1);
    int64_t t_83 = (n_1 - 1);
    m_95 = t_80;
    src = t_81;
    dst = t_82;
    n_1 = t_83;
    continue;
    break; }
    case 1: {
    r_79 = m_95;
    break; }
    default: abort();
    }
    return r_79;
  }
}
static int64_t copy(int m_96, int64_t p_4) {
  int64_t t = mhs_mem[p_4];
  int64_t r_84;
  switch ((t == 0)) {
  case 0: {
  int64_t r_85;
  switch ((t < 0)) {
  case 0: {
  r_85 = t; break; }
  case 1: {
  r_85 = (0 - t); break; }
  default: abort();
  }
  int64_t u = r_85;
  int64_t r_86;
  switch ((u == 2)) {
  case 0: {
  int64_t r_87;
  switch ((u == 3)) {
  case 0: {
  int64_t r_88;
  switch ((u == 4)) {
  case 0: {
  int64_t r_89;
  switch ((u == 5)) {
  case 0: {
  int64_t r_90;
  switch ((u == 6)) {
  case 0: {
  int64_t r_91;
  switch ((u == 7)) {
  case 0: {
  int64_t r_92;
  switch ((u == 8)) {
  case 0: {
  int64_t r_93;
  switch ((u == 9)) {
  case 0: {
  int64_t r_94;
  switch ((u == 10)) {
  case 0: {
  int64_t r_95;
  switch ((u == 11)) {
  case 0: {
  int64_t r_96;
  switch ((u == 12)) {
  case 0: {
  int64_t r_97;
  switch ((u == 13)) {
  case 0: {
  r_97 = 2; break; }
  case 1: {
  r_97 = 2; break; }
  default: abort();
  }
  r_96 = r_97; break; }
  case 1: {
  r_96 = 2; break; }
  default: abort();
  }
  r_95 = r_96; break; }
  case 1: {
  r_95 = 3; break; }
  default: abort();
  }
  r_94 = r_95; break; }
  case 1: {
  r_94 = 3; break; }
  default: abort();
  }
  r_93 = r_94; break; }
  case 1: {
  r_93 = 3; break; }
  default: abort();
  }
  r_92 = r_93; break; }
  case 1: {
  r_92 = 2; break; }
  default: abort();
  }
  r_91 = r_92; break; }
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
  r_89 = 2; break; }
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
  int64_t n_2 = r_86;
  int64_t free = mhs_mem[6];
  int m1_1 = copyWords(m_96, p_4, free, n_2);
  mhs_mem[p_4] = 0;
  mhs_mem[(p_4 + 1)] = free;
  mhs_mem[6] = (free + n_2);
  r_84 = free; break; }
  case 1: {
  r_84 = mhs_mem[(p_4 + 1)]; break; }
  default: abort();
  }
  return r_84;
}
static int scan(int m_97);
static int scan(int m_97) {
  for (;;) {
    int64_t s = mhs_mem[7];
    int64_t f = mhs_mem[6];
    int r_98;
    switch ((s >= f)) {
    case 0: {
    int64_t t_1 = mhs_mem[s];
    int r_99;
    switch ((t_1 < 0)) {
    case 0: {
    int r_100;
    switch ((t_1 == 2)) {
    case 0: {
    int r_101;
    switch ((t_1 == 3)) {
    case 0: {
    int r_102;
    switch ((t_1 == 4)) {
    case 0: {
    int r_103;
    switch ((t_1 == 5)) {
    case 0: {
    int r_104;
    switch ((t_1 == 6)) {
    case 0: {
    int r_105;
    switch ((t_1 == 7)) {
    case 0: {
    int r_106;
    switch ((t_1 == 8)) {
    case 0: {
    int r_107;
    switch ((t_1 == 9)) {
    case 0: {
    int r_108;
    switch ((t_1 == 10)) {
    case 0: {
    int r_109;
    switch ((t_1 == 11)) {
    case 0: {
    int r_110;
    switch ((t_1 == 12)) {
    case 0: {
    int r_111;
    switch ((t_1 == 13)) {
    case 0: {
    r_111 = m_97; break; }
    case 1: {
    int64_t x1_31 = copy(m_97, mhs_mem[(s + 1)]);
    int r_112;
    int64_t a0_1 = x1_31;
    int x4_31 = 0;
    mhs_mem[(s + 1)] = a0_1;
    int m2 = 0;
    r_112 = m2;
    r_111 = r_112; break; }
    default: abort();
    }
    r_110 = r_111; break; }
    case 1: {
    r_110 = m_97; break; }
    default: abort();
    }
    r_109 = r_110; break; }
    case 1: {
    r_109 = m_97; break; }
    default: abort();
    }
    r_108 = r_109; break; }
    case 1: {
    int64_t x1_32 = copy(m_97, mhs_mem[(s + 1)]);
    int r_113;
    int64_t a0_3 = x1_32;
    int x4_32 = 0;
    mhs_mem[(s + 1)] = a0_3;
    int m2_1 = 0;
    int64_t x1_33 = copy(m2_1, mhs_mem[(s + 2)]);
    int r_114;
    int64_t a0_5 = x1_33;
    int x4_33 = 0;
    mhs_mem[(s + 2)] = a0_5;
    int m2_2 = 0;
    r_114 = m2_2;
    r_113 = r_114;
    r_108 = r_113; break; }
    default: abort();
    }
    r_107 = r_108; break; }
    case 1: {
    int64_t x1_34 = copy(m_97, mhs_mem[(s + 1)]);
    int r_115;
    int64_t a0_7 = x1_34;
    int x4_34 = 0;
    mhs_mem[(s + 1)] = a0_7;
    int m2_3 = 0;
    int64_t x1_35 = copy(m2_3, mhs_mem[(s + 2)]);
    int r_116;
    int64_t a0_9 = x1_35;
    int x4_35 = 0;
    mhs_mem[(s + 2)] = a0_9;
    int m2_4 = 0;
    r_116 = m2_4;
    r_115 = r_116;
    r_107 = r_115; break; }
    default: abort();
    }
    r_106 = r_107; break; }
    case 1: {
    r_106 = m_97; break; }
    default: abort();
    }
    r_105 = r_106; break; }
    case 1: {
    r_105 = m_97; break; }
    default: abort();
    }
    r_104 = r_105; break; }
    case 1: {
    r_104 = m_97; break; }
    default: abort();
    }
    r_103 = r_104; break; }
    case 1: {
    r_103 = m_97; break; }
    default: abort();
    }
    r_102 = r_103; break; }
    case 1: {
    int64_t x1_36 = copy(m_97, mhs_mem[(s + 2)]);
    int r_117;
    int64_t a0_11 = x1_36;
    int x4_36 = 0;
    mhs_mem[(s + 2)] = a0_11;
    int m2_5 = 0;
    r_117 = m2_5;
    r_102 = r_117; break; }
    default: abort();
    }
    r_101 = r_102; break; }
    case 1: {
    int64_t x1_37 = copy(m_97, mhs_mem[(s + 2)]);
    int r_118;
    int64_t a0_13 = x1_37;
    int x4_37 = 0;
    mhs_mem[(s + 2)] = a0_13;
    int m2_6 = 0;
    r_118 = m2_6;
    r_101 = r_118; break; }
    default: abort();
    }
    r_100 = r_101; break; }
    case 1: {
    r_100 = m_97; break; }
    default: abort();
    }
    r_99 = r_100; break; }
    case 1: {
    int64_t x1_38 = copy(m_97, mhs_mem[(s + 1)]);
    int r_119;
    int64_t a0_15 = x1_38;
    int x4_38 = 0;
    mhs_mem[(s + 1)] = a0_15;
    int m2_7 = 0;
    r_119 = m2_7;
    r_99 = r_119; break; }
    default: abort();
    }
    int m1_2 = r_99;
    int64_t r_120;
    switch ((t_1 < 0)) {
    case 0: {
    r_120 = t_1; break; }
    case 1: {
    r_120 = (0 - t_1); break; }
    default: abort();
    }
    int64_t u_1 = r_120;
    int64_t r_121;
    switch ((u_1 == 2)) {
    case 0: {
    int64_t r_122;
    switch ((u_1 == 3)) {
    case 0: {
    int64_t r_123;
    switch ((u_1 == 4)) {
    case 0: {
    int64_t r_124;
    switch ((u_1 == 5)) {
    case 0: {
    int64_t r_125;
    switch ((u_1 == 6)) {
    case 0: {
    int64_t r_126;
    switch ((u_1 == 7)) {
    case 0: {
    int64_t r_127;
    switch ((u_1 == 8)) {
    case 0: {
    int64_t r_128;
    switch ((u_1 == 9)) {
    case 0: {
    int64_t r_129;
    switch ((u_1 == 10)) {
    case 0: {
    int64_t r_130;
    switch ((u_1 == 11)) {
    case 0: {
    int64_t r_131;
    switch ((u_1 == 12)) {
    case 0: {
    int64_t r_132;
    switch ((u_1 == 13)) {
    case 0: {
    r_132 = 2; break; }
    case 1: {
    r_132 = 2; break; }
    default: abort();
    }
    r_131 = r_132; break; }
    case 1: {
    r_131 = 2; break; }
    default: abort();
    }
    r_130 = r_131; break; }
    case 1: {
    r_130 = 3; break; }
    default: abort();
    }
    r_129 = r_130; break; }
    case 1: {
    r_129 = 3; break; }
    default: abort();
    }
    r_128 = r_129; break; }
    case 1: {
    r_128 = 3; break; }
    default: abort();
    }
    r_127 = r_128; break; }
    case 1: {
    r_127 = 2; break; }
    default: abort();
    }
    r_126 = r_127; break; }
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
    r_124 = 2; break; }
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
    mhs_mem[7] = (s + r_121);
    int t_133 = 0;
    m_97 = t_133;
    continue;
    break; }
    case 1: {
    r_98 = m_97;
    break; }
    default: abort();
    }
    return r_98;
  }
}
static int roots(int64_t sp, int m_98, int64_t i);
static int roots(int64_t sp, int m_98, int64_t i) {
  for (;;) {
    int r_134;
    switch ((i >= sp)) {
    case 0: {
    int64_t x1_39 = copy(m_98, mhs_mem[i]);
    int r_135;
    int64_t x3_31 = x1_39;
    int x4_39 = 0;
    mhs_mem[i] = x3_31;
    int64_t t_136 = sp;
    int t_137 = 0;
    int64_t t_138 = (i + 1);
    sp = t_136;
    m_98 = t_137;
    i = t_138;
    continue;
    r_134 = r_135;
    break; }
    case 1: {
    r_134 = m_98;
    break; }
    default: abort();
    }
    return r_134;
  }
}
static int64_t gc(int m_94) {
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
static int64_t j_5(int64_t x_93, int64_t v_7, int m_110) {
  mhs_mem[(x_93 + 2)] = v_7;
  int m_111 = 0;
  int64_t x_98 = mhs_mem[(x_93 + 2)];
  mhs_mem[4] = x_93;
  int m_112 = 0;
  int64_t x1_40 = f0(m_112, x_98);
  return x1_40;
}
static int64_t j_6(int64_t x_93, int64_t v_6, int m_108) {
  mhs_mem[(x_93 + 1)] = v_6;
  int m_109 = 0;
  int64_t x_96 = mhs_mem[(x_93 + 1)];
  int64_t x_97 = mhs_mem[x_96];
  int64_t r_139;
  switch ((x_97 == 3)) {
  case 0: {
  int64_t x_99 = mhs_mem[(x_93 + 1)];
  int r_140;
  switch (((x_93 + 2) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_93 + 2);
  r_140 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_140 = 0; break; }
  default: abort();
  }
  int m_113 = r_140;
  int64_t x_100 = mhs_mem[0];
  int64_t x_101 = mhs_mem[1];
  int64_t r_141;
  switch (((x_100 + 2) > x_101)) {
  case 0: {
  r_141 = x_100; break; }
  case 1: {
  int64_t x1_41 = gc(m_113);
  int64_t r_142;
  int64_t x3_33 = x1_41;
  int x4_41 = 0;
  int64_t r_143;
  switch (((x3_33 + 2) > mhs_mem[1])) {
  case 0: {
  r_143 = x3_33; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_143 = 0; break; }
  default: abort();
  }
  r_142 = r_143;
  r_141 = r_142; break; }
  default: abort();
  }
  int64_t x1_42 = r_141;
  int64_t r_144;
  int64_t x3_34 = x1_42;
  int x4_42 = 0;
  mhs_mem[0] = (x3_34 + 2);
  int m_114 = 0;
  mhs_mem[(x_93 + 2)] = x3_34;
  int m_115 = 0;
  mhs_mem[x3_34] = 8;
  int m_116 = 0;
  int64_t x_102 = mhs_mem[(x_93 + 2)];
  r_144 = j_5(x_93, x_102, m_116);
  r_139 = r_144; break; }
  case 1: {
  int64_t x_103 = mhs_mem[(x_93 + 1)];
  int64_t x_104 = mhs_mem[(x_103 + 1)];
  int64_t x_105 = mhs_mem[(x_103 + 2)];
  mhs_mem[(x_93 + 2)] = x_105;
  int m_117 = 0;
  int r_145;
  switch (((x_93 + 3) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_93 + 3);
  r_145 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_145 = 0; break; }
  default: abort();
  }
  int m_118 = r_145;
  int64_t x_106 = mhs_mem[0];
  int64_t x_107 = mhs_mem[1];
  int64_t r_146;
  switch (((x_106 + 2) > x_107)) {
  case 0: {
  r_146 = x_106; break; }
  case 1: {
  int64_t x1_43 = gc(m_118);
  int64_t r_147;
  int64_t x3_35 = x1_43;
  int x4_43 = 0;
  int64_t r_148;
  switch (((x3_35 + 2) > mhs_mem[1])) {
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
  mhs_mem[0] = (x3_36 + 2);
  int m_119 = 0;
  mhs_mem[(x_93 + 3)] = x3_36;
  int m_120 = 0;
  mhs_mem[x3_36] = 12;
  int m_121 = 0;
  int64_t x_108 = mhs_mem[(x_93 + 3)];
  mhs_mem[(x_108 + 1)] = x_104;
  int m_122 = 0;
  int r_150;
  switch (((x_93 + 4) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_93 + 4);
  r_150 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_150 = 0; break; }
  default: abort();
  }
  int m_123 = r_150;
  int64_t x_109 = mhs_mem[0];
  int64_t x_110 = mhs_mem[1];
  int64_t r_151;
  switch (((x_109 + 2) > x_110)) {
  case 0: {
  r_151 = x_109; break; }
  case 1: {
  int64_t x1_45 = gc(m_123);
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
  int m_124 = 0;
  mhs_mem[(x_93 + 4)] = x3_38;
  int m_125 = 0;
  mhs_mem[x3_38] = 13;
  int m_126 = 0;
  int64_t x_111 = mhs_mem[(x_93 + 2)];
  int64_t x_112 = mhs_mem[(x_93 + 4)];
  mhs_mem[(x_112 + 1)] = x_111;
  int m_127 = 0;
  int r_155;
  switch (((x_93 + 5) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_93 + 5);
  r_155 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_155 = 0; break; }
  default: abort();
  }
  int m_128 = r_155;
  int64_t x_113 = mhs_mem[0];
  int64_t x_114 = mhs_mem[1];
  int64_t r_156;
  switch (((x_113 + 3) > x_114)) {
  case 0: {
  r_156 = x_113; break; }
  case 1: {
  int64_t x1_47 = gc(m_128);
  int64_t r_157;
  int64_t x3_39 = x1_47;
  int x4_47 = 0;
  int64_t r_158;
  switch (((x3_39 + 3) > mhs_mem[1])) {
  case 0: {
  r_158 = x3_39; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_158 = 0; break; }
  default: abort();
  }
  r_157 = r_158;
  r_156 = r_157; break; }
  default: abort();
  }
  int64_t x1_48 = r_156;
  int64_t r_159;
  int64_t x3_40 = x1_48;
  int x4_48 = 0;
  mhs_mem[0] = (x3_40 + 3);
  int m_129 = 0;
  mhs_mem[(x_93 + 5)] = x3_40;
  int m_130 = 0;
  mhs_mem[x3_40] = 10;
  int m_131 = 0;
  int64_t x_115 = mhs_mem[(x_93 + 3)];
  int64_t x_116 = mhs_mem[(x_93 + 4)];
  mhs_mem[(x3_40 + 1)] = x_115;
  int m_132 = 0;
  mhs_mem[(x3_40 + 2)] = x_116;
  int m_133 = 0;
  int64_t x_117 = mhs_mem[(x_93 + 5)];
  r_159 = j_5(x_93, x_117, m_133);
  r_154 = r_159;
  r_149 = r_154;
  r_139 = r_149; break; }
  default: abort();
  }
  return r_139;
}
static int64_t j_7(int64_t x_93, int64_t v_5, int m_106) {
  mhs_mem[x_93] = v_5;
  int m_107 = 0;
  int64_t x_94 = mhs_mem[x_93];
  int64_t x_95 = mhs_mem[x_94];
  int64_t r_160;
  switch ((x_95 == 4)) {
  case 0: {
  int64_t x_118 = mhs_mem[x_93];
  int r_161;
  switch (((x_93 + 1) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_93 + 1);
  r_161 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_161 = 0; break; }
  default: abort();
  }
  int m_134 = r_161;
  int64_t x_119 = mhs_mem[0];
  int64_t x_120 = mhs_mem[1];
  int64_t r_162;
  switch (((x_119 + 2) > x_120)) {
  case 0: {
  r_162 = x_119; break; }
  case 1: {
  int64_t x1_49 = gc(m_134);
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
  int m_135 = 0;
  mhs_mem[(x_93 + 1)] = x3_42;
  int m_136 = 0;
  mhs_mem[x3_42] = 5;
  int m_137 = 0;
  int64_t x_121 = mhs_mem[(x_93 + 1)];
  r_165 = j_6(x_93, x_121, m_137);
  r_160 = r_165; break; }
  case 1: {
  int64_t x_122 = mhs_mem[x_93];
  int64_t x_123 = mhs_mem[(x_122 + 1)];
  int64_t x_124 = mhs_mem[(x_122 + 2)];
  mhs_mem[(x_93 + 1)] = x_124;
  int m_138 = 0;
  int r_166;
  switch (((x_93 + 2) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_93 + 2);
  r_166 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_166 = 0; break; }
  default: abort();
  }
  int m_139 = r_166;
  int64_t x_125 = mhs_mem[0];
  int64_t x_126 = mhs_mem[1];
  int64_t r_167;
  switch (((x_125 + 3) > x_126)) {
  case 0: {
  r_167 = x_125; break; }
  case 1: {
  int64_t x1_51 = gc(m_139);
  int64_t r_168;
  int64_t x3_43 = x1_51;
  int x4_51 = 0;
  int64_t r_169;
  switch (((x3_43 + 3) > mhs_mem[1])) {
  case 0: {
  r_169 = x3_43; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_169 = 0; break; }
  default: abort();
  }
  r_168 = r_169;
  r_167 = r_168; break; }
  default: abort();
  }
  int64_t x1_52 = r_167;
  int64_t r_170;
  int64_t x3_44 = x1_52;
  int x4_52 = 0;
  mhs_mem[0] = (x3_44 + 3);
  int m_140 = 0;
  mhs_mem[(x_93 + 2)] = x3_44;
  int m_141 = 0;
  mhs_mem[x3_44] = 3;
  int m_142 = 0;
  int64_t x_127 = mhs_mem[(x_93 + 1)];
  mhs_mem[(x3_44 + 1)] = x_123;
  int m_143 = 0;
  mhs_mem[(x3_44 + 2)] = x_127;
  int m_144 = 0;
  int64_t x_128 = mhs_mem[(x_93 + 2)];
  r_170 = j_6(x_93, x_128, m_144);
  r_160 = r_170; break; }
  default: abort();
  }
  return r_160;
}

int64_t sumSquares(int m, int64_t n) {
  mhs_mem[2] = 2064;
  int m_99 = 0;
  mhs_mem[3] = 5128;
  int m_100 = 0;
  mhs_mem[5] = 3064;
  int m_101 = 0;
  mhs_mem[0] = 2064;
  int m_102 = 0;
  mhs_mem[1] = 5128;
  int m_103 = 0;
  mhs_mem[4] = 16;
  int m_104 = 0;
  mhs_mem[8] = 0;
  int m_105 = 0;
  int64_t x_93 = mhs_mem[4];
  int b_1 = (1 > n);
  int64_t r_171;
  switch (b_1) {
  case 0: {
  int r_172;
  switch ((x_93 > 2064)) {
  case 0: {
  mhs_mem[4] = x_93;
  r_172 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_172 = 0; break; }
  default: abort();
  }
  int m_145 = r_172;
  int64_t x_129 = mhs_mem[0];
  int64_t x_130 = mhs_mem[1];
  int64_t r_173;
  switch (((x_129 + 3) > x_130)) {
  case 0: {
  r_173 = x_129; break; }
  case 1: {
  int64_t x1_53 = gc(m_145);
  int64_t r_174;
  int64_t x3_45 = x1_53;
  int x4_53 = 0;
  int64_t r_175;
  switch (((x3_45 + 3) > mhs_mem[1])) {
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
  mhs_mem[0] = (x3_46 + 3);
  int m_146 = 0;
  mhs_mem[x_93] = x3_46;
  int m_147 = 0;
  mhs_mem[x3_46] = 11;
  int m_148 = 0;
  int64_t x_131 = mhs_mem[x_93];
  mhs_mem[(x_131 + 1)] = 1;
  int m_149 = 0;
  mhs_mem[(x_131 + 2)] = n;
  int m_150 = 0;
  int r_177;
  switch (((x_93 + 1) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_93 + 1);
  r_177 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_177 = 0; break; }
  default: abort();
  }
  int m_151 = r_177;
  int64_t x_132 = mhs_mem[0];
  int64_t x_133 = mhs_mem[1];
  int64_t r_178;
  switch (((x_132 + 3) > x_133)) {
  case 0: {
  r_178 = x_132; break; }
  case 1: {
  int64_t x1_55 = gc(m_151);
  int64_t r_179;
  int64_t x3_47 = x1_55;
  int x4_55 = 0;
  int64_t r_180;
  switch (((x3_47 + 3) > mhs_mem[1])) {
  case 0: {
  r_180 = x3_47; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_180 = 0; break; }
  default: abort();
  }
  r_179 = r_180;
  r_178 = r_179; break; }
  default: abort();
  }
  int64_t x1_56 = r_178;
  int64_t r_181;
  int64_t x3_48 = x1_56;
  int x4_56 = 0;
  mhs_mem[0] = (x3_48 + 3);
  int m_152 = 0;
  mhs_mem[(x_93 + 1)] = x3_48;
  int m_153 = 0;
  mhs_mem[x3_48] = 4;
  int m_154 = 0;
  int64_t x_134 = mhs_mem[x_93];
  mhs_mem[(x3_48 + 1)] = 1;
  int m_155 = 0;
  mhs_mem[(x3_48 + 2)] = x_134;
  int m_156 = 0;
  int64_t x_135 = mhs_mem[(x_93 + 1)];
  r_181 = j_7(x_93, x_135, m_156);
  r_176 = r_181;
  r_171 = r_176; break; }
  case 1: {
  int r_182;
  switch ((x_93 > 2064)) {
  case 0: {
  mhs_mem[4] = x_93;
  r_182 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",459:65: root stack overflow"); abort();
  r_182 = 0; break; }
  default: abort();
  }
  int m_157 = r_182;
  int64_t x_136 = mhs_mem[0];
  int64_t x_137 = mhs_mem[1];
  int64_t r_183;
  switch (((x_136 + 2) > x_137)) {
  case 0: {
  r_183 = x_136; break; }
  case 1: {
  int64_t x1_57 = gc(m_157);
  int64_t r_184;
  int64_t x3_49 = x1_57;
  int x4_57 = 0;
  int64_t r_185;
  switch (((x3_49 + 2) > mhs_mem[1])) {
  case 0: {
  r_185 = x3_49; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",499:89: out of memory"); abort();
  r_185 = 0; break; }
  default: abort();
  }
  r_184 = r_185;
  r_183 = r_184; break; }
  default: abort();
  }
  int64_t x1_58 = r_183;
  int64_t r_186;
  int64_t x3_50 = x1_58;
  int x4_58 = 0;
  mhs_mem[0] = (x3_50 + 2);
  int m_158 = 0;
  mhs_mem[x_93] = x3_50;
  int m_159 = 0;
  mhs_mem[x3_50] = 6;
  int m_160 = 0;
  int64_t x_138 = mhs_mem[x_93];
  r_186 = j_7(x_93, x_138, m_160);
  r_171 = r_186; break; }
  default: abort();
  }
  int64_t x1_59 = r_171;
  int64_t r_187;
  int64_t x3_51 = x1_59;
  int x4_59 = 0;
  r_187 = x3_51;
  return r_187;
}
int main(int argc, char **argv) {
  for (int i = 1; i < argc; i++) {
    printf("%lld\n", (long long)sumSquares(0, atoll(argv[i])));
    fprintf(stderr, "%s %s: %lld collections\n", "sumSquares", argv[i], (long long)mhs_mem[8]);
  }
  return 0;
}
