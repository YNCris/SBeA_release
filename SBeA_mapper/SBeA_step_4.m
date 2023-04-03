%{
    4 Social behavior reclustering, separate 3 dimensions, LDE in 2D by UMAP;
    using watershed clustering, visulizing the representation features in 2D embedding
%}
clear all
close all
genPath = genpath('./');
addpath(genPath)
%% Set path
rootpath = ['Your path of *\BeA_path of step_1'];
SBeA_struct_path = [rootpath, '\social_struct'];
save_path = [rootpath, '\recluster_data'];
videopath = rootpath;
cutvideoname = ['Your path to save cut videos'];
mkdir(save_path)
%% get all SBeA structs
fileFolder = fullfile(SBeA_struct_path);
dirOutput = dir(fullfile(fileFolder,'*.mat'));
fileNames = {dirOutput.name}';
%% load data
load_flag = true;%load data flag
[ReMap_move_cell,Seglist_move_cell,...
    ReMap_speed_cell,Seglist_speed_cell,...
    ReMap_dist_cell,Seglist_dist_cell,fs,...
    data_move_cell,data_speed_cell,data_dist_cell] = ...
    load_recluster_data_3(SBeA_struct_path,fileNames,save_path,load_flag);
%% create savelist
savelist_cell = recluster_savelist_3(...
    ReMap_move_cell,Seglist_move_cell,...
    ReMap_speed_cell,Seglist_speed_cell,...
    ReMap_dist_cell,Seglist_dist_cell);
%% create data_sample_cell
[data_sample_cell,net,info] = init_data_sample_cell_3_big_data_dl(...
    savelist_cell,data_move_cell,data_speed_cell,...
    data_dist_cell,fileNames);
%% calculate dtak
sigma = 1;% big sigma is important, if only the data have higher dimensions
extract_len = 2000;
dist_mat_all = calculate_dtak_distance_big_data(data_sample_cell(:,1),...
    sigma,extract_len);
imagesc(dist_mat_all)
%% reclustering
show_flag = true;
[data_sample_cell,wc_struct] = recluster_SBeA_wc(dist_mat_all,data_sample_cell,show_flag);
%% calculate speed map
figure
zscore_embed = cell2mat(data_sample_cell(:,4));
speedlist = medfilt1(cellfun(@(x) mean(sqrt(x(1,:).^2+x(2,:).^2)),data_sample_cell(:,6)),30);
normspeedlist = round(mat2gray(speedlist)*255+1);
cmap = jet(256);
cmaplist = cmap(normspeedlist,:);
scatter(zscore_embed(:,1),zscore_embed(:,2),10*ones(size(zscore_embed,1),1),cmaplist,'filled');
axis square
title('speed map')
%% calculate dist map
figure
distlist = medfilt1(cellfun(@(x) min(x(:)),data_sample_cell(:,7)),3);
normdistlist = round(mat2gray(distlist)*255+1);
cmap = turbo(256);
cmaplist = cmap(normdistlist,:);
scatter(zscore_embed(:,1),zscore_embed(:,2),10*ones(size(zscore_embed,1),1),cmaplist,'filled');
axis square
title('dist map')
%% save data_sample_cell and distmatall
save([save_path,'\Your name to save data_sample_cell.mat'],'data_sample_cell');
save([save_path,'\Your name to save dist_mat_all.mat'],'dist_mat_all','-v7.3');
save([save_path,'\Your name to save wc_struct.mat'],'wc_struct');
%% cut videos
cut_videos(save_path,cutvideoname,data_sample_cell,dist_mat_all,videopath)

































