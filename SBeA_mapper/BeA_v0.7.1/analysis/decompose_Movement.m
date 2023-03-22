function segDM = decompose_Movement(K, para)
seg0s = segIni(K, para(1));
segDM = segAlg('haca', [], K, para, seg0s, []);

