function X = genUnif(mi, ma, n, varargin)
% Generate samples from the specified uniform distribution.
%
% Input
%   mi       -  minimum of each dimension, dim x 1
%   ma       -  maximum of each dimension, dim x 1
%   n        -  #samples
%   varargin
%     maMiD  -  flag of maximizing the minimum of pairwise distance, 'y' | {'n'}
%
% Output
%   X        -  dim x n
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 07-17-2009
%   modify   -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

% function option
isMaMiD = psY(varargin, 'maMiD', 'n');

dim = size(mi, 1);
nRep = select(isMaMiD, 200, 1);

Xs = cell(1, nRep);
for iRep = 1 : nRep
    Xs{iRep} = rand(dim, n) .* repmat(ma - mi, 1, n) + repmat(mi, 1, n);
end

if isMaMiD
    X = pickMaMiD(Xs);
else
    X = Xs{1};
end
