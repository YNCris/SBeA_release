#include "mex.h"

#define ptr(i, j, k) ((j) * k + i)

/* 
 * function [C, W] = dtakBack(P)
 *
 * History
 *   create  -  Feng Zhou, 03-20-2009
 *   modify  -  Feng Zhou, 12-22-2009
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

    // P
    double *P = mxGetPr(prhs[0]);
    int n1 = mxGetM(prhs[0]);
    int n2 = mxGetN(prhs[0]);

    // determine the step number
    int p = ptr(n1 - 1, n2 - 1, n1);
    int m = 1;
    while (P[p] > 0) {
        if (P[p] == 1) {
            p -= n1;
        } else if (P[p] == 2) {
            --p;
        } else if (P[p] == 3) {
            p -= n1 + 1;
        } else if (P[p] == 4) {
            p -= n1 + n1 + 1;
            ++m;
        } else if (P[p] == 5) {
            p -= n1 + 2;
            ++m;
        } else {
            printf("unknown path direction\n");
            plhs[0] = mxCreateDoubleMatrix(2, 1, mxREAL);
            plhs[1] = mxCreateDoubleMatrix(n1, n2, mxREAL);
            return;
        }
        ++m;
    }

    // C
    plhs[0] = mxCreateDoubleMatrix(2, m, mxREAL);
    double *C = mxGetPr(plhs[0]);

    // W
    plhs[1] = mxCreateDoubleMatrix(n1, n2, mxREAL);
    double *W = mxGetPr(plhs[1]);
    for (int i = 0; i < n1 * n2; ++i) {
        W[i] = 0;
    }

    // track back
    int i = n1 - 1, j = n2 - 1;
    p = ptr(i, j, n1);
    int m2 = 2 * m;
    C[--m2] = j + 1; 
    C[--m2] = i + 1;
    while (m2 > 0) {
        if (P[p] == 1) {
            W[p] = 1;
            --j;
            p -= n1;
            
        } else if (P[p] == 2) {
            W[p] = 1;
            --i;
            --p;
        } else if (P[p] == 3) {
            W[p] = 2;
            --i;
            --j;
            p -= n1 + 1;
            
        } else if (P[p] == 4) {
            W[p] = 1;
            --j;
            p -= n1;

            C[--m2] = j + 1;
            C[--m2] = i + 1;

            W[p] = 2;
            --i;
            --j;
            p -= n1 + 1;
            
        } else if (P[p] == 5) {
            W[p] = 1;
            --i;
            --p;

            C[--m2] = j + 1;
            C[--m2] = i + 1;

            W[p] = 2;
            --i;
            --j;
            p -= n1 + 1;
            
        } else {
            printf("unknown path direction\n");
            return;
        }
        
        C[--m2] = j + 1;
        C[--m2] = i + 1;
    }
    W[p] = 2;
}
