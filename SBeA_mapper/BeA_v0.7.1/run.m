clear all
genPath = genpath('./');
addpath(genPath)

%% get filename
filepath = 'Z:\hanyaning\mulldling_data_analysis\liunan_analysis\datapath20201205';
fileName = 'anx-seg-1.mat';

%% get videoname
videopath = 'Z:\hanyaning\mulldling_data_analysis\liunan_analysis\datapath20201205';
videoName = 'anx-seg-1.avi';

%% Import dataset
clear global
global BeA
data_3d_name = [filepath,'\',fileName];
import_3d(data_3d_name);

%% Import dataset
video_name = [videopath,'\',videoName];
import_video(video_name);

%% Preprocess ->  Artifact Correction
method = 'median filtering';
WinWD = 1000; %ms

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
BeA_DecParam.L1.kF = 96;

% BeA_SegParam.L2
BeA_DecParam.L2.kerType = 'g';
BeA_DecParam.L2.kerBand = 'nei';
BeA_DecParam.L2.k = 24; % Cluster number
BeA_DecParam.L2.nMi = 100; % Minimum lengths (ms)
BeA_DecParam.L2.nMa = 2000; % Maximum lengths (ms)
BeA_DecParam.L2.Ini = 'p'; % Initialization method

behavior_decomposing(BeA_DecParam);


    

