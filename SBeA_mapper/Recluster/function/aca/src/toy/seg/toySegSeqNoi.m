function [X, XD, seg] = toySegSeqNoi(X0, XD0, seg0, mod, noi, varargin)
% Insert random frames into the given sequence.
%
% Input
%   X0      -  original continuous frame matrix, 2 x n0
%   XD0     -  original discrete frame matrix, 1 x n0
%   seg0    -  original temporal segmentation result
%   mod     -  module
%   noi     -  noise level
%   varargin
%     smo
%
% Output
%   X       -  new continuous frame matrix, 2 x n
%   XD      -  new discrete frame matrix, 1 x n
%   seg     -  new temporal segmentation result
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-13-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-20-2009

% function option
isSmo = psY(varargin, 'smo', 'n');

kF = size(mod.mes, 2);
n0 = size(X0, 2);
seg = seg0;

X = []; XD = [];
p = 1;

for i = 1 : n0
    X = [X, X0(:, i)]; XD = [XD, XD0(:, i)];
    
    % insert a noisy frame
    if rand(1) < noi
        unit = float2block(rand(1), kF);
        
        x = genGauss(mod.mes(:, unit), mod.Vars(:, :, unit), 1);
        if isSmo
            XD = [XD, XD(end)];
        else
            XD = [XD, unit];
        end
        X = [X, x];
        seg.s(p + 1 : end) = seg.s(p + 1 : end) + 1;
    end
    
    if i == seg0.s(p + 1) - 1
        p = p + 1;
    end
end
