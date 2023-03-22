%{
    merge cluster videos of sbea
%}
clear all
close all
%% set path
rawvideopath = ['Z:\hanyaning\multi_mice_test\Social_analysis\' ...
    'data\shank3_wt\sbea_data_20221108\BeA_path\' ...
    'recluster_data\sbeapath_20230107_watershed'];
%% process
%% get first folder
fileFolder = fullfile(rawvideopath);
dirOutput = dir(fullfile(fileFolder,'*'));
foldernames_1 = {dirOutput.name}';
foldernames_1(1:2,:) = [];
sel_much = [1,2,3,4,5,7,9,48,70,75,78,92,93,175,182,195,196,...
    201,205,227,239,243,244,258];
parfor k = 1:length(sel_much)
    %% 
    first_folder_name = [rawvideopath,'\',num2str(sel_much(k))];
    fileFolder = fullfile(first_folder_name);
    dirOutput = dir(fullfile(fileFolder,'*'));
    foldernames_2 = {dirOutput.name}';
    foldernames_2(1:2,:) = [];
    %% merge videos
    writeobj = VideoWriter([first_folder_name,'.avi']);
    open(writeobj)
    for m = 1:size(foldernames_2,1)
        %%
        second_name = [first_folder_name,'\',...
            foldernames_2{m}];
        %%
        try
            vidobj = VideoReader(second_name);
            for p = 1:vidobj.NumFrames
                frame = read(vidobj,p);
                writeVideo(writeobj,frame)
            end
        catch
            disp('error video!')
        end
        disp(second_name)
    end
    close(writeobj)
    disp(k)
end