function X = genUnifD(mi, ma, n, varargin)
% Generate samples from the specified uniform distribution.
% Notice that the distribution is discrete, i.e.,
%   each sample is an integer between minimum and maximum interger.
%
% Input
%   mi       -  minimum of each dimension, dim x 1
%   ma       -  maximum of each dimension, dim x 1
%   n        -  #samples
%
% Output
%   X        -  dim x n
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 07-19-2009
%   modify   -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

X = genUnif(mi, ma, n);
X = round(X);
