#include "mex.h"

#define ptr(i1, i2, i3) (((i3) * nMa + i2) * nMa + i1 - 1)
#define max(a, b)  (((a) > (b)) ? (a) : (b))
#define min(a, b)  (((a) < (b)) ? (a) : (b))

/*
 * Dynamic Programming without local constraint.
 */
void acaDP(double *sOpt, double *cOpt, double *objOpt, double *K, int *s, double *G, double *T, double *wFs, int n, int nMa, int m, int k);

/*
 * Dynamic Programming with local constraint.
 */
void acaDPLc(double *sOpt, double *cOpt, double *objOpt, double *K, int *s, double *G, double *T, double *wFs, int n, int nMa, int m, int k);

/*
 * function [sOpt, cOpt, objOpt] = acaFord(K, para, seg, T, lc, wFs)
 *
 * History
 *   create  -  Feng Zhou, 07-27-2009
 *   modify  -  Feng Zhou, 12-22-2009
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

    // K
    double *K = mxGetPr(prhs[0]);
    int n = mxGetM(prhs[0]);
    
    // para.nMa
    mxArray *nMaArr = mxGetField(prhs[1], 0, "nMa");
    int nMa = int(*mxGetPr(nMaArr));

    // seg (s, G)
    mxArray *sArr = mxGetField(prhs[2], 0, "s");
    mxArray *GArr = mxGetField(prhs[2], 0, "G");
    int k = mxGetM(GArr);
    int m = mxGetN(GArr);
    double *sD = mxGetPr(sArr);
    double *G = mxGetPr(GArr);
    int *s = new int[m + 1];
    for (int i = 0; i <= m; ++i) {
        s[i] = int(sD[i]) - 1;
    }

    // T
    double *T = mxGetPr(prhs[3]);

    // lc
    int lc = int(*mxGetPr(prhs[4]));

    // wFs
    double* wFs = mxGetPr(prhs[5]);

    // sOpt, cOpt, objOpt
    plhs[0] = mxCreateDoubleMatrix(n, 1, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(n, 1, mxREAL);
    plhs[2] = mxCreateDoubleMatrix(n, 1, mxREAL);
    double *sOpt = mxGetPr(plhs[0]);
    double *cOpt = mxGetPr(plhs[1]);
    double *objOpt = mxGetPr(plhs[2]);

    // dynamic programming
    if (lc == 0) {
        acaDP(sOpt, cOpt, objOpt, K, s, G, T, wFs, n, nMa, m, k);
    } else {
        acaDPLc(sOpt, cOpt, objOpt, K, s, G, T, wFs, n, nMa, m, k);
    }

    delete[] s;
}

/*
 * Dynamic Programming without local constraint.
 */
