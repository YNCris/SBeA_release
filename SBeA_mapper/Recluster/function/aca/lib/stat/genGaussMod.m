function [mes, Vars] = genGaussMod(k, varargin)
% Generate samples from mixture of Gaussian distribution.
%
% Input
%   k       -  #classes
%   varargin
%     dis   -  distribution, {'unif'} | 'gauss'
%
%     %% uniform distribution %%
%     meMi  -  minimum of mean, dim x 1, {[0; 0]}
%     meMa  -  maximum of mean, dim x 1, {[10; 10]}
%     rBd   -  bound of radius, 1 x 2, {[.05, .15]}
%
%     %% gaussian distribution %%
%     me0   -  mean, dim x 1, {[5; 5]}
%     r0    -  radius, {1}
%     rBd   -  bound of radius, 1 x 2, {[.05, .15]}
%
%     maMiD -  flag of maximizing the minimum of pairwise distance, 'y' | {'n'}
%
% Output
%   mes     -  mean of Gaussian, dim x k
%   Vars    -  variance of Gaussian, dim x dim x k
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 07-19-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-20-2009

% function option
dis = ps(varargin, 'dis', 'unif');
maMiD = ps(varargin, 'maMiD', 'n');

if strcmp(dis, 'unif')
    % hyper-parameter
    meMi = ps(varargin, 'meMi', [  0;   0]);
    meMa = ps(varargin, 'meMa', [ 10;  10]);
    rBd = ps(varargin, 'rBd', [.05, .13]);
    rMi = (meMa - meMi) * rBd(1);
    rMa = (meMa - meMi) * rBd(2);

    % parameter
    mes = genUnif(meMi, meMa, k, 'maMiD', maMiD);
    rs = genUnif(rMi, rMa, k);
    as = pi * 2 * rand(1, k);

elseif strcmp(dis, 'gauss')
    % hyper-parameter
    me0 = ps(varargin, 'me0', [0; 0]);
    r0 = ps(varargin, 'r0', 1);
    var0 = [r0, 0; 0, r0];
    rBd = ps(varargin, 'rBd', [.2, .5] * .8);
    rMi = [r0; r0] * rBd(1);
    rMa = [r0; r0] * rBd(2);

    % parameter
    mes = genGauss(me0, var0, k, 'maMiD', maMiD);
    rs = genUnif(rMi, rMa, k);
    as = pi * 2 * rand(1, k);

else
    error('unknown distribution');
end

% variance
Vars = zeros(2, 2, k);
for c = 1 : k
    U = a2rot(as(c));
    Vars(:, :, c) = U' * diag(rs(:, c) .^ 2) * U;
end
