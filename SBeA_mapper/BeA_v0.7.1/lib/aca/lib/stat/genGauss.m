function X = genGauss(me, Var, n, varargin)
% Generate samples from the specified Gaussian distribution.
%
% Input
%   me      -  mean, dim x 1
%   Var     -  variance, dim x dim
%   n       -  #samples
%   varargin
%     maMiD  -  flag of maximizing the minimum of pairwise distance, 'y' | {'n'}
%
% Output
%   X       -  sample matrix, dim x n
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-22-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

% function option
isMaMiD = psY(varargin, 'maMiD', 'n');

dim = size(me, 1);
nRep = select(isMaMiD, 200, 1);

Xs = cell(1, nRep);
for iRep = 1 : nRep
    X0 = randn(dim, n);

    % transformation
    [V, D] = eig(Var);
    D2 = sqrt(D);

    Xs{iRep} = V * D2 * X0 + repmat(me, 1, n);
end

if isMaMiD
    X = pickMaMiD(Xs);
else
    X = Xs{1};
end
