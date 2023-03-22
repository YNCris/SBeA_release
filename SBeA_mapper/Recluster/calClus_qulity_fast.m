function CQI = calClus_qulity_fast(distMat, labels)

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

    sub_distMatIntra = distMat(intra_idx, :);
    temp_distMatInter = distMat(inter_idx, :);

    sub_distMatInter = temp_distMatInter(...
        randi(size(temp_distMatInter,1),1,sum(intra_idx)),:);

    intra_coff = mean(corrcoef(sub_distMatIntra'));
    temp_inter_coff = mean(corrcoef(sub_distMatInter'));
    tem_nIntra = sum(intra_idx);
    inter_coff = temp_inter_coff(1,1:tem_nIntra);
    
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