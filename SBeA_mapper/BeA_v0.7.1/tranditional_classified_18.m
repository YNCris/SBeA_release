%{
    using tranditional parameters to classify 18 classes
    unilateral apporach (B to W)
    unilateral apporach (W to B)
    bilateral apporach
    chasing (B to W)
    chasing (W to B)
    unilateral avoidance (B to W)
    unilateral avoidance (W to B)
    bilateral avoidance
    no change

    distance classified (close to far)
%}
clear global
clear
global BeA
data_dim = 3;
genPath = genpath('./');
addpath(genPath)
%% set save path
savepath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'zengyuting_diff_color\data_for_analysis_20220712\unmerge_data\struct'];
%% get filename
filepath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'zengyuting_diff_color\data_for_analysis_20220712\unmerge_data'];
fileFolder = fullfile(filepath);
dirOutput = dir(fullfile(fileFolder,'*.mat'));
fileNames = {dirOutput.name}';
%% get videoname
videopath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'zengyuting_diff_color\data_for_analysis_20220712\unmerge_data'];
videoFolder = fullfile(videopath);
videoOutput = dir(fullfile(videoFolder,'*.mp4'));
videoNames = {videoOutput.name}';
%%
for iData = 1:size(fileNames,1)
    %% Import dataset
    clear global
    global BeA
    data_3d_name = [filepath,'\',fileNames{iData,1}];
    import_3d(data_3d_name);

    %% Import dataset
    video_name = [videopath,'\',videoNames{iData,1}];
    import_video(video_name);
    %%

end