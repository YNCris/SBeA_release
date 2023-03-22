function [p, fC] = segPeak(fD)
% Find the peak position of a segment.
%
% Input
%   fD      -  frame distance matrix, nF x nF
%
% Output
%   p       -  position
%   fC      -  frame correspondance matrix, 2 x nC
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-01-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

n = size(fD, 1);

% flip columns
fDF = fD(:, end : -1 : 1);

% flipped frame correspondence
fCF = dtw(fDF);

% original frame correspondence
fC = fCF;
fC(2, :) = n + 1 - fCF(2, :);

% the cross with diagonal
dif = abs(fC(1, :) - fC(2, :));
[val, idx] = min(dif);

p = fC(1, idx);
