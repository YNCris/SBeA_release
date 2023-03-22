function a = matFetch(A, ind, dim)
% Fetch part of a matrix.
%
% Input
%   A       -  input matrix, m x n
%   ind     -  index, 1 x n (or 1 x m)
%   dim     -  dimensions, {1} | 2
%
% Output
%   a       -  part vector, 1 x n (or 1 x m)
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-09-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

if ~exist('dim', 'var')
    dim = 1;
end

[m, n] = size(A);

if dim == 1
    a = zeros(1, n);
    for i = 1 : n
        a(i) = A(ind(i), i);
    end

elseif dim == 2
    a = zeros(1, m);
    for i = 1 : m
        a(i) = A(i, ind(i));
    end
else
    error('unknown dimensions');    
end
