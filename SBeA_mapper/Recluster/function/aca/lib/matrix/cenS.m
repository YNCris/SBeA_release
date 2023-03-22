function S = cenS(S0)
% Centralize kernel matrix.
%
% Input
%   S0      -  original similarity matrix, n x n
%
% Output
%   S       -  new similarity matrix, n x n
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-26-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

n = size(S0, 1);

P = eye(n) - ones(n, n) / n;
S = P * S0 * P;
