%{
    绘制原始骨架测试，两只老鼠
%}
clear all
genPath = genpath('./');
addpath(genPath)

%% get filename
filepath = ['Z:\hanyaning\multi_mice_test\' ...
    'Social_analysis\data\zengyuting_diff_color\' ...
    'aggressive_data_20230317\unmerge_data_raw\' ...
    'correct'];
fileName1 = 'Black-FP2695.mat';
fileName2 = 'White-FP2695.mat';
%% get videoname
videopath = 'Z:\hanyaning\mulldling_data_analysis\liunan_analysis\datapath20201205';
videoName = 'anx-seg-1.avi';

%% Import dataset
data_3d_name = [filepath,'\',fileName1];
tempdata1 = load(data_3d_name);
X1 = tempdata1.coords3d(:,1:3:end)';
Y1 = tempdata1.coords3d(:,2:3:end)';
Z1 = tempdata1.coords3d(:,3:3:end)';
data_3d_name = [filepath,'\',fileName2];
tempdata2 = load(data_3d_name);
X2 = tempdata2.coords3d(:,1:3:end)';
Y2 = tempdata2.coords3d(:,2:3:end)';
Z2 = tempdata2.coords3d(:,3:3:end)';
%% Import dataset
video_name = [videopath,'\',videoName];
import_video(video_name);

%% 绘制原始骨架
plotstr1 = 'r';
linestr1 = 'r';
plotstr2 = 'b';
linestr2 = 'b';
for k = 1:16:size(X1,2)
    subplot(121)
    plot_skl(X1(:,k),Y1(:,k),Z1(:,k),plotstr1,linestr1)
    hold on
    plot_skl(X2(:,k),Y2(:,k),Z2(:,k),plotstr2,linestr2)
    hold off
    axis([-1000,1000,-1000,1000,0,200])
%     axis([min(X1(:)),max(X1(:)),min(Y1(:)),max(Y1(:)),min(Z1(:)),max(Z1(:))])
    view(2)
    subplot(122)
    plot_skl(X1(:,k),Y1(:,k),Z1(:,k),plotstr1,linestr1)
    hold on
    plot_skl(X2(:,k),Y2(:,k),Z2(:,k),plotstr2,linestr2)
    hold off
    axis([-1000,1000,-1000,1000,0,200])
    grid on
%     axis([min(X1(:)),max(X1(:)),min(Y1(:)),max(Y1(:)),min(Z1(:)),max(Z1(:))])
    view(-44,10)
%     pause
    pause(0.00000001)
end