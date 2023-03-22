function CQI = calClus_qulity(distMat, labels)

%ref1: https://www.geeksforgeeks.org/ml-intercluster-and-intracluster-distance/
%ref2: https://www.statisticshowto.com/intraclass-correlation/

n_sample = size(distMat, 1);
CQI = zeros(1, n_sample);

n_clus = length(unique(labels));

intra_coffCell = cell(n_clus, 1);
inter_coffCell = cell(n_clus, 1);

for i = 1:n_clus
    tic
    intra_idx = labels == i;
    inter_idx = labels ~= i;
    tem_nIntra = sum(intra_idx);
    tem_nInter = sum(inter_idx);
    sub_distMatIntra = distMat(intra_idx, :);
    sub_distMatInter = distMat(inter_idx, :);
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
    intra_coffCell{i} = intra_coff;
    inter_coffCell{i} = inter_coff;
    
    m = -1; b = 0;
    perpSlope = -1/m;
    yInt = -perpSlope * inter_coff + intra_coff;
    xProj = (yInt - b) / (m - perpSlope);
    yProj = perpSlope * xProj + yInt;
    CQI(intra_idx) = 2./(1+ exp(-8.*yProj))-1;
    toc
    disp(i)
end