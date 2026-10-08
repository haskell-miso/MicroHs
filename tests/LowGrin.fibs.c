#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

/* Data.Bool_Type.Bool: False=0, True=1 */

static int64_t f0(int64_t p, int64_t p_1);
static int64_t t0(int64_t p_2);
static int64_t t1(int64_t p_3);
static int64_t t2(int64_t p_4);
static int64_t t3(int64_t p_5);
static int64_t t4(int64_t p_6);
static int64_t f0(int64_t p, int64_t p_1) {
  int64_t f_0 = ((int64_t *)p)[0];
  int64_t x = f_0;
  int64_t r_1;
  switch ((x == 1)) {
  case 0: {
  int64_t x_1 = t3(p);
  int64_t *u_2 = (int64_t *)p;
  u_2[0] = 1;
  u_2[1] = x_1;
  int64_t u = 0;
  r_1 = x_1; break; }
  case 1: {
  int64_t f_3 = ((int64_t *)p)[1];
  r_1 = f_3; break; }
  default: abort();
  }
  int64_t x_2 = r_1;
  int64_t f_4 = ((int64_t *)x_2)[1];
  int64_t x_3 = f_4;
  int64_t f_5 = ((int64_t *)x_2)[2];
  int64_t x_4 = f_5;
  int64_t f_6 = ((int64_t *)p_1)[0];
  int64_t x_5 = f_6;
  int64_t r_7;
  switch ((x_5 == 1)) {
  case 0: {
  int64_t x_6 = t4(p_1);
  int64_t *u_8 = (int64_t *)p_1;
  u_8[0] = 1;
  u_8[1] = x_6;
  int64_t u_1 = 0;
  r_7 = x_6; break; }
  case 1: {
  int64_t f_9 = ((int64_t *)p_1)[1];
  r_7 = f_9; break; }
  default: abort();
  }
  int64_t x_7 = r_7;
  int64_t f_10 = ((int64_t *)x_7)[1];
  int64_t x_8 = f_10;
  int b = (x_8 == 0);
  int64_t r_11;
  switch (b) {
  case 0: {
  int64_t f_12 = ((int64_t *)x_4)[0];
  int64_t x_9 = f_12;
  int64_t r_13;
  switch ((x_9 == 1)) {
  case 0: {
  int64_t x_10 = t3(x_4);
  int64_t *u_14 = (int64_t *)x_4;
  u_14[0] = 1;
  u_14[1] = x_10;
  int64_t u_2 = 0;
  r_13 = x_10; break; }
  case 1: {
  int64_t f_15 = ((int64_t *)x_4)[1];
  r_13 = f_15; break; }
  default: abort();
  }
  int64_t x_11 = r_13;
  int64_t f_16 = ((int64_t *)x_11)[1];
  int64_t x_12 = f_16;
  int64_t f_17 = ((int64_t *)x_11)[2];
  int64_t x_13 = f_17;
  int64_t f_18 = ((int64_t *)x_7)[1];
  int64_t x_14 = f_18;
  int64_t x_15 = (x_14 - 1);
  int b_1 = (x_15 == 0);
  int64_t r_19;
  switch (b_1) {
  case 0: {
  int64_t *n_20 = malloc(2 * sizeof(int64_t));
  n_20[0] = 11;
  n_20[1] = 0;
  int64_t x_16 = (int64_t)n_20;
  int64_t *u_21 = (int64_t *)x_16;
  u_21[0] = 11;
  u_21[1] = x_15;
  int64_t u_3 = 0;
  int64_t x_17 = f0(x_13, x_16);
  r_19 = x_17; break; }
  case 1: {
  int64_t f_22 = ((int64_t *)x_12)[0];
  int64_t x_18 = f_22;
  int64_t r_23;
  switch ((x_18 == 1)) {
  case 0: {
  int64_t r_24;
  switch ((x_18 == 7)) {
  case 0: {
  int64_t r_25;
  switch ((x_18 == 8)) {
  case 0: {
  int64_t x_19 = t2(x_12);
  int64_t *u_26 = (int64_t *)x_12;
  u_26[0] = 1;
  u_26[1] = x_19;
  int64_t u_4 = 0;
  r_25 = x_19; break; }
  case 1: {
  int64_t x_20 = t1(x_12);
  int64_t *u_27 = (int64_t *)x_12;
  u_27[0] = 1;
  u_27[1] = x_20;
  int64_t u_5 = 0;
  r_25 = x_20; break; }
  default: abort();
  }
  r_24 = r_25; break; }
  case 1: {
  int64_t x_21 = t0(x_12);
  int64_t *u_28 = (int64_t *)x_12;
  u_28[0] = 1;
  u_28[1] = x_21;
  int64_t u_6 = 0;
  r_24 = x_21; break; }
  default: abort();
  }
  r_23 = r_24; break; }
  case 1: {
  int64_t f_29 = ((int64_t *)x_12)[1];
  r_23 = f_29; break; }
  default: abort();
  }
  int64_t x_22 = r_23;
  int64_t f_30 = ((int64_t *)x_22)[1];
  int64_t x_23 = f_30;
  r_19 = x_23; break; }
  default: abort();
  }
  r_11 = r_19; break; }
  case 1: {
  int64_t f_31 = ((int64_t *)x_3)[0];
  int64_t x_24 = f_31;
  int64_t r_32;
  switch ((x_24 == 1)) {
  case 0: {
  int64_t r_33;
  switch ((x_24 == 7)) {
  case 0: {
  int64_t r_34;
  switch ((x_24 == 8)) {
  case 0: {
  int64_t x_25 = t2(x_3);
  int64_t *u_35 = (int64_t *)x_3;
  u_35[0] = 1;
  u_35[1] = x_25;
  int64_t u_7 = 0;
  r_34 = x_25; break; }
  case 1: {
  int64_t x_26 = t1(x_3);
  int64_t *u_36 = (int64_t *)x_3;
  u_36[0] = 1;
  u_36[1] = x_26;
  int64_t u_8 = 0;
  r_34 = x_26; break; }
  default: abort();
  }
  r_33 = r_34; break; }
  case 1: {
  int64_t x_27 = t0(x_3);
  int64_t *u_37 = (int64_t *)x_3;
  u_37[0] = 1;
  u_37[1] = x_27;
  int64_t u_9 = 0;
  r_33 = x_27; break; }
  default: abort();
  }
  r_32 = r_33; break; }
  case 1: {
  int64_t f_38 = ((int64_t *)x_3)[1];
  r_32 = f_38; break; }
  default: abort();
  }
  int64_t x_28 = r_32;
  int64_t f_39 = ((int64_t *)x_28)[1];
  int64_t x_29 = f_39;
  r_11 = x_29; break; }
  default: abort();
  }
  return r_11;
}
static int64_t t0(int64_t p_2) {
  int64_t f_40 = ((int64_t *)p_2)[1];
  int64_t x_30 = f_40;
  int64_t f_41 = ((int64_t *)p_2)[2];
  int64_t x_31 = f_41;
  int64_t x_32 = (x_30 + x_31);
  int64_t *n_42 = malloc(2 * sizeof(int64_t));
  n_42[0] = 2;
  n_42[1] = x_32;
  int64_t x_33 = (int64_t)n_42;
  return x_33;
}
static int64_t t1(int64_t p_3) {
  int64_t f_43 = ((int64_t *)p_3)[1];
  int64_t x_34 = f_43;
  int64_t f_44 = ((int64_t *)p_3)[2];
  int64_t x_35 = f_44;
  int64_t f_45 = ((int64_t *)x_35)[0];
  int64_t x_36 = f_45;
  int64_t r_46;
  switch ((x_36 == 1)) {
  case 0: {
  int64_t r_47;
  switch ((x_36 == 7)) {
  case 0: {
  int64_t r_48;
  switch ((x_36 == 8)) {
  case 0: {
  int64_t x_37 = t2(x_35);
  int64_t *u_49 = (int64_t *)x_35;
  u_49[0] = 1;
  u_49[1] = x_37;
  int64_t u_10 = 0;
  r_48 = x_37; break; }
  case 1: {
  int64_t x_38 = t1(x_35);
  int64_t *u_50 = (int64_t *)x_35;
  u_50[0] = 1;
  u_50[1] = x_38;
  int64_t u_11 = 0;
  r_48 = x_38; break; }
  default: abort();
  }
  r_47 = r_48; break; }
  case 1: {
  int64_t x_39 = t0(x_35);
  int64_t *u_51 = (int64_t *)x_35;
  u_51[0] = 1;
  u_51[1] = x_39;
  int64_t u_12 = 0;
  r_47 = x_39; break; }
  default: abort();
  }
  r_46 = r_47; break; }
  case 1: {
  int64_t f_52 = ((int64_t *)x_35)[1];
  r_46 = f_52; break; }
  default: abort();
  }
  int64_t x_40 = r_46;
  int64_t f_53 = ((int64_t *)x_40)[1];
  int64_t x_41 = f_53;
  int64_t x_42 = (x_34 + x_41);
  int64_t *n_54 = malloc(2 * sizeof(int64_t));
  n_54[0] = 2;
  n_54[1] = x_42;
  int64_t x_43 = (int64_t)n_54;
  return x_43;
}
static int64_t t2(int64_t p_4) {
  int64_t f_55 = ((int64_t *)p_4)[1];
  int64_t x_44 = f_55;
  int64_t f_56 = ((int64_t *)p_4)[2];
  int64_t x_45 = f_56;
  int64_t f_57 = ((int64_t *)x_45)[0];
  int64_t x_46 = f_57;
  int64_t r_58;
  switch ((x_46 == 1)) {
  case 0: {
  int64_t r_59;
  switch ((x_46 == 7)) {
  case 0: {
  int64_t r_60;
  switch ((x_46 == 8)) {
  case 0: {
  int64_t x_47 = t2(x_45);
  int64_t *u_61 = (int64_t *)x_45;
  u_61[0] = 1;
  u_61[1] = x_47;
  int64_t u_13 = 0;
  r_60 = x_47; break; }
  case 1: {
  int64_t x_48 = t1(x_45);
  int64_t *u_62 = (int64_t *)x_45;
  u_62[0] = 1;
  u_62[1] = x_48;
  int64_t u_14 = 0;
  r_60 = x_48; break; }
  default: abort();
  }
  r_59 = r_60; break; }
  case 1: {
  int64_t x_49 = t0(x_45);
  int64_t *u_63 = (int64_t *)x_45;
  u_63[0] = 1;
  u_63[1] = x_49;
  int64_t u_15 = 0;
  r_59 = x_49; break; }
  default: abort();
  }
  r_58 = r_59; break; }
  case 1: {
  int64_t f_64 = ((int64_t *)x_45)[1];
  r_58 = f_64; break; }
  default: abort();
  }
  int64_t x_50 = r_58;
  int64_t f_65 = ((int64_t *)x_44)[0];
  int64_t x_51 = f_65;
  int64_t r_66;
  switch ((x_51 == 1)) {
  case 0: {
  int64_t r_67;
  switch ((x_51 == 7)) {
  case 0: {
  int64_t r_68;
  switch ((x_51 == 8)) {
  case 0: {
  int64_t x_52 = t2(x_44);
  int64_t *u_69 = (int64_t *)x_44;
  u_69[0] = 1;
  u_69[1] = x_52;
  int64_t u_16 = 0;
  r_68 = x_52; break; }
  case 1: {
  int64_t x_53 = t1(x_44);
  int64_t *u_70 = (int64_t *)x_44;
  u_70[0] = 1;
  u_70[1] = x_53;
  int64_t u_17 = 0;
  r_68 = x_53; break; }
  default: abort();
  }
  r_67 = r_68; break; }
  case 1: {
  int64_t x_54 = t0(x_44);
  int64_t *u_71 = (int64_t *)x_44;
  u_71[0] = 1;
  u_71[1] = x_54;
  int64_t u_18 = 0;
  r_67 = x_54; break; }
  default: abort();
  }
  r_66 = r_67; break; }
  case 1: {
  int64_t f_72 = ((int64_t *)x_44)[1];
  r_66 = f_72; break; }
  default: abort();
  }
  int64_t x_55 = r_66;
  int64_t f_73 = ((int64_t *)x_55)[1];
  int64_t x_56 = f_73;
  int64_t f_74 = ((int64_t *)x_50)[1];
  int64_t x_57 = f_74;
  int64_t x_58 = (x_56 + x_57);
  int64_t *n_75 = malloc(2 * sizeof(int64_t));
  n_75[0] = 2;
  n_75[1] = x_58;
  int64_t x_59 = (int64_t)n_75;
  return x_59;
}
static int64_t j_3(int64_t x_61, int64_t v_2) {
  int64_t f_84 = ((int64_t *)v_2)[0];
  int64_t x_66 = f_84;
  int64_t r_85;
  switch ((x_66 == 3)) {
  case 0: {
  int64_t f_86 = ((int64_t *)v_2)[1];
  int64_t x_67 = f_86;
  int64_t f_87 = ((int64_t *)v_2)[2];
  int64_t x_68 = f_87;
  int64_t f_88 = ((int64_t *)x_61)[0];
  int64_t x_69 = f_88;
  int64_t r_89;
  switch ((x_69 == 1)) {
  case 0: {
  int64_t r_90;
  switch ((x_69 == 10)) {
  case 0: {
  r_90 = x_61; break; }
  case 1: {
  int64_t x_70 = t3(x_61);
  int64_t *u_91 = (int64_t *)x_61;
  u_91[0] = 1;
  u_91[1] = x_70;
  int64_t u_20 = 0;
  r_90 = x_70; break; }
  default: abort();
  }
  r_89 = r_90; break; }
  case 1: {
  int64_t f_92 = ((int64_t *)x_61)[1];
  r_89 = f_92; break; }
  default: abort();
  }
  int64_t x_71 = r_89;
  int64_t f_93 = ((int64_t *)x_71)[1];
  int64_t x_72 = f_93;
  int64_t f_94 = ((int64_t *)x_71)[2];
  int64_t x_73 = f_94;
  int64_t *n_95 = malloc(3 * sizeof(int64_t));
  n_95[0] = 8;
  n_95[1] = 0;
  n_95[2] = 0;
  int64_t x_74 = (int64_t)n_95;
  int64_t *u_96 = (int64_t *)x_74;
  u_96[0] = 8;
  u_96[1] = x_67;
  u_96[2] = x_72;
  int64_t u_21 = 0;
  int64_t *n_97 = malloc(3 * sizeof(int64_t));
  n_97[0] = 10;
  n_97[1] = 0;
  n_97[2] = 0;
  int64_t x_75 = (int64_t)n_97;
  int64_t *u_98 = (int64_t *)x_75;
  u_98[0] = 10;
  u_98[1] = x_68;
  u_98[2] = x_73;
  int64_t u_22 = 0;
  int64_t *n_99 = malloc(3 * sizeof(int64_t));
  n_99[0] = 4;
  n_99[1] = x_74;
  n_99[2] = x_75;
  int64_t x_76 = (int64_t)n_99;
  r_85 = x_76; break; }
  case 1: {
  int64_t f_100 = ((int64_t *)v_2)[1];
  int64_t x_77 = f_100;
  int64_t f_101 = ((int64_t *)v_2)[2];
  int64_t x_78 = f_101;
  int64_t f_102 = ((int64_t *)x_61)[0];
  int64_t x_79 = f_102;
  int64_t r_103;
  switch ((x_79 == 1)) {
  case 0: {
  int64_t r_104;
  switch ((x_79 == 10)) {
  case 0: {
  r_104 = x_61; break; }
  case 1: {
  int64_t x_80 = t3(x_61);
  int64_t *u_105 = (int64_t *)x_61;
  u_105[0] = 1;
  u_105[1] = x_80;
  int64_t u_23 = 0;
  r_104 = x_80; break; }
  default: abort();
  }
  r_103 = r_104; break; }
  case 1: {
  int64_t f_106 = ((int64_t *)x_61)[1];
  r_103 = f_106; break; }
  default: abort();
  }
  int64_t x_81 = r_103;
  int64_t f_107 = ((int64_t *)x_81)[1];
  int64_t x_82 = f_107;
  int64_t f_108 = ((int64_t *)x_81)[2];
  int64_t x_83 = f_108;
  int64_t *n_109 = malloc(3 * sizeof(int64_t));
  n_109[0] = 9;
  n_109[1] = 0;
  n_109[2] = 0;
  int64_t x_84 = (int64_t)n_109;
  int64_t *u_110 = (int64_t *)x_84;
  u_110[0] = 9;
  u_110[1] = x_77;
  u_110[2] = x_82;
  int64_t u_24 = 0;
  int64_t *n_111 = malloc(3 * sizeof(int64_t));
  n_111[0] = 10;
  n_111[1] = 0;
  n_111[2] = 0;
  int64_t x_85 = (int64_t)n_111;
  int64_t *u_112 = (int64_t *)x_85;
  u_112[0] = 10;
  u_112[1] = x_78;
  u_112[2] = x_83;
  int64_t u_25 = 0;
  int64_t *n_113 = malloc(3 * sizeof(int64_t));
  n_113[0] = 4;
  n_113[1] = x_84;
  n_113[2] = x_85;
  int64_t x_86 = (int64_t)n_113;
  r_85 = x_86; break; }
  default: abort();
  }
  return r_85;
}
static int64_t t3(int64_t p_5) {
  int64_t f_76 = ((int64_t *)p_5)[1];
  int64_t x_60 = f_76;
  int64_t f_77 = ((int64_t *)p_5)[2];
  int64_t x_61 = f_77;
  int64_t f_78 = ((int64_t *)x_60)[0];
  int64_t x_62 = f_78;
  int64_t r_79;
  switch ((x_62 == 1)) {
  case 0: {
  int64_t r_80;
  switch ((x_62 == 10)) {
  case 0: {
  r_80 = x_60; break; }
  case 1: {
  int64_t x_63 = t3(x_60);
  int64_t *u_81 = (int64_t *)x_60;
  u_81[0] = 1;
  u_81[1] = x_63;
  int64_t u_19 = 0;
  r_80 = x_63; break; }
  default: abort();
  }
  r_79 = r_80; break; }
  case 1: {
  int64_t f_82 = ((int64_t *)x_60)[1];
  r_79 = f_82; break; }
  default: abort();
  }
  int64_t x_64 = r_79;
  int64_t f_83 = ((int64_t *)x_64)[0];
  int64_t x_65 = f_83;
  int64_t r_114;
  switch ((x_65 == 4)) {
  case 0: {
  int64_t f_115 = ((int64_t *)x_64)[1];
  int64_t x_87 = f_115;
  int64_t f_116 = ((int64_t *)x_64)[2];
  int64_t x_88 = f_116;
  int64_t *n_117 = malloc(3 * sizeof(int64_t));
  n_117[0] = 5;
  n_117[1] = x_87;
  n_117[2] = x_88;
  int64_t x_89 = (int64_t)n_117;
  r_114 = j_3(x_61, x_89); break; }
  case 1: {
  int64_t f_118 = ((int64_t *)x_64)[1];
  int64_t x_90 = f_118;
  int64_t f_119 = ((int64_t *)x_64)[2];
  int64_t x_91 = f_119;
  int64_t *n_120 = malloc(3 * sizeof(int64_t));
  n_120[0] = 3;
  n_120[1] = x_90;
  n_120[2] = x_91;
  int64_t x_92 = (int64_t)n_120;
  r_114 = j_3(x_61, x_92); break; }
  default: abort();
  }
  return r_114;
}
static int64_t t4(int64_t p_6) {
  int64_t f_121 = ((int64_t *)p_6)[1];
  int64_t x_93 = f_121;
  int64_t x_94 = (x_93 - 1);
  int64_t *n_122 = malloc(2 * sizeof(int64_t));
  n_122[0] = 2;
  n_122[1] = x_94;
  int64_t x_95 = (int64_t)n_122;
  return x_95;
}

