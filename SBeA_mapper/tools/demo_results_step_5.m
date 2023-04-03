%{
    show demo results of step 5
%}
clear all
close all
addpath(genpath(pwd))
%% set path
rootpath = ['Z:\hanyaning\multi_mice_test\paper\Nature Methods\' ...
    'test_run\pose tracking\BeA_path\recluster_data'];
%% load data
load([rootpath,'\Your name to save fractions_little.mat']);
load([rootpath,'\Your name to save fractions_much.mat']);
load([rootpath,'\Your name to save LDE.mat']);
load([rootpath,'\Your name to save sort_group_names.mat']);
%% plot
h1 = figure(1);
set(h1,'color','white');

subplot(221)
imagesc(fractions_little)
colormap(flipud(cbrewer2('Spectral',256)))
box off
set(gca,'TickDir','out')
set(gca,'XTickLabel',[])
set(gca,'YTick',[1,15])
title('Social behavior module fractions')
ylabel('Lower classes')

subplot(223)
imagesc(fractions_much)
set(gca,'TickDir','out')
set(gca,'YTick',[1,447])
box off
ylabel('Upper classes')
set(gca,'XTickLabel',{'A1-A2','A3-A4','A5-A6','A7-A8','A9-A10'})
xlabel('Social groups')

subplot(122)
unique_group_label = unique(cell2mat(sort_group_names(:,5)));
cmap = cbrewer2('Dark2',length(unique_group_label));
cmaplist = cmap(cell2mat(sort_group_names(:,5)),:);
for k = 1:5
    scatter(Y(k,1),Y(k,2),30,cmaplist(k,:),'filled')
    hold on
end
hold off
axis square
legend('A1-A2','A3-A4','A5-A6','A7-A8','A9-A10',...
    'Box','off','location','northeastoutside')
set(gca,'TickDir','out')
xlabel('Dimension 1')
ylabel('Dimension 2')
title('Phenotype space')












