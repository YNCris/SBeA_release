#include "mex.h"

/*
 * function l = G2L(H)
 *
 * Input
 *   G       -  class indicator matrix, k x n
 *
 * Output
 *   l       -  class label vector, 1 x n
 *
 * History
 *   create  -  Feng Zhou, 01-04-2009
 *   modify  -  Feng Zhou, 12-20-2009
 */
void mexFunction(int nlhs, mxArray *plhs[ ], int nrhs, const mxArray *prhs[ ]) {

    // G
    double *G = mxGetPr(prhs[0]);
    int k = mxGetM(prhs[0]);
    int n = mxGetN(prhs[0]);
    
    // l
    plhs[0] = mxCreateDoubleMatrix(1, n, mxREAL);
    double *l = mxGetPr(plhs[0]);

    for (int i = 0; i < n; ++i) {
        int p = i * k;
        l[i] = 0;
        for (int c = 0; c < k; ++c) {
            if (G[p++] > 0) {
                l[i] = c + 1;
                break;
            }
        }
    }
}
