function [X, XD, segH] = toySegSeqH(modH, m)
% Generate 1-D discrete sequence from the models.
%
% Input
%   mods    -  temporal model
%   m       -  segment number
%
% Output
%   X       -  continuous sequence, 2 x n
%   XD      -  discrete sequence, 1 x n
%   segs    -  temporal segmentation parameter, 1 x nH struct array
%     st    -  head's position of segment respect to frames, m_iH + 1 length
%     H     -  segment' label, k x m matrix
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-13-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-20-2009

nH = length(modH);
segH = newSeg(nH);
[X, XD, segH(end)] = toySegSeq(modH(end), m);

% top-down
G = segH(end).G; L = G2L(G);

for iH = nH - 1 : -1 : 1
    k = length(modH(iH).units);
    XH = []; sH = 1;
    for i = 1 : m
        unitHs = modH(iH + 1).unitHs;
        XH = [XH, unitHs{L(i)}];
        sH = [sH, sH(end) + length(unitHs{L(i)})];
    end
    G = L2G(XH, k);

    m = length(XH);
    s = ones(1, m + 1);
    for i = 1 : m
        units = modH(iH).units;
        s(i + 1) = s(i) + length(units{XH(i)});
    end
    
    segH(iH).s = s; segH(iH).G = G; segH(iH + 1).sH = sH;
end
segH(1).sH = segH(1).s;
