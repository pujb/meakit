/*
 * glia_Ca_3_3_terminate.c
 *
 * Code generation for function 'glia_Ca_3_3_terminate'
 *
 * C source code generated on: Thu May 19 17:32:19 2011
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "glia_Ca_3_3.h"
#include "glia_Ca_3_3_terminate.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */

/* Function Definitions */

void glia_Ca_3_3_atexit(void)
{
    emlrtExitTimeCleanup(&emlrtContextGlobal);
}

void glia_Ca_3_3_terminate(void)
{
    emlrtLeaveRtStack(&emlrtContextGlobal);
}
/* End of code generation (glia_Ca_3_3_terminate.c) */
