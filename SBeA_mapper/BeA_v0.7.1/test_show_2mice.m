%{
    绘制原始骨架测试，两只老鼠
%}
clear all
genPath = genpath('./');
addpath(genPath)

%% get filename
filepath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'zengyuting_diff_color\data_for_analysis\unmerge_data\correct'];
fileName1 = 'Black-208.mat';
fileName2 = 'White-208.mat';
%% get videoname
videopath = 'Z:\hanyaning\mulldling_data_analysis\liunan_analysis\datapath20201205';
videoName = 'anx-seg-1.avi';

%% Import dataset
clear global
global BeA
data_3d_name = [filepath,'\',fileName1];
import_3d(data_3d_name);
X1 = BeA.RawData.X';
Y1 = BeA.RawData.Y';
Z1 = BeA.RawData.Z';
clear global
global BeA
data_3d_name = [filepath,'\',fileName2];
import_3d(data_3d_name);
X2 = BeA.RawData.X';
Y2 = BeA.RawData.Y';
Z2 = BeA.RawData.Z';
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
    axis([-500,500,-500,500,0,200])
%     axis([min(X1(:)),max(X1(:)),min(Y1(:)),max(Y1(:)),min(Z1(:)),max(Z1(:))])
    view(2)
    subplot(122)
    plot_skl(X1(:,k),Y1(:,k),Z1(:,k),plotstr1,linestr1)
    hold on
    plot_skl(X2(:,k),Y2(:,k),Z2(:,k),plotstr2,linestr2)
    hold off
    axis([-500,500,-500,500,0,200])
    grid on
%     axis([min(X1(:)),max(X1(:)),min(Y1(:)),max(Y1(:)),min(Z1(:)),max(Z1(:))])
    view(-44,10)
%     pause
    pause(0.00000001)
end