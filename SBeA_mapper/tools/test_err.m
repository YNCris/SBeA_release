%{
    test err of 3d reconstruction
%}
clear all
genPath = genpath('./');
addpath(genPath)
%% set path

%% get filename
filepath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'disc1_shank3\SBeA_data_20220602'];
fileName = 'rec9-B3R7-20220606-raw3d.mat';