void acaDP(double *sOpt, double *cOpt, double *objOpt, double *K, int *s, double *G, double *T, double *wFs, int n, int nMa, int m, int k) {

    // label of segment
    int *l = new int[m];

    // weight of segment
    double *ws = new double[m];

    // #segments of each class
    int *ms = new int[k];

    for (int c = 0; c < k; ++c) {
        ms[c] = 0;
    }
    for (int i = 0; i < m; ++i) {
        ws[i] = 0;
        for (int j = s[i]; j < s[i + 1]; ++j) {
            ws[i] += wFs[j];
        }

        for (int c = 0; c < k; ++c) {
            if (G[i * k + c] == 1) {
                l[i] = c;
                ms[c]++;
                break;
            }
        }
    }

    // 3rd component in the kernel expansion of distance
    double *t3 = new double[k];
    for (int c = 0; c < k; ++c) {
        t3[c] = 0;
    }
    for (int i = 0; i < m; ++i) {
        for (int j = 0; j < m; ++j) {
            if (l[i] == l[j]) {
                t3[l[i]] += T[i * m + j];
            }
        }
    }
    for (int c = 0; c < k; ++c) {
        t3[c] /= ms[c] * ms[c];
    }

    double *Q = new double[nMa * nMa * n];
    double* t2 = new double[k];
    double* dists = new double[k];   
    for (int v = 0; v < n; ++v) {
        // initial value
        sOpt[v] = -1; cOpt[v] = -1; objOpt[v] = -1;

        int vBar = v % nMa;
        int v1Bar = (v + nMa - 1) % nMa;
        double wv = 0;
        double t1a = 0;
        for (int nv = 1; nv <= min(v + 1, nMa); ++nv) {
            // current head
            int i = v - nv + 1;
            wv += wFs[i];
            
            // 1st component in the kernel expansion of distance
            t1a += wFs[i] * K[i * n + i];
            double t1 = t1a / wv;

            // 2nd component in the kernel expansion of distance
            for (int c = 0; c < k; ++c) {
                t2[c] = 0;
            }
            for (int j = 0; j < m; ++j) {
                for (int sDot = s[j]; sDot < s[j + 1]; ++sDot) {
                    double kk = K[v * n + sDot];

                    int pp = ptr(nv, vBar, sDot);
                    if (nv == 1 && sDot == s[j]) {
                        Q[pp] = (wFs[v] + wFs[sDot]) * kk;
                    } else if (nv == 1) {
                        Q[pp] = Q[ptr(nv, vBar, sDot - 1)] + wFs[sDot] * kk;
                    } else if (sDot == s[j]) {
                        Q[pp] = Q[ptr(nv - 1, v1Bar, sDot)] + wFs[v] * kk;
                    } else {
                        double a = Q[ptr(nv - 1, v1Bar, sDot - 1)] + (wFs[v] + wFs[sDot]) * kk;
                        double b = Q[ptr(nv, vBar, sDot - 1)] + wFs[sDot] * kk;
                        double c = Q[ptr(nv - 1, v1Bar, sDot)] + wFs[v] * kk;

                        double tmp = max(a, b);
                        Q[pp] = max(tmp, c);
                    }
                }

                t2[l[j]] += Q[ptr(nv, vBar, s[j + 1] - 1)] / (wv + ws[j]);
            }

            // distance
            double dMi;
            int cMi;
            for (int c = 0; c < k; ++c) {
                t2[c] = t2[c] * 2 / ms[c];
                dists[c] = t1 - t2[c] + t3[c];

                if (c == 0) {
                    dMi = dists[c];
                    cMi = 0;
                } else {
                    if (dists[c] < dMi) {
                        dMi = dists[c];
                        cMi = c;
                    }
                }
            }

            if (i == 0 || sOpt[i - 1] >= 0) {
                double dist;
                if (i == 0) {
                    dist = dMi;
                } else {
                    dist = objOpt[i - 1] + dMi;
                }

                if (dist < objOpt[v] || objOpt[v] < 0) {
                    sOpt[v] = i;
                    cOpt[v] = cMi;
                    objOpt[v] = dist;
                }
            }
        }
    }

    for (int i = 0; i < n; ++i) {
        ++sOpt[i];
        ++cOpt[i];
    }

    delete[] l;
    delete[] ws;
    delete[] ms;
    delete[] t3;
    delete[] Q;
    delete[] t2;
    delete[] dists;
}

/*
 * Dynamic Programming with local constraint.
 */
