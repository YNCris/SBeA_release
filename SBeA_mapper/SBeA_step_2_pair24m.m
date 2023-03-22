%{
    2, Behavior segmentation by BeA
%}
clear all
close all
genPath = genpath('./');
addpath(genPath)
%% Set path
c3d_path = ['Z:\hanyaning\multi_mice_test\Social_analysis\' ...
    'data\sbea_validation\sbea_20221114'];
save_path = [c3d_path,'\struct'];
mkdir(save_path)
%% set config_bea
config_bea.BeA.DataInfo.Skl = {
    'HeadF';
    'HeadB';
    'HeadL';
    'SpineF';
    'SpineM';
    'SpineL';
    'Offset1';
    'Offset2';
    'HipL';
    'HipR';
    'ShoulderL';
    'ShoulderR'
};

config_bea.method = 'median filtering';
config_bea.WinWD = 1000; %ms

config_bea.BA.Cen = 1;
config_bea.BA.VA = 1;
config_bea.BA.CenIndex = 5;
config_bea.BA.VAIndex = 6;
config_bea.BA.SDSize = 25;
config_bea.BA.SDSDimens = [16,17,18];

config_bea.selection = [1,1,1,1,1,1,...
                        1,1,1,1,1,1,...
                        1,1,1,1,1,1,...
                        1,1,1,1,1,1,...
                        1,1,1,1,1,1,...
                        1,1,1,1,1,1];
config_bea.BeA_DecParam.L1.ralg = 'merge';
config_bea.BeA_DecParam.L1.redL = 5;
config_bea.BeA_DecParam.L1.calg = 'density';
config_bea.BeA_DecParam.L1.kF = 96;

config_bea.BeA_DecParam.L2.kerType = 'g';
config_bea.BeA_DecParam.L2.kerBand = 'nei';
config_bea.BeA_DecParam.L2.k = 24; % Cluster number
config_bea.BeA_DecParam.L2.nMi = 100; % Minimum lengths (ms)
config_bea.BeA_DecParam.L2.nMa = 2000; % Maximum lengths (ms)
config_bea.BeA_DecParam.L2.Ini = 'p'; % Initialization method
%% set bea
run_batch_main(c3d_path,save_path,config_bea)



























