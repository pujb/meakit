/*
 * norm.c
 *
 * Code generation for function 'norm'
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
static emlrtRSInfo n_emlrtRSI = { 38, "norm",
  "E:/Program Files (x86)/MATLAB/R2012a/toolbox/eml/lib/matlab/matfun/norm.m" };

static emlrtRSInfo o_emlrtRSI = { 171, "norm",
  "E:/Program Files (x86)/MATLAB/R2012a/toolbox/eml/lib/matlab/matfun/norm.m" };

static emlrtRSInfo p_emlrtRSI = { 19, "eml_xnrm2",
  "E:/Program Files (x86)/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/blas/eml_xnrm2.m"
};

static emlrtRSInfo r_emlrtRSI = { 24, "eml_blas_xnrm2",
  "E:/Program Files (x86)/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/blas/external/eml_blas_xnrm2.m"
};

/* Function Declarations */

/* Function Definitions */
real_T norm(const real_T x_data[100], const int32_T x_size[1])
{
  real_T y;
  int32_T n;
  int32_T incx;
  EMLRTPUSHRTSTACK(&n_emlrtRSI);
  EMLRTPUSHRTSTACK(&o_emlrtRSI);
  EMLRTPUSHRTSTACK(&p_emlrtRSI);
  if (x_size[0] < 1) {
    y = 0.0;
  } else {
    EMLRTPUSHRTSTACK(&r_emlrtRSI);
    n = x_size[0];
    incx = 1;
    y = dnrm232(&n, &x_data[0], &incx);
    EMLRTPOPRTSTACK(&r_emlrtRSI);
  }

  EMLRTPOPRTSTACK(&p_emlrtRSI);
  EMLRTPOPRTSTACK(&o_emlrtRSI);
  EMLRTPOPRTSTACK(&n_emlrtRSI);
  return y;
}

/* End of code generation (norm.c) */
