%{
    show demo results of step 4
%}
clear all
close all
addpath(genpath(pwd))
%% set path
rootpath = ['Z:\hanyaning\multi_mice_test\paper\Nature Methods\' ...
    'test_run\pose tracking\BeA_path\recluster_data'];
%% load data
load([rootpath,'\Your name to save data_sample_cell.mat']);
load([rootpath,'\Your name to save dist_mat_all.mat']);
load([rootpath,'\Your name to save wc_struct.mat']);
%% plot
h1 = figure(1);
set(h1,'color','white');

subplot(131)
imagesc(dist_mat_all)
axis square
box off
title('Feature matrix')
set(gca,'TickDir')
xlabel('Features')
ylabel('Social behavior modules')
set(gca,'TickDir','out')
set(gca,'XTick',[1,size(dist_mat_all,2)])
set(gca,'YTick',[1,size(dist_mat_all,1)])


hba = subplot(132);
mk_size = 4;
edge_x = 0.1;
edge_y = 0.1;
case_embed = cell2mat(data_sample_cell(:,4));
classes_list = cell2mat(data_sample_cell(:,8));
little_class = classes_list(:,1);
much_class =classes_list(:,2);
unique_little_class = unique(little_class);
unique_much_class = unique(much_class);
cmap = cbrewer2('Spectral',length(unique_little_class));
cmaplist = zeros(length(little_class),3);
for k = 1:size(unique_little_class,1)
    selidx = unique_little_class(k)==little_class;
    cmaplist(selidx,:) = ones(sum(selidx),1)*cmap(k,:);
end
L_img = wc_struct.L_much==0;
XX = wc_struct.XX_much;
YY = wc_struct.YY_much;
scatter(case_embed(:,1),case_embed(:,2),mk_size*ones(size(case_embed,1),1),...
    cmaplist,'filled')
hold on
im = imagesc([min(XX(:)),max(XX(:))],[min(YY(:)),max(YY(:))],L_img);
im.AlphaData = L_img;
hold off
colormap(hba,0.7*[1,1,1])
title('Social behavior atlas')
set(gca,'TickDir','out')
max_x = max(case_embed(:,1));
min_x = min(case_embed(:,1));
max_y = max(case_embed(:,2));
min_y = min(case_embed(:,2));
axis([min_x-edge_x,max_x+edge_x,min_y-edge_y,max_y+edge_y])
set(gca,'XTickLabel',[])
set(gca,'YTickLabel',[])
xlabel('Dimension 1')
ylabel('Dimension 2')
axis square


hba = subplot(133);
zscore_embed = cell2mat(data_sample_cell(:,4));
distlist = medfilt1(cellfun(@(x) min(x(:)),data_sample_cell(:,7)),3);
normdistlist = round(mat2gray(distlist)*255+1);
cmap = turbo(256);
cmaplist = cmap(normdistlist,:);
scatter(zscore_embed(:,1),zscore_embed(:,2),10*ones(size(zscore_embed,1),1),cmaplist,'filled');
hold on
im = imagesc([min(XX(:)),max(XX(:))],[min(YY(:)),max(YY(:))],L_img);
im.AlphaData = L_img;
hold off
colormap(hba,0.7*[1,1,1])
title('Social behavior atlas')
set(gca,'TickDir','out')
max_x = max(case_embed(:,1));
min_x = min(case_embed(:,1));
max_y = max(case_embed(:,2));
min_y = min(case_embed(:,2));
axis([min_x-edge_x,max_x+edge_x,min_y-edge_y,max_y+edge_y])
set(gca,'XTickLabel',[])
set(gca,'YTickLabel',[])
xlabel('Dimension 1')
ylabel('Dimension 2')
axis square
title('Distance map')







