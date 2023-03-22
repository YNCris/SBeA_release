%{
    separate full length data to small segments
%}
clear all
close all
%% set path and parameters
sep_time = 300;% seconds
fs = 30;
raw_data_path = 'Z:\hanyaning\multi_mice_test\Social_analysis\data\MTPM_social_20220228_all\behavior_data';
outputpath = 'Z:\hanyaning\multi_mice_test\Social_analysis\data\MTPM_social_20220228_all\behavior_data_cut';
%% get data
fileFolder = fullfile(raw_data_path);
dirOutput = dir(fullfile(fileFolder,'*.avi'));
videonames = {dirOutput.name}';
%% process
for k = 1:size(videonames,1)
    %%
    tempname = videonames{k,1}(1,1:(end-4));
    %% load video
    vidobj = VideoReader([raw_data_path,'\',tempname,'.avi']);
    %% load mat
    tempmat = load([raw_data_path,'\',tempname,'.mat']);
    %% sep data
    numFrames = vidobj.NumFrames;
    sep_frames = sep_time*fs;
    if rem(numFrames,sep_frames) == 0
        seglist = zeros(numFrames/sep_frames,2);
        for m = 1:size(seglist,1)
            seglist(m,1) = (m-1)*sep_frames+1;
            seglist(m,2) = m*sep_frames;
        end
    else
        seglist = zeros((numFrames/sep_frames)+1,2);
        for m = 1:(size(seglist,1)-1)
            seglist(m,1) = (m-1)*sep_frames+1;
            seglist(m,2) = m*sep_frames;
        end
        seglist(end,1) = seglist(end-1,2)+1;
        seglist(end,2) = rem(numFrames,sep_frames);
    end
    %%
    disp(tempname)
    disp(k)
    for m = 1:size(seglist,1)
        %%
        disp(m)
        start_pos = seglist(m,1);
        end_pos = seglist(m,2);
        %%
        writeobj = VideoWriter([outputpath,'\',...
            tempname,'-',num2str(m),'.avi']);
        open(writeobj)
        %%
        for n = start_pos:end_pos
            frame = read(vidobj,n);
            writeVideo(writeobj,frame);
        end
        close(writeobj)
        %%
        coords3d = tempmat.coords3d(start_pos:end_pos,:);
        save([outputpath,'\',tempname,'-',num2str(m),'.mat'],'coords3d')
    end
end































