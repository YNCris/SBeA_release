#include "mex.h"

/*
 * function G = L2G(l, k)
 *
 * Input
 *   l       -  class label vector, 1 x n
 *   k       -  #class, use the max(l) if not indicated
 *
 * Output
 *   G       -  class indicator matrix, k x n
 *
 * History
 *   create  -  Feng Zhou, 01-04-2009
 *   modify  -  Feng Zhou, 12-20-2009
 */
void mexFunction(int nlhs, mxArray *plhs[ ], int nrhs, const mxArray *prhs[ ]) {

    // l
    double *l = mxGetPr(prhs[0]);
    int m = mxGetM(prhs[0]);
    int n = mxGetN(prhs[0]);
    n = m > n ? m : n;
    
    // k
    int k = int(*mxGetPr(prhs[1]));
    
    // G
    plhs[0] = mxCreateDoubleMatrix(k, n, mxREAL);
    double *G = mxGetPr(plhs[0]);

    for (int i = 0; i < n; ++i) {
        int p = i * k;
        
        for (int c = 0; c < k; ++c) {
            G[p++] = 0;
        }
        
        p = int(l[i]);
        if (p > 0) {
            G[i * k + p - 1] = 1;
        }
    }
}
