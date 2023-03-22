function A = fill0(A0, val)
% Fill all the elements of the given matrix with the specific value.
%
% Input
%   A0      -  original matrix, dim1 x dim2 x ...
%   val     -  replaced value. If not indicated, use 1 instead
%
% Output
%   A       -  new matrix, k0 x k
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-04-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

if ~exist('val', 'var')
    val = 1;
end

vis = abs(A0) < eps;
A = A0;
A(vis) = val;
