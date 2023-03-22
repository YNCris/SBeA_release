function [T, P, KC, ws] = dtaksFord(K, seg, lc, wFs)
% (Generalized) Dynamic Time Alignment Kernel with segmentation.
%
% Input
%   K       -  kernel matrix, n x n
%   seg     -  segmentation
%   lc      -  local constraint (Sakoe and Chiba)
%              0 : not used
%              1 : used
%   wFs     -  frame weight, 1 x n
%              []: weight as 1
%
% Output
%   T       -  segment kernel matrix, m x m
%   P       -  path matrix, n x n
%   KC      -  cumulative kernel matrix, n x n
%   ws      -  segment weight, 1 x m
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 12-29-2008
%   modify  -  Feng Zhou (zhfe99@gmail.com), 01-13-2010

n = size(K, 1);

% local constraint
if nargin < 3
    lc = 0;
end

% frame weight
if nargin < 4
    wFs = ones(1, n);
end

s = seg.s;
m = length(s) - 1;
ws = zeros(1, m);
for i = 1 : m
    ws(i) = sum(wFs(s(i) : s(i + 1) - 1));
end

% dtak for each pair of segment
T = zeros(m, m);
[P, KC] = zeross(n, n);
for i = 1 : m
    ii = s(i) : s(i + 1) - 1;
    for j = i : m
        jj = s(j) : s(j + 1) - 1;

        [T(i, j), P(ii, jj), KC(ii, jj)] = dtakFord(K(ii, jj), lc, wFs(ii), wFs(jj));
    end
end
T = T + triu(T, 1)';
