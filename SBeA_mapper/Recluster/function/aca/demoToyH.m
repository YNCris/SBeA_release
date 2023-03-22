clear variables;
tag = 1;

%% source
wsSrc = toySegSrcH(tag);
[X, XD, paraH, segTH] = stFld(wsSrc, 'X', 'XD', 'paraH', 'segTH'); 

%% similarity
K = conKnl(conDist(XD, XD), 'nei', 0);

%% init
seg0s = segIni(K, paraH(1));

%% haca
segH = segHaca(K, paraH, seg0s{1});
segH(1) = matchSeg(segH(1), segTH(1));
segH(2) = matchSeg(segH(2), segTH(2));

%% show
showSeg(XD, segTH(1), 'fig', [1 4 1 1]);
title(sprintf('ground truth (1st level), %d frames, %d segments, %d clusters', size(K, 1), size(segTH(1).G, 2), size(segTH(1).G, 1)));
showSeg(XD, segTH(2), 'fig', [1 4 1 2]);
title(sprintf('ground truth (2nd level), %d segments, %d clusters, %.2f noise', size(segTH(2).G, 2), size(segTH(2).G, 1), wsSrc.noi));
showSeg(XD, segH(1), 'fig', [1 4 1 3]);
title('haca (1st level)');
showSeg(XD, segH(2), 'fig', [1 4 1 4]);
title(sprintf('haca (2nd level) accuracy %.2f', segH(2).acc));
