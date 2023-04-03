%{
    3. Social behavior segmentation
%}
clear all
close all
genPath = genpath('./');
addpath(genPath)
%% Set path
rootpath = ['Your path of *\BeA_path of step_1'];
BeA_struct_path = [rootpath,'\struct'];
save_path = [rootpath,'\social_struct'];
mkdir(save_path)
%% load social groups
[social_names,temp_unique_names] = load_social_group(BeA_struct_path);
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























