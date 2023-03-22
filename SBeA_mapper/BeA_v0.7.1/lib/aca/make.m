path0 = cd;

cd 'lib/cell';
mex cellss.cpp;
mex oness.cpp;
mex zeross.cpp;
cd(path0);

cd 'lib/common';
mex tokenise.cpp;
mex atoi.cpp;
mex atof.cpp;
cd(path0);

cd 'lib/label';
mex G2L.cpp;
mex L2G.cpp;
cd(path0);

cd 'src/seg/aca';
mex acaFord.cpp;
mex acaBack.cpp;
cd(path0);

cd 'src/seg/dtak';
mex dtakFord.cpp;
mex dtakBack.cpp;
cd(path0);

cd 'src/seg/ini';
mex conPropSim.cpp;
cd(path0);
