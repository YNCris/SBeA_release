clear variables;

load('tmp.mat');

seg = mergeDP(I, para);
seg2 = mergeI2H(I, [para.nMi, para.nMa]);

showI(I, 'fig', [1 3 1 1]);
showSegBar(seg, 'fig', [1 3 1 2]);
showSegBar(seg2, 'fig', [1 3 1 3]);