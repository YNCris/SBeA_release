function [Comp, Lamb, Dire, me] = pca_zhou(X)
% Principal Componant Analysis (PCA).
%
% Input
%   X       -  sample matrix, dim x n
%
% Output
%   Comp    -  principal components, dim x n
%   Lamb    -  sorted lambda (eigenvalue), dim x 1
%   Dire    -  principal directions, dim x dim
%   me      -  mean vector of X, dim x 1
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 12-30-2008
%   modify  -  Feng Zhou (zhfe99@gmail.com), 11-01-2009

[dim, n] = size(X);

% subtract the mean
me = sum(X, 2) / n;
X = X - repmat(me, 1, n);

% spectral decomposition
[U, S] = svd(X, 0);
[Lamb, index] = sort(sum(S, 2), 'descend');
Dire = U(:, index);

Comp = Dire' * X;
