function [D, DSq] = conDist(X1, X2, varargin)
% Construct the distance matrix of the given data sets.
%
% Input
%   X1      -  1st sample matrix, dim x n1
%   X2      -  2nd sample matrix, dim x n2
%   varargin
%     dst   -  distance type, 'b' | {'e'}
%              'b': Binary distance
%              'e': Euclidean distance
%
% Output
%   D       -  distance matrix, n1 x n2
%   DSq     -  square of distance matrix, n1 x n2
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-05-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 11-27-2009

% function option
dst = ps(varargin, 'dst', 'e');

n1 = size(X1, 2);
n2 = size(X2, 2);
if size(X1, 1) == 1
    X1 = [X1; zeros(1, n1)]; 
    X2 = [X2; zeros(1, n2)]; 
end

XX1 = sum(X1 .* X1); XX2 = sum(X2 .* X2); X12 = X1' * X2; 
DSq = repmat(XX1', [1 n2]) + repmat(XX2, [n1 1]) - 2 * X12;

% make sure result is all real
D = real(sqrt(DSq));

if strcmp(dst, 'b')
    th = 1e-5;
    D = real(D > th);
    DSq = D .^ 2;
   
elseif ~strcmp(dst, 'e')
    error('unknown distance type');
end
