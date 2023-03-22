function Dim = cellDim(A, c)
% Obtain the dimension of matrix in each cell.
% For each cell, Dim(i, j) = size(A{i, j}, c).
%
% Input
%   A       -  set of matrices, m x n (cell)
%   c       -  specific dimension
%
% Output
%   Dim     -  dimensionality for each matrix, m x n
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 12-29-2008
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

[m, n] = size(A);
Dim = zeros(m, n);

for i = 1 : m
    for j = 1 : n
        Dim(i, j) = size(A{i, j}, c);
    end
end
