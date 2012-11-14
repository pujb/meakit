#include "mex.h"
#include <math.h>
#include <stdio.h>

 /*last edited on April 22, 2009, to fix various issues */

#define delta 5 /* number of pts. used when verifying fit accuracy */

void W_recursive(int n_c, double *V, double *W, int channelOffset, int N) {
    double oldW[4];
    oldW[0] = W[0];
    oldW[1] = W[1];
    oldW[2] = W[2];
    /*oldW[3] = W[3];  /* no need for W[3], since it's only read once */
    W[0] =  oldW[0] + V[n_c+N+channelOffset] - V[n_c-N-1+channelOffset];
    W[1] = -oldW[0] + oldW[1] + N*V[n_c+N+channelOffset] - (-N-1)*V[n_c-N-1+channelOffset];
    W[2] =  oldW[0] - 2*oldW[1] + oldW[2] + pow(N,2)*V[n_c+N+channelOffset] - pow(-N-1,2)*V[n_c-N-1+channelOffset];
    W[3] = -oldW[0] + 3*oldW[1] - 3*oldW[2] + W[3] + pow(N,3)*V[n_c+N+channelOffset] - pow(-N-1,3)*V[n_c-N-1+channelOffset];  /* not sure about indexing for V's  */
}

void W_nonRecursive(int n_c, double *V, double *W, int channelOffset, int N) {  /* channelOffset is start index for V,
                                                                    since V has multiple data from multiple electrodes */
    int k, i;  /* index variables */
    W[0] = W[1] = W[2] = W[3] = 0;
    for(k = 0; k <= 3; ++k) {
        for(i = -N; i <= N; ++i) {
            W[k] += pow(i,k)*V[n_c+i+channelOffset];
        }
        /*  y[k] = sum((([-N:N]').^k).*V(n_c-N:n_c+N));  /* corresponding Matlab code */
    }
}

void alpha(double *a, int n_c, double *W, double *SInv) {
    a[0] = SInv[0]*W[0] + SInv[2*4]*W[2];
    a[1] = SInv[1+1*4]*W[1] + SInv[1+3*4]*W[3];
    a[2] = SInv[2]*W[0] + SInv[2+2*4]*W[2];
    a[3] = SInv[3+1*4]*W[1] + SInv[3+3*4]*W[3];
    /*mexPrintf("S[0][2] = %d, S[1][3] = %d  %d\n", SInv[2*4], SInv[1+3*4], 0.003);*/
}

void A_n(double *A, int n, int lenN, int n_c, double *W, double *SInv) {  /* n is the first of lenN pts. where you want the fit, n_c is the fit's center */
    int i;
    double a[4];
    alpha(a, n_c, W, SInv);
    for(i = 0; i < lenN; ++i) {
        A[i] = a[0] + a[1]*(n+i-n_c) + a[2]*pow(n+i-n_c,2) + a[3]*pow(n+i-n_c,3);
    }
    /* y = [a(1)*ones(1,length(n)) + a(2)*(n-n_c) + a(3)*(n-n_c).^2 + a(4)*(n-n_c).^3]'; /* corresponding Matlab code */
}

double D_n(int n_c, double *V, double *A, int channelOffset, int N) {
    double y; /* return value */
    int i;
    y = 0;
    for(i = 0; i < delta; ++i) {
        y += V[n_c-N+i+channelOffset] - A[i];
    }
    return (y*y);
    /* y = (sum(V(n_c-N:n_c-N+delta-1) - A(1:delta))).^2;  /* corresponding Matlab code */
}




/* Performs SALPA on signal to filter.
/* Call in matlab would be: [filtData, myfit] = SALPAmex(Data, N, SInv, rails, NPrePeg, NPostPeg, NPostFit, SalpaThresh, StimTimes)*/

