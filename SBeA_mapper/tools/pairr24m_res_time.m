%{
    pairr24m dataset resize time
%}
clear all
close all
%% set path
rawpath = 'Z:\hanyaning\multi_mice_test\Social_analysis\data\sbea_validation\sbea_20221114';
savepath = [rawpath,'\res_data'];
mkdir(savepath)
%% get data
fileFolder = fullfile(rawpath);
dirOutput = dir(fullfile(fileFolder,'*.mat'));
filenames = {dirOutput.name}';
%%
for k = 1:size(filenames,1)
    %%
    tempname = filenames{k,1}(1,1:(end-4));
    %% load data and videos
    tempdata = load([rawpath,'\',tempname,'.mat']);
%     vidobj = VideoReader([rawpath,'\',tempname,'.avi']);
    %% res 3D
    coords3d = tempdata.coords3d(1:4:end,:);
    save([savepath,'\',tempname,'.mat'],'coords3d')
    disp(k)
end
%%
parfor k = 1:size(filenames,1)
    %%
    tempname = filenames{k,1}(1,1:(end-4));
    %% load data and videos
%     tempdata = load([rawpath,'\',tempname,'.mat']);
    vidobj = VideoReader([rawpath,'\',tempname,'.avi']);
    %% res video
    writeobj = VideoWriter([savepath,'\',tempname,'.avi']);
    open(writeobj)
    for m = 1:4:vidobj.NumFrames
        writeVideo(writeobj,read(vidobj,m))
        if rem(m,1000) == 0
            disp([num2str(k),': ',num2str(m)])
        end
    end
    close(writeobj)
    disp(k)
end