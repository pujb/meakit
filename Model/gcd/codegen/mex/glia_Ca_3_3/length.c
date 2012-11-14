/*
 * length.c
 *
 * Code generation for function 'length'
 *
 * C source code generated on: Thu May 19 17:32:19 2011
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "glia_Ca_3_3.h"
#include "length.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */

/* Function Definitions */

/*
 * 
 */
real_T length(const real_T x_data[1000], const int32_T x_sizes[1])
{
    real_T n;
    if (x_sizes[0] == 0) {
        n = 0.0;
    } else if (x_sizes[0] > 1) {
        n = (real_T)x_sizes[0];
    } else {
        n = 1.0;
    }
    return n;
}
/* End of code generation (length.c) */
