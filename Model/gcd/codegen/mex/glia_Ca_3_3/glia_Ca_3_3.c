/*
 * glia_Ca_3_3.c
 *
 * Code generation for function 'glia_Ca_3_3'
 *
 * C source code generated on: Thu May 19 17:32:19 2011
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "glia_Ca_3_3.h"
#include "mod.h"
#include "length.h"
#include "find.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */
static emlrtRSInfo emlrtRSI = { 32, "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m" };
static emlrtBCInfo emlrtBCI = { -1, -1, 34, 36, "ip3_rel", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo b_emlrtBCI = { -1, -1, 35, 36, "ip3_rel", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo c_emlrtBCI = { -1, -1, 36, 43, "ip3_rel", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo d_emlrtBCI = { 1, 150, 44, 21, "C", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo e_emlrtBCI = { 1, 150, 44, 23, "C", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtDCInfo emlrtDCI = { 65, 22, "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 1 };
static emlrtBCInfo f_emlrtBCI = { 1, 150, 65, 22, "C1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtDCInfo b_emlrtDCI = { 65, 6, "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 1 };
static emlrtBCInfo g_emlrtBCI = { 1, 150, 65, 6, "C1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtECInfo emlrtECI = { -1, 65, 1, "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m" };
static emlrtBCInfo h_emlrtBCI = { 1, 150, 66, 22, "C1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtDCInfo c_emlrtDCI = { 66, 28, "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 1 };
static emlrtBCInfo i_emlrtBCI = { 1, 150, 66, 28, "C1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtDCInfo d_emlrtDCI = { 66, 4, "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 1 };
static emlrtBCInfo j_emlrtBCI = { 1, 150, 66, 4, "C1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtDCInfo e_emlrtDCI = { 66, 8, "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 1 };
static emlrtBCInfo k_emlrtBCI = { 1, 150, 66, 8, "C1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtECInfo b_emlrtECI = { -1, 66, 1, "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m" };
static emlrtECInfo c_emlrtECI = { -1, 67, 1, "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m" };
static emlrtBCInfo l_emlrtBCI = { 1, 150, 68, 33, "C1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtDCInfo f_emlrtDCI = { 68, 14, "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 1 };
static emlrtBCInfo m_emlrtBCI = { 1, 150, 68, 14, "C1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtECInfo d_emlrtECI = { -1, 68, 1, "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m" };
static emlrtECInfo e_emlrtECI = { -1, 74, 1, "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m" };
static emlrtBCInfo n_emlrtBCI = { 1, 150, 75, 22, "P1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtECInfo f_emlrtECI = { -1, 75, 1, "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m" };
static emlrtECInfo g_emlrtECI = { -1, 76, 1, "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m" };
static emlrtBCInfo o_emlrtBCI = { 1, 150, 77, 33, "P1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtECInfo h_emlrtECI = { -1, 77, 1, "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m" };
static emlrtECInfo i_emlrtECI = { -1, 83, 1, "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m" };
static emlrtBCInfo p_emlrtBCI = { 1, 150, 84, 22, "H1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtECInfo j_emlrtECI = { -1, 84, 1, "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m" };
static emlrtECInfo k_emlrtECI = { -1, 85, 1, "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m" };
static emlrtBCInfo q_emlrtBCI = { 1, 150, 86, 33, "H1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtECInfo l_emlrtECI = { -1, 86, 1, "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m" };
static emlrtBCInfo r_emlrtBCI = { 1, 150, 70, 17, "C1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo s_emlrtBCI = { 1, 150, 71, 14, "C1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo t_emlrtBCI = { 1, 150, 72, 16, "C1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo u_emlrtBCI = { 1, 150, 72, 23, "C1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo v_emlrtBCI = { 1, 150, 79, 17, "P1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo w_emlrtBCI = { 1, 150, 80, 14, "P1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo x_emlrtBCI = { 1, 150, 81, 16, "P1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo y_emlrtBCI = { 1, 150, 81, 23, "P1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo ab_emlrtBCI = { 1, 150, 88, 17, "H1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo bb_emlrtBCI = { 1, 150, 89, 14, "H1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo cb_emlrtBCI = { 1, 150, 90, 16, "H1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo db_emlrtBCI = { 1, 150, 90, 23, "H1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo eb_emlrtBCI = { 1, 150, 47, 39, "C", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo fb_emlrtBCI = { 1, 150, 47, 69, "C", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo gb_emlrtBCI = { 1, 150, 48, 39, "P", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo hb_emlrtBCI = { 1, 150, 48, 69, "P", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo ib_emlrtBCI = { 1, 150, 51, 47, "C", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo jb_emlrtBCI = { 1, 150, 52, 51, "C", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo kb_emlrtBCI = { 1, 150, 52, 16, "C1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo lb_emlrtBCI = { 1, 150, 52, 26, "C1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo mb_emlrtBCI = { 1, 150, 53, 47, "P", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo nb_emlrtBCI = { 1, 150, 54, 51, "P", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo ob_emlrtBCI = { 1, 150, 54, 16, "P1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo pb_emlrtBCI = { 1, 150, 54, 26, "P1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo qb_emlrtBCI = { 1, 150, 57, 49, "C", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo rb_emlrtBCI = { 1, 150, 58, 53, "C", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo sb_emlrtBCI = { 1, 150, 58, 18, "C1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo tb_emlrtBCI = { 1, 150, 58, 28, "C1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo ub_emlrtBCI = { 1, 150, 59, 49, "P", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo vb_emlrtBCI = { 1, 150, 60, 53, "P", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo wb_emlrtBCI = { 1, 150, 60, 18, "P1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo xb_emlrtBCI = { 1, 150, 60, 28, "P1", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtBCInfo yb_emlrtBCI = { 1, 150, 36, 7, "P", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtDCInfo g_emlrtDCI = { 36, 7, "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 1 };
static emlrtBCInfo ac_emlrtBCI = { 1, 150, 36, 9, "P", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtDCInfo h_emlrtDCI = { 36, 9, "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 1 };
static emlrtBCInfo bc_emlrtBCI = { 1, 150, 36, 14, "P", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtDCInfo i_emlrtDCI = { 36, 14, "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 1 };
static emlrtBCInfo cc_emlrtBCI = { 1, 150, 36, 16, "P", "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 0 };
static emlrtDCInfo j_emlrtDCI = { 36, 16, "glia_Ca_3_3", "E:/Software Profiles/matlab/util/Model/gcd/glia_Ca_3_3.m", 1 };

/* Function Declarations */

/* Function Definitions */

/*
 * function [ C1,P1,H1 ] = glia_Ca_3_3(C,P,H,location_release_amount,Row,Col)
 */
void glia_Ca_3_3(real_T C[22500], real_T P[22500], const real_T H[22500], const real_T location_release_amount[3000], real_T Row, real_T Col, real_T C1[22500], real_T P1[22500], real_T H1[22500])
{
    int32_T i0;
    boolean_T b_location_release_amount[1000];
    int32_T ip3_rel_sizes;
    real_T ip3_rel_data[1000];
    real_T loop_ub;
    int32_T i;
    real_T x;
    real_T y;
    real_T b;
    int32_T i1;
    int32_T b_loop_ub;
    int32_T i2;
    int32_T tmp_data[150];
    int32_T iv0[2];
    int32_T C1_sizes[2];
    int32_T b_C1[2];
    real_T C1_data[150];
    int32_T b_Row;
    int32_T b_C1_sizes[2];
    int32_T b_tmp_data[149];
    int32_T iv1[1];
    int32_T c_C1[1];
    real_T b_C1_data[149];
    int32_T P1_sizes[2];
    int32_T b_P1_sizes[2];
    int32_T H1_sizes[2];
    int32_T b_H1_sizes[2];
    /* GLIA_CA Summary of this function goes here */
    /* % Parameters */
    /* 'glia_Ca_3_3:5' deltaT=0.001; */
    /* % Time step interval (s),i.e. 1ms */
    /* 'glia_Ca_3_3:6' taoh=2.0; */
    /* % the time constant for the dynamics of h, unit : s */
    /* 'glia_Ca_3_3:7' b=0.111; */
    /* % Fraction of open IP3 receptors at [Ca2+]=0 */
    /* 'glia_Ca_3_3:8' V1=0.889; */
    /* % the proportion of IP3Rs that are activated by the binding of Ca2+ */
    /* 'glia_Ca_3_3:9' kp=0.17; */
    /* % the linear rate of IP3 breakdown, unit : /s */
    /* 'glia_Ca_3_3:10' mu0=0.567; */
    /* % the proportion of IP3Rs that are activated at [IP3] =0¦ÌM */
    /* 'glia_Ca_3_3:11' mu1=0.433; */
    /* % the proportion of IP3Rs that are activated by bound IP3 */
    /* 'glia_Ca_3_3:13' kflux=16.2*400; */
    /* % the maximum total Ca2+ flux through all IP3Rs, unit : ¦ÌM/s */
    /* 'glia_Ca_3_3:14' gamma=2.0*400; */
    /* % the maximmum rate of Ca2+ pumping from the cytosol, unit : ¦ÌM/s */
    /* 'glia_Ca_3_3:15' k1=0.7*400; */
    /* % Kinetic constant, unit : ¦ÌM */
    /* 'glia_Ca_3_3:16' k2=0.7*400; */
    /* % Kinetic constant, unit : ¦ÌM */
    /* 'glia_Ca_3_3:17' kgamma=0.1*400; */
    /* % Kinetic constant of calcium pumps of ER, unit : ¦ÌM */
    /* 'glia_Ca_3_3:18' Dp=300/400; */
    /* % the cytosolic diffusion coefficients of IP3, unit : (¦Ìm)^2/s */
    /* 'glia_Ca_3_3:19' Dc=20/400; */
    /* % the cytosolic diffusion coefficients of Ca2+, unit : (¦Ìm)^2/s */
    /* 'glia_Ca_3_3:20' kmu=4*400; */
    /* %  Kinetic constant of mu, unit : ¦ÌM */
    /* 'glia_Ca_3_3:21' peq=0.28*400; */
    /* % IP3 resting concentration, unit : uM */
    /* 'glia_Ca_3_3:23' Fp=5/20; */
    /* % IP3 permeability of the cell membrane, unit : ¦Ìm/s */
    /* 'glia_Ca_3_3:24' Fc=1.1/20; */
    /* % Ca2+ permeability of the cell membrane, unit : ¦Ìm/s */
    /* 'glia_Ca_3_3:26' C1=ones(150,150); */
    for (i0 = 0; i0 < 22500; i0++) {
        C1[i0] = 1.0;
        /* % the cytosolic free calcium concentration, unit : ¦ÌM */
        /* 'glia_Ca_3_3:27' P1=ones(150,150); */
        P1[i0] = 1.0;
        /* % the cytosolic IP3 concentration, unit : ¦ÌM */
        /* 'glia_Ca_3_3:28' H1=ones(150,150); */
        H1[i0] = 1.0;
    }
    /* % the proportion of IP3Rs that have not been closed by Ca2+ */
    /* % Calculation */
    /* 'glia_Ca_3_3:32' ip3_rel=find(location_release_amount(:,3)~=0); */
    EMLRTPUSHRTSTACK(&emlrtRSI);
    for (i0 = 0; i0 < 1000; i0++) {
        b_location_release_amount[i0] = (location_release_amount[2000 + i0] != 0.0);
    }
    find(b_location_release_amount, ip3_rel_data, &ip3_rel_sizes);
    EMLRTPOPRTSTACK(&emlrtRSI);
    /* 'glia_Ca_3_3:33' for i=1:length(ip3_rel) */
    loop_ub = length(ip3_rel_data, *(int32_T (*)[1])&ip3_rel_sizes);
    i = 1;
    while ((real_T)i <= loop_ub) {
        /* 'glia_Ca_3_3:34' x=ceil(location_release_amount(ip3_rel(i),1)/20); */
        emlrtDynamicBoundsCheckR2011a(i, 1, ip3_rel_sizes, &emlrtBCI, &emlrtContextGlobal);
        x = muDoubleScalarCeil(location_release_amount[(int32_T)ip3_rel_data[i - 1] - 1] / 20.0);
        /* 'glia_Ca_3_3:35' y=ceil(location_release_amount(ip3_rel(i),2)/20); */
        emlrtDynamicBoundsCheckR2011a(i, 1, ip3_rel_sizes, &b_emlrtBCI, &emlrtContextGlobal);
        y = muDoubleScalarCeil(location_release_amount[(int32_T)ip3_rel_data[i - 1] + 999] / 20.0);
        /* 'glia_Ca_3_3:36' P(x,y)=P(x,y)+location_release_amount(ip3_rel(i),3)*0.009; */
        emlrtDynamicBoundsCheckR2011a(i, 1, ip3_rel_sizes, &c_emlrtBCI, &emlrtContextGlobal);
        P[(emlrtBoundsCheckR2011a((int32_T)emlrtIntegerCheckR2011a(x, &g_emlrtDCI, &emlrtContextGlobal), &yb_emlrtBCI, &emlrtContextGlobal) + 150 * (emlrtBoundsCheckR2011a((int32_T)emlrtIntegerCheckR2011a(y, &h_emlrtDCI, &emlrtContextGlobal), &ac_emlrtBCI, &emlrtContextGlobal) - 1)) - 1] = P[(emlrtBoundsCheckR2011a((int32_T)emlrtIntegerCheckR2011a(x, &i_emlrtDCI, &emlrtContextGlobal), &bc_emlrtBCI, &emlrtContextGlobal) + 150 * (emlrtBoundsCheckR2011a((int32_T)emlrtIntegerCheckR2011a(y, &j_emlrtDCI, &emlrtContextGlobal), &cc_emlrtBCI, &emlrtContextGlobal) - 1)) - 1] + location_release_amount[(int32_T)ip3_rel_data[i - 1] + 1999] * 0.009;
        i++;
        emlrtBreakCheck();
    }
    /* 'glia_Ca_3_3:39' C=C*400; */
    for (i0 = 0; i0 < 22500; i0++) {
        /* 'glia_Ca_3_3:40' P=P*400; */
        P[i0] *= 400.0;
        C[i0] *= 400.0;
    }
    /* 'glia_Ca_3_3:42' for j=2:(Col-1) */
    loop_ub = Col - 1.0;
    x = 2.0;
    while (x <= loop_ub) {
        /* 'glia_Ca_3_3:43' for i=2:(Row-1) */
        y = Row - 1.0;
        i = 1;
        while ((real_T)(i + 1) <= y) {
            /* 'glia_Ca_3_3:44' old_cij = C(i,j); */
            emlrtBoundsCheckR2011a(i + 1, &d_emlrtBCI, &emlrtContextGlobal);
            emlrtBoundsCheckR2011a((int32_T)x, &e_emlrtBCI, &emlrtContextGlobal);
            /* 'glia_Ca_3_3:45' old_pij = P(i,j); */
            /* 'glia_Ca_3_3:46' old_hij = H(i,j); */
            /* 'glia_Ca_3_3:47' C1(i,j)=old_cij+deltaT*(Dc*(C(i+1,j)-2*old_cij+C(i-1,j)+C(i,j+1)-2*old_cij+C(i,j-1))+kflux*(mu0+mu1*P(i,j)/(kmu+P(i,j)))*H(i,j)*(b+V1*old_cij/(k1+old_cij))-gamma*old_cij/(kgamma+old_cij)); */
            b = ((((C[(emlrtBoundsCheckR2011a(i + 2, &eb_emlrtBCI, &emlrtContextGlobal) + 150 * ((int32_T)x - 1)) - 1] - 2.0 * C[i + 150 * ((int32_T)x - 1)]) + C[(i + 150 * ((int32_T)x - 1)) - 1]) + C[i + 150 * (emlrtBoundsCheckR2011a((int32_T)x + 1, &fb_emlrtBCI, &emlrtContextGlobal) - 1)]) - 2.0 * C[i + 150 * ((int32_T)x - 1)]) + C[i + 150 * ((int32_T)x - 2)];
            C1[i + 150 * ((int32_T)x - 1)] = C[i + 150 * ((int32_T)x - 1)] + 0.001 * ((0.05 * b + 6480.0 * (0.567 + 0.433 * P[i + 150 * ((int32_T)x - 1)] / (1600.0 + P[i + 150 * ((int32_T)x - 1)])) * H[i + 150 * ((int32_T)x - 1)] * (0.111 + 0.889 * C[i + 150 * ((int32_T)x - 1)] / (280.0 + C[i + 150 * ((int32_T)x - 1)]))) - 800.0 * C[i + 150 * ((int32_T)x - 1)] / (40.0 + C[i + 150 * ((int32_T)x - 1)]));
            /* 'glia_Ca_3_3:48' P1(i,j)=old_pij+deltaT*(Dp*(P(i+1,j)-2*old_pij+P(i-1,j)+P(i,j+1)-2*old_pij+P(i,j-1))+kp*(peq-old_pij)); */
            b = ((((P[(emlrtBoundsCheckR2011a(i + 2, &gb_emlrtBCI, &emlrtContextGlobal) + 150 * ((int32_T)x - 1)) - 1] - 2.0 * P[i + 150 * ((int32_T)x - 1)]) + P[(i + 150 * ((int32_T)x - 1)) - 1]) + P[i + 150 * (emlrtBoundsCheckR2011a((int32_T)x + 1, &hb_emlrtBCI, &emlrtContextGlobal) - 1)]) - 2.0 * P[i + 150 * ((int32_T)x - 1)]) + P[i + 150 * ((int32_T)x - 2)];
            P1[i + 150 * ((int32_T)x - 1)] = P[i + 150 * ((int32_T)x - 1)] + 0.001 * (0.75 * b + 0.17 * (112.00000000000001 - P[i + 150 * ((int32_T)x - 1)]));
            /* 'glia_Ca_3_3:49' H1(i,j)=old_hij+deltaT*(k2^2/(k2^2+old_cij^2)-old_hij)/taoh; */
            H1[i + 150 * ((int32_T)x - 1)] = H[i + 150 * ((int32_T)x - 1)] + 0.001 * (78400.0 / (78400.0 + muDoubleScalarPower(C[i + 150 * ((int32_T)x - 1)], 2.0)) - H[i + 150 * ((int32_T)x - 1)]) / 2.0;
            /* 'glia_Ca_3_3:50' if(mod(i,3)==0) */
            if (b_mod((real_T)(i + 1), 3.0) == 0.0) {
                /* 'glia_Ca_3_3:51' C1(i,j)=C1(i,j)-deltaT*(old_cij-C(i+1,j))*Fc; */
                b = C[i + 150 * ((int32_T)x - 1)] - C[(emlrtBoundsCheckR2011a(i + 2, &ib_emlrtBCI, &emlrtContextGlobal) + 150 * ((int32_T)x - 1)) - 1];
                C1[i + 150 * ((int32_T)x - 1)] -= 0.001 * b * 0.055000000000000007;
                /* 'glia_Ca_3_3:52' C1(i+1,j)=C1(i+1,j)+deltaT*(old_cij-C(i+1,j))*Fc; */
                b = C[i + 150 * ((int32_T)x - 1)] - C[(emlrtBoundsCheckR2011a(i + 2, &jb_emlrtBCI, &emlrtContextGlobal) + 150 * ((int32_T)x - 1)) - 1];
                C1[(emlrtBoundsCheckR2011a(i + 2, &kb_emlrtBCI, &emlrtContextGlobal) + 150 * ((int32_T)x - 1)) - 1] = C1[(emlrtBoundsCheckR2011a(i + 2, &lb_emlrtBCI, &emlrtContextGlobal) + 150 * ((int32_T)x - 1)) - 1] + 0.001 * b * 0.055000000000000007;
                /* 'glia_Ca_3_3:53' P1(i,j)=P1(i,j)-deltaT*(old_pij-P(i+1,j))*Fp; */
                b = P[i + 150 * ((int32_T)x - 1)] - P[(emlrtBoundsCheckR2011a(i + 2, &mb_emlrtBCI, &emlrtContextGlobal) + 150 * ((int32_T)x - 1)) - 1];
                P1[i + 150 * ((int32_T)x - 1)] -= 0.001 * b * 0.25;
                /* 'glia_Ca_3_3:54' P1(i+1,j)=P1(i+1,j)+deltaT*(old_pij-P(i+1,j))*Fp; */
                b = P[i + 150 * ((int32_T)x - 1)] - P[(emlrtBoundsCheckR2011a(i + 2, &nb_emlrtBCI, &emlrtContextGlobal) + 150 * ((int32_T)x - 1)) - 1];
                P1[(emlrtBoundsCheckR2011a(i + 2, &ob_emlrtBCI, &emlrtContextGlobal) + 150 * ((int32_T)x - 1)) - 1] = P1[(emlrtBoundsCheckR2011a(i + 2, &pb_emlrtBCI, &emlrtContextGlobal) + 150 * ((int32_T)x - 1)) - 1] + 0.001 * b * 0.25;
            }
            /* 'glia_Ca_3_3:56' if(mod(j,3)==0) */
            if (b_mod(x, 3.0) == 0.0) {
                /* 'glia_Ca_3_3:57' C1(i,j)=C1(i,j)-deltaT*(old_cij-C(i,j+1))*Fc; */
                b = C[i + 150 * ((int32_T)x - 1)] - C[i + 150 * (emlrtBoundsCheckR2011a((int32_T)x + 1, &qb_emlrtBCI, &emlrtContextGlobal) - 1)];
                C1[i + 150 * ((int32_T)x - 1)] -= 0.001 * b * 0.055000000000000007;
                /* 'glia_Ca_3_3:58' C1(i,j+1)=C1(i,j+1)+deltaT*(old_cij-C(i,j+1))*Fc; */
                b = C[i + 150 * ((int32_T)x - 1)] - C[i + 150 * (emlrtBoundsCheckR2011a((int32_T)x + 1, &rb_emlrtBCI, &emlrtContextGlobal) - 1)];
                C1[i + 150 * (emlrtBoundsCheckR2011a((int32_T)x + 1, &sb_emlrtBCI, &emlrtContextGlobal) - 1)] = C1[i + 150 * (emlrtBoundsCheckR2011a((int32_T)x + 1, &tb_emlrtBCI, &emlrtContextGlobal) - 1)] + 0.001 * b * 0.055000000000000007;
                /* 'glia_Ca_3_3:59' P1(i,j)=P1(i,j)-deltaT*(old_pij-P(i,j+1))*Fp; */
                b = P[i + 150 * ((int32_T)x - 1)] - P[i + 150 * (emlrtBoundsCheckR2011a((int32_T)x + 1, &ub_emlrtBCI, &emlrtContextGlobal) - 1)];
                P1[i + 150 * ((int32_T)x - 1)] -= 0.001 * b * 0.25;
                /* 'glia_Ca_3_3:60' P1(i,j+1)=P1(i,j+1)+deltaT*(old_pij-P(i,j+1))*Fp; */
                b = P[i + 150 * ((int32_T)x - 1)] - P[i + 150 * (emlrtBoundsCheckR2011a((int32_T)x + 1, &vb_emlrtBCI, &emlrtContextGlobal) - 1)];
                P1[i + 150 * (emlrtBoundsCheckR2011a((int32_T)x + 1, &wb_emlrtBCI, &emlrtContextGlobal) - 1)] = P1[i + 150 * (emlrtBoundsCheckR2011a((int32_T)x + 1, &xb_emlrtBCI, &emlrtContextGlobal) - 1)] + 0.001 * b * 0.25;
            }
            i++;
            emlrtBreakCheck();
        }
        x++;
        emlrtBreakCheck();
    }
    /* 'glia_Ca_3_3:65' C1(1,2:(Col-1))=C1(2,2:(Col-1)); */
    x = Col - 1.0;
    if (2.0 > x) {
        i0 = 0;
        i1 = 0;
    } else {
        i0 = 1;
        i1 = emlrtBoundsCheckR2011a((int32_T)emlrtIntegerCheckR2011a(x, &emlrtDCI, &emlrtContextGlobal), &f_emlrtBCI, &emlrtContextGlobal);
    }
    x = Col - 1.0;
    if (2.0 > x) {
        ip3_rel_sizes = 0;
        i = 0;
    } else {
        ip3_rel_sizes = 1;
        i = emlrtBoundsCheckR2011a((int32_T)emlrtIntegerCheckR2011a(x, &b_emlrtDCI, &emlrtContextGlobal), &g_emlrtBCI, &emlrtContextGlobal);
    }
    b_loop_ub = (i - ip3_rel_sizes) - 1;
    for (i2 = 0; i2 <= b_loop_ub; i2++) {
        tmp_data[i2] = ip3_rel_sizes + i2;
    }
    iv0[0] = 1;
    iv0[1] = i - ip3_rel_sizes;
    C1_sizes[0] = 1;
    C1_sizes[1] = i1 - i0;
    for (ip3_rel_sizes = 0; ip3_rel_sizes < 2; ip3_rel_sizes++) {
        b_C1[ip3_rel_sizes] = C1_sizes[ip3_rel_sizes];
    }
    emlrtSubAssignSizeCheckR2011a(iv0, 2, b_C1, 2, &emlrtECI, &emlrtContextGlobal);
    ip3_rel_sizes = i1 - i0;
    b_loop_ub = (i1 - i0) - 1;
    for (i1 = 0; i1 <= b_loop_ub; i1++) {
        C1_data[i1] = C1[1 + 150 * (i0 + i1)];
    }
    b_loop_ub = ip3_rel_sizes - 1;
    for (i0 = 0; i0 <= b_loop_ub; i0++) {
        C1[150 * tmp_data[i0]] = C1_data[i0];
    }
    /* 'glia_Ca_3_3:66' C1(Row,2:(Col-1))=C1(Row-1,2:(Col-1)); */
    x = Col - 1.0;
    if (2.0 > x) {
        i0 = 0;
        i1 = 0;
    } else {
        i0 = 1;
        i1 = emlrtBoundsCheckR2011a((int32_T)emlrtIntegerCheckR2011a(x, &c_emlrtDCI, &emlrtContextGlobal), &i_emlrtBCI, &emlrtContextGlobal);
    }
    x = Col - 1.0;
    if (2.0 > x) {
        ip3_rel_sizes = 0;
        i = 0;
    } else {
        ip3_rel_sizes = 1;
        i = emlrtBoundsCheckR2011a((int32_T)emlrtIntegerCheckR2011a(x, &e_emlrtDCI, &emlrtContextGlobal), &k_emlrtBCI, &emlrtContextGlobal);
    }
    i2 = emlrtBoundsCheckR2011a((int32_T)emlrtIntegerCheckR2011a(Row, &d_emlrtDCI, &emlrtContextGlobal), &j_emlrtBCI, &emlrtContextGlobal) - 1;
    b_loop_ub = (i - ip3_rel_sizes) - 1;
    for (b_Row = 0; b_Row <= b_loop_ub; b_Row++) {
        tmp_data[b_Row] = ip3_rel_sizes + b_Row;
    }
    emlrtBoundsCheckR2011a((int32_T)(Row - 1.0), &h_emlrtBCI, &emlrtContextGlobal);
    iv0[0] = 1;
    iv0[1] = i - ip3_rel_sizes;
    b_C1_sizes[0] = 1;
    b_C1_sizes[1] = i1 - i0;
    for (ip3_rel_sizes = 0; ip3_rel_sizes < 2; ip3_rel_sizes++) {
        b_C1[ip3_rel_sizes] = b_C1_sizes[ip3_rel_sizes];
    }
    emlrtSubAssignSizeCheckR2011a(iv0, 2, b_C1, 2, &b_emlrtECI, &emlrtContextGlobal);
    b_Row = (int32_T)Row;
    ip3_rel_sizes = i1 - i0;
    b_loop_ub = (i1 - i0) - 1;
    for (i1 = 0; i1 <= b_loop_ub; i1++) {
        C1_data[i1] = C1[(b_Row + 150 * (i0 + i1)) - 2];
    }
    b_loop_ub = ip3_rel_sizes - 1;
    for (i0 = 0; i0 <= b_loop_ub; i0++) {
        C1[i2 + 150 * tmp_data[i0]] = C1_data[i0];
    }
    /* 'glia_Ca_3_3:67' C1(2:(Row-1),1)=C1(2:(Row-1),2); */
    i0 = (int32_T)Row - 1;
    if (2 > i0) {
        i1 = 0;
        i0 = 0;
    } else {
        i1 = 1;
    }
    ip3_rel_sizes = (int32_T)Row - 1;
    if (2 > ip3_rel_sizes) {
        i = 0;
        ip3_rel_sizes = 0;
    } else {
        i = 1;
    }
    b_loop_ub = (ip3_rel_sizes - i) - 1;
    for (i2 = 0; i2 <= b_loop_ub; i2++) {
        b_tmp_data[i2] = i + i2;
    }
    iv1[0] = ip3_rel_sizes - i;
    c_C1[0] = i0 - i1;
    emlrtSubAssignSizeCheckR2011a(iv1, 1, c_C1, 1, &c_emlrtECI, &emlrtContextGlobal);
    ip3_rel_sizes = (i0 - i1) - 1;
    b_loop_ub = (i0 - i1) - 1;
    for (i0 = 0; i0 <= b_loop_ub; i0++) {
        b_C1_data[i0] = C1[150 + (i1 + i0)];
    }
    for (i0 = 0; i0 <= ip3_rel_sizes; i0++) {
        C1[b_tmp_data[i0]] = b_C1_data[i0];
    }
    /* 'glia_Ca_3_3:68' C1(2:(Row-1),Col)=C1(2:(Row-1),(Col-1)); */
    i0 = (int32_T)Row - 1;
    if (2 > i0) {
        i1 = 0;
        i0 = 0;
    } else {
        i1 = 1;
    }
    ip3_rel_sizes = (int32_T)Row - 1;
    if (2 > ip3_rel_sizes) {
        i = 0;
        ip3_rel_sizes = 0;
    } else {
        i = 1;
    }
    b_loop_ub = (ip3_rel_sizes - i) - 1;
    for (i2 = 0; i2 <= b_loop_ub; i2++) {
        b_tmp_data[i2] = i + i2;
    }
    i2 = emlrtBoundsCheckR2011a((int32_T)emlrtIntegerCheckR2011a(Col, &f_emlrtDCI, &emlrtContextGlobal), &m_emlrtBCI, &emlrtContextGlobal) - 1;
    emlrtBoundsCheckR2011a((int32_T)(Col - 1.0), &l_emlrtBCI, &emlrtContextGlobal);
    iv1[0] = ip3_rel_sizes - i;
    c_C1[0] = i0 - i1;
    emlrtSubAssignSizeCheckR2011a(iv1, 1, c_C1, 1, &d_emlrtECI, &emlrtContextGlobal);
    b_Row = (int32_T)Col;
    ip3_rel_sizes = (i0 - i1) - 1;
    b_loop_ub = (i0 - i1) - 1;
    for (i0 = 0; i0 <= b_loop_ub; i0++) {
        b_C1_data[i0] = C1[(i1 + i0) + 150 * (b_Row - 2)];
    }
    for (i0 = 0; i0 <= ip3_rel_sizes; i0++) {
        C1[b_tmp_data[i0] + 150 * i2] = b_C1_data[i0];
    }
    /* 'glia_Ca_3_3:69' C1(1,1)=C1(2,2); */
    C1[0] = C1[151];
    /* 'glia_Ca_3_3:70' C1(1,Col)=C1(2,(Col-1)); */
    C1[150 * ((int32_T)Col - 1)] = C1[1 + 150 * (emlrtBoundsCheckR2011a((int32_T)Col - 1, &r_emlrtBCI, &emlrtContextGlobal) - 1)];
    /* 'glia_Ca_3_3:71' C1(Row,1)=C1(Row-1,2); */
    C1[(int32_T)Row - 1] = C1[emlrtBoundsCheckR2011a((int32_T)Row - 1, &s_emlrtBCI, &emlrtContextGlobal) + 149];
    /* 'glia_Ca_3_3:72' C1(Row,Col)=C1(Row-1,(Col-1)); */
    C1[((int32_T)Row + 150 * ((int32_T)Col - 1)) - 1] = C1[(emlrtBoundsCheckR2011a((int32_T)Row - 1, &t_emlrtBCI, &emlrtContextGlobal) + 150 * (emlrtBoundsCheckR2011a((int32_T)Col - 1, &u_emlrtBCI, &emlrtContextGlobal) - 1)) - 1];
    /* 'glia_Ca_3_3:74' P1(1,2:(Col-1))=P1(2,2:(Col-1)); */
    i0 = (int32_T)Col - 1;
    if (2 > i0) {
        i1 = 0;
        i0 = 0;
    } else {
        i1 = 1;
    }
    ip3_rel_sizes = (int32_T)Col - 1;
    if (2 > ip3_rel_sizes) {
        i = 0;
        ip3_rel_sizes = 0;
    } else {
        i = 1;
    }
    b_loop_ub = (ip3_rel_sizes - i) - 1;
    for (i2 = 0; i2 <= b_loop_ub; i2++) {
        b_tmp_data[i2] = i + i2;
    }
    iv0[0] = 1;
    iv0[1] = ip3_rel_sizes - i;
    P1_sizes[0] = 1;
    P1_sizes[1] = i0 - i1;
    for (ip3_rel_sizes = 0; ip3_rel_sizes < 2; ip3_rel_sizes++) {
        C1_sizes[ip3_rel_sizes] = P1_sizes[ip3_rel_sizes];
    }
    emlrtSubAssignSizeCheckR2011a(iv0, 2, C1_sizes, 2, &e_emlrtECI, &emlrtContextGlobal);
    ip3_rel_sizes = i0 - i1;
    b_loop_ub = (i0 - i1) - 1;
    for (i0 = 0; i0 <= b_loop_ub; i0++) {
        b_C1_data[i0] = P1[1 + 150 * (i1 + i0)];
    }
    b_loop_ub = ip3_rel_sizes - 1;
    for (i0 = 0; i0 <= b_loop_ub; i0++) {
        P1[150 * b_tmp_data[i0]] = b_C1_data[i0];
    }
    /* 'glia_Ca_3_3:75' P1(Row,2:(Col-1))=P1(Row-1,2:(Col-1)); */
    i0 = (int32_T)Col - 1;
    if (2 > i0) {
        i1 = 0;
        i0 = 0;
    } else {
        i1 = 1;
    }
    ip3_rel_sizes = (int32_T)Col - 1;
    if (2 > ip3_rel_sizes) {
        i = 0;
        ip3_rel_sizes = 0;
    } else {
        i = 1;
    }
    b_loop_ub = (ip3_rel_sizes - i) - 1;
    for (i2 = 0; i2 <= b_loop_ub; i2++) {
        b_tmp_data[i2] = i + i2;
    }
    emlrtBoundsCheckR2011a((int32_T)(Row - 1.0), &n_emlrtBCI, &emlrtContextGlobal);
    iv0[0] = 1;
    iv0[1] = ip3_rel_sizes - i;
    b_P1_sizes[0] = 1;
    b_P1_sizes[1] = i0 - i1;
    for (ip3_rel_sizes = 0; ip3_rel_sizes < 2; ip3_rel_sizes++) {
        C1_sizes[ip3_rel_sizes] = b_P1_sizes[ip3_rel_sizes];
    }
    emlrtSubAssignSizeCheckR2011a(iv0, 2, C1_sizes, 2, &f_emlrtECI, &emlrtContextGlobal);
    b_Row = (int32_T)Row;
    i = (int32_T)Row;
    ip3_rel_sizes = i0 - i1;
    b_loop_ub = (i0 - i1) - 1;
    for (i0 = 0; i0 <= b_loop_ub; i0++) {
        b_C1_data[i0] = P1[(i + 150 * (i1 + i0)) - 2];
    }
    b_loop_ub = ip3_rel_sizes - 1;
    for (i0 = 0; i0 <= b_loop_ub; i0++) {
        P1[(b_Row + 150 * b_tmp_data[i0]) - 1] = b_C1_data[i0];
    }
    /* 'glia_Ca_3_3:76' P1(2:(Row-1),1)=P1(2:(Row-1),2); */
    i0 = (int32_T)Row - 1;
    if (2 > i0) {
        i1 = 0;
        i0 = 0;
    } else {
        i1 = 1;
    }
    ip3_rel_sizes = (int32_T)Row - 1;
    if (2 > ip3_rel_sizes) {
        i = 0;
        ip3_rel_sizes = 0;
    } else {
        i = 1;
    }
    b_loop_ub = (ip3_rel_sizes - i) - 1;
    for (i2 = 0; i2 <= b_loop_ub; i2++) {
        b_tmp_data[i2] = i + i2;
    }
    iv1[0] = ip3_rel_sizes - i;
    c_C1[0] = i0 - i1;
    emlrtSubAssignSizeCheckR2011a(iv1, 1, c_C1, 1, &g_emlrtECI, &emlrtContextGlobal);
    ip3_rel_sizes = (i0 - i1) - 1;
    b_loop_ub = (i0 - i1) - 1;
    for (i0 = 0; i0 <= b_loop_ub; i0++) {
        b_C1_data[i0] = P1[150 + (i1 + i0)];
    }
    for (i0 = 0; i0 <= ip3_rel_sizes; i0++) {
        P1[b_tmp_data[i0]] = b_C1_data[i0];
    }
    /* 'glia_Ca_3_3:77' P1(2:(Row-1),Col)=P1(2:(Row-1),(Col-1)); */
    i0 = (int32_T)Row - 1;
    if (2 > i0) {
        i1 = 0;
        i0 = 0;
    } else {
        i1 = 1;
    }
    ip3_rel_sizes = (int32_T)Row - 1;
    if (2 > ip3_rel_sizes) {
        i = 0;
        ip3_rel_sizes = 0;
    } else {
        i = 1;
    }
    b_loop_ub = (ip3_rel_sizes - i) - 1;
    for (i2 = 0; i2 <= b_loop_ub; i2++) {
        b_tmp_data[i2] = i + i2;
    }
    emlrtBoundsCheckR2011a((int32_T)(Col - 1.0), &o_emlrtBCI, &emlrtContextGlobal);
    iv1[0] = ip3_rel_sizes - i;
    c_C1[0] = i0 - i1;
    emlrtSubAssignSizeCheckR2011a(iv1, 1, c_C1, 1, &h_emlrtECI, &emlrtContextGlobal);
    b_Row = (int32_T)Col;
    i = (int32_T)Col;
    ip3_rel_sizes = (i0 - i1) - 1;
    b_loop_ub = (i0 - i1) - 1;
    for (i0 = 0; i0 <= b_loop_ub; i0++) {
        b_C1_data[i0] = P1[(i1 + i0) + 150 * (i - 2)];
    }
    for (i0 = 0; i0 <= ip3_rel_sizes; i0++) {
        P1[b_tmp_data[i0] + 150 * (b_Row - 1)] = b_C1_data[i0];
    }
    /* 'glia_Ca_3_3:78' P1(1,1)=P1(2,2); */
    P1[0] = P1[151];
    /* 'glia_Ca_3_3:79' P1(1,Col)=P1(2,(Col-1)); */
    P1[150 * ((int32_T)Col - 1)] = P1[1 + 150 * (emlrtBoundsCheckR2011a((int32_T)Col - 1, &v_emlrtBCI, &emlrtContextGlobal) - 1)];
    /* 'glia_Ca_3_3:80' P1(Row,1)=P1(Row-1,2); */
    P1[(int32_T)Row - 1] = P1[emlrtBoundsCheckR2011a((int32_T)Row - 1, &w_emlrtBCI, &emlrtContextGlobal) + 149];
    /* 'glia_Ca_3_3:81' P1(Row,Col)=P1(Row-1,(Col-1)); */
    P1[((int32_T)Row + 150 * ((int32_T)Col - 1)) - 1] = P1[(emlrtBoundsCheckR2011a((int32_T)Row - 1, &x_emlrtBCI, &emlrtContextGlobal) + 150 * (emlrtBoundsCheckR2011a((int32_T)Col - 1, &y_emlrtBCI, &emlrtContextGlobal) - 1)) - 1];
    /* 'glia_Ca_3_3:83' H1(1,2:(Col-1))=H1(2,2:(Col-1)); */
    i0 = (int32_T)Col - 1;
    if (2 > i0) {
        i1 = 0;
        i0 = 0;
    } else {
        i1 = 1;
    }
    ip3_rel_sizes = (int32_T)Col - 1;
    if (2 > ip3_rel_sizes) {
        i = 0;
        ip3_rel_sizes = 0;
    } else {
        i = 1;
    }
    b_loop_ub = (ip3_rel_sizes - i) - 1;
    for (i2 = 0; i2 <= b_loop_ub; i2++) {
        b_tmp_data[i2] = i + i2;
    }
    iv0[0] = 1;
    iv0[1] = ip3_rel_sizes - i;
    H1_sizes[0] = 1;
    H1_sizes[1] = i0 - i1;
    for (ip3_rel_sizes = 0; ip3_rel_sizes < 2; ip3_rel_sizes++) {
        C1_sizes[ip3_rel_sizes] = H1_sizes[ip3_rel_sizes];
    }
    emlrtSubAssignSizeCheckR2011a(iv0, 2, C1_sizes, 2, &i_emlrtECI, &emlrtContextGlobal);
    ip3_rel_sizes = i0 - i1;
    b_loop_ub = (i0 - i1) - 1;
    for (i0 = 0; i0 <= b_loop_ub; i0++) {
        b_C1_data[i0] = H1[1 + 150 * (i1 + i0)];
    }
    b_loop_ub = ip3_rel_sizes - 1;
    for (i0 = 0; i0 <= b_loop_ub; i0++) {
        H1[150 * b_tmp_data[i0]] = b_C1_data[i0];
    }
    /* 'glia_Ca_3_3:84' H1(Row,2:(Col-1))=H1(Row-1,2:(Col-1)); */
    i0 = (int32_T)Col - 1;
    if (2 > i0) {
        i1 = 0;
        i0 = 0;
    } else {
        i1 = 1;
    }
    ip3_rel_sizes = (int32_T)Col - 1;
    if (2 > ip3_rel_sizes) {
        i = 0;
        ip3_rel_sizes = 0;
    } else {
        i = 1;
    }
    b_loop_ub = (ip3_rel_sizes - i) - 1;
    for (i2 = 0; i2 <= b_loop_ub; i2++) {
        b_tmp_data[i2] = i + i2;
    }
    emlrtBoundsCheckR2011a((int32_T)(Row - 1.0), &p_emlrtBCI, &emlrtContextGlobal);
    iv0[0] = 1;
    iv0[1] = ip3_rel_sizes - i;
    b_H1_sizes[0] = 1;
    b_H1_sizes[1] = i0 - i1;
    for (ip3_rel_sizes = 0; ip3_rel_sizes < 2; ip3_rel_sizes++) {
        C1_sizes[ip3_rel_sizes] = b_H1_sizes[ip3_rel_sizes];
    }
    emlrtSubAssignSizeCheckR2011a(iv0, 2, C1_sizes, 2, &j_emlrtECI, &emlrtContextGlobal);
    b_Row = (int32_T)Row;
    i = (int32_T)Row;
    ip3_rel_sizes = i0 - i1;
    b_loop_ub = (i0 - i1) - 1;
    for (i0 = 0; i0 <= b_loop_ub; i0++) {
        b_C1_data[i0] = H1[(i + 150 * (i1 + i0)) - 2];
    }
    b_loop_ub = ip3_rel_sizes - 1;
    for (i0 = 0; i0 <= b_loop_ub; i0++) {
        H1[(b_Row + 150 * b_tmp_data[i0]) - 1] = b_C1_data[i0];
    }
    /* 'glia_Ca_3_3:85' H1(2:(Row-1),1)=H1(2:(Row-1),2); */
    i0 = (int32_T)Row - 1;
    if (2 > i0) {
        i1 = 0;
        i0 = 0;
    } else {
        i1 = 1;
    }
    ip3_rel_sizes = (int32_T)Row - 1;
    if (2 > ip3_rel_sizes) {
        i = 0;
        ip3_rel_sizes = 0;
    } else {
        i = 1;
    }
    b_loop_ub = (ip3_rel_sizes - i) - 1;
    for (i2 = 0; i2 <= b_loop_ub; i2++) {
        b_tmp_data[i2] = i + i2;
    }
    iv1[0] = ip3_rel_sizes - i;
    c_C1[0] = i0 - i1;
    emlrtSubAssignSizeCheckR2011a(iv1, 1, c_C1, 1, &k_emlrtECI, &emlrtContextGlobal);
    ip3_rel_sizes = (i0 - i1) - 1;
    b_loop_ub = (i0 - i1) - 1;
    for (i0 = 0; i0 <= b_loop_ub; i0++) {
        b_C1_data[i0] = H1[150 + (i1 + i0)];
    }
    for (i0 = 0; i0 <= ip3_rel_sizes; i0++) {
        H1[b_tmp_data[i0]] = b_C1_data[i0];
    }
    /* 'glia_Ca_3_3:86' H1(2:(Row-1),Col)=H1(2:(Row-1),(Col-1)); */
    i0 = (int32_T)Row - 1;
    if (2 > i0) {
        i1 = 0;
        i0 = 0;
    } else {
        i1 = 1;
    }
    ip3_rel_sizes = (int32_T)Row - 1;
    if (2 > ip3_rel_sizes) {
        i = 0;
        ip3_rel_sizes = 0;
    } else {
        i = 1;
    }
    b_loop_ub = (ip3_rel_sizes - i) - 1;
    for (i2 = 0; i2 <= b_loop_ub; i2++) {
        b_tmp_data[i2] = i + i2;
    }
    emlrtBoundsCheckR2011a((int32_T)(Col - 1.0), &q_emlrtBCI, &emlrtContextGlobal);
    iv1[0] = ip3_rel_sizes - i;
    c_C1[0] = i0 - i1;
    emlrtSubAssignSizeCheckR2011a(iv1, 1, c_C1, 1, &l_emlrtECI, &emlrtContextGlobal);
    b_Row = (int32_T)Col;
    i = (int32_T)Col;
    ip3_rel_sizes = (i0 - i1) - 1;
    b_loop_ub = (i0 - i1) - 1;
    for (i0 = 0; i0 <= b_loop_ub; i0++) {
        b_C1_data[i0] = H1[(i1 + i0) + 150 * (i - 2)];
    }
    for (i0 = 0; i0 <= ip3_rel_sizes; i0++) {
        H1[b_tmp_data[i0] + 150 * (b_Row - 1)] = b_C1_data[i0];
    }
    /* 'glia_Ca_3_3:87' H1(1,1)=H1(2,2); */
    H1[0] = H1[151];
    /* 'glia_Ca_3_3:88' H1(1,Col)=H1(2,(Col-1)); */
    H1[150 * ((int32_T)Col - 1)] = H1[1 + 150 * (emlrtBoundsCheckR2011a((int32_T)Col - 1, &ab_emlrtBCI, &emlrtContextGlobal) - 1)];
    /* 'glia_Ca_3_3:89' H1(Row,1)=H1(Row-1,2); */
    H1[(int32_T)Row - 1] = H1[emlrtBoundsCheckR2011a((int32_T)Row - 1, &bb_emlrtBCI, &emlrtContextGlobal) + 149];
    /* 'glia_Ca_3_3:90' H1(Row,Col)=H1(Row-1,(Col-1)); */
    H1[((int32_T)Row + 150 * ((int32_T)Col - 1)) - 1] = H1[(emlrtBoundsCheckR2011a((int32_T)Row - 1, &cb_emlrtBCI, &emlrtContextGlobal) + 150 * (emlrtBoundsCheckR2011a((int32_T)Col - 1, &db_emlrtBCI, &emlrtContextGlobal) - 1)) - 1];
    /* 'glia_Ca_3_3:92' C1=C1/400; */
    for (i0 = 0; i0 < 22500; i0++) {
        /* 'glia_Ca_3_3:93' P1=P1/400; */
        P1[i0] /= 400.0;
        C1[i0] /= 400.0;
    }
}
/* End of code generation (glia_Ca_3_3.c) */
