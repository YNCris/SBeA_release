%{
    cut videos for less memory cost
%}
clear all
close all

%% set path and name
videopath = ['G:\multi_mice_test\paper\Nature Methods\' ...
    'SBeA_upload_data_less_than_20G\fig6_data\dog\id'];
savepath = 'C:\Users\19226\Desktop\temp_for_less_save';
start_frame = 1;
end_frame = 900;
%% load videoname list
fileFolder = fullfile(videopath);
dirOutput = dir(fullfile(fileFolder,'*.avi'));
videonames = {dirOutput.name}';
%%
parfor k = 1:size(videonames,1)
    %% 
   vidobj = VideoReader([videopath,'\',videonames{k,1}]);
   writeobj = VideoWriter([savepath,'\',videonames{k,1}]);
   open(writeobj)
   for m = start_frame:end_frame
        frame = read(vidobj,m);
        writeVideo(writeobj,frame)
   end
   disp(k)
   close(writeobj)
end