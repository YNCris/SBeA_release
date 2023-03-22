function [X, XD, seg] = toySegSeq(mod, m, varargin)
% Generate sequence from the specific models.
%
% Input
%   mod     -  temporal model
%   m       -  segment number
%   varargin
%     smo   -  smooth flag, 'y' | {'n'}
%
% Output
%   X       -  continuous sequence, 2 x n
%   XD      -  discrete sequence, 1 x n
%   seg     -  temporal segmentation result
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-12-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-20-2009

% function option
isSmo = psY(varargin, 'smo', 'n');

[mes, Vars, units] = stFld(mod, 'mes', 'Vars', 'units');
k = length(units);

% repeat m times to randomly select one of the given models
s = ones(1, m + 1); G = zeros(k, m);
X = []; XD = [];

for i = 1 : m
    % class
    c = float2block(rand(1), k);
    G(c, i) = 1;

    % feature
    unit = units{c};
    len = length(unit);
    
    if isSmo
        if c == 1
            x = linspace(-5, 5, len);
            y = 1 ./ (1 + exp(-x));
        elseif c == 2
            x = linspace(-5, 5, len);
            y = exp(-x) ./ (1 + exp(-x));
        elseif c == 3
            x = linspace(-1, 1, len);
            y = x .^ 2;
        elseif c == 4
            x = linspace(-1, 1, len);
            y = 1 - x .^ 2;
        end
        XD = [XD, y];
    else
        XD = [XD, unit];
    end

    for j = 1 : len
        u = unit(j);
        x = genGauss(mes(:, u), Vars(:, :, u), 1);
        X = [X, x];
    end
    s(i + 1) = s(i) + len;
end

seg = newSeg('s', s, 'G', G);
