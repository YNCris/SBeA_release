%{
    recluster all data with selected template
%}
clear all
close all
genPath = genpath('./');
addpath(genPath)
%% set file path
filepath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\zengyuting_diff_color\' ...
    'data_for_analysis_20220712\recluster_data\cf_8_bea\cas3d\struct'];
savedatapath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'zengyuting_diff_color\data_for_analysis_20220712\recluster_data'];
%% get all BeA structs
fileFolder = fullfile(filepath);
dirOutput = dir(fullfile(fileFolder,'*.mat'));
fileNames = {dirOutput.name}';
%% load data
load_flag = true;%load data flag
tic
if load_flag
    XY_cell = cell(size(fileNames,1),1);
    ReMap_cell = cell(size(fileNames,1),1);
    Seglist_cell = cell(size(fileNames,1),1);
    V_cell = cell(size(fileNames,1),1);
    for k = 1:size(fileNames,1)
        tempBeA = load([filepath,'\',fileNames{k,1}]);
        cent_num = 13;
        pixel2mm = 1;
        fs = tempBeA.BeA.DataInfo.VideoInfo.FrameRate;%tempBeA.BeA.DataInfo.VideoInfo.FrameRate;
        XY_cell{k,1} = tempBeA.BeA.BeA_DecData.XY;
        ReMap_cell{k,1} = tempBeA.BeA.BeA_DecData.L2.ReMap;
        Seglist_cell{k,1} = tempBeA.BeA.BeA_DecData.L2.Seglist;
        cent_X = tempBeA.BeA.PreproData.X(:,cent_num);
        cent_Y = tempBeA.BeA.PreproData.Y(:,cent_num);
        cent_Z = tempBeA.BeA.PreproData.Z(:,cent_num);
        cent_XYZ = [cent_X,cent_Y,cent_Z];
        temp_vel_XYZ = diff(cent_XYZ);
        vel_XYZ = [temp_vel_XYZ; temp_vel_XYZ(end, :)];
        vel_raw = sqrt(vel_XYZ(:, 1).^2 + vel_XYZ(:, 2).^2 + vel_XYZ(:, 3).^2);
        vel_raw = fs*vel_raw/pixel2mm;%speed/s
        V_cell{k,1} = medfilt1(vel_raw',5);
%         imagesc(tempBeA.BeA.BeA_DecData.K)
%         title(fileNames{k,1})
%         colorbar
%         pause
        toc
    end
    %% save temp data
    save([savedatapath,'\recluster_data_test20221121.mat'],'XY_cell','ReMap_cell','Seglist_cell','V_cell');
else
    load([savedatapath,'\recluster_data_test20221121.mat']);
end
toc
%% create savelist
savelist_cell = cell(size(Seglist_cell,1),1);
for k = 1:size(savelist_cell,1)
    temp_Seglist = Seglist_cell{k,1};
    temp_ReMap = ReMap_cell{k,1};
    temp_savelist = zeros(size(temp_ReMap,2)-1,5);
    temp_savelist(:,1:3) = Create_savelist(temp_ReMap,temp_Seglist);
    savelist_cell{k,1} = temp_savelist;
end
%% create data_sample_cell
selection = [1,1,1,1,1,1,1,1,...
    1,1,1,1,1,1,1,1,...
    1,1,1,1,1,1,1,1,...
    1,1,1,1,1,1,1,1,...
    1,1,1,1,0,0,1,1,...
    0,1,0,0,0,0,0,0];
% selection = [1,1,1,1,1,1,1,1,...
%     1,1,1,1,1,1,1,1,...
%     1,1,1,1,1,1,1,1,...
%     1,1,1,1,1,1,1,1,...
%     1,1,1,1,1,1,1,1,...
%     1,1,1,1,1,1,1,1];
data_sample_cell = [];
for k = 1:size(savelist_cell,1)
    temp_savelist = savelist_cell{k,1};
    for m = 1:size(temp_savelist,1)
        tempdata = XY_cell{k,1}(selection==1,temp_savelist(m,1):temp_savelist(m,2));
        tempV = mean(mean(V_cell{k,1}(:,temp_savelist(m,1):temp_savelist(m,2))));
        tempsavelist = temp_savelist(m,:);
        tempsavelist(1,5) = m;
        tempfilename = fileNames{k,1};
        data_sample_cell = [data_sample_cell;{tempdata,tempsavelist,tempfilename,tempV}];
    end
end
%% select data for create template
sel_name_part = 'Black';
selname = cellfun(@(x) x(1:5),data_sample_cell(:,3),'UniformOutput',false);
selidx = strcmp(selname,sel_name_part);
sel_data_sample_cell = data_sample_cell(selidx,:);
%% calculate dtak
tic
dist_mat = zeros(size(sel_data_sample_cell,1),size(sel_data_sample_cell,1));
for m = 1:size(sel_data_sample_cell,1)
    for n = m:size(sel_data_sample_cell,1)
        %% get data
        seg_data1 = sel_data_sample_cell{m,1};
        seg_data2 = sel_data_sample_cell{n,1};
        %% calculate dtak
		condist_mat = conDist(seg_data1,seg_data2);
		Kdistmat = conKnl(condist_mat,'knl','g','nei',NaN);
		wFs1 = ones(1,size(Kdistmat,1));
		wFs2 = ones(1,size(Kdistmat,2));
		[T,~,~] = dtakFord(Kdistmat,0,wFs1,wFs2);
        dist_mat(m,n) = T;
    end
    disp(m/size(sel_data_sample_cell,1))
end
toc
% fill full matrix
dist_mat_all = dist_mat + triu(dist_mat, 1)';
%% umap embedding
[reduction, umap, clusterIdentifiers] = run_umap(dist_mat_all,'n_neighbors',80,...
    'min_dist',0.051,'metric','euclidean','n_components', 2, ...
    'sgd_tasks',1,'verbose', 'text');
embedding = umap.embedding;
plot(embedding(:,1),embedding(:,2),'o')
axis square
% embedding = tsne(dist_mat_all);
%% add speed dimension
Vdim = [data_sample_cell{:,4}]';
embed3 = [embedding,Vdim(selidx)];
% zscore
zscore_embed3 = [zscore(embed3(:,1)),zscore(embed3(:,2)),zscore(embed3(:,3))];
%%
%% recommand number of class
cluster_num_range = 10:50;
subplot(131)
E1 = evalclusters(zscore_embed3,'linkage','CalinskiHarabasz','KList',1:100);
plot(E1)
subplot(132)
E2 = evalclusters(zscore_embed3,'linkage','silhouette','KList',1:100);
plot(E2)
subplot(133)
E3 = evalclusters(zscore_embed3,'linkage','DaviesBouldin','KList',1:100);
plot(E3)
auto_num = [E1.OptimalK,E2.OptimalK,E3.OptimalK];
rec_auto_num = intersect(cluster_num_range,auto_num);
%% subset hierarchical clustering
subset_zscore_embed3 = zscore_embed3;
n_clus = 41;
D = pdist(subset_zscore_embed3,'seuclidean');
Z = squareform(D);
tree = linkage(Z, 'ward','euclidean');
T_class = cluster(tree,'maxclust',n_clus);
% cutoff = median([tree(end-2,3) tree(end-1,3)]);
% dendrogram(tree,'ColorThreshold',cutoff)
% 
subset_best_label_embedding = [subset_zscore_embed3,T_class];
% 
close all
cmaplist3 = subset_best_label_embedding(:,4);
cmapcolor3 = imresize(colormap('jet'),[length(unique(cmaplist3)),3]);
cmap3 = zeros(size(cmaplist3,1),3);
for k = 1:size(cmap3,1)
    cmap3(k,:) = cmapcolor3(cmaplist3(k,1),:);
end
scatter3(subset_best_label_embedding(:,1),subset_best_label_embedding(:,2),...
    subset_best_label_embedding(:,3),...
    10*ones(size(subset_best_label_embedding(:,1))),cmap3,'filled');
axis square
%% mapping other data
%% calculate left_dist_mat_all
left_data_sample_cell = data_sample_cell(~selidx,:);
% calculate dtak
tic
left_dist_mat_all = zeros(size(left_data_sample_cell,1),size(sel_data_sample_cell,1));
for m = 1:size(left_data_sample_cell,1)
    for n = 1:size(sel_data_sample_cell,1)
        %%get data
        seg_data1 = left_data_sample_cell{m,1};
        seg_data2 = sel_data_sample_cell{n,1};
        % calculate dtak
		condist_mat = conDist(seg_data1,seg_data2);
		Kdistmat = conKnl(condist_mat,'knl','g','nei',NaN);
		wFs1 = ones(1,size(Kdistmat,1));
		wFs2 = ones(1,size(Kdistmat,2));
		[T,~,~] = dtakFord(Kdistmat,0,wFs1,wFs2);
        left_dist_mat_all(m,n) = T;
    end
    disp(m/size(left_data_sample_cell,1))
end
toc
%% mapping by min dist
left_T = zeros(size(left_dist_mat_all,1),1);
tic
for k = 1:size(left_T,1)
    tempdistlist = left_dist_mat_all(k,:);
    tempdistmat = ones(size(dist_mat_all,1),1)*tempdistlist;
    mindist = sqrt(sum((tempdistmat-dist_mat_all).^2,2));
    minidx = find(mindist==min(mindist));
    left_T(k,1) = T_class(minidx);
    if rem(k,200) == 0
        toc
        disp(k)
    end
end
toc
%% append data
all_T = zeros(size(selidx));
all_T(selidx) = T_class;
all_T(~selidx) = left_T;
%% data_sample_cell add data
for k = 1:size(data_sample_cell,1)
    data_sample_cell{k,2}(1,4) = all_T(k,1);
end
%% save data
save([savedatapath,'\reclus_template_20221128.mat'],...
    'data_sample_cell','selidx','zscore_embed3','dist_mat_all',...
    'sel_name_part','T_class','left_T','all_T','left_dist_mat_all','-v7.3');
disp('save successful!')



































