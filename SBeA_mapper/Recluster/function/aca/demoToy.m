clear variables;
tag = 1;

%% source
wsSrc = toySegSrc(tag, 'prex', tag);
[X, XD, para, segT] = stFld(wsSrc, 'X', 'XD', 'para', 'segT');

%% similarity
K = conKnl(conDist(XD, XD), 'nei', 0);

%% init
seg0s = segIni(K, para);

%% aca
seg = segAca(K, para, seg0s{1});
seg = matchSeg(seg, segT);

%% show
showSeg(XD, segT, 'fig', [1 2 1 1]);
title(sprintf('ground truth, %d frames, %d segments, %d clusters, %.2f noise', size(K, 1), size(segT.G, 2), size(segT.G, 1), wsSrc.noi));
showSeg(XD, seg, 'fig', [1 2 1 2]);
title(sprintf('aca accuracy %.2f', seg.acc));
