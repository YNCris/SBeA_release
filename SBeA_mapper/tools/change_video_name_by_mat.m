%{
    change video name according to .mat
%}
clear all
close all
%% set path
rootpath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'zengyuting_diff_color\data_for_analysis_20220712\unmerge_data'];
%% get mat
fileFolder = fullfile(rootpath);
dirOutput = dir(fullfile(fileFolder,'*.mat'));
matnames = {dirOutput.name}';
%% get mp4
fileFolder = fullfile(rootpath);
dirOutput = dir(fullfile(fileFolder,'*.mp4'));
videonames = {dirOutput.name}';
%% process
for k = 1:size(matnames,1)
    %% sep mat name
    splmatname = split(matnames{k,1},{'-','N','.'});
    %% find same
    for m = 1:size(videonames,1)
        %%
        splvideoname = split(videonames{m,1},{'-','_'});
        %% cmp
        if strcmp(splmatname{1,1},splvideoname{8,1}) & ...
                strcmp(splmatname{3,1},splvideoname{2,1})
            newvideoname = [splmatname{1,1},'-',...
                splmatname{2,1},'N',...
                splmatname{3,1},'.mp4'];
            movefile([rootpath,'\',videonames{m,1}],[rootpath,'\',newvideoname]);
            break;
        end
    end
end