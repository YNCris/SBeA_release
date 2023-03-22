%{
    check the trajectories correct
%}
clear all
close all
%% set path
rootpath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'zengyuting_diff_color\data_for_analysis_20220712\unmerge_data\correct'];
%% get mat
fileFolder = fullfile(rootpath);
dirOutput = dir(fullfile(fileFolder,'*.mat'));
matnames = {dirOutput.name}';
%% get unique group name
all_group_name = cell(size(matnames));
for k = 1:size(all_group_name,1)
    %%
    splname = split(matnames{k,1},{'-','.'});
    all_group_name{k,1} = splname{2,1};
end
unique_group_name = unique(all_group_name);

%% process
for k = 1:size(unique_group_name,1)
    %%
    selname = {};
    for m = 1:size(all_group_name)
        if strcmp(unique_group_name{k,1},all_group_name{m,1})
            selname = [selname;matnames{m,1}];
        end
    end
    %%
    fileName1 = selname{1,1};
    fileName2 = selname{2,1};
    %%
    clear global
    global BeA
    data_3d_name = [rootpath,'\',fileName1];
    import_3d(data_3d_name);
    X1 = BeA.RawData.X';
    Y1 = BeA.RawData.Y';
    Z1 = BeA.RawData.Z';
    clear global
    global BeA
    data_3d_name = [rootpath,'\',fileName2];
    import_3d(data_3d_name);
    X2 = BeA.RawData.X';
    Y2 = BeA.RawData.Y';
    Z2 = BeA.RawData.Z';
    %% 绘制原始骨架
    plotstr1 = 'r';
    linestr1 = 'r';
    plotstr2 = 'b';
    linestr2 = 'b';
    showidx = 100;
    figure(k)
    subplot(121)
    plot_skl(X1(:,showidx),Y1(:,showidx),Z1(:,showidx),plotstr1,linestr1)
    hold on
    plot_skl(X2(:,showidx),Y2(:,showidx),Z2(:,showidx),plotstr2,linestr2)
    hold off
    axis([-1000,1000,-1000,1000,-100,200])
%     axis([min(X1(:)),max(X1(:)),min(Y1(:)),max(Y1(:)),min(Z1(:)),max(Z1(:))])
    view(2)
    subplot(122)
    plot_skl(X1(:,showidx),Y1(:,showidx),Z1(:,showidx),plotstr1,linestr1)
    hold on
    plot_skl(X2(:,showidx),Y2(:,showidx),Z2(:,showidx),plotstr2,linestr2)
    hold off
    axis([-1000,1000,-1000,1000,-100,200])
    grid on
%     axis([min(X1(:)),max(X1(:)),min(Y1(:)),max(Y1(:)),min(Z1(:)),max(Z1(:))])
    view(-44,10)
%     pause
    pause(0.00000001)
end





















