function X = sPick(X0, s)
% Pick out the needed part of the sample matrix.
%
% Input
%   X0      -  sample matrix, dim x n0
%   s       -  starting position, 1 x (m + 1)
%
% Output
%   X       -  reduced matrix, dim x n
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-04-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-23-2009

ndim = length(size(X0));

if ndim == 2
    X = X0(:, s(1 : end - 1));
    
elseif ndim == 3
    X = X0(s(1 : end - 1), :, :);
    
else
    error('unsupported');
end
