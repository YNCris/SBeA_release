function labels = recluster_Movement(paraL, segDM)
% re-clustering the movements with the added velocity dimension
%
% Input
%       - paraL          -  parameters of umap running for self-movement space
%       - segDM          -  decomposed self-movement data and parameters
%
% Output
%       - labels             -  new labels of re-clustering
%
% History
%   create  -  Kang Huang  (kang.huang@siat.ac.cn), 03-28-2020
%   modify  -  Yaning Han  (yn.han@siat.ac.cn), 07-16-2020

global BeA
fs = BeA.DataInfo.VideoInfo.FrameRate;
pixel2mm = 0.88;

[embedd2, ~, ~] = run_umap(segDM.T, ...
                    'n_components', paraL.Nc, 'min_dist',...
                    paraL.MinD, 'n_neighbors', paraL.Nn, ...
                    'verbose', 'text','sgd_tasks',1);

%% calculating velocity
BeA.DataInfo.config_bea.BA.CenIndex = 13;
cent_X = BeA.PreproData.X(:, BeA.DataInfo.config_bea.BA.CenIndex);
cent_Y = BeA.PreproData.Y(:, BeA.DataInfo.config_bea.BA.CenIndex);

cent_XY = [cent_X, cent_Y];
vel_XY = diff(cent_XY);
vel_XY = [vel_XY; vel_XY(end, :)];

vel_raw = sqrt(vel_XY(:, 1).^2 + vel_XY(:, 2).^2);
vel_raw = fs*vel_raw/pixel2mm;

window = round(0.5 * fs);
err = 0.001;
% [vel, ~] = smooth_XYadapt(vel_raw, 'mean', window, err);
[vel, ~] = smooth_XYadapt(vel_raw, 'moving', window, err);

seg_interval = segDM.s;
nSegs = size(embedd2, 1);

seg_vel = zeros(nSegs, 1);
for i = 1:nSegs
    sel_idx = seg_interval(i):seg_interval(i+1)-1;
    seg_vel(i) = mean(vel(sel_idx));
end

% seg_vel_nr = zscore(seg_vel);
seg_vel_nr = (seg_vel - mean(seg_vel))/(max(seg_vel) - min(seg_vel));
embedd3 = [embedd2(:, 1:2), seg_vel_nr];

%% reclustering 

% eva = evalclusters(embedd3, @re_clusterSimple, 'CalinskiHarabasz', 'klist',[1:20]);
% figure; plot(eva)

labels = re_cluster(embedd3, 11);

BeA.BeA_DecData.L2.velnm = seg_vel_nr;
BeA.BeA_MapData.L2.embedding = embedd2;

close 

n_clus = max(unique(labels));
n_genColor = 10;
cclr = (cbrewer2('Paired', n_genColor));
[X, Y] = meshgrid([1:3], [1:n_clus]);
if n_clus > n_genColor
    clr = interp2(X(round(linspace(1, n_clus, n_genColor)), :), Y(round(linspace(1, n_clus, n_genColor)), :), cclr, X, Y);
else
    clr = cclr(1:n_clus, :);
end

clr_map = zeros(nSegs, 3);
figure; hold on
for k = 1:n_clus
    %     if k == 2
    %         continue
    %     end
    tem_clr = clr(k, :);
    tem_idx = labels == k;
    clr_map(tem_idx, :) = repmat(tem_clr, sum(tem_idx),1);
    scatter3(embedd3(tem_idx, 1), embedd3(tem_idx, 2), embedd3(tem_idx, 3), 40, ...
        'MarkerFaceColor', tem_clr, 'MarkerEdgeColor', tem_clr, 'LineWidth', 0.1)
    
    vs(1, k).ViolinColor = tem_clr;
end













