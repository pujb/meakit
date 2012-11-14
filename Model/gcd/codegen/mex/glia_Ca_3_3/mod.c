/*
 * mod.c
 *
 * Code generation for function 'mod'
 *
 * C source code generated on: Thu May 19 17:32:19 2011
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "glia_Ca_3_3.h"
#include "mod.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */

/* Function Definitions */

/*
 * 
 */
real_T b_mod(real_T x, real_T y)
{
    return x - muDoubleScalarFloor(x / 3.0) * 3.0;
}
/* End of code generation (mod.c) */
