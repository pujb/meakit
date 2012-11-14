/*
 * util_sub_jaccard_index.c
 *
 * Code generation for function 'util_sub_jaccard_index'
 *
 * C source code generated on: Wed Jul 04 15:01:01 2012
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "util_sub_jaccard_index.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */

/* Function Definitions */
real_T util_sub_jaccard_index(real_T a, real_T b)
{
  real_T result;
  real_T dotproduct;

  /*  JACCARD_INDEX Calculating the Jaccard Coefficient Index between a and b. */
  /*  */
  /*    This is the extented jaccard index, a.k.a. Tanimoto coefficient */
  /*  */
  /*    Created on Aug/28/2010 By Pu Jiangbo */
  /*    Britton Chance Center for Biomedical Photonics */
  /*        PJB#2012-07-04  Adding assert for codegen */
  /*  Assert Class for Codegen */
  /*  This is slow */
  /*  dotproduct = dot(a, b); */
  /*  Because when a and b are both column vectors, a'*b is the same as dot(a,b) */
  dotproduct = a * b;

  /*  Avoid nan (0/0 = NaN) */
  if (!(dotproduct != 0.0)) {
    result = 0.0;
  } else {
    result = dotproduct / ((muDoubleScalarPower(muDoubleScalarAbs(a), 2.0) +
      muDoubleScalarPower(muDoubleScalarAbs(b), 2.0)) - dotproduct);
  }

  return result;
}

/* End of code generation (util_sub_jaccard_index.c) */
