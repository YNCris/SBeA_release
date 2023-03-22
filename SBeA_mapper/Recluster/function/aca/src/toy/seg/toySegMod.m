function mod = toySegMod(paraM, varargin)
% Generate models for toy segmentation.
%
% Input
%   paraM    -  model parameter
%     kF     -  #frame class
%     k      -  #segment class
%     nMi    -  minimum segment length
%     nMa    -  maximum segment length
%   varargin
%     spa    -  spatio flag, 'y' | {'n'}
%     meMi   -  minimum of mean, dim x 1, {[-10; -10]}
%     meMa   -  maximum of mean, dim x 1, {[ 10;  10]}
%     bdR    -  bound of radius,   1 x 2, {[.05, .15]}
%
% Output
%   mod      -  model
%     mes    -  mean, 2 x fk
%     Vars   -  variance, 2 x 2 x fk
%     units  -  1 x fk (cell)
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 01-12-2009
%   modify   -  Feng Zhou (zhfe99@gmail.com), 12-20-2009

% function option
isSpa = psY(varargin, 'spa', 'n');

[kF, k, nMi, nMa] = stFld(paraM, 'kF', 'k', 'nMi', 'nMa');
kFClass = floor(kF / k);

% hyper-parameter
dim = 2;
meMi = ps(varargin, 'meMi', [-10; -10]);
meMa = ps(varargin, 'meMa', [ 10;  10]);
bdR = ps(varargin, 'bdR', [.02, .05]);

if isSpa
    me0 = genUnif(meMi, meMa, k, 'maMiD', 'y');
    D = conDist(me0, me0);
    r0 = bandG(D, 1) * .3;
%     r0 = sqrt(sum((miM - maM) .^ 2)) * .2;

    mes = zeros(dim, kF); Vars = zeros(dim, dim, kF);
    for c = 1 : k
        cfk = select(c == k, kF - kFClass * (c - 1), kFClass);
        chead = kFClass * (c - 1) + 1;
        ctail = kFClass * (c - 1) + cfk;

        [mes(:, chead : ctail), Vars(:, :, chead : ctail)] = ...
            genGaussMod(cfk, 'dis', 'gauss', 'me0', me0(:, c), 'r0', r0);
    end

else
    [mes, Vars] = genGaussMod(kF, 'dis', 'unif', 'meMi', meMi, 'meMa', meMa, 'bdR', bdR);
end

units = cell(1, k);
for c = 1 : k
    len = float2block(rand(1), nMi, nMa);

    % sub states
    if isSpa
        cfk = select(c == k, kF - kFClass * (c - 1), kFClass);
        units{c} = float2block(rand(1, len), cfk) + kFClass * (c - 1);
        
    else
        units{c} = float2block(rand(1, len), kF);
    end
end

mod = newToySegMod('mes', mes, 'Vars', Vars, 'units', units, 'unitHs', units);
