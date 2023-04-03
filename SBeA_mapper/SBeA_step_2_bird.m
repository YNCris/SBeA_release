%{
    2, Behavior segmentation by BeA
%}
clear all
close all
genPath = genpath('./');
addpath(genPath)
%% Set path
c3d_path = ['Your path of *\BeA_path of step_1'];
save_path = [c3d_path,'\struct'];
mkdir(save_path)
%% set config_bea
config_bea.BeA.DataInfo.Skl = {'beak';'calvaria';'left_eye';...
    'right_eye';'neck';'left_wing_root';'left_wing_mid';'left_wing_tip';...
    'right_wing_root';'right_wing_mid';'right_wing_tip';'left_leg_root';...
    'left_leg_tip';'right_leg_root';'right_leg_tip';'back';...
    'belly';'tail_root';'tail_tip'...
};

config_bea.method = 'median filtering';
config_bea.WinWD = 1000; %ms

config_bea.BA.Cen = 1;
config_bea.BA.VA = 1;
config_bea.BA.CenIndex = 16;
config_bea.BA.VAIndex = 18;
config_bea.BA.SDSize = 25;
config_bea.BA.SDSDimens = [46,47,48];

config_bea.selection = [1,1,1,1,1,1,1,1,1,1,...
                        1,1,1,1,1,1,1,1,1,1,...
                        1,1,1,1,1,1,1,1,1,1,...
                        1,1,1,1,1,1,1,1,1,1,...
                        1,1,1,1,1,0,0,1,1,1,...
                        1,1,0,1,1,1,1];
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





























