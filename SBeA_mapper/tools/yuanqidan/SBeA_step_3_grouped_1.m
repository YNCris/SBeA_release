%{
    3. Social behavior segmentation
%}
clear all
close all
genPath = genpath('./');
addpath(genPath)
%% Set path
rootpath = ['Z:\hanyaning\multi_mice_test\Social_analysis\' ...
    'data\shank3_wt\sbea_data_20221108\BeA_path'];
BeA_struct_path = [rootpath,'\struct'];
save_path = [rootpath,'\social_struct'];
mkdir(save_path)
%% load social groups
s_num = 1;
sel_idx = ((s_num-1)*6+1):(s_num*6);
[social_names,temp_unique_names] = load_social_group(BeA_struct_path);
social_names = [social_names;
    [social_names(:,1),social_names(:,3),social_names(:,2)]];
social_names = social_names(sel_idx,:);
%% Social behavior segmentation
for iData = 1:size(social_names,1)
    %% Import dataset
    tempdataname = social_names(iData,:);
    BeA_cell = import_BeA_data(BeA_struct_path,tempdataname);
    %% create SBeA struct
    clear global
    global SBeA
    create_SBeA(social_names,BeA_struct_path,BeA_cell);
    %% Social behavior decomposition
    social_behavior_decomposing(SBeA);
    %% Save data
    save([save_path,'\', tempdataname{2},'_',tempdataname{3},...
        '_',tempdataname{1}(1,1:(end-11)),'_social_struct.mat'], 'SBeA', '-v7.3')
    disp(iData)
end























