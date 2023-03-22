function labels = re_cluster(embedding, n_clus)

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
leafOrder = optimalleaforder(tree, D);

colorThr = mean(tree(end-n_clus+1 : end-n_clus+2,3));

[H, ~, perm]= dendrogram(tree, 0, 'reorder', leafOrder, 'Orientation', 'left', ...
    'ColorThreshold', colorThr);
lineColours = cell2mat(get(H, 'Color'));
colourList = unique(lineColours, 'rows');
for colour = 2:size(colourList, 1)
    % Find which lines match this colour
    idx = ismember(lineColours, colourList(colour,:), 'rows');
    % Replace the colour for those lines
    lineColours(idx, :) = repmat(clr(colour-1,:), sum(idx),1);
end

% Apply the new colours to the chart's line objects (line by line)
for line = 1:size(H,1)
    set(H(line), 'Color', lineColours(line,:));
end

newLineColors = cell2mat(get(H, 'Color'));
new_label = zeros(size(embedding, 1), 1);

figure
hold on
for i = 1:n_clus
    tem_clr = clr(i, :);
    clr_idx = find(ismember(newLineColors, tem_clr, 'rows'));
    temClust_idx = [];
    for iIdx = 1:length(clr_idx)
        temClust_idx = [temClust_idx, H(clr_idx(iIdx)).YData];
    end
    tem_idx = unique(leafOrder(unique(round(temClust_idx))));
    
    new_label(tem_idx) = i;
end

close 
%% return new labels
labels = new_label; 