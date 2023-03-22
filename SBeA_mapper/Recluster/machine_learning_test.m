%{
    机器学习方法检查是否分开
%}
clear all
close all
%% 读取数据
load('.\data\group_compare.mat');
%% UMAP3D
dimesion_num = 3;
comp_data = zeros(size(group_compare{1,3},1),size(group_compare,1));
for k = 1:size(group_compare,1)
    comp_data(:,k) = group_compare{k,3}(:,2);
end
[reduction, umap, clusterIdentifiers] = run_umap(comp_data','n_neighbors',8,...
    'min_dist',0.051,'metric','euclidean','n_components', dimesion_num,...
    'method','MATLAB', 'verbose','text');
% reduction = tsne(comp_data','NumDimensions',2);
group_label = group_compare(:,2);%{1;2;1;2;1;2;1;2;1;2;1;2};%
group_embedding = [reduction,cell2mat(group_label)];
% 作图3D
figure
cmap = mat2gray(imresize(colormap('jet'),[2,3]));
cmaplist = zeros(size(group_embedding,1),3);
for k = 1:size(group_embedding,1)
    cmaplist(k,:) = cmap(group_embedding(k,end),:);
end
scatter3(group_embedding(:, 1), group_embedding(:, 2), group_embedding(:,3),[],cmaplist)
%% UMAP2D
dimesion_num = 2;
comp_data = zeros(size(group_compare{1,3},1),size(group_compare,1));
for k = 1:size(group_compare,1)
    comp_data(:,k) = group_compare{k,3}(:,2);
end
[reduction, umap, clusterIdentifiers] = run_umap(comp_data','n_neighbors',5,...
    'min_dist',0.1,'metric','euclidean','n_components', dimesion_num,...
    'method','MATLAB', 'verbose','text');
% reduction = tsne(comp_data','NumDimensions',2);
group_label = group_compare(:,2);%{1;2;1;2;1;2;1;2;1;2;1;2};%
group_embedding = [reduction,cell2mat(group_label)];
% 作图2D
figure
cmap = mat2gray(imresize(colormap('jet'),[2,3]));
cmaplist = zeros(size(group_embedding,1),3);
for k = 1:size(group_embedding,1)
    cmaplist(k,:) = cmap(group_embedding(k,end),:);
end
scatter(group_embedding(:, 1), group_embedding(:, 2),[],cmaplist)
%% 原始数据排序
raw_freq = comp_data';
unique_label = unique(group_embedding(:,end));
group_num = cell2mat(group_label);
cgo = clustergram(raw_freq','Standardize','column','Colormap',redbluecmap);
% 参数设置
mice_markers = struct('GroupNumber', {12,14},...
                      'Annotation', {'anx', 'ctrl'},...
                      'Color', {[1 1 0], [0.6 0.6 1]});
cgo.ColumnGroupMarker = mice_markers;

% W = raw_freq;
% D = pdist(W);
% D = squareform(D);
% % imagesc(D)
% rng('default') % For reproducibility
% tree = linkage(D, 'ward','euclidean');
% leafOrder = optimalleaforder(tree, D);
% T = cluster(tree,'maxclust',2);
% % sort_freq = 
% dendrogram(tree)




















