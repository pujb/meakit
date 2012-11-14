/*
 * util_sub_get_sync.c
 *
 * Code generation for function 'util_sub_get_sync'
 *
 * C source code generated on: Wed Jul 04 15:01:15 2012
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "util_sub_get_sync.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */

/* Function Definitions */
void util_sub_get_sync(real_T spiketimesA, real_T spiketimesB, real_T *Q, real_T
  *q)
{
  real_T cxy;
  real_T x1;
  real_T x3;
  real_T cyx;

  /* GET_SYNC The core calculation part. */
  /*  Pu Jiangbo 2010-11-08 Original */
  /*  Pu Jiangbo 2011-04-02 Extract this part into a sub-function */
  /*  Pu Jiangbo 2011-05-16 Making MEX. (Speed up x 6) */
  /*                        Removing verbose output. */
  /*  Pu Jiangbo 2012-07-04 Adding assert for Codegen */
  /*  Assert Class for Codegen */
  /*  loop for c_x|y */
  cxy = 0.0;

  /*  Determine Tau */
  x1 = spiketimesA - spiketimesA;
  x3 = spiketimesB - spiketimesB;

  /*  Use for speeding up the searching of min */
  /*  Only support length(x) = 4 */
  /*  Pu Jiangbo 2010-11-08 */
  /*  Pu Jiangbo 2011-04-03: Speedup by not using []. */
  /*  Pu Jiangbo 2011-05-16: Making it MEX */
  if (x1 > spiketimesA) {
    x1 = spiketimesA;
  }

  if (x3 > spiketimesB) {
    x3 = spiketimesB;
  }

  if (x1 > x3) {
    x1 = x3;
  }

  /*  Determine J-ij */
  if ((spiketimesA - spiketimesB > 0.0) && (spiketimesA - spiketimesB < x1 / 2.0))
  {
    cxy = 1.0;
  } else {
    if (spiketimesA == spiketimesB) {
      cxy = 0.5;
    }
  }

  /*  loop end c_x|y */
  /*  loop for c_y|x */
  cyx = 0.0;

  /*  Determine Tau */
  x1 = spiketimesA - spiketimesA;
  x3 = spiketimesB - spiketimesB;

  /*  Use for speeding up the searching of min */
  /*  Only support length(x) = 4 */
  /*  Pu Jiangbo 2010-11-08 */
  /*  Pu Jiangbo 2011-04-03: Speedup by not using []. */
  /*  Pu Jiangbo 2011-05-16: Making it MEX */
  if (x1 > spiketimesA) {
    x1 = spiketimesA;
  }

  if (x3 > spiketimesB) {
    x3 = spiketimesB;
  }

  if (x1 > x3) {
    x1 = x3;
  }

  /*  Determine J-ij */
  if ((spiketimesB - spiketimesA > 0.0) && (spiketimesB - spiketimesA < x1 / 2.0))
  {
    cyx = 1.0;
  } else {
    if (spiketimesA == spiketimesB) {
      cyx = 0.5;
    }
  }

  /*  loop end c_x|y */
  *Q = cxy + cyx;
  *q = cyx - cxy;
}

/* End of code generation (util_sub_get_sync.c) */
