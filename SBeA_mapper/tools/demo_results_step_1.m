%{
    show demo results of step 1
%}
clear all
close all
addpath(genpath(pwd))
%% set path
rootpath = ['Z:\hanyaning\multi_mice_test\paper\' ...
    'Nature Methods\test_run\pose tracking'];
dataname = 'rec11-A1A2-20220803-id3d.mat';
%% load data
load([rootpath,'\',dataname])
%% plot
setcolor = cbrewer2('Spectral',11);
mouse1_c = setcolor(3,:);
mouse2_c = setcolor(9,:);

traj1 = coords3d(:,1:48);
traj2 = coords3d(:,49:end);

smo_win = 30;
line_bias = 150;

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
xlabel('Frames')
set(gca,'YTick',[])
