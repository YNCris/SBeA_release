%{
    show demo results of step 1
%}
clear all
close all
addpath(genpath(pwd))
%% set path
rootpath = ['Z:\hanyaning\multi_mice_test\paper\' ...
    'Nature Methods\test_run\pose tracking\BeA_path\struct'];
%% load data
fileFolder = fullfile(rootpath);
dirOutput = dir(fullfile(fileFolder,'*.mat'));
beaname = {dirOutput.name}';
bea_cell = cell(size(beaname,1),1);
tic
for k = 1:size(bea_cell,1)
    tempdata = load([rootpath,'\',beaname{k,1}]);
    bea_cell{k,1} = tempdata.BeA;
    disp(k)
    toc
end
%% plot
for m = 1:size(bea_cell,1)
    %%
    G = bea_cell{m, 1}.BeA_DecData.L2.reClusData.G;
    labels = ones(size(G,2),1);
    for n = 1:size(G,2)
        try
        labels(n,1) = find(G(:,n)==1);
        catch
        end
    end
    n_clus = max(unique(labels));
    n_genColor = 10;
    
    fs = 30;
    pixel2mm = 0.88;
    BeA = bea_cell{m, 1};
    BeA.DataInfo.config_bea.BA.CenIndex = 13;
    cent_X = BeA.PreproData.X(:, BeA.DataInfo.config_bea.BA.CenIndex);
    cent_Y = BeA.PreproData.Y(:, BeA.DataInfo.config_bea.BA.CenIndex);
    
    cent_XY = [cent_X, cent_Y];
    vel_XY = diff(cent_XY);
    vel_XY = [vel_XY; vel_XY(end, :)];
    
    vel_raw = sqrt(vel_XY(:, 1).^2 + vel_XY(:, 2).^2);
    vel_raw = fs*vel_raw/pixel2mm;
    
    window = round(0.5 * fs);
    err = 0.001;
    % [vel, ~] = smooth_XYadapt(vel_raw, 'mean', window, err);
    [vel, ~] = smooth_XYadapt(vel_raw, 'moving', window, err);
    
    seg_interval = BeA.BeA_DecData.L2.reClusData.s;
    embedd2 = BeA.BeA_MapData.L2.embedding;
    nSegs = size(embedd2, 1);
    
    seg_vel = zeros(nSegs, 1);
    for i = 1:nSegs
        sel_idx = seg_interval(i):seg_interval(i+1)-1;
        seg_vel(i) = mean(vel(sel_idx));
    end
    
    % seg_vel_nr = zscore(seg_vel);
    seg_vel_nr = (seg_vel - mean(seg_vel))/(max(seg_vel) - min(seg_vel));
    embedd3 = [embedd2(:, 1:2), seg_vel_nr];
    
    subplot(2,5,m)

    cclr = (cbrewer2('Paired', n_genColor));
    [X, Y] = meshgrid([1:3], [1:n_clus]);
    if n_clus > n_genColor
        clr = interp2(X(round(linspace(1, n_clus, n_genColor)), :), Y(round(linspace(1, n_clus, n_genColor)), :), cclr, X, Y);
    else
        clr = cclr(1:n_clus, :);
    end
    
    clr_map = zeros(nSegs, 3);
    hold on
    for k = 1:n_clus
        %     if k == 2
        %         continue
        %     end
        tem_clr = clr(k, :);
        tem_idx = labels == k;
        clr_map(tem_idx, :) = repmat(tem_clr, sum(tem_idx),1);
        scatter3(embedd3(tem_idx, 1), ...
            embedd3(tem_idx, 2), ...
            embedd3(tem_idx, 3), 2*ones(size(embedd3(tem_idx, 1))), ...
            'MarkerFaceColor', tem_clr, 'MarkerEdgeColor', tem_clr, 'LineWidth', 0.01)
        
    end
    
    hold off
    grid on
    
    view(-60,30)
    zlabel('Speed')
    set(gca,'XTickLabel',[])
    set(gca,'YTickLabel',[])
    set(gca,'ZTickLabel',[])
    title(['Animal ',num2str(m)])
end
