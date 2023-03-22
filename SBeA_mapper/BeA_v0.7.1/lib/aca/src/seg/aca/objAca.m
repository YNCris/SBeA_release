function [v, v2] = objAca(K, para, seg)
% Measuring the objective of ACA.
%
% Input
%   K       -  frame similarity matrix, n x n
%   para    -  segmentation parameter
%   seg     -  temporal segmentation
%
% Output
%   v       -  objective of ACA (segment-base)
%   v2      -  objective of ACA (frame-base, should be equal to v)
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-13-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-23-2009

% local constarint
lc = ps(para, 'lc', 0);

% frame weights
wFs = ps(para, 'wFs', []);
if isempty(wFs)
    n = size(K, 1);
    wFs = ones(1, n);
end

% pairwise DTAK
[T, P] = dtaksFord(K, seg, lc, wFs);

% empty cluster
G = seg.G; [k, m] = size(G);
if cluEmp(G)
    v = inf;
    return;
end

% segment-based
v = trace((eye(m) - G' / (G * G') * G) * T);

% frame-based
if nargout > 1
    [Cs, W, WN, WL] = dtaksBack(P, seg);
    v2 = trace(WL * K);
end