/*StimTimes allows you to automatically blank at a stimulus pulse, regardless of railing.  This should be in terms of indices, not seconds*/
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    int c, i, j, k, m, numSamples, status, numElectrodes, NPrePeg, NPostPeg, NPostFit, stopPegii;
    int numStimTimes, N;
    double  *spkData, *rails, thresh, *filtData, *myFit, *stimTimes, *SInv;
    double W[4], test;
    
    numSamples = mxGetM(prhs[0]); /* gets length (i.e., M) of spkData */
    /*numElectrodes = (int)mxGetScalar(prhs[1]);*/
    numElectrodes = mxGetN(prhs[0]);
    spkData = mxGetPr(prhs[0]); /* input data to be filtered */
    N = (int)mxGetScalar(prhs[1]); /* Half-width of filter */
    SInv = mxGetPr(prhs[2]); /* S Inverse (i.e., S') */
    rails = mxGetPr(prhs[3]); /*rails is an array which contains the high and low rails for each channel [2 x Nchans] */
    NPrePeg = (int)mxGetScalar(prhs[4]);
    NPostPeg = (int)mxGetScalar(prhs[5]);
    NPostFit = (int)mxGetScalar(prhs[6]);
    thresh = mxGetScalar(prhs[7]);
    stimTimes = mxGetPr(prhs[8]);
    numStimTimes = mxGetM(prhs[8]);
    
    /* Create matrix for filtered data */
    plhs[0] = mxCreateDoubleMatrix(numSamples, numElectrodes, mxREAL);
    filtData = mxGetPr(plhs[0]);
    /* Create matrix for fit of raw data, if desired */
    if (nlhs > 1) {
        plhs[1] = mxCreateDoubleMatrix(numSamples, numElectrodes, mxREAL);
        myFit = mxGetPr(plhs[1]);
    }
    
    /* For debugging purposes */
    /*mexPrintf("S[0][2] = %e, S[1][3] = %e\n", SInv[2*4], SInv[1+3*4]);*/
   
    
    /* Filter the trace with SALPA */
    for (i = 0; i < numElectrodes; ++i) {
        int PEGGING, DEPEGGING, FULL_LOOK, W_SUCCESS;
        PEGGING = 1;
        DEPEGGING = 0;
        FULL_LOOK = 1; /* says whether you need to look at all 1:N future samples for rails (true), or just the Nth future sample (false) */
        W_SUCCESS = 0; /* says whether we successfully computed a W nonrecursive */

        j = 0;
        while(j < numSamples - N) {
            /* This first section of code looks ahead for pegging */
            int startPeg, stopPeg, startPegii;
            startPeg = -1;
            stopPeg = -1;
            /* If FULL_LOOK is true, look over the next N samples */
            if (FULL_LOOK) {
                for (k = j; k <= j+N; ++k) {
                    if (spkData[k+i*numSamples] <= rails[2*i+0] || spkData[k+i*numSamples] >= rails[2*i+1]) {
                        if (startPeg == -1) {
                            startPeg = k;
                            stopPeg = k;
                        } else {
                            stopPeg = k;
                        }
                    }
                    else {
                        for (m = 0; m < numStimTimes; ++m) {
                            if (k == stimTimes[m]) {
                                if (startPeg == -1) {
                                    startPeg = k;
                                    stopPeg = k;
                                } else { stopPeg = k; }
                            }
                        }
                    }
                }
            } else {  /* Otherwise, no full look-ahead: just the next sample */
                if (spkData[j+N+i*numSamples] <= rails[2*i+0] || spkData[j+N+i*numSamples] >= rails[2*i+1]) {
                    startPeg = j+N;
                    stopPeg = j+N;
                } else {
                    for (m = 0; m < numStimTimes; ++m) {
                        if (j+N == (int)stimTimes[m]) {
                            if (startPeg == -1) {
                                startPeg = j+N;
                                stopPeg = j+N;
                            } else { stopPeg = j+N; }
                        }
                    }
                }
            }
            
            /* Respond to pegging (railing) if detected */
            if (startPeg >= 0) {
                if (stopPeg + NPostPeg > numSamples) {
                    stopPegii = numSamples - 1;
                }
                else {
                    stopPegii = stopPeg + NPostPeg;
                }

                W_SUCCESS = 0; /*since we just hit or are still on a peg, we have no W's yet */

                if (PEGGING == 0) {
                    int backtrackJ; /* tracks where fit should backtrack, to avoid using contaminated W */
                    double *A;
                    A = mxCalloc(N + 1, sizeof(double));
                    /*check to make sure start index is valid*/
                    if (startPeg - NPrePeg >= 0) {
                        startPegii = startPeg - NPrePeg;
                    }else{
                        startPegii = 0; /*go as far back as possible */
                    }
                    /* copy filtered data into output, up till peg , but scoot back by NPrePeg */
                    /*W_recursive(j-1, spkData, W, i*numSamples, N); /*commented out, since this next W would include artifact */
                    W_nonRecursive(startPegii - N, spkData, W, i*numSamples, N); /*changed to nonRecursive, and started fit before it's contaminated by artifact */
                    backtrackJ = startPegii - N;
                    if (backtrackJ > j) backtrackJ = j;
                    A_n(A, backtrackJ, startPegii - backtrackJ, startPegii - N, W, SInv);
                    for (k = backtrackJ; k < startPegii; ++k) {
                        filtData[k+i*numSamples] = spkData[k+i*numSamples] - A[k - backtrackJ];
                    }
                    if (nlhs > 1)
                        for (k = backtrackJ; k < startPegii; ++k)
                            myFit[k+i*numSamples] = A[k - backtrackJ];

                    /* zero out peg */
                    for (k = startPegii; k <= stopPegii; ++k)
                        filtData[k+i*numSamples] = 0;
                    if (nlhs > 1)
                        for (k = startPegii; k <= stopPegii; ++k)
                            myFit[k+i*numSamples] = 0;
                    mxFree(A);
                } else {   /* PEGGING == 1, which means we're still in the same peg */
                    for (k = j; k <= stopPegii; ++k)
                        filtData[k+i*numSamples] = 0;  /* zero out pegging */
                    if (nlhs > 1)
                        for (k = j; k <= stopPegii; ++k)
                            myFit[k+i*numSamples] = 0;
                }
                PEGGING = 1; /* declare that we're pegging */
                DEPEGGING = 0;
                j = stopPegii + 1; /* move to the next data point after peg */
                FULL_LOOK = 1;  /* because we jumped ahead, we need to ensure we check for rails thoroughly */
                continue;
            } else {
                FULL_LOOK = 0;  /* now, we know there is no pegging for the next N pts. */
            }
        /* this ends peg checking */

            if (PEGGING == 1) {
            /* we were just at a rail, now we're trying to fit data */
                int n_c;
                /*double A[N+1];*/
                double *A;
                A = mxCalloc(N + 1, sizeof(double));
                PEGGING = 0;

                n_c = j + N;  /* start the fit N samples away */

            /*obscure case where we attempt to start a fit, but there isn't enough data to do it. This can happen when I have very long RC
             *constants, but the trial ends.  */
                if(n_c + N < numSamples){
                    W_nonRecursive(n_c, spkData, W, i*numSamples, N);
                }else{
                    break; /*if we can't even attempt to compute a Wnonrecursive, nothing left we can hope to do, exit while loop*/
                }
                A_n(A, j, N+1, n_c, W, SInv);
                if (D_n(n_c, spkData, A, i*numSamples, N) < thresh) {
                /* satisfies fit criterion */
                    W_SUCCESS = 1; /*declare successful computation of Wnonrecursive within threshold */
                    for (k = 0; k < NPostFit; ++k)
                        filtData[k+j+i*numSamples] = 0.0;
                    if (nlhs > 1)
                        for (k = 0; k < NPostFit; ++k)
                            myFit[k+j+i*numSamples] = 0.0;
                    for (k = NPostFit; k <= N; ++k)
                    /* subtract out fit */
                        filtData[k+j+i*numSamples] = spkData[k+j+i*numSamples] - A[k];
                    if (nlhs > 1)
                        for (k = NPostFit; k <= N; ++k)
                            myFit[k+j+i*numSamples] = A[k];
                    j = n_c + 1;  /* jump ahead to end of fit */
                } else {  /* fit wasn't good enough */
                    filtData[j+i*numSamples] = 0; /* set pt. to zero, since the fit was too crappy */
                    if (nlhs > 1)
                        myFit[j+i*numSamples] = 0;
                    ++j;  /* go to next pt. */
                    DEPEGGING = 1;
                }
                mxFree(A);
                continue;
            }

            else if (DEPEGGING == 1) {  /* we've come out of a peg, but the fit wasn't good */
                int n_c;
                /*double A[N+1];*/
                double *A;
                A = mxCalloc(N + 1, sizeof(double));

                n_c = j + N;
                W_recursive(n_c, spkData, W, i*numSamples, N);
                A_n(A, j, N+1, n_c, W, SInv);
                if (D_n(n_c, spkData, A, i*numSamples, N) < thresh) {
                /* satisfies fit criterion */
                    W_SUCCESS = 1; /*declare successful computation of Wnonrecursive within threshold*/
                    for (k = 0; k <= N; ++k)
                    /* subtract out fit */
                        filtData[k+j+i*numSamples] = spkData[k+j+i*numSamples] - A[k];
                    if (nlhs > 1)
                        for (k = 0; k <= N; ++k)
                            myFit[k+j+i*numSamples] = A[k];
                    j = n_c + 1;  /* jump ahead to end of fit */
                    DEPEGGING = 0;
                } else {  /* fit wasn't good enough */
                    filtData[j+i*numSamples] = 0; /* set pt. to zero, since the fit was too crappy */
                    if (nlhs > 1)
                        myFit[j+i*numSamples] = 0;
                    ++j;  /* go to next pt. */
                }
                mxFree(A);
                continue;
            }

            else {  /* now, it's the normal algorithm */
                double A[1];

                W_recursive(j, spkData, W, i*numSamples, N);
                A_n(A, j, 1, j, W, SInv);  /* get point to fit */
                filtData[j+i*numSamples] = spkData[j+i*numSamples] - A[0];
                if (nlhs > 1)
                    myFit[j+i*numSamples] = A[0];
                ++j;
            }
        }

        {/* take care of last N pts.;
        do this in its own scope, so we can avoid resizing A[] */
            /*double A[N];  /* this may wind up being slightly bigger than necessary */
            double *A;
            A = mxCalloc(N, sizeof(double));
            if(W_SUCCESS ==1){
                A_n(A, j, numSamples-j, j-1, W, SInv);
                for (k = j; k < numSamples; ++k)
                    filtData[k+i*numSamples] = spkData[k+i*numSamples] - A[k-j];
                if (nlhs > 1)
                    for (k = j; k < numSamples; ++k)
                        myFit[k+i*numSamples]= A[k-j];
            }else{ /*came out of the obscure case where we don't have even a single W, so just 0 out everything*/
                for (k = j; k < numSamples; ++k)
                    filtData[k+i*numSamples] = 0;
                if (nlhs > 1)
                    for (k = j; k < numSamples; ++k)
                        myFit[k+i*numSamples]= 0;
            }
            mxFree(A);
        }
    } 
}