function [s, idxs] = n2s(ns)
% Join the vector of frame length together.
%
% Example
%   ns = [1 3 5 3] -> s = [1 2 5 10 13], idxs = {[1], [2 3 4], [5 6 7 8 9], [10 11 12 13]}
%
% Input
%   ns      -  frame length, 1 x m
%
% Output
%   s       -  starting position of each segment, 1 x (m + 1)
%   idxs    -  index, 1 x m (cell)
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-30-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 01-03-2010

m = length(ns);

s = ones(1, m + 1);
idxs = cell(1, m);
for i = 1 : m
    s(i + 1) = s(i) + ns(i);
    idxs{i} = s(i) : s(i + 1) - 1;
end
