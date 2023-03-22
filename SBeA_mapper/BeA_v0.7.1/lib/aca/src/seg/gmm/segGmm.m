function [seg, I, I0] = segGmm(K, para, varargin)
% Spatial segmentation.
% We use spectral clustering (SC) instead of GMM, because we found SC
% is superior to GMM and SC can be computed by the kernel matrix.
%
% Input
%   K         -  frame similarity matrix, n x n
%   para      -  segmentation parameter
%   varargin
%     segStd  -  ground-truth segmentation
%
% Output
%   seg       -  segmentation
%   I         -  frame label after filtering, n x n
%   I0        -  frame label given by gmm (sc), n x n
%
% History
%   create    -  Feng Zhou (zhfe99@gmail.com), 12-29-2008
%   modify    -  Feng Zhou (zhfe99@gmail.com), 12-23-2009

k = para(end).k;
nH = length(para);
[w1 w2] = zeross(1, nH);
for i = 1 : nH
%     w1(i) = round(.5 * para(i).maW);
    w1(i) = para(i).nMi;
    w2(i) = para(i).nMa;
end

mi = 1; ma = 1;
for i = 1 : nH
    mi = mi * w1(i);
    ma = ma * w2(i);
end
w = [mi, ma];

% spectral clustering
I0 = cluSc(K, k);

% filtering
I = filterI(I0, w);
seg = I2Seg(I);
