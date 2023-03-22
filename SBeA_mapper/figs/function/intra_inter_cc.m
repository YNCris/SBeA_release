function [intra_cc_all_mat,inter_cc_all_mat] = ...
    intra_inter_cc(dist_mat_all,all_labels,feat_num)
% dist_mat_all = parrot_distmat.dist_mat_all;
% all_labels = cell2mat(parrot_dsc.data_sample_cell(:,8));
unique_labels = unique(all_labels(:,1));
intra_cc_all = cell(length(unique_labels),1);%内部相关系数
inter_cc_all = cell(length(unique_labels),1);%外部相关系数
% feat_num = 100;
for k = 1:length(unique_labels)
    %%
    sel_cc_idx = unique_labels(k) == all_labels(:,1);
    sel_social_feat = dist_mat_all(sel_cc_idx,:);
    non_social_dist_mat = dist_mat_all(~sel_cc_idx,:);
    rand('seed',1234)
    sel_social_feat_idx = randi(size(sel_social_feat,1),1,feat_num)';
    sel_social_feat_1 = sel_social_feat(sel_social_feat_idx,:);
    rand('seed',5678)
    sel_social_feat_idx = randi(size(sel_social_feat,1),1,feat_num)';
    sel_social_feat_2 = sel_social_feat(sel_social_feat_idx,:);
    rand('seed',3456)
    sel_social_feat_idx = randi(size(non_social_dist_mat,1),1,feat_num)';
    sel_non_social_feat = dist_mat_all(sel_social_feat_idx,:);
    %% calculate intra cc
    temp_intra_list = zeros(feat_num,1);
    for m = 1:feat_num
        R = corrcoef(sel_social_feat_1(m,:),sel_social_feat_2(m,:));
        temp_intra_list(m,1) = R(1,2);
    end
    %% calculate inter cc
    temp_inter_list = zeros(feat_num,1);
    for m = 1:feat_num
        R = corrcoef(sel_social_feat_1(m,:),sel_non_social_feat(m,:));
        temp_inter_list(m,1) = R(1,2);
    end
    %% append data
    intra_cc_all{k,1} = temp_intra_list';
    inter_cc_all{k,1} = temp_inter_list';
end
intra_cc_all_mat = cell2mat(intra_cc_all)';
inter_cc_all_mat = cell2mat(inter_cc_all)';