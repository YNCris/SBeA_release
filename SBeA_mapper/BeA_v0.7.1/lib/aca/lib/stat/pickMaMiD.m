function [X, i, ds, miDs] = pickMaMiD(Xs)
% Pick the sample sets to maxmize the minmum pairwise distance.
%
% Input
%   Xs      -  sample set, 1 x m (cell), dim x n
%
% Output
%   X       -  dim x n
%   i       -  index of ouptput
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 07-17-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

m = length(Xs);
n = size(Xs{1}, 2);

ds = zeros(1, m);
miDs = zeros(m, n);
for i = 1 : m
    X = Xs{i};

    D = conDist(X, X);
    D = D + diag(ones(1, n) * inf);
    miD = min(D); miDs(i, :) = miD;
    ds(i) = min(miD);
end

[tmp, i] = max(ds);
X = Xs{i};
