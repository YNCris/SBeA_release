function [wsIn, wsSeg] = mocSeg(wsData, featPara, para)
% Segmentation on motion capture data.
%
% Input
%   wsData    -  mocap data
%   featPara  -  feature parameter
%   para      -  segmentation parameter
%
% Output
%   wsIn      -   
%   wsSeg     -  work space
%
% History
%   create    -  Feng Zhou (zhfe99@gmail.com), 12-29-2008
%   modify    -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

para1 = para(1);

% feature
[DOF, joint] = dofFilter(wsData.DOF, wsData.joint, featPara);
Q = dof2feat(DOF, joint, featPara);

% temporal reduction
[X, stR, DX] = tempoReduce(Q, para1);
Q = stPick(Q, stR);

% frame similiarity
mdim = psY(para1, 'mdim', 'n');
if mdim
    fS = conSim(conDist(Q, Q, 'type', 'e'), 'type', 'g', 'neigh', para1.neigh);
else
    fS = conSim(conDist(X, X));
end

% initalize
seg0 = initSeg(fS, para1);

% tempo segment
[wsSeg.seg, wsSeg.seg0B, wsSeg.S] = tempoSeg(fS, para, 'seg0', seg0);

% spation segment
fSm = conSim(conDist(Q, Q, 'type', 'e'), 'type', 'g');
[wsSeg.segS, wsSeg.IS] = spatioSeg(fSm, para);

% match to ground-truth
if isfield(wsData, 'segStd')
    wsSeg.segStd = reduceSeg(wsData.segStd, stR);
    [wsSeg.seg(end), wsSeg.acc] = matchSeg(wsSeg.seg(end), 'segStd', wsSeg.segStd);
    
    Istd = H2I(wsSeg.segStd.st, wsSeg.segStd.H);
    [wsSeg.IS, wsSeg.accS] = match(wsSeg.IS, Istd);
end

wsSeg.seg0 = seg0; wsSeg.stR = stR; wsSeg.X = X;
wsSeg.DX = DX; wsSeg.Q = Q; wsSeg.fS = fS;
