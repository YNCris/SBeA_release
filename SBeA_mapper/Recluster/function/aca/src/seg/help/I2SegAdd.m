function seg = I2SegAdd(I)
% Convert the frame-based indicator matrix into segment-based indicator matrix.
%
% Input
%   I       -  indicator matrix of frames, k x n
%
% Output
%   seg
%     H     -  indicator matrix of motions, (k + 1) x m
%     st    -  starting points for each motion, 1 x (m + 1)
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 03-03-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 11-12-2009

[k, n] = size(I);

I2 = zeros(k + 1, n);
vis = sum(I, 1) == 0;

I2(1 : k, :) = I;
I2(k + 1, vis) = 1;
seg = I2Seg(I2);
