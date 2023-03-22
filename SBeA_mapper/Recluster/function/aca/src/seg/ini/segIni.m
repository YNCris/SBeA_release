function [seg0s, inis, para] = segIni(K, para, varargin)
% Initalize the segmentation.
%
% Input
%   K       -  frame similarity matrix, n x n
%   para    -  segmentation parameter
%     ini   -  initialization method, 'r' | 'p'
%              'r': rand segmentation
%              'p': propagative segmentation
%              'g': gmm
%     nIni  -  #initialization
%   varargin
%     segT  -  ground-truth segmentation, {[]}
%
% Output
%   seg0    -  initial segmentations, 1 x nIni (cell)
%   inis    -  initialization method, 1 x nIni (cell)
%   para    -  copy from the input
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-12-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 01-14-2010

% save option
prom('m', 'new init seg (%s): %d times\n', para.ini, para.nIni);

% function option
segT = ps(varargin, 'segT', []);

ini = para.ini; nIni = para.nIni;
[seg0s, inis] = cellss(1, nIni);

for i = 1 : nIni
    if strcmp(ini, 'r')
        seg0s{i} = segIniR(K, para);
        inis{i} = 'r';
    elseif strcmp(ini, 'p')
        seg0s{i} = segIniP(K, para);
        inis{i} = 'p';
    else
        error('unknown method');
    end

    % match with ground-truth segmentation
    if ~isempty(segT)
        seg0s{i} = match(seg0s{i}, 'segT', segT);
    end
end
