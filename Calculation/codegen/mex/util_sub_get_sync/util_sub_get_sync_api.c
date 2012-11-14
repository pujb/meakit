/*
 * util_sub_get_sync_api.c
 *
 * Code generation for function 'util_sub_get_sync_api'
 *
 * C source code generated on: Wed Jul 04 15:01:15 2012
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "util_sub_get_sync.h"
#include "util_sub_get_sync_api.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */
static real_T b_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId);
static real_T c_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
  *msgId);
static real_T emlrt_marshallIn(const mxArray *spiketimesA, const char_T
  *identifier);
static const mxArray *emlrt_marshallOut(real_T u);

/* Function Definitions */
static real_T b_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId)
{
  real_T y;
  y = c_emlrt_marshallIn(emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static real_T c_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
  *msgId)
{
  real_T ret;
  emlrtCheckBuiltInCtxR2011b(&emlrtContextGlobal, msgId, src, "double", FALSE,
    0U, 0);
  ret = *(real_T *)mxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

static real_T emlrt_marshallIn(const mxArray *spiketimesA, const char_T
  *identifier)
{
  real_T y;
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = identifier;
  thisId.fParent = NULL;
  y = b_emlrt_marshallIn(emlrtAlias(spiketimesA), &thisId);
  emlrtDestroyArray(&spiketimesA);
  return y;
}

static const mxArray *emlrt_marshallOut(real_T u)
{
  const mxArray *y;
  const mxArray *m0;
  y = NULL;
  m0 = mxCreateDoubleScalar(u);
  emlrtAssign(&y, m0);
  return y;
}

void util_sub_get_sync_api(const mxArray * const prhs[2], const mxArray *plhs[2])
{
  real_T spiketimesA;
  real_T spiketimesB;
  real_T q;
  real_T Q;

  /* Marshall function inputs */
  spiketimesA = emlrt_marshallIn(emlrtAliasP(prhs[0]), "spiketimesA");
  spiketimesB = emlrt_marshallIn(emlrtAliasP(prhs[1]), "spiketimesB");

  /* Invoke the target function */
  util_sub_get_sync(spiketimesA, spiketimesB, &Q, &q);

  /* Marshall function outputs */
  plhs[0] = emlrt_marshallOut(Q);
  plhs[1] = emlrt_marshallOut(q);
}

/* End of code generation (util_sub_get_sync_api.c) */
