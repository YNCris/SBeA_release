%{
    rename cut videos
%}
clear all
close all
%% set path and name
videopath = ['C:\Users\19226\Desktop\temp_for_less_save'];
%% load videoname list
fileFolder = fullfile(videopath);
dirOutput = dir(fullfile(fileFolder,'*.avi'));
videonames = {dirOutput.name}';
%%
for k = 1:size(videonames,1)
    %% 
    rawname = videonames{k,1};
    newname = rawname;
    newname((end-21):(end-4)) = [];
    movefile([videopath,'\',rawname],[videopath,'\',newname]);
end
