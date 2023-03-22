function vis = idx2vis(idx, n)
% Convert the actual positions to binary indicator.
%
% Input
%   p    -  actual positions, 1 x m
%   n    -  vector length
%
% Output
%   vis  -  binary indicator, 1 x n (binary)
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 02-04-2008
%   modify   -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

vis = zeros(1, n);
vis(idx) = 1;
