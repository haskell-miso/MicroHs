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
static int64_t t0(int m_25, int64_t p_2);
static int64_t t1(int m_46, int64_t p_3);
static int64_t t2(int m_54, int64_t p_4);
static int64_t gc(int m_96);
static int64_t j(int64_t x, int64_t v_1, int m_7) {
  mhs_mem[4] = x;
  int m_8 = 0;
  return v_1;
}
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
  int m_9 = 0;
  mhs_mem[(x + 4)] = x_9;
  int m_10 = 0;
  int64_t x_10 = (p_1 + 1);
  int64_t x_11 = mhs_mem[(x + 4)];
  mhs_mem[4] = x;
  int m_11 = 0;
  int64_t x1_2 = f0(m_11, x_11, x_10);
  int64_t r_5;
  int64_t x3_2 = x1_2;
  int x4_2 = 0;
  r_5 = j(x, x3_2, x4_2);
  r_4 = r_5; break; }
  case 1: {
  int64_t x_12 = mhs_mem[(x + 2)];
  int64_t x_13 = mhs_mem[(x_12 + 1)];
  r_4 = j(x, x_13, m_6); break; }
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
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
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
  int64_t r_6;
  switch ((x_4 == 8)) {
  case 0: {
  int64_t x_14 = mhs_mem[(x + 1)];
  int64_t x_15 = mhs_mem[(x_14 + 1)];
  int64_t x_16 = mhs_mem[(x_14 + 2)];
  mhs_mem[(x + 2)] = x_15;
  int m_12 = 0;
  mhs_mem[(x + 3)] = x_16;
  int m_13 = 0;
  int r_7;
  switch (((x + 4) > 2064)) {
  case 0: {
  mhs_mem[4] = (x + 4);
  r_7 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_7 = 0; break; }
  default: abort();
  }
  int m_14 = r_7;
  int64_t x_17 = mhs_mem[0];
  int64_t x_18 = mhs_mem[1];
  int64_t r_8;
  switch (((x_17 + 3) > x_18)) {
  case 0: {
  r_8 = x_17; break; }
  case 1: {
  int64_t x1_3 = gc(m_14);
  int64_t r_9;
  int64_t x3_3 = x1_3;
  int x4_3 = 0;
  int64_t r_10;
  switch (((x3_3 + 3) > mhs_mem[1])) {
  case 0: {
  r_10 = x3_3; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_10 = 0; break; }
  default: abort();
  }
  r_9 = r_10;
  r_8 = r_9; break; }
  default: abort();
  }
  int64_t x1_4 = r_8;
  int64_t r_11;
  int64_t x3_4 = x1_4;
  int x4_4 = 0;
  mhs_mem[0] = (x3_4 + 3);
  int m_15 = 0;
  mhs_mem[(x + 4)] = x3_4;
  int m_16 = 0;
  mhs_mem[x3_4] = 9;
  int m_17 = 0;
  int64_t x_19 = mhs_mem[(x + 2)];
  int64_t x_20 = mhs_mem[(x + 3)];
  mhs_mem[(x3_4 + 1)] = x_19;
  int m_18 = 0;
  mhs_mem[(x3_4 + 2)] = x_20;
  int m_19 = 0;
  int64_t x_21 = mhs_mem[(x + 4)];
  r_11 = j_1(x, p_1, x_21, m_19);
  r_6 = r_11; break; }
  case 1: {
  int64_t x_22 = mhs_mem[(x + 1)];
  int r_12;
  switch (((x + 2) > 2064)) {
  case 0: {
  mhs_mem[4] = (x + 2);
  r_12 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_12 = 0; break; }
  default: abort();
  }
  int m_20 = r_12;
  int64_t x_23 = mhs_mem[0];
  int64_t x_24 = mhs_mem[1];
  int64_t r_13;
  switch (((x_23 + 2) > x_24)) {
  case 0: {
  r_13 = x_23; break; }
  case 1: {
  int64_t x1_5 = gc(m_20);
  int64_t r_14;
  int64_t x3_5 = x1_5;
  int x4_5 = 0;
  int64_t r_15;
  switch (((x3_5 + 2) > mhs_mem[1])) {
  case 0: {
  r_15 = x3_5; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
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
  mhs_mem[0] = (x3_6 + 2);
  int m_21 = 0;
  mhs_mem[(x + 2)] = x3_6;
  int m_22 = 0;
  mhs_mem[x3_6] = 7;
  int m_23 = 0;
  mhs_mem[(x3_6 + 1)] = p_1;
  int m_24 = 0;
  int64_t x_25 = mhs_mem[(x + 2)];
  r_16 = j_1(x, p_1, x_25, m_24);
  r_6 = r_16; break; }
  default: abort();
  }
  r_3 = r_6;
  return r_3;
}
static int64_t j_2(int64_t x_26, int64_t v_2, int m_27) {
  mhs_mem[(x_26 + 1)] = v_2;
  int m_28 = 0;
  int64_t x_31 = mhs_mem[(x_26 + 1)];
  mhs_mem[4] = x_26;
  int m_29 = 0;
  return x_31;
}
static int64_t t0(int m_25, int64_t p_2) {
  int64_t x_26 = mhs_mem[4];
  mhs_mem[x_26] = p_2;
  int m_26 = 0;
  int64_t x_27 = mhs_mem[x_26];
  int64_t x_28 = mhs_mem[(x_27 + 1)];
  int64_t x_29 = mhs_mem[(x_27 + 2)];
  int64_t x_30 = (x_28 + 1);
  int b = (x_30 > x_29);
  int64_t r_17;
  switch (b) {
  case 0: {
  int r_18;
  switch (((x_26 + 1) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_26 + 1);
  r_18 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_18 = 0; break; }
  default: abort();
  }
  int m_30 = r_18;
  int64_t x_32 = mhs_mem[0];
  int64_t x_33 = mhs_mem[1];
  int64_t r_19;
  switch (((x_32 + 3) > x_33)) {
  case 0: {
  r_19 = x_32; break; }
  case 1: {
  int64_t x1_7 = gc(m_30);
  int64_t r_20;
  int64_t x3_7 = x1_7;
  int x4_7 = 0;
  int64_t r_21;
  switch (((x3_7 + 3) > mhs_mem[1])) {
  case 0: {
  r_21 = x3_7; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_21 = 0; break; }
  default: abort();
  }
  r_20 = r_21;
  r_19 = r_20; break; }
  default: abort();
  }
  int64_t x1_8 = r_19;
  int64_t r_22;
  int64_t x3_8 = x1_8;
  int x4_8 = 0;
  mhs_mem[0] = (x3_8 + 3);
  int m_31 = 0;
  mhs_mem[(x_26 + 1)] = x3_8;
  int m_32 = 0;
  mhs_mem[x3_8] = 11;
  int m_33 = 0;
  int64_t x_34 = mhs_mem[(x_26 + 1)];
  mhs_mem[(x_34 + 1)] = x_30;
  int m_34 = 0;
  mhs_mem[(x_34 + 2)] = x_29;
  int m_35 = 0;
  int r_23;
  switch (((x_26 + 2) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_26 + 2);
  r_23 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_23 = 0; break; }
  default: abort();
  }
  int m_36 = r_23;
  int64_t x_35 = mhs_mem[0];
  int64_t x_36 = mhs_mem[1];
  int64_t r_24;
  switch (((x_35 + 3) > x_36)) {
  case 0: {
  r_24 = x_35; break; }
  case 1: {
  int64_t x1_9 = gc(m_36);
  int64_t r_25;
  int64_t x3_9 = x1_9;
  int x4_9 = 0;
  int64_t r_26;
  switch (((x3_9 + 3) > mhs_mem[1])) {
  case 0: {
  r_26 = x3_9; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
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
  int m_37 = 0;
  mhs_mem[(x_26 + 2)] = x3_10;
  int m_38 = 0;
  mhs_mem[x3_10] = 4;
  int m_39 = 0;
  int64_t x_37 = mhs_mem[(x_26 + 1)];
  mhs_mem[(x3_10 + 1)] = x_30;
  int m_40 = 0;
  mhs_mem[(x3_10 + 2)] = x_37;
  int m_41 = 0;
  int64_t x_38 = mhs_mem[(x_26 + 2)];
  r_27 = j_2(x_26, x_38, m_41);
  r_22 = r_27;
  r_17 = r_22; break; }
  case 1: {
  int r_28;
  switch (((x_26 + 1) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_26 + 1);
  r_28 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_28 = 0; break; }
  default: abort();
  }
  int m_42 = r_28;
  int64_t x_39 = mhs_mem[0];
  int64_t x_40 = mhs_mem[1];
  int64_t r_29;
  switch (((x_39 + 2) > x_40)) {
  case 0: {
  r_29 = x_39; break; }
  case 1: {
  int64_t x1_11 = gc(m_42);
  int64_t r_30;
  int64_t x3_11 = x1_11;
  int x4_11 = 0;
  int64_t r_31;
  switch (((x3_11 + 2) > mhs_mem[1])) {
  case 0: {
  r_31 = x3_11; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
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
  mhs_mem[0] = (x3_12 + 2);
  int m_43 = 0;
  mhs_mem[(x_26 + 1)] = x3_12;
  int m_44 = 0;
  mhs_mem[x3_12] = 6;
  int m_45 = 0;
  int64_t x_41 = mhs_mem[(x_26 + 1)];
  r_32 = j_2(x_26, x_41, m_45);
  r_17 = r_32; break; }
  default: abort();
  }
  return r_17;
}
static int64_t t1(int m_46, int64_t p_3) {
  int64_t x_42 = mhs_mem[4];
  mhs_mem[x_42] = p_3;
  int m_47 = 0;
  int64_t x_43 = mhs_mem[x_42];
  int64_t x_44 = mhs_mem[(x_43 + 1)];
  int64_t x_45 = (x_44 * x_44);
  int r_33;
  switch (((x_42 + 1) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_42 + 1);
  r_33 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_33 = 0; break; }
  default: abort();
  }
  int m_48 = r_33;
  int64_t x_46 = mhs_mem[0];
  int64_t x_47 = mhs_mem[1];
  int64_t r_34;
  switch (((x_46 + 2) > x_47)) {
  case 0: {
  r_34 = x_46; break; }
  case 1: {
  int64_t x1_13 = gc(m_48);
  int64_t r_35;
  int64_t x3_13 = x1_13;
  int x4_13 = 0;
  int64_t r_36;
  switch (((x3_13 + 2) > mhs_mem[1])) {
  case 0: {
  r_36 = x3_13; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
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
  int m_49 = 0;
  mhs_mem[(x_42 + 1)] = x3_14;
  int m_50 = 0;
  mhs_mem[x3_14] = 2;
  int m_51 = 0;
  mhs_mem[(x3_14 + 1)] = x_45;
  int m_52 = 0;
  int64_t x_48 = mhs_mem[(x_42 + 1)];
  mhs_mem[4] = x_42;
  int m_53 = 0;
  r_37 = x_48;
  return r_37;
}
static int64_t j_3(int64_t x_49, int64_t v_4, int m_61) {
  mhs_mem[(x_49 + 4)] = v_4;
  int m_62 = 0;
  int64_t x_58 = mhs_mem[(x_49 + 4)];
  mhs_mem[4] = x_49;
  int m_63 = 0;
  return x_58;
}
static int64_t j_4(int64_t x_49, int64_t v_3, int m_59) {
  mhs_mem[(x_49 + 3)] = v_3;
  int m_60 = 0;
  int64_t x_56 = mhs_mem[(x_49 + 3)];
  int64_t x_57 = mhs_mem[x_56];
  int64_t r_42;
  switch ((x_57 == 3)) {
  case 0: {
  int64_t x_59 = mhs_mem[(x_49 + 3)];
  int r_43;
  switch (((x_49 + 4) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_49 + 4);
  r_43 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_43 = 0; break; }
  default: abort();
  }
  int m_64 = r_43;
  int64_t x_60 = mhs_mem[0];
  int64_t x_61 = mhs_mem[1];
  int64_t r_44;
  switch (((x_60 + 2) > x_61)) {
  case 0: {
  r_44 = x_60; break; }
  case 1: {
  int64_t x1_17 = gc(m_64);
  int64_t r_45;
  int64_t x3_17 = x1_17;
  int x4_17 = 0;
  int64_t r_46;
  switch (((x3_17 + 2) > mhs_mem[1])) {
  case 0: {
  r_46 = x3_17; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_46 = 0; break; }
  default: abort();
  }
  r_45 = r_46;
  r_44 = r_45; break; }
  default: abort();
  }
  int64_t x1_18 = r_44;
  int64_t r_47;
  int64_t x3_18 = x1_18;
  int x4_18 = 0;
  mhs_mem[0] = (x3_18 + 2);
  int m_65 = 0;
  mhs_mem[(x_49 + 4)] = x3_18;
  int m_66 = 0;
  mhs_mem[x3_18] = 8;
  int m_67 = 0;
  int64_t x_62 = mhs_mem[(x_49 + 4)];
  r_47 = j_3(x_49, x_62, m_67);
  r_42 = r_47; break; }
  case 1: {
  int64_t x_63 = mhs_mem[(x_49 + 3)];
  int64_t x_64 = mhs_mem[(x_63 + 1)];
  int64_t x_65 = mhs_mem[(x_63 + 2)];
  mhs_mem[(x_49 + 4)] = x_65;
  int m_68 = 0;
  int r_48;
  switch (((x_49 + 5) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_49 + 5);
  r_48 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_48 = 0; break; }
  default: abort();
  }
  int m_69 = r_48;
  int64_t x_66 = mhs_mem[0];
  int64_t x_67 = mhs_mem[1];
  int64_t r_49;
  switch (((x_66 + 2) > x_67)) {
  case 0: {
  r_49 = x_66; break; }
  case 1: {
  int64_t x1_19 = gc(m_69);
  int64_t r_50;
  int64_t x3_19 = x1_19;
  int x4_19 = 0;
  int64_t r_51;
  switch (((x3_19 + 2) > mhs_mem[1])) {
  case 0: {
  r_51 = x3_19; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
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
  int m_70 = 0;
  mhs_mem[(x_49 + 5)] = x3_20;
  int m_71 = 0;
  mhs_mem[x3_20] = 12;
  int m_72 = 0;
  int64_t x_68 = mhs_mem[(x_49 + 5)];
  mhs_mem[(x_68 + 1)] = x_64;
  int m_73 = 0;
  int r_53;
  switch (((x_49 + 6) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_49 + 6);
  r_53 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_53 = 0; break; }
  default: abort();
  }
  int m_74 = r_53;
  int64_t x_69 = mhs_mem[0];
  int64_t x_70 = mhs_mem[1];
  int64_t r_54;
  switch (((x_69 + 2) > x_70)) {
  case 0: {
  r_54 = x_69; break; }
  case 1: {
  int64_t x1_21 = gc(m_74);
  int64_t r_55;
  int64_t x3_21 = x1_21;
  int x4_21 = 0;
  int64_t r_56;
  switch (((x3_21 + 2) > mhs_mem[1])) {
  case 0: {
  r_56 = x3_21; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
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
  int m_75 = 0;
  mhs_mem[(x_49 + 6)] = x3_22;
  int m_76 = 0;
  mhs_mem[x3_22] = 13;
  int m_77 = 0;
  int64_t x_71 = mhs_mem[(x_49 + 4)];
  int64_t x_72 = mhs_mem[(x_49 + 6)];
  mhs_mem[(x_72 + 1)] = x_71;
  int m_78 = 0;
  int r_58;
  switch (((x_49 + 7) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_49 + 7);
  r_58 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_58 = 0; break; }
  default: abort();
  }
  int m_79 = r_58;
  int64_t x_73 = mhs_mem[0];
  int64_t x_74 = mhs_mem[1];
  int64_t r_59;
  switch (((x_73 + 3) > x_74)) {
  case 0: {
  r_59 = x_73; break; }
  case 1: {
  int64_t x1_23 = gc(m_79);
  int64_t r_60;
  int64_t x3_23 = x1_23;
  int x4_23 = 0;
  int64_t r_61;
  switch (((x3_23 + 3) > mhs_mem[1])) {
  case 0: {
  r_61 = x3_23; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
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
  mhs_mem[0] = (x3_24 + 3);
  int m_80 = 0;
  mhs_mem[(x_49 + 7)] = x3_24;
  int m_81 = 0;
  mhs_mem[x3_24] = 10;
  int m_82 = 0;
  int64_t x_75 = mhs_mem[(x_49 + 5)];
  int64_t x_76 = mhs_mem[(x_49 + 6)];
  mhs_mem[(x3_24 + 1)] = x_75;
  int m_83 = 0;
  mhs_mem[(x3_24 + 2)] = x_76;
  int m_84 = 0;
  int64_t x_77 = mhs_mem[(x_49 + 7)];
  r_62 = j_3(x_49, x_77, m_84);
  r_57 = r_62;
  r_52 = r_57;
  r_42 = r_52; break; }
  default: abort();
  }
  return r_42;
}
static int64_t t2(int m_54, int64_t p_4) {
  int64_t x_49 = mhs_mem[4];
  mhs_mem[x_49] = p_4;
  int m_55 = 0;
  int64_t x_50 = mhs_mem[x_49];
  int64_t x_51 = mhs_mem[(x_50 + 1)];
  mhs_mem[(x_49 + 1)] = x_51;
  int m_56 = 0;
  int r_38;
  switch (((x_49 + 2) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_49 + 2);
  r_38 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_38 = 0; break; }
  default: abort();
  }
  int m_57 = r_38;
  int64_t x_52 = mhs_mem[(x_49 + 1)];
  int64_t x_53 = mhs_mem[x_52];
  int64_t r_39;
  switch ((x_53 < 0)) {
  case 0: {
  int64_t x1_15 = t0(m_57, x_52);
  int64_t r_40;
  int64_t x3_15 = x1_15;
  int x4_15 = 0;
  int64_t q_1 = mhs_mem[(x_49 + 1)];
  mhs_mem[q_1] = -11;
  mhs_mem[(q_1 + 1)] = x3_15;
  r_40 = x3_15;
  r_39 = r_40; break; }
  case 1: {
  r_39 = mhs_mem[(x_52 + 1)]; break; }
  default: abort();
  }
  int64_t x1_16 = r_39;
  int64_t r_41;
  int64_t x3_16 = x1_16;
  int x4_16 = 0;
  mhs_mem[(x_49 + 2)] = x3_16;
  int m_58 = 0;
  int64_t x_54 = mhs_mem[(x_49 + 2)];
  int64_t x_55 = mhs_mem[x_54];
  int64_t r_63;
  switch ((x_55 == 4)) {
  case 0: {
  int64_t x_78 = mhs_mem[(x_49 + 2)];
  int r_64;
  switch (((x_49 + 3) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_49 + 3);
  r_64 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_64 = 0; break; }
  default: abort();
  }
  int m_85 = r_64;
  int64_t x_79 = mhs_mem[0];
  int64_t x_80 = mhs_mem[1];
  int64_t r_65;
  switch (((x_79 + 2) > x_80)) {
  case 0: {
  r_65 = x_79; break; }
  case 1: {
  int64_t x1_25 = gc(m_85);
  int64_t r_66;
  int64_t x3_25 = x1_25;
  int x4_25 = 0;
  int64_t r_67;
  switch (((x3_25 + 2) > mhs_mem[1])) {
  case 0: {
  r_67 = x3_25; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_67 = 0; break; }
  default: abort();
  }
  r_66 = r_67;
  r_65 = r_66; break; }
  default: abort();
  }
  int64_t x1_26 = r_65;
  int64_t r_68;
  int64_t x3_26 = x1_26;
  int x4_26 = 0;
  mhs_mem[0] = (x3_26 + 2);
  int m_86 = 0;
  mhs_mem[(x_49 + 3)] = x3_26;
  int m_87 = 0;
  mhs_mem[x3_26] = 5;
  int m_88 = 0;
  int64_t x_81 = mhs_mem[(x_49 + 3)];
  r_68 = j_4(x_49, x_81, m_88);
  r_63 = r_68; break; }
  case 1: {
  int64_t x_82 = mhs_mem[(x_49 + 2)];
  int64_t x_83 = mhs_mem[(x_82 + 1)];
  int64_t x_84 = mhs_mem[(x_82 + 2)];
  mhs_mem[(x_49 + 3)] = x_84;
  int m_89 = 0;
  int r_69;
  switch (((x_49 + 4) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_49 + 4);
  r_69 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_69 = 0; break; }
  default: abort();
  }
  int m_90 = r_69;
  int64_t x_85 = mhs_mem[0];
  int64_t x_86 = mhs_mem[1];
  int64_t r_70;
  switch (((x_85 + 3) > x_86)) {
  case 0: {
  r_70 = x_85; break; }
  case 1: {
  int64_t x1_27 = gc(m_90);
  int64_t r_71;
  int64_t x3_27 = x1_27;
  int x4_27 = 0;
  int64_t r_72;
  switch (((x3_27 + 3) > mhs_mem[1])) {
  case 0: {
  r_72 = x3_27; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
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
  mhs_mem[0] = (x3_28 + 3);
  int m_91 = 0;
  mhs_mem[(x_49 + 4)] = x3_28;
  int m_92 = 0;
  mhs_mem[x3_28] = 3;
  int m_93 = 0;
  int64_t x_87 = mhs_mem[(x_49 + 3)];
  mhs_mem[(x3_28 + 1)] = x_83;
  int m_94 = 0;
  mhs_mem[(x3_28 + 2)] = x_87;
  int m_95 = 0;
  int64_t x_88 = mhs_mem[(x_49 + 4)];
  r_73 = j_4(x_49, x_88, m_95);
  r_63 = r_73; break; }
  default: abort();
  }
  r_41 = r_63;
  return r_41;
}
static int copyWords(int m_97, int64_t src, int64_t dst, int64_t n_1);
static int copyWords(int m_97, int64_t src, int64_t dst, int64_t n_1) {
  int r_74;
  switch ((n_1 == 0)) {
  case 0: {
  mhs_mem[dst] = mhs_mem[src];
  r_74 = copyWords(0, (src + 1), (dst + 1), (n_1 - 1)); break; }
  case 1: {
  r_74 = m_97; break; }
  default: abort();
  }
  return r_74;
}
static int64_t copy(int m_98, int64_t p_5) {
  int64_t t = mhs_mem[p_5];
  int64_t r_75;
  switch ((t == 0)) {
  case 0: {
  int64_t r_76;
  switch ((t < 0)) {
  case 0: {
  r_76 = t; break; }
  case 1: {
  r_76 = (0 - t); break; }
  default: abort();
  }
  int64_t u = r_76;
  int64_t r_77;
  switch ((u == 2)) {
  case 0: {
  int64_t r_78;
  switch ((u == 3)) {
  case 0: {
  int64_t r_79;
  switch ((u == 4)) {
  case 0: {
  int64_t r_80;
  switch ((u == 5)) {
  case 0: {
  int64_t r_81;
  switch ((u == 6)) {
  case 0: {
  int64_t r_82;
  switch ((u == 7)) {
  case 0: {
  int64_t r_83;
  switch ((u == 8)) {
  case 0: {
  int64_t r_84;
  switch ((u == 9)) {
  case 0: {
  int64_t r_85;
  switch ((u == 10)) {
  case 0: {
  int64_t r_86;
  switch ((u == 11)) {
  case 0: {
  int64_t r_87;
  switch ((u == 12)) {
  case 0: {
  int64_t r_88;
  switch ((u == 13)) {
  case 0: {
  r_88 = 2; break; }
  case 1: {
  r_88 = 2; break; }
  default: abort();
  }
  r_87 = r_88; break; }
  case 1: {
  r_87 = 2; break; }
  default: abort();
  }
  r_86 = r_87; break; }
  case 1: {
  r_86 = 3; break; }
  default: abort();
  }
  r_85 = r_86; break; }
  case 1: {
  r_85 = 3; break; }
  default: abort();
  }
  r_84 = r_85; break; }
  case 1: {
  r_84 = 3; break; }
  default: abort();
  }
  r_83 = r_84; break; }
  case 1: {
  r_83 = 2; break; }
  default: abort();
  }
  r_82 = r_83; break; }
  case 1: {
  r_82 = 2; break; }
  default: abort();
  }
  r_81 = r_82; break; }
  case 1: {
  r_81 = 2; break; }
  default: abort();
  }
  r_80 = r_81; break; }
  case 1: {
  r_80 = 2; break; }
  default: abort();
  }
  r_79 = r_80; break; }
  case 1: {
  r_79 = 3; break; }
  default: abort();
  }
  r_78 = r_79; break; }
  case 1: {
  r_78 = 3; break; }
  default: abort();
  }
  r_77 = r_78; break; }
  case 1: {
  r_77 = 2; break; }
  default: abort();
  }
  int64_t n_2 = r_77;
  int64_t free = mhs_mem[6];
  int m1_1 = copyWords(m_98, p_5, free, n_2);
  mhs_mem[p_5] = 0;
  mhs_mem[(p_5 + 1)] = free;
  mhs_mem[6] = (free + n_2);
  r_75 = free; break; }
  case 1: {
  r_75 = mhs_mem[(p_5 + 1)]; break; }
  default: abort();
  }
  return r_75;
}
static int scan(int m_99);
static int scan(int m_99) {
  int64_t s = mhs_mem[7];
  int64_t f = mhs_mem[6];
  int r_89;
  switch ((s >= f)) {
  case 0: {
  int64_t t_1 = mhs_mem[s];
  int r_90;
  switch ((t_1 < 0)) {
  case 0: {
  int r_91;
  switch ((t_1 == 2)) {
  case 0: {
  int r_92;
  switch ((t_1 == 3)) {
  case 0: {
  int r_93;
  switch ((t_1 == 4)) {
  case 0: {
  int r_94;
  switch ((t_1 == 5)) {
  case 0: {
  int r_95;
  switch ((t_1 == 6)) {
  case 0: {
  int r_96;
  switch ((t_1 == 7)) {
  case 0: {
  int r_97;
  switch ((t_1 == 8)) {
  case 0: {
  int r_98;
  switch ((t_1 == 9)) {
  case 0: {
  int r_99;
  switch ((t_1 == 10)) {
  case 0: {
  int r_100;
  switch ((t_1 == 11)) {
  case 0: {
  int r_101;
  switch ((t_1 == 12)) {
  case 0: {
  int r_102;
  switch ((t_1 == 13)) {
  case 0: {
  r_102 = m_99; break; }
  case 1: {
  int64_t x1_29 = copy(m_99, mhs_mem[(s + 1)]);
  int r_103;
  int64_t a0_1 = x1_29;
  int x4_29 = 0;
  mhs_mem[(s + 1)] = a0_1;
  int m2 = 0;
  r_103 = m2;
  r_102 = r_103; break; }
  default: abort();
  }
  r_101 = r_102; break; }
  case 1: {
  r_101 = m_99; break; }
  default: abort();
  }
  r_100 = r_101; break; }
  case 1: {
  r_100 = m_99; break; }
  default: abort();
  }
  r_99 = r_100; break; }
  case 1: {
  int64_t x1_30 = copy(m_99, mhs_mem[(s + 1)]);
  int r_104;
  int64_t a0_3 = x1_30;
  int x4_30 = 0;
  mhs_mem[(s + 1)] = a0_3;
  int m2_1 = 0;
  int64_t x1_31 = copy(m2_1, mhs_mem[(s + 2)]);
  int r_105;
  int64_t a0_5 = x1_31;
  int x4_31 = 0;
  mhs_mem[(s + 2)] = a0_5;
  int m2_2 = 0;
  r_105 = m2_2;
  r_104 = r_105;
  r_99 = r_104; break; }
  default: abort();
  }
  r_98 = r_99; break; }
  case 1: {
  int64_t x1_32 = copy(m_99, mhs_mem[(s + 1)]);
  int r_106;
  int64_t a0_7 = x1_32;
  int x4_32 = 0;
  mhs_mem[(s + 1)] = a0_7;
  int m2_3 = 0;
  int64_t x1_33 = copy(m2_3, mhs_mem[(s + 2)]);
  int r_107;
  int64_t a0_9 = x1_33;
  int x4_33 = 0;
  mhs_mem[(s + 2)] = a0_9;
  int m2_4 = 0;
  r_107 = m2_4;
  r_106 = r_107;
  r_98 = r_106; break; }
  default: abort();
  }
  r_97 = r_98; break; }
  case 1: {
  r_97 = m_99; break; }
  default: abort();
  }
  r_96 = r_97; break; }
  case 1: {
  r_96 = m_99; break; }
  default: abort();
  }
  r_95 = r_96; break; }
  case 1: {
  r_95 = m_99; break; }
  default: abort();
  }
  r_94 = r_95; break; }
  case 1: {
  r_94 = m_99; break; }
  default: abort();
  }
  r_93 = r_94; break; }
  case 1: {
  int64_t x1_34 = copy(m_99, mhs_mem[(s + 2)]);
  int r_108;
  int64_t a0_11 = x1_34;
  int x4_34 = 0;
  mhs_mem[(s + 2)] = a0_11;
  int m2_5 = 0;
  r_108 = m2_5;
  r_93 = r_108; break; }
  default: abort();
  }
  r_92 = r_93; break; }
  case 1: {
  int64_t x1_35 = copy(m_99, mhs_mem[(s + 2)]);
  int r_109;
  int64_t a0_13 = x1_35;
  int x4_35 = 0;
  mhs_mem[(s + 2)] = a0_13;
  int m2_6 = 0;
  r_109 = m2_6;
  r_92 = r_109; break; }
  default: abort();
  }
  r_91 = r_92; break; }
  case 1: {
  r_91 = m_99; break; }
  default: abort();
  }
  r_90 = r_91; break; }
  case 1: {
  int64_t x1_36 = copy(m_99, mhs_mem[(s + 1)]);
  int r_110;
  int64_t a0_15 = x1_36;
  int x4_36 = 0;
  mhs_mem[(s + 1)] = a0_15;
  int m2_7 = 0;
  r_110 = m2_7;
  r_90 = r_110; break; }
  default: abort();
  }
  int m1_2 = r_90;
  int64_t r_111;
  switch ((t_1 < 0)) {
  case 0: {
  r_111 = t_1; break; }
  case 1: {
  r_111 = (0 - t_1); break; }
  default: abort();
  }
  int64_t u_1 = r_111;
  int64_t r_112;
  switch ((u_1 == 2)) {
  case 0: {
  int64_t r_113;
  switch ((u_1 == 3)) {
  case 0: {
  int64_t r_114;
  switch ((u_1 == 4)) {
  case 0: {
  int64_t r_115;
  switch ((u_1 == 5)) {
  case 0: {
  int64_t r_116;
  switch ((u_1 == 6)) {
  case 0: {
  int64_t r_117;
  switch ((u_1 == 7)) {
  case 0: {
  int64_t r_118;
  switch ((u_1 == 8)) {
  case 0: {
  int64_t r_119;
  switch ((u_1 == 9)) {
  case 0: {
  int64_t r_120;
  switch ((u_1 == 10)) {
  case 0: {
  int64_t r_121;
  switch ((u_1 == 11)) {
  case 0: {
  int64_t r_122;
  switch ((u_1 == 12)) {
  case 0: {
  int64_t r_123;
  switch ((u_1 == 13)) {
  case 0: {
  r_123 = 2; break; }
  case 1: {
  r_123 = 2; break; }
  default: abort();
  }
  r_122 = r_123; break; }
  case 1: {
  r_122 = 2; break; }
  default: abort();
  }
  r_121 = r_122; break; }
  case 1: {
  r_121 = 3; break; }
  default: abort();
  }
  r_120 = r_121; break; }
  case 1: {
  r_120 = 3; break; }
  default: abort();
  }
  r_119 = r_120; break; }
  case 1: {
  r_119 = 3; break; }
  default: abort();
  }
  r_118 = r_119; break; }
  case 1: {
  r_118 = 2; break; }
  default: abort();
  }
  r_117 = r_118; break; }
  case 1: {
  r_117 = 2; break; }
  default: abort();
  }
  r_116 = r_117; break; }
  case 1: {
  r_116 = 2; break; }
  default: abort();
  }
  r_115 = r_116; break; }
  case 1: {
  r_115 = 2; break; }
  default: abort();
  }
  r_114 = r_115; break; }
  case 1: {
  r_114 = 3; break; }
  default: abort();
  }
  r_113 = r_114; break; }
  case 1: {
  r_113 = 3; break; }
  default: abort();
  }
  r_112 = r_113; break; }
  case 1: {
  r_112 = 2; break; }
  default: abort();
  }
  mhs_mem[7] = (s + r_112);
  r_89 = scan(0); break; }
  case 1: {
  r_89 = m_99; break; }
  default: abort();
  }
  return r_89;
}
static int roots(int64_t sp, int m_100, int64_t i);
static int roots(int64_t sp, int m_100, int64_t i) {
  int r_124;
  switch ((i >= sp)) {
  case 0: {
  int64_t x1_37 = copy(m_100, mhs_mem[i]);
  int r_125;
  int64_t x3_29 = x1_37;
  int x4_37 = 0;
  mhs_mem[i] = x3_29;
  r_125 = roots(sp, 0, (i + 1));
  r_124 = r_125; break; }
  case 1: {
  r_124 = m_100; break; }
  default: abort();
  }
  return r_124;
}
static int64_t gc(int m_96) {
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
static int64_t j_5(int64_t x_89, int64_t v_9, int m_116) {
  mhs_mem[4] = x_89;
  int m_117 = 0;
  return v_9;
}
static int64_t j_8(int64_t x_89, int64_t v_12, int m_129) {
  mhs_mem[(x_89 + 11)] = v_12;
  int m_130 = 0;
  int64_t x_114 = mhs_mem[(x_89 + 11)];
  int64_t x_115 = mhs_mem[x_114];
  int64_t r_136;
  switch ((x_115 == 7)) {
  case 0: {
  int64_t x_116 = mhs_mem[(x_89 + 11)];
  int64_t x_117 = mhs_mem[(x_116 + 1)];
  int64_t x_118 = mhs_mem[(x_116 + 2)];
  mhs_mem[(x_89 + 12)] = x_117;
  int m_132 = 0;
  mhs_mem[(x_89 + 13)] = x_118;
  int m_133 = 0;
  int64_t x_119 = mhs_mem[(x_89 + 13)];
  mhs_mem[4] = x_89;
  int m_134 = 0;
  int64_t x1_42 = f0(m_134, x_119, 3);
  int64_t r_137;
  int64_t x3_34 = x1_42;
  int x4_42 = 0;
  r_137 = j_5(x_89, x3_34, x4_42);
  r_136 = r_137; break; }
  case 1: {
  int64_t x_120 = mhs_mem[(x_89 + 11)];
  int64_t x_121 = mhs_mem[(x_120 + 1)];
  r_136 = j_5(x_89, x_121, m_130); break; }
  default: abort();
  }
  return r_136;
}
static int64_t j_9(int64_t x_89, int64_t v_10, int m_122) {
  mhs_mem[(x_89 + 7)] = v_10;
  int m_123 = 0;
  int64_t x_105 = mhs_mem[(x_89 + 7)];
  int64_t x_106 = mhs_mem[x_105];
  int64_t r_131;
  switch ((x_106 == 7)) {
  case 0: {
  int64_t x_107 = mhs_mem[(x_89 + 7)];
  int64_t x_108 = mhs_mem[(x_107 + 1)];
  int64_t x_109 = mhs_mem[(x_107 + 2)];
  mhs_mem[(x_89 + 8)] = x_108;
  int m_125 = 0;
  mhs_mem[(x_89 + 9)] = x_109;
  int m_126 = 0;
  int r_132;
  switch (((x_89 + 10) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 10);
  r_132 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_132 = 0; break; }
  default: abort();
  }
  int m_127 = r_132;
  int64_t x_110 = mhs_mem[(x_89 + 9)];
  int64_t x_111 = mhs_mem[x_110];
  int64_t r_133;
  switch ((x_111 < 0)) {
  case 0: {
  int64_t x1_40 = t2(m_127, x_110);
  int64_t r_134;
  int64_t x3_32 = x1_40;
  int x4_40 = 0;
  int64_t q_3 = mhs_mem[(x_89 + 9)];
  mhs_mem[q_3] = -13;
  mhs_mem[(q_3 + 1)] = x3_32;
  r_134 = x3_32;
  r_133 = r_134; break; }
  case 1: {
  r_133 = mhs_mem[(x_110 + 1)]; break; }
  default: abort();
  }
  int64_t x1_41 = r_133;
  int64_t r_135;
  int64_t x3_33 = x1_41;
  int x4_41 = 0;
  mhs_mem[(x_89 + 10)] = x3_33;
  int m_128 = 0;
  int64_t x_112 = mhs_mem[(x_89 + 10)];
  int64_t x_113 = mhs_mem[x_112];
  int64_t r_138;
  switch ((x_113 == 8)) {
  case 0: {
  int64_t x_122 = mhs_mem[(x_89 + 10)];
  int64_t x_123 = mhs_mem[(x_122 + 1)];
  int64_t x_124 = mhs_mem[(x_122 + 2)];
  mhs_mem[(x_89 + 11)] = x_123;
  int m_135 = 0;
  mhs_mem[(x_89 + 12)] = x_124;
  int m_136 = 0;
  int r_139;
  switch (((x_89 + 13) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 13);
  r_139 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_139 = 0; break; }
  default: abort();
  }
  int m_137 = r_139;
  int64_t x_125 = mhs_mem[0];
  int64_t x_126 = mhs_mem[1];
  int64_t r_140;
  switch (((x_125 + 3) > x_126)) {
  case 0: {
  r_140 = x_125; break; }
  case 1: {
  int64_t x1_43 = gc(m_137);
  int64_t r_141;
  int64_t x3_35 = x1_43;
  int x4_43 = 0;
  int64_t r_142;
  switch (((x3_35 + 3) > mhs_mem[1])) {
  case 0: {
  r_142 = x3_35; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_142 = 0; break; }
  default: abort();
  }
  r_141 = r_142;
  r_140 = r_141; break; }
  default: abort();
  }
  int64_t x1_44 = r_140;
  int64_t r_143;
  int64_t x3_36 = x1_44;
  int x4_44 = 0;
  mhs_mem[0] = (x3_36 + 3);
  int m_138 = 0;
  mhs_mem[(x_89 + 13)] = x3_36;
  int m_139 = 0;
  mhs_mem[x3_36] = 9;
  int m_140 = 0;
  int64_t x_127 = mhs_mem[(x_89 + 11)];
  int64_t x_128 = mhs_mem[(x_89 + 12)];
  mhs_mem[(x3_36 + 1)] = x_127;
  int m_141 = 0;
  mhs_mem[(x3_36 + 2)] = x_128;
  int m_142 = 0;
  int64_t x_129 = mhs_mem[(x_89 + 13)];
  r_143 = j_8(x_89, x_129, m_142);
  r_138 = r_143; break; }
  case 1: {
  int64_t x_130 = mhs_mem[(x_89 + 10)];
  int r_144;
  switch (((x_89 + 11) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 11);
  r_144 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_144 = 0; break; }
  default: abort();
  }
  int m_143 = r_144;
  int64_t x_131 = mhs_mem[0];
  int64_t x_132 = mhs_mem[1];
  int64_t r_145;
  switch (((x_131 + 2) > x_132)) {
  case 0: {
  r_145 = x_131; break; }
  case 1: {
  int64_t x1_45 = gc(m_143);
  int64_t r_146;
  int64_t x3_37 = x1_45;
  int x4_45 = 0;
  int64_t r_147;
  switch (((x3_37 + 2) > mhs_mem[1])) {
  case 0: {
  r_147 = x3_37; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_147 = 0; break; }
  default: abort();
  }
  r_146 = r_147;
  r_145 = r_146; break; }
  default: abort();
  }
  int64_t x1_46 = r_145;
  int64_t r_148;
  int64_t x3_38 = x1_46;
  int x4_46 = 0;
  mhs_mem[0] = (x3_38 + 2);
  int m_144 = 0;
  mhs_mem[(x_89 + 11)] = x3_38;
  int m_145 = 0;
  mhs_mem[x3_38] = 7;
  int m_146 = 0;
  mhs_mem[(x3_38 + 1)] = 2;
  int m_147 = 0;
  int64_t x_133 = mhs_mem[(x_89 + 11)];
  r_148 = j_8(x_89, x_133, m_147);
  r_138 = r_148; break; }
  default: abort();
  }
  r_135 = r_138;
  r_131 = r_135; break; }
  case 1: {
  int64_t x_134 = mhs_mem[(x_89 + 7)];
  int64_t x_135 = mhs_mem[(x_134 + 1)];
  r_131 = j_5(x_89, x_135, m_123); break; }
  default: abort();
  }
  return r_131;
}
static int64_t j_10(int64_t x_89, int64_t v_8, int m_114) {
  mhs_mem[(x_89 + 3)] = v_8;
  int m_115 = 0;
  int64_t x_96 = mhs_mem[(x_89 + 3)];
  int64_t x_97 = mhs_mem[x_96];
  int64_t r_126;
  switch ((x_97 == 7)) {
  case 0: {
  int64_t x_98 = mhs_mem[(x_89 + 3)];
  int64_t x_99 = mhs_mem[(x_98 + 1)];
  int64_t x_100 = mhs_mem[(x_98 + 2)];
  mhs_mem[(x_89 + 4)] = x_99;
  int m_118 = 0;
  mhs_mem[(x_89 + 5)] = x_100;
  int m_119 = 0;
  int r_127;
  switch (((x_89 + 6) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 6);
  r_127 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_127 = 0; break; }
  default: abort();
  }
  int m_120 = r_127;
  int64_t x_101 = mhs_mem[(x_89 + 5)];
  int64_t x_102 = mhs_mem[x_101];
  int64_t r_128;
  switch ((x_102 < 0)) {
  case 0: {
  int64_t x1_38 = t2(m_120, x_101);
  int64_t r_129;
  int64_t x3_30 = x1_38;
  int x4_38 = 0;
  int64_t q_2 = mhs_mem[(x_89 + 5)];
  mhs_mem[q_2] = -13;
  mhs_mem[(q_2 + 1)] = x3_30;
  r_129 = x3_30;
  r_128 = r_129; break; }
  case 1: {
  r_128 = mhs_mem[(x_101 + 1)]; break; }
  default: abort();
  }
  int64_t x1_39 = r_128;
  int64_t r_130;
  int64_t x3_31 = x1_39;
  int x4_39 = 0;
  mhs_mem[(x_89 + 6)] = x3_31;
  int m_121 = 0;
  int64_t x_103 = mhs_mem[(x_89 + 6)];
  int64_t x_104 = mhs_mem[x_103];
  int64_t r_149;
  switch ((x_104 == 8)) {
  case 0: {
  int64_t x_136 = mhs_mem[(x_89 + 6)];
  int64_t x_137 = mhs_mem[(x_136 + 1)];
  int64_t x_138 = mhs_mem[(x_136 + 2)];
  mhs_mem[(x_89 + 7)] = x_137;
  int m_148 = 0;
  mhs_mem[(x_89 + 8)] = x_138;
  int m_149 = 0;
  int r_150;
  switch (((x_89 + 9) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 9);
  r_150 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_150 = 0; break; }
  default: abort();
  }
  int m_150 = r_150;
  int64_t x_139 = mhs_mem[0];
  int64_t x_140 = mhs_mem[1];
  int64_t r_151;
  switch (((x_139 + 3) > x_140)) {
  case 0: {
  r_151 = x_139; break; }
  case 1: {
  int64_t x1_47 = gc(m_150);
  int64_t r_152;
  int64_t x3_39 = x1_47;
  int x4_47 = 0;
  int64_t r_153;
  switch (((x3_39 + 3) > mhs_mem[1])) {
  case 0: {
  r_153 = x3_39; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_153 = 0; break; }
  default: abort();
  }
  r_152 = r_153;
  r_151 = r_152; break; }
  default: abort();
  }
  int64_t x1_48 = r_151;
  int64_t r_154;
  int64_t x3_40 = x1_48;
  int x4_48 = 0;
  mhs_mem[0] = (x3_40 + 3);
  int m_151 = 0;
  mhs_mem[(x_89 + 9)] = x3_40;
  int m_152 = 0;
  mhs_mem[x3_40] = 9;
  int m_153 = 0;
  int64_t x_141 = mhs_mem[(x_89 + 7)];
  int64_t x_142 = mhs_mem[(x_89 + 8)];
  mhs_mem[(x3_40 + 1)] = x_141;
  int m_154 = 0;
  mhs_mem[(x3_40 + 2)] = x_142;
  int m_155 = 0;
  int64_t x_143 = mhs_mem[(x_89 + 9)];
  r_154 = j_9(x_89, x_143, m_155);
  r_149 = r_154; break; }
  case 1: {
  int64_t x_144 = mhs_mem[(x_89 + 6)];
  int r_155;
  switch (((x_89 + 7) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 7);
  r_155 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_155 = 0; break; }
  default: abort();
  }
  int m_156 = r_155;
  int64_t x_145 = mhs_mem[0];
  int64_t x_146 = mhs_mem[1];
  int64_t r_156;
  switch (((x_145 + 2) > x_146)) {
  case 0: {
  r_156 = x_145; break; }
  case 1: {
  int64_t x1_49 = gc(m_156);
  int64_t r_157;
  int64_t x3_41 = x1_49;
  int x4_49 = 0;
  int64_t r_158;
  switch (((x3_41 + 2) > mhs_mem[1])) {
  case 0: {
  r_158 = x3_41; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_158 = 0; break; }
  default: abort();
  }
  r_157 = r_158;
  r_156 = r_157; break; }
  default: abort();
  }
  int64_t x1_50 = r_156;
  int64_t r_159;
  int64_t x3_42 = x1_50;
  int x4_50 = 0;
  mhs_mem[0] = (x3_42 + 2);
  int m_157 = 0;
  mhs_mem[(x_89 + 7)] = x3_42;
  int m_158 = 0;
  mhs_mem[x3_42] = 7;
  int m_159 = 0;
  mhs_mem[(x3_42 + 1)] = 1;
  int m_160 = 0;
  int64_t x_147 = mhs_mem[(x_89 + 7)];
  r_159 = j_9(x_89, x_147, m_160);
  r_149 = r_159; break; }
  default: abort();
  }
  r_130 = r_149;
  r_126 = r_130; break; }
  case 1: {
  int64_t x_148 = mhs_mem[(x_89 + 3)];
  int64_t x_149 = mhs_mem[(x_148 + 1)];
  r_126 = j_5(x_89, x_149, m_115); break; }
  default: abort();
  }
  return r_126;
}
static int64_t j_11(int64_t x_89, int64_t v_7, int m_112) {
  mhs_mem[(x_89 + 2)] = v_7;
  int m_113 = 0;
  int64_t x_94 = mhs_mem[(x_89 + 2)];
  int64_t x_95 = mhs_mem[x_94];
  int64_t r_160;
  switch ((x_95 == 8)) {
  case 0: {
  int64_t x_150 = mhs_mem[(x_89 + 2)];
  int64_t x_151 = mhs_mem[(x_150 + 1)];
  int64_t x_152 = mhs_mem[(x_150 + 2)];
  mhs_mem[(x_89 + 3)] = x_151;
  int m_161 = 0;
  mhs_mem[(x_89 + 4)] = x_152;
  int m_162 = 0;
  int r_161;
  switch (((x_89 + 5) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 5);
  r_161 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_161 = 0; break; }
  default: abort();
  }
  int m_163 = r_161;
  int64_t x_153 = mhs_mem[0];
  int64_t x_154 = mhs_mem[1];
  int64_t r_162;
  switch (((x_153 + 3) > x_154)) {
  case 0: {
  r_162 = x_153; break; }
  case 1: {
  int64_t x1_51 = gc(m_163);
  int64_t r_163;
  int64_t x3_43 = x1_51;
  int x4_51 = 0;
  int64_t r_164;
  switch (((x3_43 + 3) > mhs_mem[1])) {
  case 0: {
  r_164 = x3_43; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_164 = 0; break; }
  default: abort();
  }
  r_163 = r_164;
  r_162 = r_163; break; }
  default: abort();
  }
  int64_t x1_52 = r_162;
  int64_t r_165;
  int64_t x3_44 = x1_52;
  int x4_52 = 0;
  mhs_mem[0] = (x3_44 + 3);
  int m_164 = 0;
  mhs_mem[(x_89 + 5)] = x3_44;
  int m_165 = 0;
  mhs_mem[x3_44] = 9;
  int m_166 = 0;
  int64_t x_155 = mhs_mem[(x_89 + 3)];
  int64_t x_156 = mhs_mem[(x_89 + 4)];
  mhs_mem[(x3_44 + 1)] = x_155;
  int m_167 = 0;
  mhs_mem[(x3_44 + 2)] = x_156;
  int m_168 = 0;
  int64_t x_157 = mhs_mem[(x_89 + 5)];
  r_165 = j_10(x_89, x_157, m_168);
  r_160 = r_165; break; }
  case 1: {
  int64_t x_158 = mhs_mem[(x_89 + 2)];
  int r_166;
  switch (((x_89 + 3) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 3);
  r_166 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_166 = 0; break; }
  default: abort();
  }
  int m_169 = r_166;
  int64_t x_159 = mhs_mem[0];
  int64_t x_160 = mhs_mem[1];
  int64_t r_167;
  switch (((x_159 + 2) > x_160)) {
  case 0: {
  r_167 = x_159; break; }
  case 1: {
  int64_t x1_53 = gc(m_169);
  int64_t r_168;
  int64_t x3_45 = x1_53;
  int x4_53 = 0;
  int64_t r_169;
  switch (((x3_45 + 2) > mhs_mem[1])) {
  case 0: {
  r_169 = x3_45; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_169 = 0; break; }
  default: abort();
  }
  r_168 = r_169;
  r_167 = r_168; break; }
  default: abort();
  }
  int64_t x1_54 = r_167;
  int64_t r_170;
  int64_t x3_46 = x1_54;
  int x4_54 = 0;
  mhs_mem[0] = (x3_46 + 2);
  int m_170 = 0;
  mhs_mem[(x_89 + 3)] = x3_46;
  int m_171 = 0;
  mhs_mem[x3_46] = 7;
  int m_172 = 0;
  mhs_mem[(x3_46 + 1)] = 0;
  int m_173 = 0;
  int64_t x_161 = mhs_mem[(x_89 + 3)];
  r_170 = j_10(x_89, x_161, m_173);
  r_160 = r_170; break; }
  default: abort();
  }
  return r_160;
}
static int64_t j_12(int64_t x_89, int64_t v_6, int m_110) {
  mhs_mem[(x_89 + 1)] = v_6;
  int m_111 = 0;
  int64_t x_92 = mhs_mem[(x_89 + 1)];
  int64_t x_93 = mhs_mem[x_92];
  int64_t r_171;
  switch ((x_93 == 3)) {
  case 0: {
  int64_t x_162 = mhs_mem[(x_89 + 1)];
  int r_172;
  switch (((x_89 + 2) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 2);
  r_172 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_172 = 0; break; }
  default: abort();
  }
  int m_174 = r_172;
  int64_t x_163 = mhs_mem[0];
  int64_t x_164 = mhs_mem[1];
  int64_t r_173;
  switch (((x_163 + 2) > x_164)) {
  case 0: {
  r_173 = x_163; break; }
  case 1: {
  int64_t x1_55 = gc(m_174);
  int64_t r_174;
  int64_t x3_47 = x1_55;
  int x4_55 = 0;
  int64_t r_175;
  switch (((x3_47 + 2) > mhs_mem[1])) {
  case 0: {
  r_175 = x3_47; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_175 = 0; break; }
  default: abort();
  }
  r_174 = r_175;
  r_173 = r_174; break; }
  default: abort();
  }
  int64_t x1_56 = r_173;
  int64_t r_176;
  int64_t x3_48 = x1_56;
  int x4_56 = 0;
  mhs_mem[0] = (x3_48 + 2);
  int m_175 = 0;
  mhs_mem[(x_89 + 2)] = x3_48;
  int m_176 = 0;
  mhs_mem[x3_48] = 8;
  int m_177 = 0;
  int64_t x_165 = mhs_mem[(x_89 + 2)];
  r_176 = j_11(x_89, x_165, m_177);
  r_171 = r_176; break; }
  case 1: {
  int64_t x_166 = mhs_mem[(x_89 + 1)];
  int64_t x_167 = mhs_mem[(x_166 + 1)];
  int64_t x_168 = mhs_mem[(x_166 + 2)];
  mhs_mem[(x_89 + 2)] = x_168;
  int m_178 = 0;
  int r_177;
  switch (((x_89 + 3) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 3);
  r_177 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_177 = 0; break; }
  default: abort();
  }
  int m_179 = r_177;
  int64_t x_169 = mhs_mem[0];
  int64_t x_170 = mhs_mem[1];
  int64_t r_178;
  switch (((x_169 + 2) > x_170)) {
  case 0: {
  r_178 = x_169; break; }
  case 1: {
  int64_t x1_57 = gc(m_179);
  int64_t r_179;
  int64_t x3_49 = x1_57;
  int x4_57 = 0;
  int64_t r_180;
  switch (((x3_49 + 2) > mhs_mem[1])) {
  case 0: {
  r_180 = x3_49; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_180 = 0; break; }
  default: abort();
  }
  r_179 = r_180;
  r_178 = r_179; break; }
  default: abort();
  }
  int64_t x1_58 = r_178;
  int64_t r_181;
  int64_t x3_50 = x1_58;
  int x4_58 = 0;
  mhs_mem[0] = (x3_50 + 2);
  int m_180 = 0;
  mhs_mem[(x_89 + 3)] = x3_50;
  int m_181 = 0;
  mhs_mem[x3_50] = 12;
  int m_182 = 0;
  int64_t x_171 = mhs_mem[(x_89 + 3)];
  mhs_mem[(x_171 + 1)] = x_167;
  int m_183 = 0;
  int r_182;
  switch (((x_89 + 4) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 4);
  r_182 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_182 = 0; break; }
  default: abort();
  }
  int m_184 = r_182;
  int64_t x_172 = mhs_mem[0];
  int64_t x_173 = mhs_mem[1];
  int64_t r_183;
  switch (((x_172 + 2) > x_173)) {
  case 0: {
  r_183 = x_172; break; }
  case 1: {
  int64_t x1_59 = gc(m_184);
  int64_t r_184;
  int64_t x3_51 = x1_59;
  int x4_59 = 0;
  int64_t r_185;
  switch (((x3_51 + 2) > mhs_mem[1])) {
  case 0: {
  r_185 = x3_51; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_185 = 0; break; }
  default: abort();
  }
  r_184 = r_185;
  r_183 = r_184; break; }
  default: abort();
  }
  int64_t x1_60 = r_183;
  int64_t r_186;
  int64_t x3_52 = x1_60;
  int x4_60 = 0;
  mhs_mem[0] = (x3_52 + 2);
  int m_185 = 0;
  mhs_mem[(x_89 + 4)] = x3_52;
  int m_186 = 0;
  mhs_mem[x3_52] = 13;
  int m_187 = 0;
  int64_t x_174 = mhs_mem[(x_89 + 2)];
  int64_t x_175 = mhs_mem[(x_89 + 4)];
  mhs_mem[(x_175 + 1)] = x_174;
  int m_188 = 0;
  int r_187;
  switch (((x_89 + 5) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 5);
  r_187 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_187 = 0; break; }
  default: abort();
  }
  int m_189 = r_187;
  int64_t x_176 = mhs_mem[0];
  int64_t x_177 = mhs_mem[1];
  int64_t r_188;
  switch (((x_176 + 3) > x_177)) {
  case 0: {
  r_188 = x_176; break; }
  case 1: {
  int64_t x1_61 = gc(m_189);
  int64_t r_189;
  int64_t x3_53 = x1_61;
  int x4_61 = 0;
  int64_t r_190;
  switch (((x3_53 + 3) > mhs_mem[1])) {
  case 0: {
  r_190 = x3_53; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_190 = 0; break; }
  default: abort();
  }
  r_189 = r_190;
  r_188 = r_189; break; }
  default: abort();
  }
  int64_t x1_62 = r_188;
  int64_t r_191;
  int64_t x3_54 = x1_62;
  int x4_62 = 0;
  mhs_mem[0] = (x3_54 + 3);
  int m_190 = 0;
  mhs_mem[(x_89 + 5)] = x3_54;
  int m_191 = 0;
  mhs_mem[x3_54] = 10;
  int m_192 = 0;
  int64_t x_178 = mhs_mem[(x_89 + 3)];
  int64_t x_179 = mhs_mem[(x_89 + 4)];
  mhs_mem[(x3_54 + 1)] = x_178;
  int m_193 = 0;
  mhs_mem[(x3_54 + 2)] = x_179;
  int m_194 = 0;
  int64_t x_180 = mhs_mem[(x_89 + 5)];
  r_191 = j_11(x_89, x_180, m_194);
  r_186 = r_191;
  r_181 = r_186;
  r_171 = r_181; break; }
  default: abort();
  }
  return r_171;
}
static int64_t j_13(int64_t x_89, int64_t v_5, int m_108) {
  mhs_mem[x_89] = v_5;
  int m_109 = 0;
  int64_t x_90 = mhs_mem[x_89];
  int64_t x_91 = mhs_mem[x_90];
  int64_t r_192;
  switch ((x_91 == 4)) {
  case 0: {
  int64_t x_181 = mhs_mem[x_89];
  int r_193;
  switch (((x_89 + 1) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 1);
  r_193 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_193 = 0; break; }
  default: abort();
  }
  int m_195 = r_193;
  int64_t x_182 = mhs_mem[0];
  int64_t x_183 = mhs_mem[1];
  int64_t r_194;
  switch (((x_182 + 2) > x_183)) {
  case 0: {
  r_194 = x_182; break; }
  case 1: {
  int64_t x1_63 = gc(m_195);
  int64_t r_195;
  int64_t x3_55 = x1_63;
  int x4_63 = 0;
  int64_t r_196;
  switch (((x3_55 + 2) > mhs_mem[1])) {
  case 0: {
  r_196 = x3_55; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_196 = 0; break; }
  default: abort();
  }
  r_195 = r_196;
  r_194 = r_195; break; }
  default: abort();
  }
  int64_t x1_64 = r_194;
  int64_t r_197;
  int64_t x3_56 = x1_64;
  int x4_64 = 0;
  mhs_mem[0] = (x3_56 + 2);
  int m_196 = 0;
  mhs_mem[(x_89 + 1)] = x3_56;
  int m_197 = 0;
  mhs_mem[x3_56] = 5;
  int m_198 = 0;
  int64_t x_184 = mhs_mem[(x_89 + 1)];
  r_197 = j_12(x_89, x_184, m_198);
  r_192 = r_197; break; }
  case 1: {
  int64_t x_185 = mhs_mem[x_89];
  int64_t x_186 = mhs_mem[(x_185 + 1)];
  int64_t x_187 = mhs_mem[(x_185 + 2)];
  mhs_mem[(x_89 + 1)] = x_187;
  int m_199 = 0;
  int r_198;
  switch (((x_89 + 2) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 2);
  r_198 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_198 = 0; break; }
  default: abort();
  }
  int m_200 = r_198;
  int64_t x_188 = mhs_mem[0];
  int64_t x_189 = mhs_mem[1];
  int64_t r_199;
  switch (((x_188 + 3) > x_189)) {
  case 0: {
  r_199 = x_188; break; }
  case 1: {
  int64_t x1_65 = gc(m_200);
  int64_t r_200;
  int64_t x3_57 = x1_65;
  int x4_65 = 0;
  int64_t r_201;
  switch (((x3_57 + 3) > mhs_mem[1])) {
  case 0: {
  r_201 = x3_57; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_201 = 0; break; }
  default: abort();
  }
  r_200 = r_201;
  r_199 = r_200; break; }
  default: abort();
  }
  int64_t x1_66 = r_199;
  int64_t r_202;
  int64_t x3_58 = x1_66;
  int x4_66 = 0;
  mhs_mem[0] = (x3_58 + 3);
  int m_201 = 0;
  mhs_mem[(x_89 + 2)] = x3_58;
  int m_202 = 0;
  mhs_mem[x3_58] = 3;
  int m_203 = 0;
  int64_t x_190 = mhs_mem[(x_89 + 1)];
  mhs_mem[(x3_58 + 1)] = x_186;
  int m_204 = 0;
  mhs_mem[(x3_58 + 2)] = x_190;
  int m_205 = 0;
  int64_t x_191 = mhs_mem[(x_89 + 2)];
  r_202 = j_12(x_89, x_191, m_205);
  r_192 = r_202; break; }
  default: abort();
  }
  return r_192;
}

int64_t count(int m, int64_t n) {
  mhs_mem[2] = 2064;
  int m_101 = 0;
  mhs_mem[3] = 5128;
  int m_102 = 0;
  mhs_mem[5] = 3064;
  int m_103 = 0;
  mhs_mem[0] = 2064;
  int m_104 = 0;
  mhs_mem[1] = 5128;
  int m_105 = 0;
  mhs_mem[4] = 16;
  int m_106 = 0;
  mhs_mem[8] = 0;
  int m_107 = 0;
  int64_t x_89 = mhs_mem[4];
  int b_1 = (1 > n);
  int64_t r_203;
  switch (b_1) {
  case 0: {
  int r_204;
  switch ((x_89 > 2064)) {
  case 0: {
  mhs_mem[4] = x_89;
  r_204 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_204 = 0; break; }
  default: abort();
  }
  int m_206 = r_204;
  int64_t x_192 = mhs_mem[0];
  int64_t x_193 = mhs_mem[1];
  int64_t r_205;
  switch (((x_192 + 3) > x_193)) {
  case 0: {
  r_205 = x_192; break; }
  case 1: {
  int64_t x1_67 = gc(m_206);
  int64_t r_206;
  int64_t x3_59 = x1_67;
  int x4_67 = 0;
  int64_t r_207;
  switch (((x3_59 + 3) > mhs_mem[1])) {
  case 0: {
  r_207 = x3_59; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_207 = 0; break; }
  default: abort();
  }
  r_206 = r_207;
  r_205 = r_206; break; }
  default: abort();
  }
  int64_t x1_68 = r_205;
  int64_t r_208;
  int64_t x3_60 = x1_68;
  int x4_68 = 0;
  mhs_mem[0] = (x3_60 + 3);
  int m_207 = 0;
  mhs_mem[x_89] = x3_60;
  int m_208 = 0;
  mhs_mem[x3_60] = 11;
  int m_209 = 0;
  int64_t x_194 = mhs_mem[x_89];
  mhs_mem[(x_194 + 1)] = 1;
  int m_210 = 0;
  mhs_mem[(x_194 + 2)] = n;
  int m_211 = 0;
  int r_209;
  switch (((x_89 + 1) > 2064)) {
  case 0: {
  mhs_mem[4] = (x_89 + 1);
  r_209 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_209 = 0; break; }
  default: abort();
  }
  int m_212 = r_209;
  int64_t x_195 = mhs_mem[0];
  int64_t x_196 = mhs_mem[1];
  int64_t r_210;
  switch (((x_195 + 3) > x_196)) {
  case 0: {
  r_210 = x_195; break; }
  case 1: {
  int64_t x1_69 = gc(m_212);
  int64_t r_211;
  int64_t x3_61 = x1_69;
  int x4_69 = 0;
  int64_t r_212;
  switch (((x3_61 + 3) > mhs_mem[1])) {
  case 0: {
  r_212 = x3_61; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_212 = 0; break; }
  default: abort();
  }
  r_211 = r_212;
  r_210 = r_211; break; }
  default: abort();
  }
  int64_t x1_70 = r_210;
  int64_t r_213;
  int64_t x3_62 = x1_70;
  int x4_70 = 0;
  mhs_mem[0] = (x3_62 + 3);
  int m_213 = 0;
  mhs_mem[(x_89 + 1)] = x3_62;
  int m_214 = 0;
  mhs_mem[x3_62] = 4;
  int m_215 = 0;
  int64_t x_197 = mhs_mem[x_89];
  mhs_mem[(x3_62 + 1)] = 1;
  int m_216 = 0;
  mhs_mem[(x3_62 + 2)] = x_197;
  int m_217 = 0;
  int64_t x_198 = mhs_mem[(x_89 + 1)];
  r_213 = j_13(x_89, x_198, m_217);
  r_208 = r_213;
  r_203 = r_208; break; }
  case 1: {
  int r_214;
  switch ((x_89 > 2064)) {
  case 0: {
  mhs_mem[4] = x_89;
  r_214 = 0; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",447:65: root stack overflow"); abort();
  r_214 = 0; break; }
  default: abort();
  }
  int m_218 = r_214;
  int64_t x_199 = mhs_mem[0];
  int64_t x_200 = mhs_mem[1];
  int64_t r_215;
  switch (((x_199 + 2) > x_200)) {
  case 0: {
  r_215 = x_199; break; }
  case 1: {
  int64_t x1_71 = gc(m_218);
  int64_t r_216;
  int64_t x3_63 = x1_71;
  int x4_71 = 0;
  int64_t r_217;
  switch (((x3_63 + 2) > mhs_mem[1])) {
  case 0: {
  r_217 = x3_63; break; }
  case 1: {
  fprintf(stderr, "%s\n", "\"/home/dmjio/Desktop/MicroHs-lambda/bin/../lib/Staged/Low/Lazy.hs\",485:89: out of memory"); abort();
  r_217 = 0; break; }
  default: abort();
  }
  r_216 = r_217;
  r_215 = r_216; break; }
  default: abort();
  }
  int64_t x1_72 = r_215;
  int64_t r_218;
  int64_t x3_64 = x1_72;
  int x4_72 = 0;
  mhs_mem[0] = (x3_64 + 2);
  int m_219 = 0;
  mhs_mem[x_89] = x3_64;
  int m_220 = 0;
  mhs_mem[x3_64] = 6;
  int m_221 = 0;
  int64_t x_201 = mhs_mem[x_89];
  r_218 = j_13(x_89, x_201, m_221);
  r_203 = r_218; break; }
  default: abort();
  }
  int64_t x1_73 = r_203;
  int64_t r_219;
  int64_t x3_65 = x1_73;
  int x4_73 = 0;
  r_219 = x3_65;
  return r_219;
}
int main(int argc, char **argv) {
  for (int i = 1; i < argc; i++) {
    printf("%lld\n", (long long)count(0, atoll(argv[i])));
    fprintf(stderr, "%s %s: %lld collections\n", "count", argv[i], (long long)mhs_mem[8]);
  }
  return 0;
}
