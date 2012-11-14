/*
 * util_sub_get_sync_mex.c
 *
 * Code generation for function 'util_sub_get_sync'
 *
 * C source code generated on: Wed Jul 04 15:01:15 2012
 *
 */

/* Include files */
#include "mex.h"
#include "util_sub_get_sync_api.h"
#include "util_sub_get_sync_initialize.h"
#include "util_sub_get_sync_terminate.h"

/* Type Definitions */

/* Function Declarations */
static void util_sub_get_sync_mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
MEXFUNCTION_LINKAGE mxArray *emlrtMexFcnProperties(void);

/* Variable Definitions */
emlrtContext emlrtContextGlobal = { true, false, EMLRT_VERSION_INFO, NULL, "util_sub_get_sync", NULL, false, {2045744189U,2170104910U,2743257031U,4284093946U}, 0, false, 1, false };

/* Function Definitions */
static void util_sub_get_sync_mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  /* Temporary copy for mex outputs. */
  mxArray *outputs[2];
  int n = 0;
  int nOutputs = (nlhs < 1 ? 1 : nlhs);
  /* Check for proper number of arguments. */
  if(nrhs != 2) {
    mexErrMsgIdAndTxt("emlcoder:emlmex:WrongNumberOfInputs","2 inputs required for entry-point 'util_sub_get_sync'.");
  } else if(nlhs > 2) {
    mexErrMsgIdAndTxt("emlcoder:emlmex:TooManyOutputArguments","Too many output arguments for entry-point 'util_sub_get_sync'.");
  }
  /* Module initialization. */
  util_sub_get_sync_initialize(&emlrtContextGlobal);
  /* Call the function. */
  util_sub_get_sync_api(prhs,(const mxArray**)outputs);
  /* Copy over outputs to the caller. */
  for (n = 0; n < nOutputs; ++n) {
    plhs[n] = emlrtReturnArrayR2009a(outputs[n]);
  }
  /* Module finalization. */
  util_sub_get_sync_terminate();
}

void util_sub_get_sync_atexit_wrapper(void)
{
  util_sub_get_sync_atexit();
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  /* Initialize the memory manager. */
  mexAtExit(util_sub_get_sync_atexit_wrapper);
  emlrtClearAllocCount(&emlrtContextGlobal, 0, 0, NULL);
  /* Dispatch the entry-point. */
  util_sub_get_sync_mexFunction(nlhs, plhs, nrhs, prhs);
}

mxArray *emlrtMexFcnProperties(void)
{
    const char *mexProperties[] = {
        "Version",
        "EntryPoints"};
    const char *epProperties[] = {
        "Name",
        "NumberOfInputs",
        "NumberOfOutputs",
        "ConstantInputs"};
    mxArray *xResult = mxCreateStructMatrix(1,1,2,mexProperties);
    mxArray *xEntryPoints = mxCreateStructMatrix(1,1,4,epProperties);
    mxArray *xInputs = NULL;
    xInputs = mxCreateLogicalMatrix(1, 2);
    mxSetFieldByNumber(xEntryPoints, 0, 0, mxCreateString("util_sub_get_sync"));
    mxSetFieldByNumber(xEntryPoints, 0, 1, mxCreateDoubleScalar(2));
    mxSetFieldByNumber(xEntryPoints, 0, 2, mxCreateDoubleScalar(2));
    mxSetFieldByNumber(xEntryPoints, 0, 3, xInputs);
    mxSetFieldByNumber(xResult, 0, 0, mxCreateString("7.14.0.739 (R2012a)"));
    mxSetFieldByNumber(xResult, 0, 1, xEntryPoints);

    return xResult;
}
/* End of code generation (util_sub_get_sync_mex.c) */
