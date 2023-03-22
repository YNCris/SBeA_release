%{
    calculate the distance between two mice
%}
clear all
close all
%% set path
gtpath = 'F:\multi_mice_test\Social_analysis\methods_compare\data\gt_data';
savepath = 'F:\multi_mice_test\Social_analysis\methods_compare\data\save_data';
%% load gt
fileFolder = fullfile(gtpath);
dirOutput = dir(fullfile(fileFolder,'*.avi'));
gtvideonames = {dirOutput.name}';
%% compare data
dist_cell = cell(size(gtvideonames,1),2);
for k = 1:size(gtvideonames,1)
    %%
    tempname = gtvideonames{k,1}(1,1:(end-4));
    dist_cell{k,1} = tempname;
    %% load gt data
    single_1_csv = importdata([gtpath,'\single_1_',tempname,'.csv']);
    single_2_csv = importdata([gtpath,'\single_2_',tempname,'.csv']);
    single_1_data = single_1_csv.data;
    single_1_data(:,1) = [];
    single_1_data(:,3:3:end) = [];
    single_2_data = single_2_csv.data;
    single_2_data(:,1) = [];
    single_2_data(:,3:3:end) = [];
    %% calculate distance
    single_1_x = single_1_data(:,1:2:end);
    single_1_y = single_1_data(:,2:2:end);
    single_2_x = single_2_data(:,1:2:end);
    single_2_y = single_2_data(:,2:2:end);
    mean_single_1_x = single_1_x(:,13);
    mean_single_1_y = single_1_y(:,13);
    mean_single_2_x = single_2_x(:,13);
    mean_single_2_y = single_2_y(:,13);
    dist_list = sqrt((mean_single_1_x-mean_single_2_x).^2+(mean_single_1_y-mean_single_2_y).^2);
    dist_cell{k,2} = dist_list;
end
%% save
save([savepath,'\dist_cell.mat'],"dist_cell");
disp('save finished!')