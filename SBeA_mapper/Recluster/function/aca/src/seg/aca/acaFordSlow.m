function [sOpt, cOpt, objOpt] = acaFordSlow(K, para, seg, T, lc, wFs)
% Forward step in ACA.
%
% Input
%   K       -  kernel matrix, n x n
%   seg     -  inital segmentation
%   para    -  segmentation parameter
%   T       -  pairwise DTAK, m x m
%   lc      -  local constraint (Sakoe and Chiba)
%              0 : not used
%              1 : used
%   wFs     -  frame weights, 1 x n
%
% Output
%   sOpt    -  optimum starting position, n x 1
%   cOpt    -  optimum label, n x 1
%   objOpt  -  optimum objective, n x 1
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 12-29-2008
%   modify  -  Feng Zhou (zhfe99@gmail.com), 01-13-2010

if lc == 0
    [sOpt, cOpt, objOpt] = acaDP(K, para, seg, T, wFs);
elseif lc == 1
    [sOpt, cOpt, objOpt] = acaDPLc(K, para, seg, T, wFs);
else
    error('unknown local constraint');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sOpt, cOpt, objOpt] = acaDP(K, para, seg, T, wFs)
% Move forward to construct the path matrix without local constraint.
%
% Input
%   K       -  kernel matrix, n x n
%   seg     -  inital segmentation
%   para    -  segmentation parameter
%   T       -  pairwise DTAK, m x m
%   wFs     -  frame weights, 1 x n
%
% Output
%   sOpt    -  optimum starting position, 1 x n
%   cOpt    -  optimum label, 1 x n
%   objOpt  -  optimum objective, 1 x n

nMa = para.nMa;
s = seg.s; G = seg.G;

n = s(end) - 1; [k, m] = size(G);
l = G2L(G);
Q = zeros(nMa, nMa, n);
[sOpt, cOpt, objOpt] = zeross(n, 1);
ws = zeros(1, m);
for i = 1 : m
    ws(i) = sum(wFs(s(i) : s(i + 1) - 1));
end

