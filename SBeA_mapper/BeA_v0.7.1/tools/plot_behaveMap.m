function plot_behaveMap(PDF, embedding)

% mapping multi-layer bahvior into low-D space
%
% Input
%   PDF        -  parameters for behavior mapping
%   embedding  -  3x1 cells, embeddings of all 3 layers
%
%
% History
%   create  -  Kang Huang  (kang.huang@siat.ac.cn), 03-02-2020

global HBT

for il = 1:2
    eval(['Seg(il) = HBT.HBT_DecData.L', num2str(il), '.MedData;'])
end

seg.s = Seg(2).sH;
seg.G = HBT.HBT_DecData.L2.reClusData.G;
labelsL2 = G2L_Slow(seg.G);
% Seg_cell = Seglist;
embed2 = [embedding{2, 1}(:, 1:2), HBT.HBT_DecData.L2.velnm];

% try
%     label_txt = importdata(['./fig3/YiV20190226-01-car_1_behavior_label_', num2str(3), '.txt']);
%     annotes = label_txt;
% catch

% end


figure
set(gcf, 'Position', [300, 300, 1200, 400])
%     subplot('Position', [0.1 0.1 0.8 0.8]);
subplot(121)
hold on

load './data/myCM_WBYR.mat'
X = PDF.X;
Y = PDF.Y;
PPDF = PDF.PPDF;
imagesc(X, Y, PPDF);
colormap(mycmap)

embed1 = embedding{1, 1};

min_x = min(embed1(:, 1)); max_x = max(embed1(:, 1));
xlim([min_x*1.1, max_x*1.1])
min_y = min(embed1(:, 2)); max_y = max(embed1(:, 2));
ylim([min_y*1.2, max_y*1.2])

set(gca, 'FontSize', 10, 'TickDir', 'out', 'TickLength',[0.01, 0.01], ...
    'ytick',[], 'xtick',[], 'Box', 'off', 'LineWidth', 0.5, 'XDir', 'reverse', 'YDir', 'reverse');
xlabel('UMAP1'); ylabel('UMAP2');
axis square
hold off

subplot(122)
hold on
n_clus2 = max(unique(labelsL2));
n_genColor = 10;
cclr = (cbrewer2('Paired', n_genColor));
[X, Y] = meshgrid([1:3], [1:n_clus2]);
if n_clus2 > n_genColor
    clr2 = interp2(X(round(linspace(1, n_clus2, n_genColor)), :), Y(round(linspace(1, n_clus2, n_genColor)), :), cclr, X, Y);
else
    clr2 = cclr(1:n_clus2, :);
end

for i2 = 1:n_clus2
    %     if i2 == 2
    %         continue
    %     end
    temIdx2 = labelsL2 == i2;
    tem_clr = clr2(i2, :);
    scatter3(embed2(temIdx2, 1), embed2(temIdx2, 2), embed2(temIdx2, 3), 30, ...
        'MarkerFaceColor', tem_clr, 'MarkerEdgeColor', tem_clr, 'LineWidth', 0.1)
    %     try
    %         label_txt = importdata(['./fig3/YiV20190226-01-car_1_behavior_label_', num2str(2), '.txt']);
    %         annotes = label_txt;
    %         text(embed2(temIdx2(1), 1), embed2(temIdx2(1), 2), annotes(i2))
    %     catch
    %         text(embed2(temIdx2(1), 1), embed2(temIdx2(1), 2), num2str(i2))
    %     end
    
end

min_x = min(embed2(:, 1)); max_x = max(embed2(:, 1));
xlim([min_x*1.3, max_x*1.3])
min_y = min(embed2(:, 2)); max_y = max(embed2(:, 2));
ylim([min_y*1.2, max_y*1.2])
set(gca, 'FontSize', 10, 'view', [30 30], 'TickDir', 'out', 'TickLength',[0.01, 0.01], ...
    'ytick',[], 'xtick',[], 'Box', 'off', 'LineWidth', 0.5)
grid on
xlabel('UMAP1'); ylabel('UMAP2');zlabel('Velocity');
axis square
view(225, 36)
%     title(annotes{tem_Clus})
hold off

