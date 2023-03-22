function seg = I2Seg(I)
% Convert the frame-class indicator matrix into segment-class indicator matrix.
%
% Input
%   I       -  frame-class indicator matrix, k x n
%
% Output
%   seg     -  temporal segmentation
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-12-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-23-2009

[k, n] = size(I);
maxM = n;

if k == 1
    k = 2;
    I = [I; 1 - I];
end

G = zeros(k, maxM);
s = ones(1, maxM + 1);

m = 0;
for i = 1 : n
    c = find(I(:, i), 1);
    if m == 0 || c ~= c0
        m = m + 1;
        G(c, m) = 1;
        s(m) = i;
        c0 = c;
    end
end
s(m + 1) = n + 1;
s(m + 2 : end) = [];
G(:, m + 1 : end) = [];

seg = newSeg('s', s, 'G', G);
