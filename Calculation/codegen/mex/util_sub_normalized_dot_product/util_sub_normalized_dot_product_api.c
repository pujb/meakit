/*
 * util_sub_normalized_dot_product_api.c
 *
 * Code generation for function 'util_sub_normalized_dot_product_api'
 *
 * C source code generated on: Wed Jul 04 15:26:18 2012
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "util_sub_normalized_dot_product.h"
#include "util_sub_normalized_dot_product_api.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */
static void b_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId, real_T y_data[100], int32_T y_size[1]);
static void c_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
  *msgId, real_T ret_data[100], int32_T ret_size[1]);
static void emlrt_marshallIn(const mxArray *a, const char_T *identifier, real_T
  y_data[100], int32_T y_size[1]);
static const mxArray *emlrt_marshallOut(real_T u);

/* Function Definitions */
static void b_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId, real_T y_data[100], int32_T y_size[1])
{
  c_emlrt_marshallIn(emlrtAlias(u), parentId, y_data, y_size);
  emlrtDestroyArray(&u);
}

static void c_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
  *msgId, real_T ret_data[100], int32_T ret_size[1])
{
  int32_T iv2[1];
  boolean_T bv0[1];
  iv2[0] = 100;
  bv0[0] = TRUE;
  emlrtCheckVsBuiltInCtxR2011b(&emlrtContextGlobal, msgId, src, "double", FALSE,
    1U, iv2, bv0, ret_size);
  emlrtImportArrayR2011b(src, ret_data, 8, FALSE);
  emlrtDestroyArray(&src);
}

static void emlrt_marshallIn(const mxArray *a, const char_T *identifier, real_T
  y_data[100], int32_T y_size[1])
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = identifier;
  thisId.fParent = NULL;
  b_emlrt_marshallIn(emlrtAlias(a), &thisId, y_data, y_size);
  emlrtDestroyArray(&a);
}

static const mxArray *emlrt_marshallOut(real_T u)
{
  const mxArray *y;
  const mxArray *m1;
  y = NULL;
  m1 = mxCreateDoubleScalar(u);
  emlrtAssign(&y, m1);
  return y;
}

void util_sub_normalized_dot_product_api(const mxArray * const prhs[2], const
  mxArray *plhs[1])
{
  int32_T a_size[1];
  real_T a_data[100];
  int32_T b_size[1];
  real_T b_data[100];
  real_T result;

  /* Marshall function inputs */
  emlrt_marshallIn(emlrtAliasP(prhs[0]), "a", a_data, a_size);
  emlrt_marshallIn(emlrtAliasP(prhs[1]), "b", b_data, b_size);

  /* Invoke the target function */
  result = util_sub_normalized_dot_product(a_data, a_size, b_data, b_size);

  /* Marshall function outputs */
  plhs[0] = emlrt_marshallOut(result);
}

/* End of code generation (util_sub_normalized_dot_product_api.c) */