% 3rd component in the kernel expansion of distance
t3 = diag((G * G') \ (G * T * G') / (G * G'));

for v = 1 : n
    % initial value
    sOpt(v) = 0; cOpt(v) = 0; objOpt(v) = -1;
    vBar = mod(v, nMa) + 1;
    v1Bar = mod(v - 1, nMa) + 1;

    wv = 0; t1a = 0;
    for nv = 1 : min(nMa, v)
        % current head
        i = v - nv + 1;
        wv = wv + wFs(i);
        
        % 1st component in the kernel expansion of distance
        t1a = t1a + wFs(i) * K(i, i);
        t1 = t1a / wv;

        % 2nd component in the kernel expansion of distance
        t2 = zeros(k, 1);
        for j = 1 : m
            for sDot = s(j) : s(j + 1) - 1
                kk = K(v, sDot);

                if nv == 1 && sDot == s(j)
                    Q(nv, vBar, sDot) = (wFs(v) + wFs(sDot)) * kk;
                elseif nv == 1
                    Q(nv, vBar, sDot) = Q(nv, vBar, sDot - 1) + wFs(sDot) * kk;
                elseif sDot == s(j)
                    Q(nv, vBar, sDot) = Q(nv - 1, v1Bar, sDot) + wFs(v) * kk;
                else
                    a = Q(nv - 1, v1Bar, sDot - 1) + (wFs(v) + wFs(sDot)) * kk;
                    b = Q(nv, vBar, sDot - 1) + wFs(sDot) * kk;
                    c = Q(nv - 1, v1Bar, sDot) + wFs(v) * kk;                    
                    Q(nv, vBar, sDot) = max([a, b, c]);
                end
            end

            t2(l(j)) = t2(l(j)) + Q(nv, vBar, s(j + 1) - 1) / (wv + ws(j));
        end
        t2 = (G * G') \ t2 * 2;
        
        % distance
        dists = t1 - t2 + t3;

        [distMi, cMi] = min(dists);

        i = v - nv + 1;
        if i == 1 || sOpt(i - 1) > 0

            if i == 1
                dist = distMi;
            else
                dist = objOpt(i - 1) + distMi;
            end

            if dist < objOpt(v) || objOpt(v) < 0
                sOpt(v) = i;
                cOpt(v) = cMi;
                objOpt(v) = dist;
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sOpt, cOpt, objOpt] = acaDPLc(K, para, seg, T, wFs)
% Move forward to construct the path matrix without local constraint.
%
% Input
%   K       -  kernel matrix, n x n
%   seg     -  inital segmentation
%   para    -  segmentation parameter
%   T       -  pairwise DTAK, m x m
%   wFs     -  frame weights, 1 x n
%
% Output
%   sOpt    -  optimum starting position, 1 x n
%   cOpt    -  optimum label, 1 x n
%   objOpt  -  optimum objective, 1 x n

nMa = para.nMa;
s = seg.s; G = seg.G;

n = s(end) - 1; [k, m] = size(G);
l = G2L(G);
[Q, P] = zeross(nMa, nMa, n);
[sOpt, cOpt, objOpt] = zeross(n, 1);
ws = zeros(1, m);
for i = 1 : m
    ws(i) = sum(wFs(s(i) : s(i + 1) - 1));
end

% 3rd component in the kernel expansion of distance
t3 = diag((G * G') \ (G * T * G') / (G * G'));

for v = 1 : n
    % initial value
    sOpt(v) = 0; cOpt(v) = 0; objOpt(v) = -1;
    vBar = mod(v, nMa) + 1;
    v1Bar = mod(v - 1, nMa) + 1;
    v2Bar = mod(v - 2, nMa) + 1;

    wv = 0; t1a = 0;
    for nv = 1 : min(nMa, v)
        % current head
        i = v - nv + 1;
        wv = wv + wFs(i);
        
        % 1st component in the kernel expansion of distance
        t1a = t1a + wFs(i) * K(i, i);
        t1 = t1a / wv;

        % 2nd component in the kernel expansion of distance
        t2 = zeros(k, 1);
        for j = 1 : m
            for sDot = s(j) : s(j + 1) - 1
                kk = K(v, sDot);
                
                Q(nv, vBar, sDot) = -1;
                P(nv, vBar, sDot) = -1;

                if nv == 1 && sDot == s(j)
                    Q(nv, vBar, sDot) = (wFs(v) + wFs(sDot)) * kk;
                    P(nv, vBar, sDot) = 0;
                    
                elseif nv == 1
                    
                elseif sDot == s(j)
                    
                elseif nv == 2 || sDot == s(j) + 1
                    if P(nv - 1, v1Bar, sDot - 1) >= 0
                        Q(nv, vBar, sDot) = Q(nv - 1, v1Bar, sDot - 1) + (wFs(v) + wFs(sDot)) * kk;
                        P(nv, vBar, sDot) = 3;
                    end

                else
                    if P(nv - 1, v1Bar, sDot - 1) >= 0
                        Q(nv, vBar, sDot) = Q(nv - 1, v1Bar, sDot - 1) + (wFs(v) + wFs(sDot)) * kk;
                        P(nv, vBar, sDot) = 3;
                    end
                    
                    tmp = Q(nv - 1, v1Bar, sDot - 2) + (wFs(v) + wFs(sDot - 1)) * K(v, sDot - 1) + wFs(sDot) * kk;
                    if P(nv - 1, v1Bar, sDot - 2) >= 0 && tmp > Q(nv, vBar, sDot)
                        Q(nv, vBar, sDot) = tmp;
                        P(nv, vBar, sDot) = 4;
                    end

                    tmp = Q(nv - 2, v2Bar, sDot - 1) + (wFs(v - 1) + wFs(sDot)) * K(v - 1, sDot) + wFs(v) * kk;
                    if P(nv - 2, v2Bar, sDot - 1) >= 0 && tmp > Q(nv, vBar, sDot)
                        Q(nv, vBar, sDot) = tmp;
                        P(nv, vBar, sDot) = 5;
                    end
                end
            end
            t2(l(j)) = t2(l(j)) + Q(nv, vBar, s(j + 1) - 1) / (wv + ws(j));
        end
        t2 = (G * G') \ t2 * 2;

        % distance
        dists = t1 - t2 + t3;

        [distMi, cMi] = min(dists);

        i = v - nv + 1;
        if i == 1 || sOpt(i - 1) > 0

            if i == 1
                dist = distMi;
            else
                dist = objOpt(i - 1) + distMi;
            end

            if dist < objOpt(v) || objOpt(v) < 0
                sOpt(v) = i;
                cOpt(v) = cMi;
                objOpt(v) = dist;
            end
        end
    end
end
