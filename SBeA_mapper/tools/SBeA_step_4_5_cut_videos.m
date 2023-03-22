%{
    4.5: cut videos
%}
clear all
close all
genPath = genpath('./');
addpath(genPath)
%% Set path
rootpath = ['Z:\hanyaning\multi_mice_test\Social_analysis\' ...
    'data\shank3_wt\sbea_data_20221108\BeA_path'];
SBeA_struct_path = [rootpath, '\social_struct'];
save_path = [rootpath, '\recluster_data'];
videopath = rootpath;
cutvideoname = 'sbeapath_20230107_watershed';
%% load data
load([save_path,'\SBeA_data_sample_cell_20221209.mat']);
load([save_path,'\SBeA_dist_mat_all_20221209.mat']);
%% cut videos
cut_videos_much(save_path,cutvideoname,data_sample_cell,dist_mat_all,videopath)
































