/*
 * util_sub_jaccard_index_terminate.c
 *
 * Code generation for function 'util_sub_jaccard_index_terminate'
 *
 * C source code generated on: Wed Jul 04 15:01:01 2012
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "util_sub_jaccard_index.h"
#include "util_sub_jaccard_index_terminate.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */

/* Function Definitions */
void util_sub_jaccard_index_atexit(void)
{
  emlrtEnterRtStack(&emlrtContextGlobal);
  emlrtLeaveRtStack(&emlrtContextGlobal);
  emlrtExitTimeCleanup(&emlrtContextGlobal);
}

void util_sub_jaccard_index_terminate(void)
{
  emlrtLeaveRtStack(&emlrtContextGlobal);
}

/* End of code generation (util_sub_jaccard_index_terminate.c) */