void acaDPLc(double *sOpt, double *cOpt, double *objOpt, double *K, int *s, double *G, double *T, double *wFs, int n, int nMa, int m, int k) {
    // label of segment
    int *l = new int[m];

    // weight of segment
    double *ws = new double[m];
    
    // #segments of each class
    int *ms = new int[k];

    for (int c = 0; c < k; ++c) {
        ms[c] = 0;
    }
    for (int i = 0; i < m; ++i) {
        ws[i] = 0;
        for (int j = s[i]; j < s[i + 1]; ++j) {
            ws[i] += wFs[j];
        }

        for (int c = 0; c < k; ++c) {
            if (G[i * k + c] == 1) {
                l[i] = c;
                ms[c]++;
                break;
            }
        }
    }

    // 3rd component in the kernel expansion of distance
    double *t3 = new double[k];
    for (int c = 0; c < k; ++c) {
        t3[c] = 0;
    }
    for (int i = 0; i < m; ++i) {
        for (int j = 0; j < m; ++j) {
            if (l[i] == l[j]) {
                t3[l[i]] += T[i * m + j];
            }
        }
    }
    for (int c = 0; c < k; ++c) {
        t3[c] /= ms[c] * ms[c];
    }

    double *Q = new double[nMa * nMa * n];
    int *P = new int[nMa * nMa * n];
    double* t2 = new double[k];
    double* dists = new double[k];
    for (int v = 0; v < n; ++v) {
        // initial value
        sOpt[v] = -1; cOpt[v] = -1; objOpt[v] = -1;

        int vBar = v % nMa;
        int v1Bar = (v + nMa - 1) % nMa;
        int v2Bar = (v + nMa - 2) % nMa;
        double wv = 0;
        double t1a = 0;
        for (int nv = 1; nv <= min(v + 1, nMa); ++nv) {
            // current head
            int i = v - nv + 1;
            wv += wFs[i];
            
            // 1st component in the kernel expansion of distance
            t1a += wFs[i] * K[i * n + i];
            double t1 = t1a / wv;

            // 2nd component in the kernel expansion of distance
            for (int c = 0; c < k; ++c) {
                t2[c] = 0;
            }
            for (int j = 0; j < m; ++j) {
                for (int sDot = s[j]; sDot < s[j + 1]; ++sDot) {
                    double kk = K[v * n + sDot];
                   
                    int pp = ptr(nv, vBar, sDot);
                    Q[pp] = -1;
                    P[pp] = -1;
                    if (nv == 1 && sDot == s[j]) {
                        Q[pp] = (wFs[v] + wFs[sDot]) * kk;
                        P[pp] = 0;
                    } else if (nv == 1) {
                        
                    } else if (sDot == s[j]) {
                        
                    } else if (nv == 2 || sDot == s[j] + 1) {
                        if (P[ptr(nv - 1, v1Bar, sDot - 1)] >= 0) {
                            Q[pp] = Q[ptr(nv - 1, v1Bar, sDot - 1)] + (wFs[v] + wFs[sDot]) * kk;
                            P[pp] = 3;
                        }

                    } else {
                        if (P[ptr(nv - 1, v1Bar, sDot - 1)] >= 0) {
                            Q[pp] = Q[ptr(nv - 1, v1Bar, sDot - 1)] + (wFs[v] + wFs[sDot]) * kk;
                            P[pp] = 3;
                        }
                        
                        double tmp = Q[ptr(nv - 1, v1Bar, sDot - 2)] + (wFs[v] + wFs[sDot - 1]) * K[v * n + sDot - 1] + wFs[sDot] * kk;
                        if (P[ptr(nv - 1, v1Bar, sDot - 2)] >= 0 && tmp > Q[pp]) {
                            Q[pp] = tmp;
                            P[pp] = 4;
                        }

                        tmp = Q[ptr(nv - 2, v2Bar, sDot - 1)] + (wFs[v - 1] + wFs[sDot]) * K[(v - 1) * n + sDot] + wFs[v] * kk;
                        if (P[ptr(nv - 2, v2Bar, sDot - 1)] >= 0 && tmp > Q[pp]) {
                            Q[pp] = tmp;
                            P[pp] = 5;
                        }
                    }
                }

                t2[l[j]] += Q[ptr(nv, vBar, s[j + 1] - 1)] / (wv + ws[j]);
            }

            // distance
            double dMi;
            int cMi;
            for (int c = 0; c < k; ++c) {
                t2[c] = t2[c] * 2 / ms[c];
                dists[c] = t1 - t2[c] + t3[c];

                if (c == 0) {
                    dMi = dists[c];
                    cMi = 0;
                } else {
                    if (dists[c] < dMi) {
                        dMi = dists[c];
                        cMi = c;
                    }
                }
            }

            if (i == 0 || sOpt[i - 1] >= 0) {
                double dist;
                if (i == 0) {
                    dist = dMi;
                } else {
                    dist = objOpt[i - 1] + dMi;
                }

                if (dist < objOpt[v] || objOpt[v] < 0) {
                    sOpt[v] = i;
                    cOpt[v] = cMi;
                    objOpt[v] = dist;
                }
            }
        }
    }
 
    for (int i = 0; i < n; ++i) {
        ++sOpt[i];
        ++cOpt[i];
    }

    delete[] l;
    delete[] ws;
    delete[] ms;
    delete[] t3;
    delete[] Q;
    delete[] P;
    delete[] t2;
    delete[] dists;
}
