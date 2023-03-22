#include "mex.h"

#define max(a, b)  (((a) > (b)) ? (a) : (b))
#define argmax(a, b)  (((a) > (b)) ? 0 : 1)

/*
 * The most general implementation of DTAK via Dynamic Programming.
 */
double dtakDP(double *K, double *P, double *KC, int n1, int n2, double *wF1s, double *wF2s);

/*
 * Dynamic Programming with local constraint (Sakoe and Chiba).
 */
double dtakDPLc(double *K, double *P, double *KC, int n1, int n2, double *wF1s, double *wF2s);

/*
 * function [v, P, KC] = dtakFord(K, lc, wF1s, wF2s)
 *
 * History
 *   create  -  Feng Zhou, 03-20-2009
 *   modify  -  Feng Zhou, 12-21-2009
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

    // K
    double *K = mxGetPr(prhs[0]);
    int n1 = mxGetM(prhs[0]);
    int n2 = mxGetN(prhs[0]);

    // lc
    int lc = 0;
    if (nrhs < 2) {
    } else {
        lc = int(*mxGetPr(prhs[1]));
    }

    // wF1s, wF2s
    double *wF1s = new double[n1];
    double *wF2s = new double[n2];
    if (nrhs < 3) {
        for (int i = 0; i < n1; ++i) {
            wF1s[i] = 1;
        }
        for (int i = 0; i < n2; ++i) {
            wF2s[i] = 1;
        }
    } else {
        double *wF1sTmp = mxGetPr(prhs[2]);
        for (int i = 0; i < n1; ++i) {
            wF1s[i] = wF1sTmp[i];
        }
        double *wF2sTmp = mxGetPr(prhs[3]);
        for (int i = 0; i < n2; ++i) {
            wF2s[i] = wF2sTmp[i];
        }
    }

    // v
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
    double *v = mxGetPr(plhs[0]);

    // P
    plhs[1] = mxCreateDoubleMatrix(n1, n2, mxREAL);
    double *P = mxGetPr(plhs[1]);

    // KC
    plhs[2] = mxCreateDoubleMatrix(n1, n2, mxREAL);
    double *KC = mxGetPr(plhs[2]);
    
    // dynamic programming
    if (lc == 0) {
        *v = dtakDP(K, P, KC, n1, n2, wF1s, wF2s);
    } else {
        *v = dtakDPLc(K, P, KC, n1, n2, wF1s, wF2s);
    }
    
    // normalized
    double wF1 = 0;
    for (int i = 0; i < n1; ++i) {
        wF1 += wF1s[i];
    }
    double wF2 = 0;
    for (int i = 0; i < n2; ++i) {
        wF2 += wF2s[i];
    }
    *v /= wF1 + wF2;
    
    delete[] wF1s;
    delete[] wF2s;
}

/*
 * Dynamic Programming without local constraint.
 */
double dtakDP(double *K, double *P, double *KC, int n1, int n2, double *wF1s, double *wF2s) {
    int dP[2][2] = {{1, 3}, {2, 3}};
    double kij, tmpKC, wFi, wFj;
    int p, tmpP1, tmpP2;

    for (int i = 0; i < n1; ++i) {
        wFi = wF1s[i];
        for (int j = 0; j < n2; ++j) {
            wFj = wF2s[j];
            p = j * n1 + i;
            kij = K[p];

            if (i == 0 && j == 0) {
                KC[p] = (wFi + wFj) * kij;
                P[p] = 0;
            } else if (i == 0) {
                KC[p] = KC[p - n1] + wFj * kij;
                P[p] = 1;
            } else if (j == 0) {
                KC[p] = KC[p - 1] + wFi * kij;
                P[p] = 2;
            } else {
                tmpKC = max(KC[p - n1] + wFj * kij, KC[p - 1] + wFi * kij);
                tmpP1 = argmax(KC[p - n1] + wFj * kij, KC[p - 1] + wFi * kij);

                KC[p] = max(tmpKC, KC[p - n1 - 1] + (wFi + wFj) * kij);
                tmpP2 = argmax(tmpKC, KC[p - n1 - 1] + (wFi + wFj) * kij);
                P[p] = dP[tmpP1][tmpP2];
            }
        }
    }
    return KC[n1 * n2 - 1];
}

/*
 * Dynamic Programming with local constraint (Sakoe and Chiba).
 */
double dtakDPLc(double *K, double *P, double *KC, int n1, int n2, double *wF1s, double *wF2s) {
    double kij, tmp, wFi, wFj, wFii, wFjj;
    int p;
    for (int i = 0; i < n1; ++i) {
        wFi = wF1s[i];
        for (int j = 0; j < n2; ++j) {
            wFj = wF2s[j];
            p = j * n1 + i;
            kij = K[p];
            KC[p] = -1;
            P[p] = -1;

            if (i == 0 && j == 0) {
                KC[p] = (wFi + wFj) * kij;
                P[p] = 0;
            } else if (i == 0) {
            } else if (j == 0) {
            } else if (i == 1 || j == 1) {
                if (P[p - n1 - 1] >= 0) {
                    KC[p] = KC[p - n1 - 1] + (wFi + wFj) * kij;
                    P[p] = 3;
                }
            } else {
                wFii = wF1s[i - 1];
                wFjj = wF2s[j - 1];
                if (P[p - n1 - 1] >= 0) {
                    KC[p] = KC[p - n1 - 1] + (wFi + wFj) * kij;
                    P[p] = 3;
                }
                
                if (P[p - n1 - n1 - 1] >= 0) {
                    tmp = KC[p - n1 - n1 - 1] + (wFi + wFjj) * K[p - n1] + wFj * kij;
                    if (tmp > KC[p]) {
                        KC[p] = tmp;
                        P[p] = 4;
                    }
                }
                
                if (P[p - n1 - 2] >= 0) {
                    tmp = KC[p - n1 - 2] + (wFii + wFj) * K[p - 1] + wFi * kij;
                    if (tmp > KC[p]) {
                        KC[p] = tmp;
                        P[p] = 5;
                    }
                }
            }
        }
    }
    return KC[n1 * n2 - 1];
}
