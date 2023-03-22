function [Cs, W, WN, WL, WS, WL2] = dtaksBack(P, seg)
% Correspondence matrix for Dynamic Time Alignment Kernel.
%
% Input
%   P       -  path matrix, n x n
%   seg     -  temporal segmentation
%
% Output
%   Cs      -  frame correspondance matrix, m x m (cell)
%   W       -  warping matrix, n x n
%   WN      -  normalized warping matrix, n x n
%   WL      -  Laplacian warping matrix, n x n
%   WS      -  warping matrix with only the value for segments of the same class, n x n
%   WL2     -  Laplacian warping matrix, n x n
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 12-29-2008
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-22-2009

n = size(P, 1);
s = seg.s; G = seg.G;
m = length(s) - 1;
lens = diff(s);

[W, WN] = zeross(n, n);
Cs = cell(m, m);
for i = 1 : m
    for j = i : m
        leni = lens(i);
        lenj = lens(j);
        idxi = s(i) : s(i + 1) - 1;
        idxj = s(j) : s(j + 1) - 1;

        % corrspondence
        [Cij, Wij] = dtakBack(P(idxi, idxj));
        Cs{i, j} = Cij;
        Cs{j, i} = Cij([2, 1], :);

        % store
        WNij = Wij / (leni + lenj);
        W(idxi, idxj) = Wij; 
        WN(idxi, idxj) = WNij;
    end
end
W = triu(W, 0) + triu(W, 1)';
WN = triu(WN, 0) + triu(WN, 1)';

if nargout > 3
    [I, H] = seg2IH(seg);
    WL = (eye(n) - H' * G' / (G * G') * G * H) .* WN;
    WS = ((G * H)' * G * H) .* W;
    WL2 = (H' * G' / (G * G') * G * H) .* WN;
end
