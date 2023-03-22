function labels = re_clusterSimple(embedding, n_clus)

% re-clustering the decomposed components acoording to the low-D embeddings
%
% Input
%       - embedding          -  low-D embeddings of decomposed segments
%       - re_cluN2           -  numbers of re-clustering
%
% Output
%       - labels             -  new labels of re-clustering
%
% History
%   create  -  Kang Huang  (kang.huang@siat.ac.cn), 03-02-2020

global HBT

% interp color map
n_genColor = 10;
cclr = (cbrewer2('Paired', n_genColor));
[X, Y] = meshgrid([1:3], [1:n_clus]);
if n_clus > n_genColor
    clr = interp2(X(round(linspace(1, n_clus, n_genColor)), :), Y(round(linspace(1, n_clus, n_genColor)), :), cclr, X, Y);
else
    clr = cclr;
end

% sort T by linkage
% % D = 1 - T;
% % D(1 : 1+size(D,1) : end) = 0;

D = pdist(embedding, 'seuclidean');
D = squareform(D);
tree = linkage(D, 'ward','euclidean');
labels = cluster(tree, 'maxclust', n_clus);

% figure
% hold on
% for i = 1:n_clus
%     tem_clr = clr(i, :);
%     tem_idx = labels == i;
%     scatter3(embedding(tem_idx, 1), embedding(tem_idx, 2), embedding(tem_idx, 3), 40, ...
%         'MarkerFaceColor', tem_clr, 'MarkerEdgeColor', tem_clr, 'LineWidth', 0.1)
% end