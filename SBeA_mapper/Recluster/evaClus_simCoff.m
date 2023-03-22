function [box_plotX, box_tags, box_clors] = evaClus_simCoff(sort_label, sort_distMat, n_clus, label_order)

%ref1: https://www.geeksforgeeks.org/ml-intercluster-and-intracluster-distance/
%ref2: https://www.statisticshowto.com/intraclass-correlation/

sort_label = flipud(sort_label);

n_genColor = 10;
cclr = (cbrewer2('Paired', n_genColor));
[X, Y] = meshgrid([1:3], [1:n_clus]);
if n_clus > n_genColor
    clr = interp2(X(round(linspace(1, n_clus, n_genColor)), :), Y(round(linspace(1, n_clus, n_genColor)), :), cclr, X, Y);
else
    clr = cclr;

end

n_sample = size(sort_distMat, 1);
intra_coffCell = cell(12, 1);
inter_coffCell = cell(12, 1);
box_plotX = []; box_tags = {}; box_clors = [];

for i = 1:n_clus
    idx = label_order(i);
    i
    intra_idx = sort_label == idx;
    inter_idx = sort_label ~= idx;
    tem_nIntra = sum(intra_idx);
    tem_nInter = sum(inter_idx);
    sub_distMatIntra = sort_distMat(intra_idx, :);
    sub_distMatInter = sort_distMat(inter_idx, :);
    intra_coff = zeros(1, tem_nIntra);
    inter_coff = zeros(1, tem_nIntra);
    for j = 1:tem_nIntra
        xx = sub_distMatIntra(j, :);
        tem_all_coffIntra = zeros(1, tem_nIntra);
        for k = 1:tem_nIntra
            yy = sub_distMatIntra(k, :);
            tem_coff = corrcoef(xx, yy);
            tem_all_coffIntra(k) = tem_coff(1, 2);
        end
        intra_coff(j) = mean(tem_all_coffIntra);
        
        
        tem_all_coffInter = zeros(1, tem_nInter);
        for k = 1:tem_nInter
            zz = sub_distMatInter(k, :);
            tem_coff = corrcoef(xx, zz);
            tem_all_coffInter(k) = tem_coff(1, 2);
        end
        inter_coff(j) = mean(tem_all_coffInter);
    end
    pos_intra = ones(tem_nIntra, 1)*(i-0.2);
%     scatter(pos_intra, intra_coff, 200, '.', 'MarkerFaceColor', clr(idx, :), 'MarkerEdgeColor', clr(idx, :))
    pos_inter = ones(tem_nIntra, 1)*(i+0.2);
%     scatter(pos_inter, inter_coff, 200, '.', 'MarkerFaceColor', [.7 .7 .7], 'MarkerEdgeColor', [.7 .7 .7])
    
    intra_coffCell{idx} = intra_coff;
    inter_coffCell{idx} = inter_coff;
    
    box_plotX = [box_plotX, intra_coff, inter_coff];
    tag_intra = repmat({['Intra-', num2str(idx)]}, tem_nIntra, 1);
    tag_inter = repmat({['Inter-', num2str(idx)]}, tem_nIntra, 1);
    box_tags = [box_tags; tag_intra; tag_inter];
    
    clr_intra = repmat(clr(idx, :), tem_nIntra, 1);
    clr_inter = repmat([.7 .7 .7], tem_nIntra, 1);
    box_clors = [box_clors; clr_intra; clr_inter];
end