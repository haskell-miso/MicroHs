#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

/* Data.Bool_Type.Bool: False=0, True=1 */

static int64_t f0(int64_t p);
static int64_t t0(int64_t p_1);
static int64_t t1(int64_t p_2);
static int64_t t2(int64_t p_3);
static int64_t j_1(int64_t v) {
  int64_t f_1 = ((int64_t *)v)[0];
  int64_t x_1 = f_1;
  int64_t r_2;
  switch ((x_1 == 7)) {
  case 0: {
  int64_t f_3 = ((int64_t *)v)[1];
  int64_t x_2 = f_3;
  int64_t f_4 = ((int64_t *)v)[2];
  int64_t x_3 = f_4;
  int64_t f_5 = ((int64_t *)x_3)[0];
  int64_t x_4 = f_5;
  int64_t r_6;
  switch ((x_4 == 1)) {
  case 0: {
  int64_t x_5 = t2(x_3);
  int64_t *u_7 = (int64_t *)x_3;
  u_7[0] = 1;
  u_7[1] = x_5;
  int64_t u = 0;
  r_6 = x_5; break; }
  case 1: {
  int64_t f_8 = ((int64_t *)x_3)[1];
  r_6 = f_8; break; }
  default: abort();
  }
  int64_t x_6 = r_6;
  int64_t x_7 = f0(x_6);
  int64_t f_9 = ((int64_t *)x_2)[0];
  int64_t x_8 = f_9;
  int64_t r_10;
  switch ((x_8 == 1)) {
  case 0: {
  int64_t x_9 = t1(x_2);
  int64_t *u_11 = (int64_t *)x_2;
  u_11[0] = 1;
  u_11[1] = x_9;
  int64_t u_1 = 0;
  r_10 = x_9; break; }
  case 1: {
  int64_t f_12 = ((int64_t *)x_2)[1];
  r_10 = f_12; break; }
  default: abort();
  }
  int64_t x_10 = r_10;
  int64_t f_13 = ((int64_t *)x_10)[1];
  int64_t x_11 = f_13;
  int64_t x_12 = (x_11 + x_7);
  r_2 = x_12; break; }
  case 1: {
  int64_t f_14 = ((int64_t *)v)[1];
  int64_t x_13 = f_14;
  r_2 = x_13; break; }
  default: abort();
  }
  return r_2;
}
static int64_t f0(int64_t p) {
  int64_t f_0 = ((int64_t *)p)[0];
  int64_t x = f_0;
  int64_t r_15;
  switch ((x == 8)) {
  case 0: {
  int64_t f_16 = ((int64_t *)p)[1];
  int64_t x_14 = f_16;
  int64_t f_17 = ((int64_t *)p)[2];
  int64_t x_15 = f_17;
  int64_t *n_18 = malloc(3 * sizeof(int64_t));
  n_18[0] = 9;
  n_18[1] = x_14;
  n_18[2] = x_15;
  int64_t x_16 = (int64_t)n_18;
  r_15 = j_1(x_16); break; }
  case 1: {
  int64_t *n_19 = malloc(2 * sizeof(int64_t));
  n_19[0] = 7;
  n_19[1] = 0;
  int64_t x_17 = (int64_t)n_19;
  r_15 = j_1(x_17); break; }
  default: abort();
  }
  return r_15;
}
static int64_t t0(int64_t p_1) {
  int64_t f_20 = ((int64_t *)p_1)[1];
  int64_t x_18 = f_20;
  int64_t f_21 = ((int64_t *)p_1)[2];
  int64_t x_19 = f_21;
  int64_t x_20 = (x_18 + 1);
  int b = (x_20 > x_19);
  int64_t r_22;
  switch (b) {
  case 0: {
  int64_t *n_23 = malloc(3 * sizeof(int64_t));
  n_23[0] = 11;
  n_23[1] = 0;
  n_23[2] = 0;
  int64_t x_21 = (int64_t)n_23;
  int64_t *u_24 = (int64_t *)x_21;
  u_24[0] = 11;
  u_24[1] = x_20;
  u_24[2] = x_19;
  int64_t u_2 = 0;
  int64_t *n_25 = malloc(3 * sizeof(int64_t));
  n_25[0] = 4;
  n_25[1] = x_20;
  n_25[2] = x_21;
  int64_t x_22 = (int64_t)n_25;
  r_22 = x_22; break; }
  case 1: {
  int64_t *n_26 = malloc(1 * sizeof(int64_t));
  n_26[0] = 6;
  int64_t x_23 = (int64_t)n_26;
  r_22 = x_23; break; }
  default: abort();
  }
  return r_22;
}
static int64_t t1(int64_t p_2) {
  int64_t f_27 = ((int64_t *)p_2)[1];
  int64_t x_24 = f_27;
  int64_t x_25 = (x_24 * x_24);
  int64_t *n_28 = malloc(2 * sizeof(int64_t));
  n_28[0] = 2;
  n_28[1] = x_25;
  int64_t x_26 = (int64_t)n_28;
  return x_26;
}
static int64_t j_4(int64_t v_3) {
  int64_t f_35 = ((int64_t *)v_3)[0];
  int64_t x_32 = f_35;
  int64_t r_36;
  switch ((x_32 == 3)) {
  case 0: {
  int64_t *n_37 = malloc(1 * sizeof(int64_t));
  n_37[0] = 8;
  int64_t x_33 = (int64_t)n_37;
  r_36 = x_33; break; }
  case 1: {
  int64_t f_38 = ((int64_t *)v_3)[1];
  int64_t x_34 = f_38;
  int64_t f_39 = ((int64_t *)v_3)[2];
  int64_t x_35 = f_39;
  int64_t *n_40 = malloc(2 * sizeof(int64_t));
  n_40[0] = 12;
  n_40[1] = 0;
  int64_t x_36 = (int64_t)n_40;
  int64_t *u_41 = (int64_t *)x_36;
  u_41[0] = 12;
  u_41[1] = x_34;
  int64_t u_4 = 0;
  int64_t *n_42 = malloc(2 * sizeof(int64_t));
  n_42[0] = 13;
  n_42[1] = 0;
  int64_t x_37 = (int64_t)n_42;
  int64_t *u_43 = (int64_t *)x_37;
  u_43[0] = 13;
  u_43[1] = x_35;
  int64_t u_5 = 0;
  int64_t *n_44 = malloc(3 * sizeof(int64_t));
  n_44[0] = 10;
  n_44[1] = x_36;
  n_44[2] = x_37;
  int64_t x_38 = (int64_t)n_44;
  r_36 = x_38; break; }
  default: abort();
  }
  return r_36;
}
static int64_t t2(int64_t p_3) {
  int64_t f_29 = ((int64_t *)p_3)[1];
  int64_t x_27 = f_29;
  int64_t f_30 = ((int64_t *)x_27)[0];
  int64_t x_28 = f_30;
  int64_t r_31;
  switch ((x_28 == 1)) {
  case 0: {
  int64_t x_29 = t0(x_27);
  int64_t *u_32 = (int64_t *)x_27;
  u_32[0] = 1;
  u_32[1] = x_29;
  int64_t u_3 = 0;
  r_31 = x_29; break; }
  case 1: {
  int64_t f_33 = ((int64_t *)x_27)[1];
  r_31 = f_33; break; }
  default: abort();
  }
  int64_t x_30 = r_31;
  int64_t f_34 = ((int64_t *)x_30)[0];
  int64_t x_31 = f_34;
  int64_t r_45;
  switch ((x_31 == 4)) {
  case 0: {
  int64_t *n_46 = malloc(1 * sizeof(int64_t));
  n_46[0] = 5;
  int64_t x_39 = (int64_t)n_46;
  r_45 = j_4(x_39); break; }
  case 1: {
  int64_t f_47 = ((int64_t *)x_30)[1];
  int64_t x_40 = f_47;
  int64_t f_48 = ((int64_t *)x_30)[2];
  int64_t x_41 = f_48;
  int64_t *n_49 = malloc(3 * sizeof(int64_t));
  n_49[0] = 3;
  n_49[1] = x_40;
  n_49[2] = x_41;
  int64_t x_42 = (int64_t)n_49;
  r_45 = j_4(x_42); break; }
  default: abort();
  }
  return r_45;
}
static int64_t j_5(int64_t v_7) {
  int64_t x_45 = f0(v_7);
  return x_45;
}
static int64_t j_6(int64_t v_6) {
  int64_t f_51 = ((int64_t *)v_6)[0];
  int64_t x_44 = f_51;
  int64_t r_52;
  switch ((x_44 == 3)) {
  case 0: {
  int64_t *n_53 = malloc(1 * sizeof(int64_t));
  n_53[0] = 8;
  int64_t x_46 = (int64_t)n_53;
  r_52 = j_5(x_46); break; }
  case 1: {
  int64_t f_54 = ((int64_t *)v_6)[1];
  int64_t x_47 = f_54;
  int64_t f_55 = ((int64_t *)v_6)[2];
  int64_t x_48 = f_55;
  int64_t *n_56 = malloc(2 * sizeof(int64_t));
  n_56[0] = 12;
  n_56[1] = 0;
  int64_t x_49 = (int64_t)n_56;
  int64_t *u_57 = (int64_t *)x_49;
  u_57[0] = 12;
  u_57[1] = x_47;
  int64_t u_6 = 0;
  int64_t *n_58 = malloc(2 * sizeof(int64_t));
  n_58[0] = 13;
  n_58[1] = 0;
  int64_t x_50 = (int64_t)n_58;
  int64_t *u_59 = (int64_t *)x_50;
  u_59[0] = 13;
  u_59[1] = x_48;
  int64_t u_7 = 0;
  int64_t *n_60 = malloc(3 * sizeof(int64_t));
  n_60[0] = 10;
  n_60[1] = x_49;
  n_60[2] = x_50;
  int64_t x_51 = (int64_t)n_60;
  r_52 = j_5(x_51); break; }
  default: abort();
  }
  return r_52;
}
static int64_t j_7(int64_t v_5) {
  int64_t f_50 = ((int64_t *)v_5)[0];
  int64_t x_43 = f_50;
  int64_t r_61;
  switch ((x_43 == 4)) {
  case 0: {
  int64_t *n_62 = malloc(1 * sizeof(int64_t));
  n_62[0] = 5;
  int64_t x_52 = (int64_t)n_62;
  r_61 = j_6(x_52); break; }
  case 1: {
  int64_t f_63 = ((int64_t *)v_5)[1];
  int64_t x_53 = f_63;
  int64_t f_64 = ((int64_t *)v_5)[2];
  int64_t x_54 = f_64;
  int64_t *n_65 = malloc(3 * sizeof(int64_t));
  n_65[0] = 3;
  n_65[1] = x_53;
  n_65[2] = x_54;
  int64_t x_55 = (int64_t)n_65;
  r_61 = j_6(x_55); break; }
  default: abort();
  }
  return r_61;
}

int64_t sumSquares(int64_t n) {
  int b_1 = (1 > n);
  int64_t r_66;
  switch (b_1) {
  case 0: {
  int64_t *n_67 = malloc(3 * sizeof(int64_t));
  n_67[0] = 11;
  n_67[1] = 0;
  n_67[2] = 0;
  int64_t x_56 = (int64_t)n_67;
  int64_t *u_68 = (int64_t *)x_56;
  u_68[0] = 11;
  u_68[1] = 1;
  u_68[2] = n;
  int64_t u_8 = 0;
  int64_t *n_69 = malloc(3 * sizeof(int64_t));
  n_69[0] = 4;
  n_69[1] = 1;
  n_69[2] = x_56;
  int64_t x_57 = (int64_t)n_69;
  r_66 = j_7(x_57); break; }
  case 1: {
  int64_t *n_70 = malloc(1 * sizeof(int64_t));
  n_70[0] = 6;
  int64_t x_58 = (int64_t)n_70;
  r_66 = j_7(x_58); break; }
  default: abort();
  }
  return r_66;
}
int main(int argc, char **argv) {
  for (int i = 1; i < argc; i++) printf("%lld\n", (long long)sumSquares(atoll(argv[i])));
  return 0;
}
