clear all
close all
%% set path
videopath = 'Z:\hanyaning\multi_mice_test\Social_analysis\data\disc1_shank3\SBeA_data_20220602\temp';
fileFolder = fullfile(videopath);
dirOutput = dir(fullfile(fileFolder,'*.avi'));
videonames = {dirOutput.name}';
%% load frames
frame_list = zeros(size(videonames,1),1);
for k = 1:size(frame_list,1)
    vidobj = VideoReader([videopath,'\',videonames{k,1}]);
    frame_list(k,1) = vidobj.NumFrames;
end