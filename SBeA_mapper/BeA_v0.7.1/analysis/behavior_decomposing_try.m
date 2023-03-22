function behavior_decomposing_try(HBT_DecParam)

% perform 3-layer (poses, movements, ethograms) behavior decomposition
%
% Input
%   HBT_DecParam       -  parameters for behavior decomposition
%       - HBT_DecParam.L1	-  parameters for layer 1
%           - calg          -  clustering algorithm type, {'kmeans'} | 'density'
%           - ralg          -  reduction algorithm type, {'merge'} | 'ave'
%           - redL          -  maximum segment length
%           - kF            -  frame cluster, needed if the calg is 'kmeans'
%       - HBT_DecParam.L2	-  parameters for layer 2
%           - kerType       -  kernel type, 'g' | 'st' | 'bi'
%           	'g':  Gaussian kernel
%               'st': Self Tunning kernel. See the paper in NIPS 2004, Self-Tuning Spectral Clustering
%               'bi': Bipartite Maximum Weight Matching. See the paper in AISTAT 2007, 
%                     Loopy Belief Propagation for Bipartite Maximum Weight b-Matching
%           - kerBand       -  #nearest neighbour to compute the kernel bandwidth, {.1}
%               0: binary kernel
%               NaN: set bandwidth to 1
%           - k             -  class number of layer 2.
%           - nMi           -  minimum length of every motifs
%           - nMa           -  maximum length of every motifs
%           - Ini           -  initialization method of layer 2
%       - HBT_DecParam.L3	-  parameters for layer 3
%           - k             -  class number of layer 3.
%           - nMi           -  minimum length of every motifs
%           - nMa           -  maximum length of every motifs
%           - Ini           -  initialization method of layer 3
%
% Output
%   global HBT.HBT_DecData
%       - HBT_DecData.K     - PxP matrix saving the distance matrix.
%       - HBT_DecData.L1    - HBT data of layer 1
%           ReMap:          - mapping list of layer 1 with data
%           Seglist:        - decomposition results of layer 1
%           MedData:        - intermediate variables
%       - HBT_DecData.L2    - HBT data of layer 2
%           ReMap:          - mapping list of layer 2 with data
%           Seglist:        - decomposition results of layer 2
%           MedData:        - intermediate variables
%       - HBT_DecData.L3    - HBT data of layer 3
%           ReMap:          - mapping list of layer 3 with data
%           Seglist:        - decomposition results of layer 3
%           MedData:        - intermediate variables
% History
%   create  -  Kang Huang  (kang.huang@siat.ac.cn), 03-02-2020

%% Initialize para for decompostion
global HBT

timer_all = clock;
% fs = HBT.DataInfo.VideoInfo.FrameRate;
fs = 30;

paraP.k = HBT_DecParam.L1.kF;
paraP.kF = paraP(1,1).k;
paraP.redL = HBT_DecParam.L1.redL;
paraP.calg = HBT_DecParam.L1.calg;
paraP.ralg = HBT_DecParam.L1.ralg;

paraME(1,1).k = HBT_DecParam.L2.k;
paraME(1,1).kF = 'f';
paraME(1,1).nMi = round(HBT_DecParam.L2.nMi/(fs*paraP.redL));
paraME(1,1).nMa = round(HBT_DecParam.L2.nMa/(fs*paraP.redL));
paraME(1,1).ini = HBT_DecParam.L2.Ini;
paraME(1,1).nIni = 1;
paraME(1,1).kerType = 'bi';
paraME(1,1).kerBand = 'nei';



paraME(2,1).k = HBT_DecParam.L3.k;
paraME(2,1).kF = paraME(2,1).k*2;
paraME(2,1).nMi = HBT_DecParam.L3.nMi/HBT_DecParam.L2.nMa;
paraME(2,1).nMa = HBT_DecParam.L3.nMa/HBT_DecParam.L2.nMa;
paraME(2,1).ini = HBT_DecParam.L3.Ini;
paraME(2,1).nIni = 1;



dim = size(HBT.PreproData.X);
data = zeros(dim)';
for i = 1:dim(2)
    data((i*2)-1, :) = HBT.PreproData.X(:, i);
    data((i*2), :) = HBT.PreproData.Y(:, i);
end

% romdom select 1 minute data
sel_start = round(1 * (size(data, 2) - fs*60));
data = data(:, sel_start:sel_start+fs*60);

%% Decompose poses
timer = clock;
[DP_sR, DP_X, DP_XD, DP_XD0, G1] = decompose_poses(data, paraP);
addMes2log(1, ['Decomposing poses, time elapse: ' num2str(etime(clock,timer)) 'seconds'], 0, 1)

%% Calculating kernel matrix
timer = clock;
K = conKnl(conDist(DP_X, DP_X), paraME(1,1).kerType, paraME(1,1).kerBand);
addMes2log(1, ['Calculating kernel matrix, time elapse: ' num2str(etime(clock,timer)) 'seconds'], 0, 1)

%% Decompose movements and ethograms
timer = clock;
segDME = decompose_MoveEtho(K, paraME);
addMes2log(1, ['Decomposing movements and ethograms, time elapse: ' num2str(etime(clock,timer)) 'seconds'], 0, 1)

%% Results transfer
decBehavior = segDME;
decBehavior(2) = segDME(1);
decBehavior(3) = segDME(2);
decBehavior(1).s = DP_sR;
decBehavior(1).sH = DP_sR;
decBehavior(1).G = G1;
decBehavior(1).tim = [];
decBehavior(1).obj = [];
decBehavior(1).T = K;

Seg_cell = cell(3,1);
Seglist = DP_XD0;
Seg_cell{1,1} = Seglist;
for p = 1:2
    
    TRL = segDME(p).s;
    MapFL = DP_sR;
    TFL = 0.*TRL;
    for m = 1:size(TRL,2)
        for n = 1:size(MapFL,2)
            if n == TRL(1,m)
                TFL(1,m) = MapFL(1,n);
            end
        end
    end
    decBehavior(p+1).s = TFL;
    decBehavior(p+1).G = segDME(p).G;
    Seglist = SegBarTrans(decBehavior(p+1));
    Seg_cell{p+1,1} = Seglist;
    
end
%% Save results
HBT_DecData = struct;
HBT_DecData.XY = data;
HBT_DecData.K = K;
HBT_DecData.DP_X = DP_X;
HBT_DecData.L1.ReMap = decBehavior(1).s;
HBT_DecData.L1.Seglist = Seg_cell{1}; 
HBT_DecData.L1.MedData = decBehavior(1);
HBT_DecData.L2.ReMap = decBehavior(2).s;
HBT_DecData.L2.Seglist = Seg_cell{2}; 
HBT_DecData.L2.MedData = decBehavior(2);
HBT_DecData.L3.ReMap = decBehavior(3).s;
HBT_DecData.L3.Seglist = Seg_cell{3}; 
HBT_DecData.L3.MedData = decBehavior(3);

HBT.HBT_DecData = HBT_DecData;

addMes2log(1, ['Decomposing completed, time elapse: ' num2str(etime(clock, timer_all)) 'seconds'], 0, 1)





