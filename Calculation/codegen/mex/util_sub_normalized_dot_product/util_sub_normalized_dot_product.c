/*
 * util_sub_normalized_dot_product.c
 *
 * Code generation for function 'util_sub_normalized_dot_product'
 *
 * C source code generated on: Wed Jul 04 15:26:18 2012
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "util_sub_normalized_dot_product.h"
#include "norm.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */
static emlrtRSInfo c_emlrtRSI = { 21, "util_sub_normalized_dot_product",
  "D:/Software Profiles/matlab/util/Calculation/util_sub_normalized_dot_product.m"
};

static emlrtRSInfo d_emlrtRSI = { 27, "util_sub_normalized_dot_product",
  "D:/Software Profiles/matlab/util/Calculation/util_sub_normalized_dot_product.m"
};

static emlrtRSInfo e_emlrtRSI = { 49, "mtimes",
  "E:/Program Files (x86)/MATLAB/R2012a/toolbox/eml/lib/matlab/ops/mtimes.m" };

static emlrtRSInfo f_emlrtRSI = { 21, "mtimes",
  "E:/Program Files (x86)/MATLAB/R2012a/toolbox/eml/lib/matlab/ops/mtimes.m" };

static emlrtRSInfo g_emlrtRSI = { 89, "mtimes",
  "E:/Program Files (x86)/MATLAB/R2012a/toolbox/eml/lib/matlab/ops/mtimes.m" };

static emlrtRSInfo h_emlrtRSI = { 84, "mtimes",
  "E:/Program Files (x86)/MATLAB/R2012a/toolbox/eml/lib/matlab/ops/mtimes.m" };

static emlrtRSInfo i_emlrtRSI = { 31, "eml_xdotu",
  "E:/Program Files (x86)/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/blas/eml_xdotu.m"
};

static emlrtRSInfo j_emlrtRSI = { 28, "eml_xdot",
  "E:/Program Files (x86)/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/blas/eml_xdot.m"
};

static emlrtRSInfo l_emlrtRSI = { 28, "eml_blas_xdot",
  "E:/Program Files (x86)/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/blas/external/eml_blas_xdot.m"
};

static emlrtMCInfo c_emlrtMCI = { 85, 13, "mtimes",
  "E:/Program Files (x86)/MATLAB/R2012a/toolbox/eml/lib/matlab/ops/mtimes.m" };

static emlrtMCInfo d_emlrtMCI = { 84, 23, "mtimes",
  "E:/Program Files (x86)/MATLAB/R2012a/toolbox/eml/lib/matlab/ops/mtimes.m" };

static emlrtMCInfo e_emlrtMCI = { 90, 13, "mtimes",
  "E:/Program Files (x86)/MATLAB/R2012a/toolbox/eml/lib/matlab/ops/mtimes.m" };

static emlrtMCInfo f_emlrtMCI = { 89, 23, "mtimes",
  "E:/Program Files (x86)/MATLAB/R2012a/toolbox/eml/lib/matlab/ops/mtimes.m" };

static emlrtBCInfo emlrtBCI = { -1, -1, 59, 19, "", "eml_blas_xdot",
  "E:/Program Files (x86)/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/blas/external/eml_blas_xdot.m",
  0 };

static emlrtBCInfo b_emlrtBCI = { -1, -1, 60, 5, "", "eml_blas_xdot",
  "E:/Program Files (x86)/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/blas/external/eml_blas_xdot.m",
  0 };

/* Function Declarations */
static void error(const mxArray *b, emlrtMCInfo *location);
static const mxArray *message(const mxArray *b, emlrtMCInfo *location);

/* Function Definitions */
static void error(const mxArray *b, emlrtMCInfo *location)
{
  const mxArray *pArray;
  pArray = b;
  emlrtCallMATLAB(0, NULL, 1, &pArray, "error", TRUE, location);
}

static const mxArray *message(const mxArray *b, emlrtMCInfo *location)
{
  const mxArray *pArray;
  const mxArray *m2;
  pArray = b;
  return emlrtCallMATLAB(1, &m2, 1, &pArray, "message", TRUE, location);
}

