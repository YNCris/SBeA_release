function [X, G] = genGausses(mes, Vars, n, varargin)
% Generate samples from the specified Gaussian distribution.
%
% Input
%   mes     -  mean, dim x k
%   Vars    -  variance, dim x dim x k
%   n       -  #samples
%   varargin
%     bdN   -  boundary of variance of sample number, {[.8, 1.2]}
%
% Output
%   X       -  sample matrix, dim x n
%   G       -  class indicator matrix, k x n
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 07-20-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-20-2009

% function option
bdN = ps(varargin, 'bdN', [.8 1.2]);

[dim, k] = size(mes);

% sample number
ns = genUnifD(bdN(1) * n, bdN(2) * n, k);

% sample
Xs = cell(1, k);
for c = 1 : k
    Xs{c} = genGauss(mes(:, c), Vars(:, :, c), ns(c));
end
X = cat(2, Xs{:});
G = ns2G(ns);
