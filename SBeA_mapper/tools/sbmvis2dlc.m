%{
    transfer sbmvis data to deeplabcut data
%}
clear all
close all
%% set path and parameters
dlcimgpath = 'G:\multi_mice_test\Social_analysis\methods_compare\envs\SBeA_cmp-HYN-2022-05-05\labeled-data';
vispath = 'G:\multi_mice_test\Social_analysis\methods_compare\data\raw_videos\train';
datalength = 200;
%% load namelist
fileFolder = fullfile(dlcimgpath);
dirOutput = dir(fullfile(fileFolder,'train*'));
dlcnames = {dirOutput.name}';
%%
for k = 1:size(dlcnames,1)
    %%
    tempname = dlcnames{k,1};
    %% load h5
%     info = h5info([dlcimgpath,'\',tempname,'\CollectedData_HYN.h5']);
    h5data = h5read([dlcimgpath,'\',tempname,'\CollectedData_HYN.h5'],'/df_with_missing/block0_values');
    h5disp(([dlcimgpath,'\',tempname,'\CollectedData_HYN.h5']))
    %% load csv
    csvdata = importfile([dlcimgpath,'\',tempname,'\CollectedData_HYN.csv'],[1,inf]);
    %% load single csv
    single_1_csvdata = importdata([vispath,'\single_1_',tempname,'.csv']);
    single_2_csvdata = importdata([vispath,'\single_2_',tempname,'.csv']);
    %% load img idx
    img_idx = table2array(csvdata(5:(datalength+5-1),3))+1;
    %% cas single 1 2
    casdata1 = single_1_csvdata.data;
    casdata2 = single_2_csvdata.data;
    casdata1(:,1:3:end) = [];
    casdata2(:,1:3:end) = [];
    casdata = [casdata1,casdata2];
%     %% temp cmp
%     templabel = table2array(csvdata(5,4:end));
%     rawlabel = casdata(1,:);
%     sublabel = abs(rawlabel-templabel);
    %% create new h5data
    new_h5data = h5data;
    new_h5data(:,1:datalength) = casdata(img_idx,:)';
    %% create new csvdata
    new_csvdata = casdata(img_idx,:);
    %% save h5data
    h5write([dlcimgpath,'\',tempname,'\CollectedData_HYN.h5'],'/df_with_missing/block0_values',new_h5data);
    %%
    disp(k)
end
