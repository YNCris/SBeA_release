function [v, v2] = objHaca(K, paraH, segH)
% Measuring the objective of HACA.
%
% Input
%   K       -  frame similarity matrix, n x n
%   paraH   -  segmentation parameter, 1 x nH (struct)
%   segH    -  temporal segmentation, 1 x nH (struct)
%
% Output
%   v       -  objective of HACA (segment-base)
%   v2      -  objective of HACA (frame-base, should be equal to v)
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-13-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-23-2009

% #levels in hierarchical
nH = length(paraH);

% At the bottom level, all frames have the unit weights
wFs = ones(1, size(K, 1));
for iH = 1 : nH - 1
    % local constarint
    lc = ps(paraH(iH), 'lc', 0);

    [T, P, KC, ws] = dtaksFord(K, segH(iH), lc, wFs);
    
    % new level
    wFs = ws;
    K = T;
end

% top level, same to ACA
para = paraH(nH);
para.wFs = wFs;
seg = segH(nH);
seg.s = seg.sH;
[v, v2] = objAca(K, para, seg);
