%{
    show SBeA
%}
clear all
close all
genPath = genpath('./');
addpath(genPath)
%% Set path
SBeA_struct_path = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'zengyuting_diff_color\data_for_analysis\unmerge_data\social_struct'];
SBeA_name = 'Black_White_207_social_struct.mat';
%% load data
load([SBeA_struct_path,'\',SBeA_name]);
%%
mean_dist = mean(SBeA.RawData.dist_body,1);
min_dist = min(SBeA.RawData.dist_body,[],1);
%% 绘制原始骨架
plotstr1 = 'r';
linestr1 = 'r';
plotstr2 = 'b';
linestr2 = 'b';
A1 = SBeA.RawData.traj{1,1};
A2 = SBeA.RawData.traj{2,1};
X1 = A1(:,1:16)';
Y1 = A1(:,17:32)';
Z1 = A1(:,33:end)';
X2 = A2(:,1:16)';
Y2 = A2(:,17:32)';
Z2 = A2(:,33:end)';
for k = 1:16:size(X1,2)
    subplot(221)
    plot_skl(X1(:,k),Y1(:,k),Z1(:,k),plotstr1,linestr1)
    hold on
    plot_skl(X2(:,k),Y2(:,k),Z2(:,k),plotstr2,linestr2)
    hold off
    title(min_dist(k))
    axis([-500,500,-500,500,0,200])
%     axis([min(X1(:)),max(X1(:)),min(Y1(:)),max(Y1(:)),min(Z1(:)),max(Z1(:))])
    view(2)
    subplot(222)
    plot_skl(X1(:,k),Y1(:,k),Z1(:,k),plotstr1,linestr1)
    hold on
    plot_skl(X2(:,k),Y2(:,k),Z2(:,k),plotstr2,linestr2)
    hold off
    axis([-500,500,-500,500,0,200])
    grid on
%     axis([min(X1(:)),max(X1(:)),min(Y1(:)),max(Y1(:)),min(Z1(:)),max(Z1(:))])
    view(-44,10)
%     pause
    subplot(212)
    plot(min_dist,'b')
    hold on
    plot([k,k],[min(min_dist),max(min_dist)],'-r')
    hold off
    pause
%     pause(0.00000001)
end
%% test UMAP
dist_body = SBeA.RawData.dist_body';
[~, umap, ~] = run_umap(dist_body,'n_neighbors',80,...
    'min_dist',0.3,'metric','euclidean','n_components', 2, 'verbose', 'text');
embedding = umap.embedding;
zscore_embed = zscore(embedding);
%% temp show
speedlist = min_dist;
normspeedlist = round(mat2gray(speedlist)*255+1);
cmap = jet(256);
cmaplist = cmap(normspeedlist,:);
scatter(zscore_embed(:,1),zscore_embed(:,2),10*ones(size(zscore_embed,1),1),cmaplist,'filled');
axis square


























