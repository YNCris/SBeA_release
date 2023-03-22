%{
    3. Social behavior segmentation
%}
clear all
close all
genPath = genpath('./');
addpath(genPath)
%% Set path
rootpath = ['Z:\hanyaning\multi_mice_test\' ...
    'Social_analysis\data\disc1_shank3\SBeA_data_20220822\BeA_no_dist_path'];
BeA_struct_path = [rootpath,'\struct'];
save_path = ['Z:\hanyaning\multi_mice_test\Social_analysis\' ...
    'data\figs\fig4\panel_6\social_struct'];
mkdir(save_path)
%% load social groups
[social_names,temp_unique_names] = load_social_group(BeA_struct_path,'.mat');
%% Social behavior segmentation
for iData = 1:size(social_names,1)
    %% Import dataset
    tempdataname = social_names(iData,:);
    BeA_cell = import_BeA_data(BeA_struct_path,tempdataname);
    %% create SBeA struct
    clear global
    global SBeA
    create_SBeA_big_data(social_names,BeA_struct_path,BeA_cell);
    %% Social behavior decomposition
%     social_behavior_decomposing_big_data(SBeA);
    social_behavior_decomposing_big_data_no_dist(SBeA);
    %% Save data
    save([save_path,'\', tempdataname{2},'_',tempdataname{3},...
        '_',tempdataname{1}(1,1:(end-11)),'_social_struct.mat'], 'SBeA', '-v7.3')
    disp(iData)
end























