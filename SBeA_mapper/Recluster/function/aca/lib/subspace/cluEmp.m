function flag = cluEmp(G)
% Test whether any cluster has entries or not.
%
% Input
%   G       -  indicator matrix, k x n
%
% Output
%   flag    -  empty flag
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-13-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-20-2009

flag = ~isempty(find(sum(G, 2) == 0, 1));
