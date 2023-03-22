function segDME = decompose_MoveEtho(K, para)
seg0s = segIni(K, para(1));
segDME = segAlg('haca', [], K, para, seg0s, []);