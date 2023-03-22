function segH = segHaca(K, paraH, seg0)
% Hierarchical Aligned Cluster Analysis (HACA).
%
% Input
%   K       -  kernel matrix, n x n
%   paraH   -  segmentation parameter, 1 x nH (struct)
%   seg0    -  inital segmentation (1st level)
%
% Output
%   segH    -  segmentation, 1 x nH (struct)
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-05-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 01-14-2010

% #level in hierarchy
nH = length(paraH);
segH = newSeg(nH);

% segment weight
% At the bottom level, all frames have the unit weights
n = size(K, 1);
wFs = ones(1, n);
s0 = 1 : (n + 1);

% bottom-up
for iH = 1 : nH
    prom('b', 'haca: %d level\n', iH);
    
    % segmentation parameter
    para = paraH(iH);
    para.wFs = wFs;
    
    % initialization
    if iH > 1
        seg0s = segIni(K, para, 'savL', 0);
    else
        seg0s = {seg0};
    end
    nIni = length(seg0s);
    
    % aca at one level
    objLs = zeros(1, nIni);
    segLs = cell(1, nIni);
    for i = 1 : nIni
        
        segLs{i} = segAca(K, para, seg0s{i});
        objLs(i) = segLs{i}.obj;
    end
    
    % choose the result with minimum objective value
    [objL, iOpt] = min(objLs);
    segL = segLs{iOpt};
    
    % gdtak
    lc = ps(para, 'lc', 0);
    [T, P, KC, ws] = dtaksFord(K, segL, lc, para.wFs);
    
    % adjust the segment's position
    segL.sH = segL.s;
    segL.s = s0(segL.sH);
    segL.T = T;
    %     segL.KC = KC;
    
    % update for next level
    segH(iH) = segL;
    K = T;
    wFs = ws;
    s0 = segL.s;
end
