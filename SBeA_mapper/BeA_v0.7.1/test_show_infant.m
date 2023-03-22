%{
    绘制原始骨架测试
%}
clear all
genPath = genpath('./');
addpath(genPath)

%% get filename
filepath = ['X:\wangzhouwei\item\mice\' ...
    'mice20230111-w-2023-01-30\rot_to_ground\results\wt1'];
fileName = 'Data3d-rot3d.mat';

%% Import dataset
tempdata = load([filepath,'\',fileName]);

%% 绘制原始骨架
X = tempdata.coords3d(:,1:3:end)';
Y = tempdata.coords3d(:,2:3:end)';
Z = tempdata.coords3d(:,3:3:end)';
XM = X(1:16,:);
YM = Y(1:16,:);
ZM = Z(1:16,:);
XI = X(17:end,:);
YI = Y(17:end,:);
ZI = Z(17:end,:);
plotstr = 'k';
linestr = 'k';
for k = 1:16:size(X,2)
    subplot(121)
    plot_skl(XM(:,k),YM(:,k),ZM(:,k),plotstr,linestr)
    axis([min(XM(:)),max(XM(:)),min(YM(:)), ...
        max(YM(:)),min(ZM(:)),max(ZM(:))])
    hold on
    for m = 1:size(XI,1)
        plot3(XI(m,k),YI(m,k),ZI(m,k),'or','MarkerSize',4)
        hold on
    end
    hold off
    view(2)
    subplot(122)
    plot_skl(XM(:,k),YM(:,k),ZM(:,k),plotstr,linestr)
    hold on
    for m = 1:size(XI,1)
        plot3(XI(m,k),YI(m,k),ZI(m,k),'or','MarkerSize',4)
        hold on
    end
    hold off
    axis([min(XM(:)),max(XM(:)),min(YM(:)), ...
        max(YM(:)),min(ZM(:)),max(ZM(:))])
    view(3)
%     pause
    pause(0.00000001)
end