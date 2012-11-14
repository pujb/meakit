/*
 * util_sub_normalized_dot_product_terminate.c
 *
 * Code generation for function 'util_sub_normalized_dot_product_terminate'
 *
 * C source code generated on: Wed Jul 04 15:26:18 2012
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "util_sub_normalized_dot_product.h"
#include "util_sub_normalized_dot_product_terminate.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */

/* Function Definitions */
void util_sub_normalized_dot_product_atexit(void)
{
  emlrtEnterRtStack(&emlrtContextGlobal);
  emlrtLeaveRtStack(&emlrtContextGlobal);
  emlrtExitTimeCleanup(&emlrtContextGlobal);
}

void util_sub_normalized_dot_product_terminate(void)
{
  emlrtLeaveRtStack(&emlrtContextGlobal);
}

/* End of code generation (util_sub_normalized_dot_product_terminate.c) */
