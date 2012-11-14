/*
 * glia_Ca_3_3_api.c
 *
 * Code generation for function 'glia_Ca_3_3_api'
 *
 * C source code generated on: Thu May 19 17:32:19 2011
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "glia_Ca_3_3.h"
#include "glia_Ca_3_3_api.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */
static void b_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier *parentId, real_T y[22500]);
static void c_emlrt_marshallIn(const mxArray *location_release_amount, const char_T *identifier, real_T y[3000]);
static void d_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier *parentId, real_T y[3000]);
static real_T e_emlrt_marshallIn(const mxArray *Row, const char_T *identifier);
static void emlrt_marshallIn(const mxArray *C, const char_T *identifier, real_T y[22500]);
static const mxArray *emlrt_marshallOut(const real_T u[22500]);
static real_T f_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier *parentId);
static void g_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier *msgId, real_T ret[22500]);
static void h_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier *msgId, real_T ret[3000]);
static real_T i_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier *msgId);

/* Function Definitions */

static void b_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier *parentId, real_T y[22500])
{
    g_emlrt_marshallIn(emlrtAlias(u), parentId, y);
    emlrtDestroyArray(&u);
}

static void c_emlrt_marshallIn(const mxArray *location_release_amount, const char_T *identifier, real_T y[3000])
{
    emlrtMsgIdentifier thisId;
    thisId.fIdentifier = identifier;
    thisId.fParent = NULL;
    d_emlrt_marshallIn(emlrtAlias(location_release_amount), &thisId, y);
    emlrtDestroyArray(&location_release_amount);
}

static void d_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier *parentId, real_T y[3000])
{
    h_emlrt_marshallIn(emlrtAlias(u), parentId, y);
    emlrtDestroyArray(&u);
}

static real_T e_emlrt_marshallIn(const mxArray *Row, const char_T *identifier)
{
    real_T y;
    emlrtMsgIdentifier thisId;
    thisId.fIdentifier = identifier;
    thisId.fParent = NULL;
    y = f_emlrt_marshallIn(emlrtAlias(Row), &thisId);
    emlrtDestroyArray(&Row);
    return y;
}

static void emlrt_marshallIn(const mxArray *C, const char_T *identifier, real_T y[22500])
{
    emlrtMsgIdentifier thisId;
    thisId.fIdentifier = identifier;
    thisId.fParent = NULL;
    b_emlrt_marshallIn(emlrtAlias(C), &thisId, y);
    emlrtDestroyArray(&C);
}

static const mxArray *emlrt_marshallOut(const real_T u[22500])
{
    const mxArray *y;
    static const int32_T iv2[2] = { 150, 150 };
    const mxArray *m0;
    real_T (*pData)[];
    int32_T i;
    y = NULL;
    m0 = mxCreateNumericArray(2, (int32_T *)&iv2, mxDOUBLE_CLASS, mxREAL);
    pData = (real_T (*)[])mxGetPr(m0);
    for (i = 0; i < 22500; i++) {
        (*pData)[i] = u[i];
    }
    emlrtAssign(&y, m0);
    return y;
}

static real_T f_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier *parentId)
{
    real_T y;
    y = i_emlrt_marshallIn(emlrtAlias(u), parentId);
    emlrtDestroyArray(&u);
    return y;
}

static void g_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier *msgId, real_T ret[22500])
{
    int32_T i;
    int32_T iv3[2];
    int32_T i5;
    for (i = 0; i < 2; i++) {
        iv3[i] = 150;
    }
    emlrtCheckBuiltInR2011a(msgId, src, "double", FALSE, 2U, iv3);
    for (i = 0; i < 150; i++) {
        for (i5 = 0; i5 < 150; i5++) {
            ret[i5 + 150 * i] = (*(real_T (*)[22500])mxGetData(src))[i5 + 150 * i];
        }
    }
    emlrtDestroyArray(&src);
}

static void h_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier *msgId, real_T ret[3000])
{
    int32_T i6;
    int32_T iv4[2];
    int32_T i7;
    for (i6 = 0; i6 < 2; i6++) {
        iv4[i6] = 1000 + -997 * i6;
    }
    emlrtCheckBuiltInR2011a(msgId, src, "double", FALSE, 2U, iv4);
    for (i6 = 0; i6 < 3; i6++) {
        for (i7 = 0; i7 < 1000; i7++) {
            ret[i7 + 1000 * i6] = (*(real_T (*)[3000])mxGetData(src))[i7 + 1000 * i6];
        }
    }
    emlrtDestroyArray(&src);
}

static real_T i_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier *msgId)
{
    real_T ret;
    emlrtCheckBuiltInR2011a(msgId, src, "double", FALSE, 0U, 0);
    ret = *(real_T *)mxGetData(src);
    emlrtDestroyArray(&src);
    return ret;
}

void glia_Ca_3_3_api(glia_Ca_3_3StackData *SD, const mxArray * const prhs[6], const mxArray *plhs[3])
{
    real_T location_release_amount[3000];
    real_T Row;
    real_T Col;
    int32_T i4;
    /* Marshall function inputs */
    emlrt_marshallIn(emlrtAliasP(prhs[0]), "C", SD->f0.C);
    emlrt_marshallIn(emlrtAliasP(prhs[1]), "P", SD->f0.P);
    emlrt_marshallIn(emlrtAliasP(prhs[2]), "H", SD->f0.H);
    c_emlrt_marshallIn(emlrtAliasP(prhs[3]), "location_release_amount", location_release_amount);
    Row = e_emlrt_marshallIn(emlrtAliasP(prhs[4]), "Row");
    Col = e_emlrt_marshallIn(emlrtAliasP(prhs[5]), "Col");
    /* Invoke the target function */
    for (i4 = 0; i4 < 22500; i4++) {
        SD->f0.b_C[i4] = SD->f0.C[i4];
        SD->f0.b_P[i4] = SD->f0.P[i4];
        SD->f0.b_H[i4] = SD->f0.H[i4];
    }
    glia_Ca_3_3(SD->f0.b_C, SD->f0.b_P, SD->f0.b_H, location_release_amount, Row, Col, SD->f0.C, SD->f0.P, SD->f0.H);
    /* Marshall function outputs */
    plhs[0] = emlrt_marshallOut(SD->f0.C);
    plhs[1] = emlrt_marshallOut(SD->f0.P);
    plhs[2] = emlrt_marshallOut(SD->f0.H);
}
/* End of code generation (glia_Ca_3_3_api.c) */
