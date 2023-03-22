function [I, H] = seg2IH(seg)
% Convert the motion-based indicator matrix into frame-based indicator matrix.
%
% Input
%   seg     -  segmentation
%
% Output
%   I       -  frame-class indicator, k x n
%   H       -  frame-segment indicator, m x n
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-12-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-20-2009

s = seg.s; G = seg.G;
[k, m] = size(G);
n = s(end) - 1;

H = zeros(m, n);
I = zeros(k, n);
for i = 1 : m
    H(i, s(i) : s(i + 1) - 1) = 1;
    I(G(:, i) ~= 0, s(i) : s(i + 1) - 1) = 1;
end
