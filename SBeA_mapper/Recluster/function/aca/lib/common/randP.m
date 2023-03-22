function idxs = randP(ps, n)
% Randomly sampling integers from 1 : m with the given probability.
%
% Input
%   ps      -  probability, 1 x m
%   n       -  number of sampling times
%
% Output
%   idxs    -  integer, 1 x n
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 12-04-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-04-2009

m = length(ps);
pcs = cumsum(ps);

qs = rand(1, n);
idxs = zeros(1, n);
for i = 1 : n
    idx = find(pcs >= qs(i), 1);
    idxs(i) = idx;
end
