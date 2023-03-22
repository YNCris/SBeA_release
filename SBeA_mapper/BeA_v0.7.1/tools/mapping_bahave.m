function mapping_bahave(HBT_MapParam)

% mapping multi-layer bahvior into low-D space
%
% Input
%   HBT_MapParam       -  parameters for behavior mapping
%       - Method       -  dimensionality reduction algorithms: 'umap'|'tsne'
%       - L1           -  dimensionality reduction parameters for layer 1
%       - L2           -  dimensionality reduction parameters for layer 2
%       - L3           -  dimensionality reduction parameters for layer 3
%
% Output
%   global HBT.HBT_MapData
%
% History
%   create  -  Kang Huang  (kang.huang@siat.ac.cn), 03-02-2020


global HBT

if isfield(HBT.HBT_MapData, 'L1')
    if ~isfield(HBT.HBT_MapData.L1, 'embedding') && strcmp(HBT.HBT_DecParam.L1.calg, 'kmeans')
        calcul_embedding(HBT_MapParam)
    end
else
    calcul_embedding(HBT_MapParam)
end
% close all


Border = 0.5;
Sigma = 0.4;
stepNum = 200;

embedding{1, 1} = HBT.HBT_MapData.L1.embedding;
embedding{2, 1} = HBT.HBT_MapData.L2.embedding;

if ~isfield(HBT.HBT_MapData.L1', 'PDF')
    PDF = calcul_density_L1(embedding, Border, Sigma, stepNum);
    HBT.HBT_MapData.L1.PDF = PDF;
end

% plot behavior map
plot_behaveMap(HBT.HBT_MapData.L1.PDF, embedding)









