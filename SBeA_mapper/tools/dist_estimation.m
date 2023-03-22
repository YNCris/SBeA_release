%{
    distribution estimation
%}
clear all
close all
genPath = genpath('./');
addpath(genPath)
%% set path
datapath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'zengyuting_diff_color\data_for_analysis\recluster_data'];
bea_name = 'data_sample_cell.mat';
sbea_name = 'SBeA_data_sample_cell_20220623.mat';
group_name = 'group_compare.mat';
two_mice_name = 'group_GC.mat';
%% load data
bea_data = load([datapath,'\',bea_name]);
sbea_data = load([datapath,'\',sbea_name]);
group_data = load([datapath,'\',group_name]);
two_mice = load([datapath,'\',two_mice_name]);
%% find unique
bea_namelist = unique(bea_data.data_sample_cell(:,3));
sbea_namelist = unique(sbea_data.data_sample_cell(:,3));
bea_savelist = cell2mat(bea_data.data_sample_cell(:,2));
bea_beh = unique(bea_savelist(:,4));
sbea_hierlabel = cell2mat(sbea_data.data_sample_cell(:,8));
sbea_beh1 = unique(sbea_hierlabel(:,1));
sbea_beh2 = unique(sbea_hierlabel(:,2));
%% estimate beahvior distribution, individuals
for k = 1:size(bea_namelist,1)
    tempname = bea_namelist{k,1};
    %%
    sel_data = bea_data.data_sample_cell(strcmp(tempname,bea_data.data_sample_cell(:,3)),:);
    %% 
    etho = zeros(size(bea_beh,1),bea_savelist(end,2));
    %%  assignment
    for m = 1:size(sel_data,1)
        etho(sel_data{m,2}(1,4),sel_data{m,2}(1,1)) = 1;
    end
    %% 
    diff_cell = cell(size(etho,1),1);
    for m = 1:size(diff_cell,1)
        temptimelist = find(etho(m,:)==1);
        diff_cell{m,1} = diff(temptimelist);
    end
end
%% estimate beahvior distribution, groups
indiname = group_data.group_compare(:,1:2);
group_idx = unique(cell2mat(group_data.group_compare(:,2)));
for k = 1:size(group_idx,1)
    %%
    all_diff_cell = cell(size(bea_beh,1),1);
    for m = 1:size(sel_group,1)
        sel_data = bea_data.data_sample_cell(strcmp(sel_group{m,1},bea_data.data_sample_cell(:,3)),:);
        %% 
        etho = zeros(size(bea_beh,1),bea_savelist(end,2));
        %%  assignment
        for n = 1:size(sel_data,1)
            etho(sel_data{n,2}(1,4),sel_data{n,2}(1,1)) = 1;
        end
        %% 
        diff_cell = cell(size(etho,1),1);
        for n = 1:size(diff_cell,1)
            temptimelist = find(etho(n,:)==1);
            diff_cell{n,1} = diff(temptimelist);
            all_diff_cell{n,1} = [all_diff_cell{n,1},diff_cell{n,1}];
        end
    end
    %% distribution estimation
    alpha = 0.05;
    for m = 1:41
        disp(m)
        if isempty(diff_cell{m,1}) == 0
            p_judge(all_diff_cell{m,1},alpha)
        end
    end
end