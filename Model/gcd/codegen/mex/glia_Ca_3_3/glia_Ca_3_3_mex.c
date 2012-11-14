/*
 * glia_Ca_3_3_mex.c
 *
 * Code generation for function 'glia_Ca_3_3'
 *
 * C source code generated on: Thu May 19 17:32:19 2011
 *
 */

/* Include files */
#include "mex.h"
#include "glia_Ca_3_3_api.h"
#include "glia_Ca_3_3_initialize.h"
#include "glia_Ca_3_3_terminate.h"

/* Type Definitions */

/* Function Declarations */
static void glia_Ca_3_3_mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);

/* Variable Definitions */
emlrtContext emlrtContextGlobal = { true, false, EMLRT_VERSION_INFO, NULL, "glia_Ca_3_3", NULL, false, NULL };

/* Function Definitions */
static void glia_Ca_3_3_mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  /* Temporary copy for mex outputs. */
  mxArray *outputs[3];
  int n = 0;
  int nOutputs = (nlhs < 1 ? 1 : nlhs);
  glia_Ca_3_3StackData* glia_Ca_3_3StackDataLocal = (glia_Ca_3_3StackData*)mxCalloc(1,sizeof(glia_Ca_3_3StackData));
  /* Check for proper number of arguments. */
  if(nrhs != 6) {
    mexErrMsgIdAndTxt("emlcoder:emlmex:WrongNumberOfInputs","6 inputs required for entry-point 'glia_Ca_3_3'.");
  } else if(nlhs > 3) {
    mexErrMsgIdAndTxt("emlcoder:emlmex:TooManyOutputArguments","Too many output arguments for entry-point 'glia_Ca_3_3'.");
  }
  /* Module initialization. */
  glia_Ca_3_3_initialize(&emlrtContextGlobal);
  /* Call the function. */
  glia_Ca_3_3_api(glia_Ca_3_3StackDataLocal, prhs,(const mxArray**)outputs);
  /* Copy over outputs to the caller. */
  for (n = 0; n < nOutputs; ++n) {
    plhs[n] = emlrtReturnArrayR2009a(outputs[n]);
  }
  /* Module finalization. */
  glia_Ca_3_3_terminate();
  mxFree(glia_Ca_3_3StackDataLocal);
}
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  /* Initialize the memory manager. */
  mexAtExit(glia_Ca_3_3_atexit);
  emlrtClearAllocCount(&emlrtContextGlobal, 0, 0, NULL);
  /* Dispatch the entry-point. */
  glia_Ca_3_3_mexFunction(nlhs, plhs, nrhs, prhs);
}
/* End of code generation (glia_Ca_3_3_mex.c) */
