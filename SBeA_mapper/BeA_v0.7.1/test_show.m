%{
    绘制原始骨架测试
%}
clear all
genPath = genpath('./');
addpath(genPath)

%% get filename
filepath = 'Z:\hanyaning\mulldling_data_analysis\liuhaoyi_analysis\data_20221205\struct';
fileName = 'DP-seg6_struct.mat';

%% get videoname
videopath = 'Z:\hanyaning\mulldling_data_analysis\liunan_analysis\datapath20201205';
videoName = 'anx-seg-1.avi';

%% Import dataset
clear global
global BeA
data_3d_name = [filepath,'\',fileName];
import_3d(data_3d_name);

%% Import dataset
video_name = [videopath,'\',videoName];
import_video(video_name);

%% 绘制原始骨架
X = BeA.RawData.X';
Y = BeA.RawData.Y';
Z = BeA.RawData.Z';
plotstr = 'k';
linestr = 'k';
for k = 1:16:size(X,2)
    subplot(121)
    plot_skl(X(:,k),Y(:,k),Z(:,k),plotstr,linestr)
    axis([min(X(:)),max(X(:)),min(Y(:)),max(Y(:)),min(Z(:)),max(Z(:))])
    view(2)
    tempdist = sqrt((X(13,k)-X(14,k)).^2+(Y(13,k)-Y(14,k)).^2+(Z(13,k)-Z(14,k)).^2);
    title([num2str(k),'-',num2str(tempdist)])
    subplot(122)
    plot_skl(X(:,k),Y(:,k),Z(:,k),plotstr,linestr)
    axis([min(X(:)),max(X(:)),min(Y(:)),max(Y(:)),min(Z(:)),max(Z(:))])
    view(3)
    tempdist = sqrt((X(13,k)-X(14,k)).^2+(Y(13,k)-Y(14,k)).^2+(Z(13,k)-Z(14,k)).^2);
    title([num2str(k),'-',num2str(tempdist)])
%     pause
    pause(0.00000001)
end