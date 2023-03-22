#include "mex.h"

#define ptr(i, j) ((j) * n + i)
#define max(a, b)  (((a) > (b)) ? (a) : (b))
#define min(a, b)  (((a) < (b)) ? (a) : (b))

/* 
 * function S = conPropSim(S0, maW)
 *
 * History
 *   create  -  Feng Zhou, 07-29-2009
 *   modify  -  Feng Zhou, 07-29-2009
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

    // S0
    double *S0 = mxGetPr(prhs[0]);
    int n = mxGetM(prhs[0]);

    // maW
    double *maWD = mxGetPr(prhs[1]);
    int maW = int(*maWD);

    // S
    plhs[0] = mxCreateDoubleMatrix(n, n, mxREAL);
    double *S = mxGetPr(plhs[0]);

    double tmp;
    int ii, jj;
    for (int i1 = 0; i1 < n; ++i1) {
        for (int j1 = i1 + 1; j1 < n; ++j1) {
            for (int w = 1; w <= maW; ++w) {
                int i2 = i1 + w;
                int j2 = j1 + w;

                if (i2 < n && j2 < n) {
                    tmp = min(S0[ptr(i1, j1)], S0[ptr(i2, j2)]);

                    ii = i1; jj = j1;
                    S[ptr(ii, jj)] = max(S[ptr(ii, jj)], tmp);
                    ii = i2; jj = j2;
                    S[ptr(ii, jj)] = max(S[ptr(ii, jj)], tmp);
                    ii = i1; jj = j2;
                    S[ptr(ii, jj)] = max(S[ptr(ii, jj)], tmp);
                    ii = i2; jj = j1;
                    S[ptr(ii, jj)] = max(S[ptr(ii, jj)], tmp);
                }
            }
        }
    }

    for (int i1 = 0; i1 < n; ++i1) {
        S[ptr(i1, i1)] = 1;
        for (int j1 = i1 + 1; j1 < n; ++j1) {
            S[ptr(j1, i1)] = S[ptr(i1, j1)];
        }
    }
}
