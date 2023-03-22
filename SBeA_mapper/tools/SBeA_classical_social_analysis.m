%{
    classical social analysis
    ref and object mice
%}
clear all
close all
genPath = genpath('./');
addpath(genPath)
%% Set path
BeA_struct_path = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'zengyuting_diff_color\data_for_analysis_20220712\unmerge_data\struct'];
datapath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'zengyuting_diff_color\data_for_analysis_20220712\recluster_data'];
dataname = {'data_sample_cell_20220715.mat'};
savedatapath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'zengyuting_diff_color\data_for_analysis_20220712\recluster_data'];
%% load data
for k = 1:size(dataname,1)
    load([datapath,'\',dataname{k,1}]);
end
%% load social groups
[social_names,temp_unique_names] = load_social_group(BeA_struct_path);
%% parameter calculation, direction vector
dist_dir_cell = cell(size(social_names,1),1);
for iData = 1:size(social_names,1)
    %% Import dataset
    tempdataname = social_names(iData,:);
    BeA_cell = import_BeA_data(BeA_struct_path,tempdataname);
    %% calculate distance
    cent_num = 13;
    cent_list_cell = cell(size(BeA_cell,1),1);
    for m = 1:size(BeA_cell,1)
        cent_list_cell{m,1} = [...
            BeA_cell{m,1}.PreproData.X(:,cent_num),...
            BeA_cell{m,1}.PreproData.Y(:,cent_num),...
            BeA_cell{m,1}.PreproData.Z(:,cent_num)];
    end
    distance_list = sqrt(sum((cent_list_cell{1,1} - cent_list_cell{2,1}).^2,2));
    distance_list = distance_list-min(distance_list);
    dist_list_cell = cell(size(BeA_cell,1),1);
    for m = 1:size(dist_list_cell,1)
        dist_list_cell{m,1} = distance_list;
    end
    %% calculate angle of nose to center
    nose_num = 1;
    nose_list_cell = cell(size(BeA_cell,1),1);
    for m = 1:size(BeA_cell,1)
        nose_list_cell{m,1} = [...
            BeA_cell{m,1}.PreproData.X(:,nose_num),...
            BeA_cell{m,1}.PreproData.Y(:,nose_num),...
            BeA_cell{m,1}.PreproData.Z(:,nose_num)];
    end
    cent_vec_1 = cent_list_cell{2,1}-cent_list_cell{1,1};
    nose_vec_1 = nose_list_cell{1,1}-cent_list_cell{1,1};
    cent_vec_2 = cent_list_cell{1,1}-cent_list_cell{2,1};
    nose_vec_2 = nose_list_cell{2,1}-cent_list_cell{2,1};
    tempangle_1 = vec_angle(cent_vec_1,nose_vec_1);
    tempangle_2 = vec_angle(cent_vec_2,nose_vec_2);
    dir_list_cell = {tempangle_1;tempangle_2};
    %% 
    dist_dir_cell{iData,1} = [dist_list_cell,dir_list_cell];
    disp(iData)
end
%% create dist_dir_data_sample_cell
dist_dir_data_sample_cell = cell(size(data_sample_cell,1),10);
for m = 1:size(social_names,1)
    for n = 1:(size(social_names,2)-1)
        %% select name
        selname = [social_names{m,n+1},'-',social_names{m,1}];
        sel_cell = data_sample_cell(strcmp(data_sample_cell(:,3),selname),:);
        sel_idx = find(strcmp(data_sample_cell(:,3),selname));
        sel_dist_dir = dist_dir_cell{m,1}(n,:);
        %%
        for k = sel_idx'
            start_idx = data_sample_cell{k,2}(1,1);
            end_idx = data_sample_cell{k,2}(1,2);
            dist_dir_data_sample_cell{k,1} = ...
                sel_dist_dir{1,1}(start_idx:end_idx,1);
            dist_dir_data_sample_cell{k,2} = ...
                sel_dist_dir{1,2}(start_idx:end_idx,1);
            dist_dir_data_sample_cell{k,3} = ...
                diff(dist_dir_data_sample_cell{k,1});
        end
    end
end
dist_dir_data_sample_cell(:,4) = cellfun(@(x) x(1),...
    dist_dir_data_sample_cell(:,1), 'UniformOutput', false);
dist_dir_data_sample_cell(:,5) = cellfun(@(x) mean(x),...
    dist_dir_data_sample_cell(:,2), 'UniformOutput', false);
dist_dir_data_sample_cell(:,6) = cellfun(@(x) mean(x),...
    dist_dir_data_sample_cell(:,3), 'UniformOutput', false);
%% find clusters of dist and dir
dist_list_all = cell2mat(dist_dir_data_sample_cell(:,4));
dir_list_all = cell2mat(dist_dir_data_sample_cell(:,5));
d_dist_list_all = cell2mat(dist_dir_data_sample_cell(:,6));
d_dist_list_all(isnan(d_dist_list_all)) = 0;
figure(1)
subplot(311)
hist(dist_list_all,256)
title('dist')
subplot(312)
hist(dir_list_all,256)
title('dir')
subplot(313)
hist(d_dist_list_all,256)
title('d_dist')
clus_dist = [100,400];
clus_dir = [60,120];
clus_d_dist = [-0.1,0.1];
label_dist = {'close','middle','far'};
label_dir = {'face to','body to','back to'};
label_d_dist = {'get close','get still','get far'};
clus_dist = [min(dist_list_all),clus_dist,max(dist_list_all)];
clus_dir = [min(dir_list_all),clus_dir,max(dir_list_all)];
clus_d_dist = [min(d_dist_list_all),clus_d_dist,max(d_dist_list_all)];
dist_idx = (size(clus_dist,2)-1)*ones(size(dist_list_all));
dir_idx = (size(clus_dir,2)-1)*ones(size(dir_list_all));
d_dist_idx = (size(clus_d_dist,2)-1)*ones(size(d_dist_list_all));
for k = 1:(size(clus_dist,2)-1)
    start_pos = clus_dist(1,k);
    end_pos = clus_dist(1,k+1);
    dist_idx((dist_list_all>=start_pos)&(dist_list_all<end_pos),:) = k;
end
for k = 1:(size(clus_dir,2)-1)
    start_pos = clus_dir(1,k);
    end_pos = clus_dir(1,k+1);
    dir_idx((dir_list_all>=start_pos)&(dir_list_all<end_pos),:) = k;
end
for k = 1:(size(clus_d_dist,2)-1)
    start_pos = clus_d_dist(1,k);
    end_pos = clus_d_dist(1,k+1);
    d_dist_idx((d_dist_list_all>=start_pos)&(d_dist_list_all<end_pos),:) = k;
end
figure(2)
subplot(131)
plot(sort(dist_idx))
title('dist')
subplot(132)
plot(sort(dir_idx))
title('dir')
subplot(133)
plot(sort(d_dist_idx))
title('d_dist')
dist_dir_data_sample_cell(:,7) = num2cell(dist_idx);
dist_dir_data_sample_cell(:,8) = num2cell(dir_idx);
dist_dir_data_sample_cell(:,9) = num2cell(d_dist_idx);
for k = 1:size(dist_dir_data_sample_cell,1)
    dist_dir_data_sample_cell{k,10} = [...
        label_dist{dist_dir_data_sample_cell{k,7}},'-',...
        label_dir{dist_dir_data_sample_cell{k,8}},'-',...
        label_d_dist{dist_dir_data_sample_cell{k,9}}];
end
figure(3)
hist(categorical(dist_dir_data_sample_cell(:,10)))
%% merge classes
single_idx = cell2mat(data_sample_cell(:,2));
single_idx = single_idx(:,4);
all_idx = dist_idx + dir_idx*10 + d_dist_idx*100 + single_idx*1000;
unique_all_idx = unique(all_idx);
%% save
save([savedatapath,'\dist_dir_data_sample_cell.mat'],'dist_dir_data_sample_cell');
disp('save successful!')



































