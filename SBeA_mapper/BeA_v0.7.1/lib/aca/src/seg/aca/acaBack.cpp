#include "mex.h"
#include "string.h"

/* 
 * function seg = acaBack(k, sOpt, cOpt)
 *
 * History
 *   create  -  Feng Zhou, 08-23-2009
 *   modify  -  Feng Zhou, 08-23-2009
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

    // k
    int k = int(*mxGetPr(prhs[0]));

    // sOpt
    double *sOptD = mxGetPr(prhs[1]);
    int n = mxGetM(prhs[1]);
    int *sOpt = new int[n];
    for (int i = 0; i < n; ++i) {
        sOpt[i] = int(sOptD[i]) - 1;
    }

    // cOpt
    double *cOptD = mxGetPr(prhs[2]);
    int *cOpt = new int[n];
    for (int i = 0; i < n; ++i) {
        cOpt[i] = int(cOptD[i]) - 1;
    }    

    // determine the step number
    int v = n - 1;
    int m = 0;
    while (v >= 0) {
        ++m;
        v = sOpt[v] - 1;
    }

    // s
    mxArray* paras[2];

    paras[0] = mxCreateDoubleMatrix(1, m + 1, mxREAL);
    double *s = mxGetPr(paras[0]);
    
    // G
    paras[1] = mxCreateDoubleMatrix(k, m, mxREAL);
    double *G = mxGetPr(paras[1]);
    memset(G, 0, k * m * sizeof(double));

    // trace back
    v = n - 1;
    while (v >= 0) {
        s[m] = v + 2;
        G[k * (m - 1) + cOpt[v]] = 1;

        --m;
        v = sOpt[v] - 1;
    }
    s[m] = 1;

    // seg
    mexCallMATLAB(1, plhs, 0, NULL, "newSeg");
    mxSetField(plhs[0], 0, "s", paras[0]);
    mxSetField(plhs[0], 0, "G", paras[1]);

    delete[] sOpt;
    delete[] cOpt;
}
