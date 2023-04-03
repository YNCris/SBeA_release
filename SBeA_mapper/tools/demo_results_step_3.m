%{
    show demo results of step 3
%}
clear all
close all
addpath(genpath(pwd))
%% set path
rootpath = ['Z:\hanyaning\multi_mice_test\paper\Nature Methods\' ...
    'test_run\pose tracking\BeA_path\social_struct'];
%% load data
fileFolder = fullfile(rootpath);
dirOutput = dir(fullfile(fileFolder,'*.mat'));
beaname = {dirOutput.name}';
bea_cell = cell(size(beaname,1),1);
tic
for k = 1:size(bea_cell,1)
    tempdata = load([rootpath,'\',beaname{k,1}]);
    bea_cell{k,1} = tempdata.SBeA;
    disp(k)
    toc
end
%% plot
h1 = figure(1);
set(h1,'color','white');

start_show = 1;
end_show = 27000;

setcolor = cbrewer2('Spectral',11);
mouse1_c = setcolor(3,:);
mouse2_c = setcolor(9,:);

coords3d = bea_cell{1,1}.RawData.traj;

traj1 = coords3d{1}(start_show:end_show,:);
traj2 = coords3d{2}(start_show:end_show,:);

smo_win = 30;
line_bias = 50;

subplot('Position',[0.1,0.5,0.8,0.3])
for k = 1:48
    plot(smooth(...
        traj1(:,k)+k*line_bias-mean(traj1(:,k)),smo_win),...
        'Color',mouse1_c)
    hold on
end
mice_bias = 300;
for k = 1:48
    plot(smooth( ...
        traj2(:,k)+mice_bias+(k+48)*...
    line_bias-mean(traj2(:,k)),smo_win),...
        'Color',mouse2_c)
    hold on
end
hold off

box off
set(gca,'TickDir','out')
set(gca,'YTick',[],'XTickLabel',[])
axis([0,end_show-start_show,-300,100*line_bias+mice_bias])

NM_seg = bea_cell{1,1}.SBeA_DecData.L2.Seglist(start_show:end_show);
L_seg = bea_cell{1,1}.SBeA_DecData_speed.L2.Seglist(start_show:end_show);
D_seg = bea_cell{1,1}.SBeA_DecData_dist.L2.Seglist(start_show:end_show);

all_seg = ...
    (abs([0,diff(NM_seg)])>0)|...
    (abs([0,diff(L_seg)])>0)|...
    (abs([0,diff(D_seg)])>0);

temph1 = subplot('Position',[0.1,0.45,0.8,0.03]);
imagesc(NM_seg)
cmap = cbrewer2('Spectral',length(unique(NM_seg)));
colormap(temph1,cmap)
box off
set(gca,'TickDir','out')
set(gca,'YTick',[],'XTickLabel',[])
ylabel('NM')
% axis([start_show,end_show,0.5,1.5])

temph2 = subplot('Position',[0.1,0.4,0.8,0.03]);
imagesc(L_seg)
cmap = cbrewer2('Spectral',length(unique(NM_seg)));
colormap(temph2,cmap)
box off
set(gca,'TickDir','out')
set(gca,'YTick',[],'XTickLabel',[])
ylabel('L')

temph3 = subplot('Position',[0.1,0.35,0.8,0.03]);
imagesc(D_seg)
cmap = cbrewer2('Spectral',length(unique(NM_seg)));
colormap(temph3,cmap)
box off
set(gca,'TickDir','out')
set(gca,'YTick',[],'XTickLabel',[])
ylabel('D')

temph4 = subplot('Position',[0.1,0.28,0.8,0.03]);
imagesc(all_seg)
cmap = [0.7*ones(1,3);1,1,1];
colormap(temph4,cmap)
box off
set(gca,'TickDir','out')
set(gca,'YTick',[])
ylabel('All')
xlabel('Frames')







