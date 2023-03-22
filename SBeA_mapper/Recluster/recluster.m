%{
    recluster all data
%}
clear all
close all
genPath = genpath('./');
addpath(genPath)
%% set file path
filepath = ['Z:\hanyaning\multi_mice_test\' ...
    'Social_analysis\data\zengyuting_diff_color\' ...
    'aggressive_data_20230317\unmerge_data\white_struct'];
savedatapath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\zengyuting_diff_color\aggressive_data_20230317\recluster_data'];
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
    save([savedatapath,'\recluster_data_test20230301.mat'],'XY_cell','ReMap_cell','Seglist_cell','V_cell');
else
    load([savedatapath,'\recluster_data_test20230301.mat']);
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
%% calculate dtak
tic
dist_mat = zeros(size(data_sample_cell,1),size(data_sample_cell,1));
for m = 1:size(data_sample_cell,1)
    for n = m:size(data_sample_cell,1)
        %% get data
        seg_data1 = data_sample_cell{m,1};
        seg_data2 = data_sample_cell{n,1};
        %% calculate dtak
		condist_mat = conDist(seg_data1,seg_data2);
		Kdistmat = conKnl(condist_mat,'knl','g','nei',NaN);
		wFs1 = ones(1,size(Kdistmat,1));
		wFs2 = ones(1,size(Kdistmat,2));
		[T,~,~] = dtakFord(Kdistmat,0,wFs1,wFs2);
        dist_mat(m,n) = T;
    end
    disp(m/size(data_sample_cell,1))
end
toc
%% fill full matrix
dist_mat_all = dist_mat + triu(dist_mat, 1)';
%% embedding
[reduction, umap, clusterIdentifiers] = run_umap(dist_mat_all,...
    'n_neighbors',199,'sgd_tasks',1,...
    'min_dist',0.05,'metric','seuclidean','n_components', 2, 'verbose', 'text');
embedding = umap.embedding;
% plot(embedding(:,1),embedding(:,2),'o')
% axis square
% embedding = tsne(dist_mat_all,'Perplexity',5);
plot(embedding(:,1),embedding(:,2),'o')
axis square
%% add speed dimension
Vdim = [data_sample_cell{:,4}]';
embed3 = [embedding,Vdim];
% zscore
zscore_embed3 = [zscore(embed3(:,1)),zscore(embed3(:,2)),zscore(embed3(:,3))];
%% data_sample_cell reassignment
for k = 1:size(data_sample_cell,1)
    data_sample_cell{k,5} = embed3(k,:);
    data_sample_cell{k,6} = zscore_embed3(k,:);
end
% save('.\data\data_sample_cell.mat','data_sample_cell')
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
%% hierarchical clustering
n_clus = 50;
D = pdist(zscore_embed3,'seuclidean');
Z = squareform(D);
tree = linkage(Z, 'ward','euclidean');
T = cluster(tree,'maxclust',n_clus);
% cutoff = median([tree(end-2,3) tree(end-1,3)]);
% dendrogram(tree,'ColorThreshold',cutoff)
% 
best_label_embedding = [zscore_embed3,T];
% 
close all
cmaplist3 = best_label_embedding(:,4);
cmapcolor3 = imresize(colormap('jet'),[length(unique(cmaplist3)),3]);
cmap3 = zeros(size(cmaplist3,1),3);
for k = 1:size(cmap3,1)
    cmap3(k,:) = cmapcolor3(cmaplist3(k,1),:);
end
scatter3(best_label_embedding(:,1),best_label_embedding(:,2),best_label_embedding(:,3),...
    10*ones(size(best_label_embedding(:,1))),cmap3,'filled');
axis square
%% data_sample_cell add data
for k = 1:size(data_sample_cell,1)
    data_sample_cell{k,2}(1,4) = best_label_embedding(k,4);