int64_t fibs(int64_t n) {
  int b_2 = (n == 0);
  int64_t r_123;
  switch (b_2) {
  case 0: {
  int64_t x_96 = (n - 1);
  int b_3 = (x_96 == 0);
  int64_t r_124;
  switch (b_3) {
  case 0: {
  int64_t x_97 = (x_96 - 1);
  int b_4 = (x_97 == 0);
  int64_t r_125;
  switch (b_4) {
  case 0: {
  int64_t *n_126 = malloc(3 * sizeof(int64_t));
  n_126[0] = 10;
  n_126[1] = 0;
  n_126[2] = 0;
  int64_t x_98 = (int64_t)n_126;
  int64_t *n_127 = malloc(3 * sizeof(int64_t));
  n_127[0] = 6;
  n_127[1] = 0;
  n_127[2] = 0;
  int64_t x_99 = (int64_t)n_127;
  int64_t *n_128 = malloc(3 * sizeof(int64_t));
  n_128[0] = 4;
  n_128[1] = 0;
  n_128[2] = 0;
  int64_t x_100 = (int64_t)n_128;
  int64_t *n_129 = malloc(3 * sizeof(int64_t));
  n_129[0] = 7;
  n_129[1] = 0;
  n_129[2] = 0;
  int64_t x_101 = (int64_t)n_129;
  int64_t *u_130 = (int64_t *)x_101;
  u_130[0] = 7;
  u_130[1] = 0;
  u_130[2] = 1;
  int64_t u_26 = 0;
  int64_t *n_131 = malloc(3 * sizeof(int64_t));
  n_131[0] = 10;
  n_131[1] = 0;
  n_131[2] = 0;
  int64_t x_102 = (int64_t)n_131;
  int64_t *u_132 = (int64_t *)x_102;
  u_132[0] = 10;
  u_132[1] = x_99;
  u_132[2] = x_100;
  int64_t u_27 = 0;
  int64_t *u_133 = (int64_t *)x_100;
  u_133[0] = 4;
  u_133[1] = x_101;
  u_133[2] = x_102;
  int64_t u_28 = 0;
  int64_t *u_134 = (int64_t *)x_99;
  u_134[0] = 6;
  u_134[1] = 1;
  u_134[2] = x_100;
  int64_t u_29 = 0;
  int64_t *u_135 = (int64_t *)x_98;
  u_135[0] = 10;
  u_135[1] = x_99;
  u_135[2] = x_100;
  int64_t u_30 = 0;
  int64_t *n_136 = malloc(2 * sizeof(int64_t));
  n_136[0] = 11;
  n_136[1] = 0;
  int64_t x_103 = (int64_t)n_136;
  int64_t *u_137 = (int64_t *)x_103;
  u_137[0] = 11;
  u_137[1] = x_97;
  int64_t u_31 = 0;
  int64_t x_104 = f0(x_98, x_103);
  r_125 = x_104; break; }
  case 1: {
  r_125 = 1; break; }
  default: abort();
  }
  r_124 = r_125; break; }
  case 1: {
  r_124 = 1; break; }
  default: abort();
  }
  r_123 = r_124; break; }
  case 1: {
  r_123 = 0; break; }
  default: abort();
  }
  return r_123;
}
int main(int argc, char **argv) {
  for (int i = 1; i < argc; i++) printf("%lld\n", (long long)fibs(atoll(argv[i])));
  return 0;
}
