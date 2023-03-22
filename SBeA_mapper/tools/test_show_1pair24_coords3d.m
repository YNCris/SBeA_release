%{
    绘制原始骨架测试
%}
clear all
genPath = genpath('./');
addpath(genPath)

%% get filename
filepath = ['Z:\hanyaning\multi_mice_test\' ...
    'Social_analysis\data\sbea_validation\sbea_20221114'];
fileName = 'SR1-rec1-SR1SR2-20210119.mat';
% savepathname = 'C:\Users\19226\Desktop\test1.avi';
% writeobj = VideoWriter(savepathname);
% open(writeobj)
%% Import data
load([filepath,'\',fileName]);
%% 绘制原始骨架
coords3d = fillmissing(coords3d,'linear');
X = coords3d(:,1:3:end)';
Y = coords3d(:,2:3:end)';
Z = coords3d(:,3:3:end)';
plotstr = 'r';
linestr = 'b';
smo_win = 15;
X = medfilt1(X,smo_win,[],2);
Y = medfilt1(Y,smo_win,[],2);
Z = medfilt1(Z,smo_win,[],2);
h1 = figure(1);
set(h1,'Position',[900,100,600,800])
set(h1,'color','white');
grid on
for k = 1:2:size(X,2)
    subplot(121)
    plot_skl_pair24(X(:,k),Y(:,k),Z(:,k),plotstr,linestr)
    axis([min(X(:)),max(X(:)),min(Y(:)),max(Y(:)),min(Z(:)),max(Z(:))])
    view(2)
    title('2D view')
    grid on
    subplot(122)
    plot_skl_pair24(X(:,k),Y(:,k),Z(:,k),plotstr,linestr)
    axis([min(X(:)),max(X(:)),min(Y(:)),max(Y(:)),min(Z(:)),max(Z(:))+1500])
    view(3)
    title(['3D view, frame: ',num2str(k)])
    grid on
%     pause
    at = getframe(gca);
%     writeVideo(writeobj,at.cdata)
    pause(0.00000001)
end
% close(writeobj)