end
%% group_statistics
unique_mat = unique(data_sample_cell(:,3));
group_compare = cell(size(unique_mat,1),6);
group_compare(:,1) = unique_mat;
group_num_list = num2cell([ones(15,1);2*ones(15,1)]);
group_compare(:,2) = group_num_list;
%% 
% figure
% data_num = 100;
class_num = max(T(:));
for k = 1:size(group_compare,1)
    %% 
    filename = group_compare{k,1};
    temp_data_sample_cell = data_sample_cell;
    empty_list = zeros(size(temp_data_sample_cell,1),1);
    for m = 1:size(empty_list,1)
        if strcmp(data_sample_cell{m,3},filename) == 0
            empty_list(m,1) = 1;
        end
    end
    temp_data_sample_cell(empty_list==1,:) = [];
%     temp_data_sample_cell = temp_data_sample_cell(1:data_num,:);
    %% 
    class_num_mat = zeros(class_num,2);
    class_num_mat(:,1) = 1:class_num;
    for m = 1:size(temp_data_sample_cell,1)
        for n = 1:size(class_num_mat,1)
            if temp_data_sample_cell{m,2}(1,4) == class_num_mat(n,1)
                class_num_mat(n,2) = class_num_mat(n,2)+1;
            end
        end
    end
    scale_class_num_mat = class_num_mat(:,2)./sum(class_num_mat(:,2));
    class_num_mat(:,2) = scale_class_num_mat;
    %% 
    class_time_mat = zeros(class_num,2);
    class_time_mat(:,1) = 1:class_num;
    for m = 1:size(temp_data_sample_cell,1)
        for n = 1:size(class_time_mat,1)
            if temp_data_sample_cell{m,2}(1,4) == class_time_mat(n,1)
                class_time_mat(n,2) = class_time_mat(n,2)+size(temp_data_sample_cell{m,1},2);
            end
        end
    end
    scale_class_time_mat = class_time_mat(:,2)./sum(class_time_mat(:,2));
    class_time_mat(:,2) = scale_class_time_mat;
    %% 
    temp_transmat = zeros(class_num,class_num);
    temp_label_list = zeros(size(temp_data_sample_cell,1),1);
    for m = 1:size(temp_label_list,1)
        temp_label_list(m,1) = temp_data_sample_cell{m,2}(1,4);
    end
    pre_state = temp_label_list(1:(end-1),1);
    cur_state = temp_label_list(2:end,1);
    for m = 1:size(pre_state,1)
        temp_transmat(pre_state(m,1),cur_state(m,1)) = ...
            temp_transmat(pre_state(m,1),cur_state(m,1))+1;
    end
    sum_transmat = sum(temp_transmat,2);
    transmat = temp_transmat./(sum_transmat.*ones(1,class_num)+eps);
    %% 
    a = [transmat'-eye(class_num);ones(1,class_num)];
    b = [zeros(class_num,1);1];
    p_limit = a\b;
    %% 
    temp_test_limit = transmat^100000000;
    test_limit = temp_test_limit(1,:)';
    eps_limit = abs(test_limit-p_limit);
    %% 
    group_compare{k,3} = class_num_mat;
    group_compare{k,4} = class_time_mat;
    group_compare{k,5} = transmat;
    group_compare{k,6} = p_limit;
end
group_compare = sortrows(group_compare,2);
%% statistic number
group_compare_num = zeros(size(group_compare{1,3},1),size(group_compare,1));
for k = 1:size(group_compare_num,2)
    group_compare_num(:,k) = group_compare{k,3}(:,2);
end
%% statistic time
group_compare_time = zeros(size(group_compare{1,3},1),size(group_compare,1));
for k = 1:size(group_compare_time,2)
    group_compare_time(:,k) = group_compare{k,4}(:,2);
end
%% save data
save([savedatapath,'\dist_mat_all_20230301.mat'],'dist_mat_all','-v7.3');
save([savedatapath,'\embedding_20230301.mat'],'best_label_embedding','-v7.3');
save([savedatapath,'\group_compare_20230301.mat'],'group_compare','-v7.3');
save([savedatapath,'\data_sample_cell_20230301.mat'],'data_sample_cell','-v7.3');
disp('save finished!');
































