clear global
clear
global BeA
data_dim = 3;
genPath = genpath('./');
addpath(genPath)
%% set save path
savepath = ['Z:\hanyaning\multi_mice_test\' ...
    'Social_analysis\data\zengyuting_diff_color\' ...
    'aggressive_data_20230317\unmerge_data\struct'];
mkdir(savepath)
%% get filename
filepath = ['Z:\hanyaning\multi_mice_test\' ...
    'Social_analysis\data\zengyuting_diff_color\' ...
    'aggressive_data_20230317\unmerge_data'];
fileFolder = fullfile(filepath);
dirOutput = dir(fullfile(fileFolder,'*.mat'));
fileNames = {dirOutput.name}';

%% get videoname
videopath = filepath;
videoFolder = fullfile(videopath);
videoOutput = dir(fullfile(videoFolder,'*.avi'));
videoNames = {videoOutput.name}';

%% Import dataset

for iData = 1:size(fileNames,1)
    %% Import dataset
    clear global
    global BeA
    data_3d_name = [filepath,'\',fileNames{iData,1}];
    import_3d(data_3d_name);

    %% Import dataset
    video_name = [videopath,'\',videoNames{iData,1}];
    import_video(video_name);

    %% Preprocess ->  Artifact Correction
    method = 'median filtering';
    WinWD = 40; %ms

    artifact_correction(method, WinWD);

    %% Aanlysis  -> 1. body alignment
    BA.Cen = 1;
    BA.VA = 1;
    BA.CenIndex = 13;
    BA.VAIndex = 14;
    BA.SDSize = 25;
    BA.SDSDimens = [40,41,42];
    body_alignment(BA);

    %% Aanlysis -> 2. Feature Selection

    body_parts = BeA.DataInfo.Skl;
    nBodyParts = length(body_parts);
    weight = ones(1, nBodyParts);
    featNames = body_parts';
    selection = [1,1,1,1,1,1,1,1,...
                1,1,1,1,1,1,1,1,...
                1,1,1,1,1,1,1,1,...
                1,1,1,1,1,1,1,1,...
                1,1,1,1,0,0,1,1,...
                0,1,0,0,0,0,0,0];

    for i = 1:nBodyParts
        BeA_DecParam.FS(i).featNames = body_parts{i};
        BeA_DecParam.FS(i).weight = weight(i);
    end
    BeA_DecParam.selection = selection;
    %% Aanlysis -> Behavior Decomposing

    % BeA_SegParam.L1
    BeA_DecParam.L1.ralg = 'merge';
    BeA_DecParam.L1.redL = 5;
    BeA_DecParam.L1.calg = 'density';
    BeA_DecParam.L1.kF = 3;% small class get higher performance

    % BeA_SegParam.L2
    BeA_DecParam.L2.kerType = 'g';
    BeA_DecParam.L2.kerBand = 'nei';
    BeA_DecParam.L2.k = 24; % Cluster number
    BeA_DecParam.L2.nMi = 100; % Minimum lengths (ms)
    BeA_DecParam.L2.nMa = 2000; % Maximum lengths (ms)
    BeA_DecParam.L2.Ini = 'p'; % Initialization method

    behavior_decomposing(BeA_DecParam);

    %%
    save([savepath,'\', ...
        fileNames{iData,1}(1,1:(end-4)),'_struct.mat'], 'BeA', '-v7.3')
end

