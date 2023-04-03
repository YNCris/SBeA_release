%{
    5. group analysis
    compare the social behavior fractions
%}
clear all
close all
genPath = genpath('./');
addpath(genPath)
%% Set path
rootpath = ['Your path of *\BeA_path of step_1'];
recluster_path = [rootpath, '\recluster_data'];
%% load data
dsc = load([recluster_path,'\Your name to save data_sample_cell.mat']);
%% analysis
beh_labels = cell2mat(dsc.data_sample_cell(:,8));
unique_little_labels = unique(beh_labels(:,1));
unique_much_labels = unique(beh_labels(:,2));
unique_data_name = unique(dsc.data_sample_cell(:,3));
tempsplname = cellfun(@(x) split(x,'_'),unique_data_name,...
    'UniformOutput',false);
%
mice_names = {'Your animal name like below'};
mice_names = {...
    'A1','G1';
    'A2','G2';
    'A3','G3';
    'A4','G4';
    'A5','G5';
    'A6','G6';
    'A7','G7';
    'A8','G8';
    'A9','G9';
    'A10','G10';};
% mice_names = {...
%     'M1','KO';
%     'M2','KO';
%     'M3','KO';
%     'M4','KO';
%     'M5','KO';
%     'M6','WT';
%     'M7','WT';
%     'M8','WT';
%     'M9','WT';
%     'M10','WT'};

group_names = cell(size(tempsplname,1),5);
for k = 1:size(group_names,1)
    %%
    tempname1 = tempsplname{k,1}{1};
    tempname2 = tempsplname{k,1}{2};
    selidx1 = find(strcmp(tempname1,mice_names(:,1)));
    selidx2 = find(strcmp(tempname2,mice_names(:,1)));
    group_names{k,1} = unique_data_name{k,1};
    group_names{k,2} = mice_names{selidx1,2};
    group_names{k,3} = mice_names{selidx2,2};
    group_names{k,4} = [mice_names{selidx1,2},'-',mice_names{selidx2,2}];
%     if strcmp(group_names{k,4},'WT-WT')
%         group_names{k,5} = 1;
%     elseif strcmp(group_names{k,4},'KO-KO')
%         group_names{k,5} = 3;
%     else
%         group_names{k,5} = 2;
%     end
end
group_names(:,5) = {1;2;3;4;5};
%% 
unique_group_idx = unique(cell2mat(group_names(:,5)));
fractions_little = zeros(length(unique_little_labels),...
    size(group_names,1));
fractions_much = zeros(length(unique_much_labels),...
    size(group_names,1));
sort_group_names = sortrows(group_names,5);
for k = 1:size(sort_group_names,1)
    %%
    tempname = sort_group_names{k,1};
    sel_data_sample_cell = dsc.data_sample_cell(...
        strcmp(tempname,dsc.data_sample_cell(:,3)),:);
    all_frame_num = sum(cell2mat(cellfun(@(x) size(x,2),...
        sel_data_sample_cell(:,1),...
        'UniformOutput',false)));
    %%
    sel_labels = cell2mat(sel_data_sample_cell(:,8));
    tab_little_label = tabulate(sel_labels(:,1));
    tab_much_label = tabulate(sel_labels(:,2));
    fractions_little(tab_little_label(:,1),k) = tab_little_label(:,3)/100;
    fractions_much(tab_much_label(:,1),k) = tab_much_label(:,3)/100;
end
%% LDE
Y = run_umap(fractions_much','sgd_tasks',1);
unique_group_label = unique(cell2mat(sort_group_names(:,5)));
cmap = cbrewer2('Spectral',length(unique_group_label));
cmaplist = cmap(cell2mat(sort_group_names(:,5)),:);
scatter(Y(:,1),Y(:,2),30*ones(size(Y,1),1),cmaplist,'filled')
%% save
save([recluster_path,'\Your name to save fractions_little.mat'],...
    'fractions_little')
save([recluster_path,'\Your name to save fractions_much.mat'],...
    'fractions_much')
save([recluster_path,'\Your name to save sort_group_names.mat'],...
    'sort_group_names')
save([recluster_path,'\Your name to save LDE.mat'],...
    'Y')
disp('Save finished!')





































