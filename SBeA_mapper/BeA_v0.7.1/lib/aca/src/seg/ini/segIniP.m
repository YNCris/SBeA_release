function [seg, KP] = segIniP(K, para)
% Initalize segmentation based on non-tempo-warping clustering.
%
% Input
%   K       -  frame similarity matrix, n x n
%   para    -  segmentation parameter
%
% Output
%   seg     -  segmentation result
%   KP      -  similarity matrix used by initalization, n x n
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-26-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-23-2009

% progative similarity matrix
KP = conPropSim(K, para.nMa/2);

% eva = evalclusters(KP, @cluSc_L, 'CalinskiHarabasz', 'klist', [1:20]);
% spectral clustering
I = cluSc(KP, para.k);

% obtain the class labels for segments
seg = mergeDP(I, para);
% seg = mergeI2H(I, para);

% randomly initalize when some cluster is empty
if cluEmp(seg.G)
    seg = segIniR(K, para);
    warning('a:b', 'empty class in prop init, use rand init instead\n');
end
