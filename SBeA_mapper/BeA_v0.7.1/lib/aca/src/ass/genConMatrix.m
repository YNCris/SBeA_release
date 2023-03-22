function [C, Cm1, Cm2] = genConMatrix(seg1, seg2)
% Generate the confusion matrix of two segmentations in a fast way.
% The confusion is defined by the length of frames that are overlapped by the same group of segments.
%
% Input
%   seg1    -  the first segmentation
%     s     -  starting position, 1 x (m1 + 1)
%     G     -  indicator matrix, k1 x m1
%   seg2    -  the second segmentation
%     s     -  starting position, 1 x (m2 + 1)
%     G     -  indicator matrix, k2 x m2
%
% Output
%   C       -  the confusion matrix (class by class), k1 x k2
%   Cm1     -  the confusion matrix (1st class by 2nd segment), k1 x m2
%   Cm2     -  the confusion matrix (2nd class by 1st segment), k2 x m1
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-18-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-22-2009

s1 = seg1.s; G1 = seg1.G; [k1, m1] = size(G1);
s2 = seg2.s; G2 = seg2.G; [k2, m2] = size(G2);

% compute the overlap of each pair of segments
C = zeros(k1, k2); Cm1 = zeros(k1, m2); Cm2 = zeros(k2, m1);
for i = 1 : m1
    for j = 1 : m2
        a = max(s1(i), s2(j));
        b = min(s1(i + 1), s2(j + 1));
        
        if a < b
            c1 = find(G1(:, i));
            c2 = find(G2(:, j));
            C(c1, c2) = C(c1, c2) + b - a;
            Cm1(c1, j) = Cm1(c1, j) + b - a;
            Cm2(c2, i) = Cm2(c2, i) + b - a;
        end
    end
end

% normalize
ms = diff(s2);
Cm1 = Cm1 ./ fill0(repmat(ms, k1, 1));

ms = diff(s1);
Cm2 = Cm2 ./ fill0(repmat(ms, k2, 1));
