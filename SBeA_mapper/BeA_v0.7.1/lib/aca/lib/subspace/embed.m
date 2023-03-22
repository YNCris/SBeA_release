function Y = embed(X, H, dim, varargin)
% Project the feature according to the specific algorithm.
%
% Input
%   X       -  original sample matrix, dim0 x n or distance / similarity matrix, n x n
%   H       -  class indicator matrix, k x n
%   dim     -  dimensions after projection
%   varargin
%     nei   -  neighbour size
%     alg   -  algorithm type, {'pca'} | 'lda' | 'kpca' | 'mds' | 'lle' | 'sc'
%     x     -  sample matrix flag, {'y'} | 'n'
%              'y': X in the input is the sample matrix
%              'n': X in the input is the similarity matrix
%
% Output
%   Y       -  new sample matrix, dim x n
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-25-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

% function option
alg = ps(varargin, 'alg', 'pca');
isX = psY(varargin, 'x', 'y');

if strcmp(alg, 'pca')
    checkInput(isX, true);

    Comp = pca(X);
    Y = Comp(1 : dim, :);

elseif strcmp(alg, 'lda')
    checkInput(isX, true);

    Comp = lda(X, H);
    Y = Comp(1 : dim, :);
    
elseif strcmp(alg, 'qda')
    checkInput(isX, true);

    ind = qda(X, H);
    Comp = X(ind, :);
    Y = Comp(1 : dim, :);    

elseif strcmp(alg, 'kpca')
    checkInput(isX, false);
    
    Y = kpca(X, dim);

elseif strcmp(alg, 'sc')
    checkInput(isX, false);
    
    [Htmp, Y] = sc(X, dim);

elseif strcmp(alg, 'mds')
    checkInput(isX, false);
    
    Y = mds(X, dim, varargin{:});

elseif strcmp(alg, 'lle')
    checkInput(isX, true);
    
    Y = lle(X, dim, varargin{:});

else
    error('unknown feature selection algorithm');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function checkInput(isX, flag)
% Check the sample matrix flag to be the expected boolean flag.
%
% Input
%   isX     -  sample matrix flag
%   flag    -  expected flag

if flag && ~isX
    error('The input must be a sample matrix.');
end

if ~flag && isX
    error('The input must be a similarity matrix.');
end
