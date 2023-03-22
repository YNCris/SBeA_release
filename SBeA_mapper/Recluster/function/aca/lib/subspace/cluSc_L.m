function H = cluSc_L(S, k)
% Spectral Clustering, output cluster labels.
%
% Input
%   S       -  similarity matrix, n x n
%   k       -  cluster number
%
% Output
%   H       -  indicator matrix, k x n
%   Y       -  sample matrix after embedding, k x n
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-22-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 11-05-2009

De = diag(sum(S, 2));
De2 = sqrt(De);
L = De2 \ S / De2;

X = eigk(L, k);
Y = X';

% normalize rows of X
tmp = sqrt(sum(X .^ 2, 2));
for i = 1 : length(tmp)
    if abs(tmp(i)) < eps
        tmp(i) = 1;
    end
end
X = diag(tmp) \ X;

% k-means
H = G2L_Slow(kmean(X', k))';
