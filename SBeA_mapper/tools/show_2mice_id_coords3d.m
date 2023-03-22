%{
    绘制原始骨架测试，两只�?�鼠，带ID
%}
clear all
genPath = genpath('./');
addpath(genPath)

%% get filename
% filepath = ['Z:\hanyaning\multi_mice_test\' ...
%     'Social_analysis\data\shank3_wt\sbea_data_20221108'];
% fileName = 'rec22-M5M6-20221109-id3d.mat';


% filepath = ['Z:\hanyaning\multi_mice_test\' ...
%     'Social_analysis\data\shank3_wt\sbea_data_20221108'];
% fileName = 'rec22-M5M6-20221109-id3d.mat';
filepath = ['Y:\wangnan\video\HuJi\SBeA_data_20230213'];
fileName = 'rec1-M1M2-20230208173814-id3d.mat';
%% Import dataset
load([filepath,'\',fileName])
mousename = cellstr(name3d);
data1 = coords3d(:,1:48);
data2 = coords3d(:,49:96);
X1 = data1(:,1:3:end)';
Y1 = data1(:,2:3:end)';
Z1 = data1(:,3:3:end)';
X2 = data2(:,1:3:end)';
Y2 = data2(:,2:3:end)';
Z2 = data2(:,3:3:end)';
%% 绘制原始骨架
plotstr1 = 'r';
linestr1 = 'r';
plotstr2 = 'b';
linestr2 = 'b';
for k = 1:10:size(data1,1)
    subplot(121)
    plot_skl(X1(:,k),Y1(:,k),Z1(:,k),plotstr1,linestr1)
    hold on
    plot_skl(X2(:,k),Y2(:,k),Z2(:,k),plotstr2,linestr2)
    hold off
    axis([-300,300,200,800,-20,100])
%     axis([min(X1(:)),max(X1(:)),min(Y1(:)),max(Y1(:)),min(Z1(:)),max(Z1(:))])
    view(2)
    title(k)
    subplot(122)
    plot_skl(X1(:,k),Y1(:,k),Z1(:,k),plotstr1,linestr1)
    hold on
    plot_skl(X2(:,k),Y2(:,k),Z2(:,k),plotstr2,linestr2)
    hold off
%     title(err3d(k,1))
    axis([-300,300,200,800,-20,100])
    grid on
%     axis([min(X1(:)),max(X1(:)),min(Y1(:)),max(Y1(:)),min(Z1(:)),max(Z1(:))])
    view(-44,10)
%     pause
    pause(0.00000001)
end