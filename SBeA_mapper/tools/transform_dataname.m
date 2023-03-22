%{
    old 4 cameras data to new data
%}
clear all
close all
%% set path and name
groupname = 'group';
videodate = '20230302';
videopath = ['X:\hanyaning\multi_mice_test\Social_analysis\' ...
    'data\group_detect\raw_data\rename_20230301'];
calipathname = ['X:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'group_detect\raw_data\calibrationimages_20230228_1\' ...
    'caliParas.mat'];
%% load videoname list
fileFolder = fullfile(videopath);
dirOutput = dir(fullfile(fileFolder,'*.avi'));
videonames = {dirOutput.name}';
%%
for k = 1:size(videonames,1)
    %% 
    rawname = videonames{k,1};
    splname = split(rawname,'-');
    camidx = split(splname{end},'.');
    newname = ['rec',num2str(splname{2,1}),'-',groupname,'-',...
        videodate,'-camera-',num2str(str2double(camidx{1,1})-1),'.avi'];
    movefile([videopath,'\',rawname],[videopath,'\',newname]);
    %%
    newcaliname = ['rec',num2str(splname{2,1}),'-',groupname,'-',...
        videodate,'-caliParas.mat'];
    if str2double(camidx{1,1}) == 1
        copyfile(calipathname,videopath);
        movefile([videopath,'\caliParas.mat'],[videopath,'\',newcaliname]);
    end
end
