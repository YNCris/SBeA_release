%{
    绘制原始骨架测试，两只�?�鼠
%}
clear all
genPath = genpath('./');
addpath(genPath)

%% get filename
filepath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'hcl_bird_ljh\sbea_mice_20221123'];
fileName = 'seg-8-mouse-day1-rot3d.mat';
%% Import dataset
load([filepath,'\',fileName])
% new_coords3d = [coords3d(:,2:end),coords3d(:,1)];
% for m = 1:size(coords3d,2)
%     coords3d(:,m) = medfilt1(coords3d(:,m),3);
% end
% coords3d(err3d>100,:) = nan;
% coords3d(isnan(err3d),:) = nan;
% coords3d = fillmissing(coords3d,'linear');
animal_num = 4;
body_parts_num = 16;
data_cell = cell(animal_num,3); 
for k = 1:animal_num
    data_cell{k,1} = coords3d(:,(k-1)*16*3+1:3:(k)*16*3)';
    data_cell{k,2} = coords3d(:,(k-1)*16*3+2:3:(k)*16*3)';
    data_cell{k,3} = coords3d(:,(k-1)*16*3+3:3:(k)*16*3)';
end
% data1 = coords3d(:,1:48);
% data2 = coords3d(:,49:96);



% X1 = data1(:,1:3:end)';
% Y1 = data1(:,2:3:end)';
% Z1 = data1(:,3:3:end)';
% X2 = data2(:,1:3:end)';
% Y2 = data2(:,2:3:end)';
% Z2 = data2(:,3:3:end)';
%% 绘制原始骨架
% plotstr1 = 'r';
% linestr1 = 'r';
% plotstr2 = 'b';
% linestr2 = 'b';

map = [93/255 137/255 255/255 
    232/255 147/255 255/255  
    240/255 151/255 81/255 
    247/255 76/255 69/255 
    240/255 225/255 12/255  
    26/255 181/255 184/255 
    99/255 255/255 158/255 
    203/255 215/255 235/255 
    ];

figure;
%%
% for k = 1:10:size(coords3d,1)
for k = 30
    subplot(121)
    for i = 1:animal_num
        X1 = data_cell{i,1};
        Y1 = data_cell{i,2};
        Z1 = data_cell{i,3};
        plot_skl(X1(:,k),Y1(:,k),Z1(:,k),map(i,:),map(i,:))
        hold on
    end
    hold off
    axis([-1000,1000,-1000,1000,-550,900])
%     axis([min(X1(:)),max(X1(:)),min(Y1(:)),max(Y1(:)),min(Z1(:)),max(Z1(:))])
    view(2)
    title(k)
    subplot(122)
    for i = 1:animal_num
        X1 = data_cell{i,1};
        Y1 = data_cell{i,2};
        Z1 = data_cell{i,3};
        plot_skl(X1(:,k),Y1(:,k),Z1(:,k),map(i,:),map(i,:))
        hold on
    end
    hold off
    grid on
    axis([min(X1(:)),max(X1(:)),min(Y1(:)),max(Y1(:)),min(Z1(:)),max(Z1(:))])
    view(-44,10)

%     title(err3d(k,1))
%     axis([-1000,1000,-1000,1000,0,400])

%     pause
%     pause(0.00000001)
    pause(0.0000001)
end