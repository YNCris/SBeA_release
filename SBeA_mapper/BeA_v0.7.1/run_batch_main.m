function run_batch_main(c3d_path,save_path,config_bea)
    data_dim = 3;
    genPath = genpath('./');
    addpath(genPath)
    %% set save path
    savepath = save_path;
    %% get filename
    filepath = c3d_path;
    fileFolder = fullfile(filepath);
    dirOutput = dir(fullfile(fileFolder,'*.mat'));
    fileNames = {dirOutput.name}';
    
    %% get videoname
    videopath = c3d_path;
    videoFolder = fullfile(videopath);
    videoOutput = dir(fullfile(videoFolder,'*.avi'));
    videoNames = {videoOutput.name}';
    
    %% Import dataset
    for iData = 1:size(fileNames,1)
        %% Import dataset
        close all
        clear global
        global BeA
        data_3d_name = [filepath,'\',fileNames{iData,1}];
        import_3d(data_3d_name);
        BeA.DataInfo.Skl = config_bea.BeA.DataInfo.Skl;
        BeA.DataInfo.config_bea = config_bea;
        %% Import dataset
        video_name = [videopath,'\',videoNames{iData,1}];
        import_video(video_name);
    
        %% Preprocess ->  Artifact Correction
        method = config_bea.method;
        WinWD = config_bea.WinWD; %ms
    
        artifact_correction(method, WinWD);
    
        %% Aanlysis  -> 1. body alignment
        BA.Cen = config_bea.BA.Cen;
        BA.VA = config_bea.BA.VA;
        BA.CenIndex = config_bea.BA.CenIndex;
        BA.VAIndex = config_bea.BA.VAIndex;
        BA.SDSize = config_bea.BA.SDSize;
        BA.SDSDimens = config_bea.BA.SDSDimens;
        body_alignment(BA);
    
        %% Aanlysis -> 2. Feature Selection
    
        body_parts = BeA.DataInfo.Skl;
        nBodyParts = length(body_parts);
        weight = ones(1, nBodyParts);
        featNames = body_parts';
        selection = config_bea.selection;
    
        for i = 1:nBodyParts
            BeA_DecParam.FS(i).featNames = body_parts{i};
            BeA_DecParam.FS(i).weight = weight(i);
        end
        BeA.BeA_DecParam.selection = selection;
        %% Aanlysis -> Behavior Decomposing
    
        % BeA_SegParam.L1
        BeA.BeA_DecParam.L1.ralg = config_bea.BeA_DecParam.L1.ralg;
        BeA.BeA_DecParam.L1.redL = config_bea.BeA_DecParam.L1.redL;
        BeA.BeA_DecParam.L1.calg = config_bea.BeA_DecParam.L1.calg;
        BeA.BeA_DecParam.L1.kF = config_bea.BeA_DecParam.L1.kF;
    
        % BeA_SegParam.L2
        BeA.BeA_DecParam.L2.kerType = config_bea.BeA_DecParam.L2.kerType;
        BeA.BeA_DecParam.L2.kerBand = config_bea.BeA_DecParam.L2.kerBand;
        BeA.BeA_DecParam.L2.k = config_bea.BeA_DecParam.L2.k; % Cluster number
        BeA.BeA_DecParam.L2.nMi = config_bea.BeA_DecParam.L2.nMi; % Minimum lengths (ms)
        BeA.BeA_DecParam.L2.nMa = config_bea.BeA_DecParam.L2.nMa; % Maximum lengths (ms)
        BeA.BeA_DecParam.L2.Ini = config_bea.BeA_DecParam.L2.Ini; % Initialization method
    
        behavior_decomposing(BeA.BeA_DecParam);
    
        %%
        save([savepath,'\', ...
            fileNames{iData,1}(1,1:(end-4)),'_struct.mat'], 'BeA', '-v7.3')
    end

