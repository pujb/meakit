/*
 * norm.h
 *
 * Code generation for function 'norm'
 *
 * C source code generated on: Wed Jul 04 15:26:18 2012
 *
 */

#ifndef __NORM_H__
#define __NORM_H__
/* Include files */
#include <math.h>
#include <stdlib.h>
#include <string.h>

#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include "blascompat32.h"
#include "rtwtypes.h"
#include "util_sub_normalized_dot_product_types.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */
extern real_T norm(const real_T x_data[100], const int32_T x_size[1]);
#ifdef __WATCOMC__
#pragma aux norm value [8087];
#endif
#endif
/* End of code generation (norm.h) */
