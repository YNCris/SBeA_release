%{
    2, Behavior segmentation by BeA
%}
clear all
close all
genPath = genpath('./');
addpath(genPath)
%% Set path
c3d_path = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'hcl_bird\sbea_data_20220919\BeA_path'];
save_path = [c3d_path,'\struct'];
mkdir(save_path)
%% run bea
run_batch_main(c3d_path,save_path)





























