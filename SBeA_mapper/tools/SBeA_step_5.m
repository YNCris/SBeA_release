%{
    5 The relationship between single behavior and social behavior,
    using markov chain to analysis
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
%% using HMM for the estimation of transitions bwtween two social behaviors
hmm_label_cell = cell(size(two_mice.group_GC,1),9);
mini_batch_size = 1000;
for k = 1:size(hmm_label_cell,1)
    %% load name
    splname = split(two_mice.group_GC{k,1},'_');
    name_s = [two_mice.group_GC{k,2},'_',two_mice.group_GC{k,3},'_',...
        splname{1,1},'_social_struct.mat'];
    name_m1 = [two_mice.group_GC{k,2},'-',splname{1,1},'_struct.mat'];
    name_m2 = [two_mice.group_GC{k,3},'-',splname{1,1},'_struct.mat'];
    %% load data
    unique_data_s = sbea_data.data_sample_cell(...
        strcmp(sbea_data.data_sample_cell(:,3),name_s),:);
    unique_data_m1 = bea_data.data_sample_cell(...
        strcmp(bea_data.data_sample_cell(:,3),name_m1),:);
    unique_data_m2 = bea_data.data_sample_cell(...
        strcmp(bea_data.data_sample_cell(:,3),name_m2),:);
    %% create time label list
    label_list_s = cell2mat(cellfun(@(x,y) ones(size(x,2),1)*y(2),...
        unique_data_s(:,1),unique_data_s(:,8),'UniformOutput',false));
    label_list_m1 = cell2mat(cellfun(@(x,y) ones(size(x,2),1)*y(4),...
        unique_data_m1(:,1),unique_data_m1(:,2),'UniformOutput',false));
    label_list_m2 = cell2mat(cellfun(@(x,y) ones(size(x,2),1)*y(4),...
        unique_data_m2(:,1),unique_data_m2(:,2),'UniformOutput',false));
    label_list_m = (label_list_m1-1)*length(bea_beh)+label_list_m2;%joint label
    symbols = 1:(bea_beh(end)*bea_beh(end));
    statenames = sbea_beh2;
    %% seg time label list into mini-batch
    mini_m = cell(round(length(label_list_m)/mini_batch_size),1);
    for m = 1:size(mini_m,1)
        start_pos = (m-1)*mini_batch_size+1;
        end_pos = m*mini_batch_size;
        if end_pos > length(label_list_m)
            end_pos = length(label_list_m);
        end
        temp_mini_m = label_list_m(start_pos:end_pos,:);
        mini_m{m,1} = temp_mini_m;
    end
    %% estimate emission probability and transition probability
    seq = label_list_m;
    states = label_list_s;
    [estimateTR, estimateE] = hmmestimate(seq,states,...
        'Symbols',symbols,'Statenames',statenames);
    hmm_label_cell(k,:) = {label_list_s,label_list_m1,label_list_m2,...
        label_list_m,mini_m,statenames,symbols,estimateTR,estimateE};
end
%% transition estimation in batch
unique_group_idx = unique(cell2mat(two_mice.group_GC(:,4)));
hmm_train_cell = cell(size(unique_group_idx,1),2);
for k = 1:size(unique_group_idx,1)
    %%
    tempgroup = unique_group_idx(k,1);
    %%
    sel_idx = tempgroup==cell2mat(two_mice.group_GC(:,4));
    %%
    sel_hmm_cell = hmm_label_cell(sel_idx,:);
    %%
    temp_mini_batch = reshape([sel_hmm_cell{:,5}],[],1);
    train_seq = cellfun(@(x) x',temp_mini_batch,'UniformOutput',false);
    trguess = sel_hmm_cell{1,8}+eps;
    emitguess = sel_hmm_cell{1,9}+eps;
    [esttr,estemit] = hmmtrain(train_seq,trguess,emitguess,'Verbose',true);
    hmm_train_cell(k,:) = {esttr,estemit};
end
%% HMM chi-square test
seq_m = hmm_label_cell{1,1};
numStates = size(hmm_label_cell{1,8},1);
alp = 0.05;

m_1 = length(seq_m) - 2;

f_ij = zeros(numStates);
seqLen = length(seq_m);

for count = 1:seqLen-1
    f_ij(seq_m(count),seq_m(count+1)) = f_ij(seq_m(count),seq_m(count+1)) + 1;
end

sum_ij_fij = sum(f_ij(:));

sum_j_fij = sum(f_ij,2);

P_j = sum_j_fij./sum_ij_fij;

P_j(P_j == 0) = -inf;
sum_j_fij(sum_j_fij == 0) = -inf;

P_ij = f_ij./repmat(sum_j_fij,1,numStates);



ln_abs = abs(log(P_ij./repmat(P_j,1,numStates)));

ln_abs(isinf(ln_abs)) = 0;

f_ij_ln_abs = 2*f_ij.*ln_abs;

chi_square = sum(f_ij_ln_abs(:));

x = chi2inv(1-alp,m_1);

disp(x)

if chi_square > x
    h = 1;
    disp('Obey Markov property!')
else
    h = 0;
    disp('Violate Markov property!')
end
















































