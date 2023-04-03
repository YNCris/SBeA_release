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
config_bea.BeA.DataInfo.Skl = {'nose';'left_ear';'right_ear';'neck';...
                            'left_front_limb';'right_front_limb';...
                            'left_hind_limb';'right_hind_limb';...
                            'left_front_claw';'right_front_claw';...
                            'left_hind_claw';'right_hind_claw';...
                            'back';'root_tail';'mid_tail';'tip_tail'};

config_bea.method = 'median filtering';
config_bea.WinWD = 1000; %ms

config_bea.BA.Cen = 1;
config_bea.BA.VA = 1;
config_bea.BA.CenIndex = 13;
config_bea.BA.VAIndex = 14;
config_bea.BA.SDSize = 25;
config_bea.BA.SDSDimens = [40,41,42];

config_bea.selection = [1,1,1,1,1,1,1,1,...
                        1,1,1,1,1,1,1,1,...
                        1,1,1,1,1,1,1,1,...
                        1,1,1,1,1,1,1,1,...
                        1,1,1,1,0,0,1,1,...
                        0,1,0,0,0,0,0,0];
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





























