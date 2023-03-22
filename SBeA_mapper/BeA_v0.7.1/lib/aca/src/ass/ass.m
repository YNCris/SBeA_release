function [P, acc] = ass(C, varargin)
% Obtain the optimal assignment for the confusion matrix.
%
% Objective
%   acc = max trace(C * P') subject to P is a permutation matrix
%   so that, acc = trace(C * P').
%
% Notice
%   C has been nomalized, sum(sum(C)) == 1
%
% Example
%   An example for Bipartite Matching which can be solved by the Hungarain algorithm (parameter alg = 'hug')
%              assume C = [1 0 3; ...     then P = [0 0 1; ...
%                          2 0 0; ...               1 0 0; ...
%                          0 1 0];                  0 1 0];
%
%   An example for Non-symmetric Matching which can be solved by the Greedy algorithm (parameter alg = 'non')
%              assume C = [1 0 3 0; ...   then P = [0 0 1 0; ...
%                          2 1 0 0; ...             1 1 0 0; ...
%                          0 0 0 2];                0 0 0 1];
%
% Input
%   C       -  confusion matrix, k1 x k2
%   varargin
%     alg   -  assignment algorithm, {'hug'} | 'non'
%              'hug': Hungarian algorithm. If C is non-symmetric, then dummy rows will be inserted
%              'non': greedy function for non-symmetric C (k1 ~= k2)
%
% Output
%   P       -  permutation matrix, k1 x k2
%   acc     -  accuracy
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-25-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 11-03-2009

% function option
alg = ps(varargin, 'alg', 'hug');

[k1, k2] = size(C);
P = zeros(k1, k2);

% normalize C
C = C / fill0(sum(sum(C)));

if strcmp(alg, 'hug')
    % convert to minmum-cost assignment problem
    ma = max(max(C));
    C2 = ones(size(C)) * ma - C;

    % apply Hungarian algorithm
    idx = assignmentoptimal(C2);

    % permuation matrix
    ind = sub2ind([k1, k2], 1 : k1, idx');
    P(ind) = 1;

elseif strcmp(alg, 'non')
    for i = 1 : k2
        [tmp, idx] = max(C(:, i));
        P(idx(1), i) = 1;
    end    
else

    error('unknown algorithm');
end

acc = trace(C * P');
