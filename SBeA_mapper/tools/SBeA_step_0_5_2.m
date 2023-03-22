%{
    0.5. Social behavior reclustering, separate 3 dimensions
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
data_sample_cell = init_data_sample_cell_3(savelist_cell,...
    data_move_cell,data_speed_cell,data_dist_cell,fileNames);
%% calculate dtak
sigma = 3;
dist_mat_all = calculate_dtak(data_sample_cell,sigma);
%% reclustering
show_flag = true;
data_sample_cell = recluster_SBeA_3(dist_mat_all,data_sample_cell,show_flag);
%% save data_sample_cell and distmatall
save([save_path,'\SBeA_data_sample_cell_20220531.mat'],'data_sample_cell');
save([save_path,'\SBeA_dist_mat_all_20220531.mat'],'dist_mat_all');
%% cut videos
savevideopath = [save_path,'\sbeapath_20220531_hier_cluster'];
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
raw_embed = cell2mat(data_sample_cell(:,4));
tempT = cell2mat(data_sample_cell(:,2));
T = tempT(:,4);
best_label_embedding = [raw_embed,T];
cmaplist3 = best_label_embedding(:,3);
cmapcolor3 = imresize(jet,[length(unique(cmaplist3)),3]);
cmap3 = zeros(size(cmaplist3,1),3);
for k = 1:size(cmap3,1)
    cmap3(k,:) = cmapcolor3(cmaplist3(k,1),:);
end
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
    temph = figure(1);
    set(temph,'Position',[50,50,1800,800])
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

        show_class = sub_data_sample_cell{m,2}(1,4);
        show_idx = sub_data_sample_cell{m,2}(1,3);
        show_point = best_label_embedding(show_idx,1:2);
        show_class_points_idx = best_label_embedding(:,3)==show_class;
        show_class_points_c = cmap3;
        show_class_points_c(show_class_points_idx~=1,:) = ...
            ones(sum(show_class_points_idx~=1),1)*[0.25,0.25,0.25];
        subplot(122)
        scatter(best_label_embedding(:,1),best_label_embedding(:,2),...
            10*ones(size(best_label_embedding(:,1))),show_class_points_c,'filled');
        hold on
        plot(show_point(1),show_point(2),'g+','MarkerSize',10)
        hold off
        axis square
        title(['class idx: ',temp1])
        for n = tempstartframe:tempendframe
            frame1 = read(vidobj1,n);
            frame2 = read(vidobj2,n);
            sumframe = uint8((double(frame1)+double(frame2))/2);
            subplot(121)
            imshow(sumframe)

            saveframe = getframe(temph);
            writeVideo(writeobj,saveframe.cdata);
        end
        close(writeobj);
        pause(1)
        disp('write idx')
        disp(m);
    end
    disp(k);
end
















