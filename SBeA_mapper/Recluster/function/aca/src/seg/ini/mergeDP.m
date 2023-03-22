function seg = mergeDP(I, para)
% Obtain the class labels of segments when given lables for frames.
% Used in initialization.
%
% Input
%   I       -  indicator matrix of frames
%   para    -  segmentation parameter
%
% Output
%   seg     -  segmentation result
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 07-28-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-17-2009

nMi = para.nMi;
nMa = para.nMa;

[k, n] = size(I);
[optObj, optSt, optC] = zeross(n, 1);

% forward
for v = 1 : n
    optObj(v) = -1; optSt(v) = 0; optC(v) = 0;

    for wv = 1 : min(nMa, v)
        i = v - wv + 1;

        dists = zeros(k, 1);
        for c = 1 : k
            l = I(c, i : v);
            dists(c) = wv - sum(l);
        end
        [miD, miC] = min(dists);

        if wv >= nMi && (i == 1 || optSt(i - 1) > 0)

            if i == 1
                dist = miD;
            else
                dist = optObj(i - 1) + miD;
            end

            if nMi < optObj(v) || optObj(v) < 0
                optObj(v) = dist;
                optSt(v) = i;
                optC(v) = miC;
            end
        end
    end
end

% backward
seg = acaBack(k, optSt, optC);
