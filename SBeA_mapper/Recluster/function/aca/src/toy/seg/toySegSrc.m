function wsSrc = toySegSrc(tag, varargin)
% Synthetically generate data for temporal segmentation.
%
% Input
%   tag      -  data type
%               1: normal
%               2: short sequence
%   varargin
%     noi    -  noise level, {.1}
%     nIni   -  #initialization, {1}
%     spa    -  spatio flag, {'n'}
%
% Output
%   wsSrc
%     mod    -  model of generating sequence
%     paraM  -  parameter of generated model
%     para   -  segmentation parameter
%     X      -  2-D sequence, 2 x n
%     XD     -  1-D sequence, 1 x n
%     segT   -  ground-truth segmentation
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 03-17-2009
%   modify   -  Feng Zhou (zhfe99@gmail.com), 01-14-2010

prom('m', 'new toy seg src: tag %d\n', tag);

% function option
noi = ps(varargin, 'noi', .1);
nIni = ps(varargin, 'nIni', 10);
spa = ps(varargin, 'spa', 'n');

% parameter
if tag == 1
    paraM.kF = 10; paraM.k = 3; paraM.nMi = 6; paraM.nMa = 9;
    m = 10;

elseif tag == 2
    paraM.kF = 10; paraM.k = 3; paraM.nMi = 3; paraM.nMa = 4;
    m = 10;

else
    error('unknown tag');
end

% model
mod = toySegMod(paraM, 'spa', spa);

% sequence with ground-truth segmentation (Just make sure each cluster not be empty)
while true
    [X, XD, segT] = toySegSeq(mod, m);
    if ~cluEmp(segT.G)
        break;
    end
end

% noise
[X, XD, segT] = toySegSeqNoi(X, XD, segT, mod, noi);

% segmentation parameter
para = paraM;
para.ini = 'r'; para.nIni = nIni;

% adjust the length constraint because the sequence has been inserted by noisy frames
para.nMa = max(max(diff(segT.s)), para.nMa);

% store
wsSrc.mod = mod;
wsSrc.paraM = paraM;
wsSrc.para = para;
wsSrc.X = X;
wsSrc.XD = XD;
wsSrc.segT = segT;
wsSrc.noi = noi;
