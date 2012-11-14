/*
 * find.c
 *
 * Code generation for function 'find'
 *
 * C source code generated on: Thu May 19 17:32:19 2011
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "glia_Ca_3_3.h"
#include "find.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */
static emlrtECInfo m_emlrtECI = { -1, 221, 17, "find", "D:/MATLAB/R2011a/toolbox/eml/lib/matlab/elmat/find.m" };

/* Function Declarations */

/* Function Definitions */

/*
 * 
 */
void find(const boolean_T x[1000], real_T i_data[1000], int32_T i_sizes[1])
{
    int32_T idx;
    int32_T ii;
    boolean_T exitg1;
    boolean_T guard1 = FALSE;
    int32_T i3;
    int32_T tmp_data[1000];
    int32_T b_tmp_data[1000];
    int16_T b_i_data[1000];
    idx = 0;
    i_sizes[0] = 1000;
    ii = 1;
    exitg1 = 0U;
    while ((exitg1 == 0U) && (ii <= 1000)) {
        guard1 = FALSE;
        if (x[ii - 1]) {
            idx++;
            i_data[idx - 1] = (real_T)ii;
            if (idx >= 1000) {
                exitg1 = 1U;
            } else {
                guard1 = TRUE;
            }
        } else {
            guard1 = TRUE;
        }
        if (guard1 == TRUE) {
            ii++;
        }
    }
    if (1 > idx) {
        idx = 0;
    }
    ii = idx - 1;
    for (i3 = 0; i3 <= ii; i3++) {
        tmp_data[i3] = 1 + i3;
    }
    ii = idx - 1;
    for (i3 = 0; i3 <= ii; i3++) {
        b_tmp_data[i3] = tmp_data[i3];
    }
    emlrtVectorVectorIndexCheckR2011a(1000, 1, 1, idx, &m_emlrtECI, &emlrtContextGlobal);
    ii = idx - 1;
    for (i3 = 0; i3 <= ii; i3++) {
        b_i_data[i3] = (int16_T)i_data[b_tmp_data[i3] - 1];
    }
    i_sizes[0] = idx;
    ii = idx - 1;
    for (i3 = 0; i3 <= ii; i3++) {
        i_data[i3] = (real_T)b_i_data[i3];
    }
}
/* End of code generation (find.c) */