real_T util_sub_normalized_dot_product(const real_T a_data[100], const int32_T
  a_size[1], const real_T b_data[100], const int32_T b_size[1])
{
  real_T result;
  int32_T unnamed_idx_1;
  int32_T loop_ub;
  int32_T incy;
  real_T b_a_data[100];
  const mxArray *y;
  static const int32_T iv0[2] = { 1, 45 };

  const mxArray *m0;
  static const char_T cv0[45] = { 'C', 'o', 'd', 'e', 'r', ':', 't', 'o', 'o',
    'l', 'b', 'o', 'x', ':', 'm', 't', 'i', 'm', 'e', 's', '_', 'n', 'o', 'D',
    'y', 'n', 'a', 'm', 'i', 'c', 'S', 'c', 'a', 'l', 'a', 'r', 'E', 'x', 'p',
    'a', 'n', 's', 'i', 'o', 'n' };

  const mxArray *b_y;
  static const int32_T iv1[2] = { 1, 21 };

  static const char_T cv1[21] = { 'C', 'o', 'd', 'e', 'r', ':', 'M', 'A', 'T',
    'L', 'A', 'B', ':', 'i', 'n', 'n', 'e', 'r', 'd', 'i', 'm' };

  real_T dotproduct;
  real_T a;
  real_T b;

  /* NORMALIZED_DOT_PRODUCT Calculating the dot product of a,b then divides it */
  /* using norm(a) * norm(b) */
  /*  */
  /*    Created on Jul/22/2010 By Pu Jiangbo */
  /*    Britton Chance Center for Biomedical Photonics */
  /*  */
  /*    $Revision: */
  /*        PJB#2010-08-28  Speeding, use A'*B instead of dot */
  /*        PJB#2012-07-04  Adding assert for codegen */
  /*  Assert Class for Codegen */
  /*  This is slow */
  /*  dotproduct = dot(a, b); */
  /*  Because when a and b are both column vectors, a'*b is the same as dot(a,b) */
  EMLRTPUSHRTSTACK(&c_emlrtRSI);
  unnamed_idx_1 = a_size[0];
  loop_ub = a_size[0] - 1;
  for (incy = 0; incy <= loop_ub; incy++) {
    b_a_data[incy] = a_data[incy];
  }

  EMLRTPUSHRTSTACK(&f_emlrtRSI);
  if (!(a_size[0] == b_size[0])) {
    if ((a_size[0] == 1) || (b_size[0] == 1)) {
      EMLRTPUSHRTSTACK(&h_emlrtRSI);
      y = NULL;
      m0 = mxCreateCharArray(2, iv0);
      emlrtInitCharArray(45, m0, cv0);
      emlrtAssign(&y, m0);
      error(message(y, &c_emlrtMCI), &d_emlrtMCI);
      EMLRTPOPRTSTACK(&h_emlrtRSI);
    } else {
      EMLRTPUSHRTSTACK(&g_emlrtRSI);
      b_y = NULL;
      m0 = mxCreateCharArray(2, iv1);
      emlrtInitCharArray(21, m0, cv1);
      emlrtAssign(&b_y, m0);
      error(message(b_y, &e_emlrtMCI), &f_emlrtMCI);
      EMLRTPOPRTSTACK(&g_emlrtRSI);
    }
  }

  EMLRTPOPRTSTACK(&f_emlrtRSI);
  if ((a_size[0] == 1) || (b_size[0] == 1)) {
    dotproduct = 0.0;
    loop_ub = a_size[0] - 1;
    for (incy = 0; incy <= loop_ub; incy++) {
      dotproduct += b_a_data[incy] * b_data[incy];
    }
  } else {
    EMLRTPUSHRTSTACK(&e_emlrtRSI);
    EMLRTPUSHRTSTACK(&i_emlrtRSI);
    EMLRTPUSHRTSTACK(&j_emlrtRSI);
    if (a_size[0] < 1) {
      dotproduct = 0.0;
    } else {
      EMLRTPUSHRTSTACK(&l_emlrtRSI);
      loop_ub = 1;
      incy = 1;
      emlrtDynamicBoundsCheck(1, 1, a_size[0], &emlrtBCI);
      emlrtDynamicBoundsCheck(1, 1, b_size[0], &b_emlrtBCI);
      dotproduct = ddot32(&unnamed_idx_1, &b_a_data[0], &loop_ub, &b_data[0],
                          &incy);
      EMLRTPOPRTSTACK(&l_emlrtRSI);
    }

    EMLRTPOPRTSTACK(&j_emlrtRSI);
    EMLRTPOPRTSTACK(&i_emlrtRSI);
    EMLRTPOPRTSTACK(&e_emlrtRSI);
  }

  EMLRTPOPRTSTACK(&c_emlrtRSI);

  /*  Avoid NaN (0 / 0 = NaN) */
  if (!(dotproduct != 0.0)) {
    result = 0.0;
  } else {
    EMLRTPUSHRTSTACK(&d_emlrtRSI);
    a = norm(a_data, a_size);
    b = norm(b_data, b_size);
    result = dotproduct / (a * b);
    EMLRTPOPRTSTACK(&d_emlrtRSI);
  }

  return result;
}

/* End of code generation (util_sub_normalized_dot_product.c) */
