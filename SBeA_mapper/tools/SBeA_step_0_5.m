%{
    0.5. Social behavior reclustering
%}
clear all
close all
genPath = genpath('./');
addpath(genPath)
%% Set path
SBeA_struct_path = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'zengyuting_diff_color\data_for_analysis\unmerge_data\social_struct'];
save_path = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'zengyuting_diff_color\data_for_analysis\recluster_data'];
videopath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'zengyuting_diff_color\data_for_analysis\unmerge_data'];
%% get all SBeA structs
fileFolder = fullfile(SBeA_struct_path);
dirOutput = dir(fullfile(fileFolder,'*.mat'));
fileNames = {dirOutput.name}';
%% load data
load_flag = true;%load data flag
[speed_cell,dist_body_cell,dist_n2n_cell,dist_n2a_cell,dist_a2n_cell,...
    segdata_cell,ReMap_cell,Seglist_cell,fs] = ...
    load_recluster_data(SBeA_struct_path,fileNames,save_path,load_flag);
%% create savelist
savelist_cell = recluster_savelist(Seglist_cell,ReMap_cell);
%% create data_sample_cell
data_sample_cell = init_data_sample_cell(savelist_cell,segdata_cell,speed_cell,...
    dist_body_cell,dist_n2n_cell,dist_n2a_cell,dist_a2n_cell,fileNames);
%% calculate dtak
sigma = 30;
dist_mat_all = calculate_dtak(data_sample_cell,sigma);
%% reclustering
show_flag = true;
data_sample_cell = recluster_SBeA(dist_mat_all,data_sample_cell,show_flag);
%% save data_sample_cell and distmatall
save([save_path,'\SBeA_data_sample_cell_20220526.mat'],'data_sample_cell');
save([save_path,'\SBeA_dist_mat_all_20220526.mat'],'dist_mat_all');
%% cut videos
savevideopath = [save_path,'\sbeapath_20220526'];
mkdir(savevideopath);
savelist = cell2mat(data_sample_cell(:,2));
unique_class = unique(savelist(:,4));
for k = 1:size(unique_class,1)
    temp1 = unique_class(k,1);
    mkdir([savevideopath,'\',num2str(temp1)])
end
%% calculate CQI
CQI = calClus_qulity_fast(dist_mat_all, savelist(:,4));
%% cut
fileFolder = fullfile(videopath);
dirOutput = dir(fullfile(fileFolder,'*.mp4'));
videonames = {dirOutput.name}';
for k = 1:size(fileNames,1)
    %% load videos
    splname = split(fileNames{k,1},'_');
    a1_name = splname{1,1};
    a2_name = splname{2,1};
    all_name = splname{3,1};
    vidobj1 = VideoReader([videopath,'\',a1_name,'-',all_name,'.mp4']);
    vidobj2 = VideoReader([videopath,'\',a2_name,'-',all_name,'.mp4']);
    %% get sub_data_sample_cell
    sub_data_sample_cell = data_sample_cell(strcmp(data_sample_cell(:,3),fileNames{k,1}),:);
    sub_CQI = CQI(1,strcmp(data_sample_cell(:,3),fileNames{k,1}));
    %% write videos
    for m = 1:size(sub_data_sample_cell,1)
        %%
        tempstartframe = sub_data_sample_cell{m,2}(1,1);
        tempendframe = sub_data_sample_cell{m,2}(1,2);
        temp1 = num2str(sub_data_sample_cell{m,2}(1,4));
        temp2 = sub_data_sample_cell{m,3}(1,1:(end-4));
        temp3 = num2str(sub_data_sample_cell{m,2}(1,3));
        temp4 = num2str(sub_CQI(1,m),'%4.2f');
        writeobj = VideoWriter([savevideopath,'\',temp1,'\',temp4,'_',temp2,'_',temp3,'_',...
                num2str(tempstartframe),'_',num2str(tempendframe),'.avi']);
            writeobj.FrameRate = vidobj1.FrameRate;
        open(writeobj);
        for n = tempstartframe:tempendframe
            frame1 = read(vidobj1,n);
            frame2 = read(vidobj2,n);
            writeVideo(writeobj,uint8((double(frame1)+double(frame2))/2));
        end
        close(writeobj);
        pause(1)
        disp('write idx')
        disp(m);
    end
    disp(k);
end
















