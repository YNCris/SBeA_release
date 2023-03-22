%{
    绘制原始骨架测试，两只老鼠
%}
clear all
genPath = genpath('./');
addpath(genPath)

%% get filename
filepath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'hcl_bird\sbea_data_20220919'];
fileName = 'rec3-B1B2-20220919-id3d.mat';
%% Import dataset
load([filepath,'\',fileName])
% for m = 1:size(coords3d,2)
%     coords3d(:,m) = medfilt1(coords3d(:,m),3);
% end
% coords3d(err3d>100,:) = nan;
% coords3d(isnan(err3d),:) = nan;
% coords3d = fillmissing(coords3d,'linear');
data1 = coords3d(:,1:57);
data2 = coords3d(:,58:114);
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
for k = 1:20:size(data1,1)
    subplot(121)
    plot_skl_bird(X1(:,k),Y1(:,k),Z1(:,k),plotstr1,linestr1)
    hold on
    plot_skl_bird(X2(:,k),Y2(:,k),Z2(:,k),plotstr2,linestr2)
    hold off
    axis([-1000,1000,-1000,1000,0,200])
%     axis([min(X1(:)),max(X1(:)),min(Y1(:)),max(Y1(:)),min(Z1(:)),max(Z1(:))])
    view(2)
    title(k)
    subplot(122)
    plot_skl_bird(X1(:,k),Y1(:,k),Z1(:,k),plotstr1,linestr1)
    hold on
    plot_skl_bird(X2(:,k),Y2(:,k),Z2(:,k),plotstr2,linestr2)
    hold off
%     title(err3d(k,1))
%     axis([-1000,1000,-1000,1000,0,400])
    grid on
    axis([min(X1(:)),max(X1(:)),min(Y1(:)),max(Y1(:)),min(Z1(:)),max(Z1(:))])
    view(-44,10)
%     pause
    pause(0.00000001)
end