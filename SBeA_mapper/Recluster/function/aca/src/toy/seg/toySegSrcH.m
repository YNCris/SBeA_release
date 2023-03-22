function wsSrc = toySegSrcH(tag)
% Synthetically generate data for temporal segmentation.
%
% Input
%   tag      -  data type
%               1: haca (normal)
%
% Output
%   wsSrc
%     mod    -  model of generating sequence
%     paraM  -  parameter of generated model
%     para   -  segmentation parameter (ACA)
%     paraH  -  segmentation parameter (HACA)
%     X      -  2-D sequence, 2 x n
%     XD     -  1-D sequence, 1 x n
%     segT   -  ground-truth segmentation (ACA)
%     segTH  -  ground-truth segmentation (HACA)
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 03-17-2009
%   modify   -  Feng Zhou (zhfe99@gmail.com), 01-14-2010

prom('m', 'new toy seg src: tag %d\n', tag);

% parameter
if tag == 1
    paraMH = struct('kF', {10, 6}, 'k', {7, 3}, 'nMi', {2, 3}, 'nMa', {3 4});
    m = 10; noi = .1;

else
    error('unknown tag');
end

% model
modH = toySegModH(paraMH, 'rep', 'n');

% sequence with ground-truth segmentation (Just make sure each cluster not be empty)
while true
    [X, XD, segTH] = toySegSeqH(modH, m);
    if ~cluEmp(segTH(end).G)
        break;
    end
end

% noise
[X, XD, segTH] = toySegSeqNoiH(X, XD, segTH, modH, noi);

% segmentation parameter
paraH = paraMH;
paraH(1).ini = 'r'; paraH(2).ini = 'r';
paraH(1).nIni = 10; paraH(2).nIni = 10;
for iH = 1 : length(paraH)
    paraH(iH).nMa = max(max(diff(segTH(iH).sH)), paraH(iH).nMa);
end

% store
wsSrc.modH = modH;
wsSrc.paraMH = paraMH;
wsSrc.para = paraH2para(paraH);
wsSrc.paraH = paraH;
wsSrc.X = X;
wsSrc.XD = XD;
wsSrc.segT = segTH(end);
wsSrc.segTH = segTH;
wsSrc.noi = noi;

