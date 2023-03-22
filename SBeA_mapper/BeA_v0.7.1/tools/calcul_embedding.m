function calcul_embedding(HBT_MapParam)

% dimensionality reduction and return low-D embedding
%
% Input
%   HBT_MapParam       -  parameters for behavior mapping
%       - Method       -  dimensionality reduction algorithms: 'umap'|'tsne'
%       - L1           -  dimensionality reduction parameters for layer 1
%           - MinD     -  ref. run_umap 'min_dist'
%           - Nn       -  ref. run_umap 'n_neighbors'
%           - Pp       -  ref. tsne 'Perplexity'
%           - Nc       -  ref. run_umap 'n_components' or ref. tsne 'NumDimensions'
%       - L2           -  dimensionality reduction parameters for layer 2
%           - MinD     -  ref. run_umap 'min_dist'
%           - Nn       -  ref. run_umap 'n_neighbors'
%           - Pp       -  ref. tsne 'Perplexity'
%           - Nc       -  ref. run_umap 'n_components' or ref. tsne 'NumDimensions'
%
% Output
%   HBT_MapData
%   Seg_cell           - segments indices of each layer
%   embedding          - low-D embeddings of each layer
%
% History
%   create  -  Kang Huang  (kang.huang@siat.ac.cn), 03-02-2020

global HBT

% embedding = cell(1, 1);
% Seg_cell = cell(1, 1);

tem_T = HBT.HBT_DecData.L1.MedData.T;
paraL = HBT_MapParam.L1;

switch HBT_MapParam.Method
    case 'umap'
        if strcmp(HBT.HBT_DecParam.L1.calg, 'density')
            tem_dr = HBT.HBT_DecData.DP_X;
        else
            [tem_dr, ~, ~] = run_umap(tem_T, ...
                'n_components', paraL.Nc, 'min_dist', paraL.MinD, 'n_neighbors', paraL.Nn);
        end
    case 'tsne'
        tem_dr = tsne_d(tem_T, [], paraL.Nc, paraL.Pp);
end

seg.s = HBT.HBT_DecData.L1.MedData.sH;
seg.G = HBT.HBT_DecData.L1.MedData.G;
Seglist = SegLabelTrans(seg);
%     Seg_cell{il, 1} = Seglist;
%     embedding{il, 1} = tem_dr;
HBT.HBT_MapData.L1.Seg_cell = Seglist;
HBT.HBT_MapData.L1.embedding = tem_dr;

