function dist_mat_all = calculate_dtak_distance(data_sample_cell,sigma)
tic
dist_mat = zeros(size(data_sample_cell,1),size(data_sample_cell,1));
for m = 1:size(data_sample_cell,1)
    for n = m:size(data_sample_cell,1)
        %% get data
        seg_data1 = data_sample_cell{m,1}(1:2,:);
        seg_data2 = data_sample_cell{n,1}(1:2,:);
        %% calculate dtak
		condist_mat = conDist(seg_data1,seg_data2);
		Kdistmat = conKnl(condist_mat,sigma,'knl','g','nei',NaN);
		wFs1 = ones(1,size(Kdistmat,1));
		wFs2 = ones(1,size(Kdistmat,2));
		[T,~,~] = dtakFord(Kdistmat,0,wFs1,wFs2);
        dist_mat(m,n) = T;
    end
    disp(m/size(data_sample_cell,1))
end
toc
%% fill full matrix
dist_mat_all = dist_mat + triu(dist_mat, 1)';