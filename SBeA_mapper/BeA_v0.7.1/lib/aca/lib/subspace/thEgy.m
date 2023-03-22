function m = thEgy(egy, t)
% Threshold the energy by keep the part of original vector, such that
%   sum(egy(1 : m)) / sum(egy) >= t
%
% Input
%   egy     -  energy vector (descendly sorted, positive), 1 x n or n x 1
%   t       -  threshold
%
% Output
%   m       -  retained dimension
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-12-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

egy = egy / sum(egy);
egyCum = cumsum(egy);
m = find(egyCum >= t, 1);
