function nd_mat = mp_nd(X,Y,lh_mat,minthres,maxthres)
% morphological noise detection
%
% Input
%   X           -  matrix of X data, N x M (matrix)
%   Y           -  matrix of Y data, N x M (matrix)
%   lh_mat      -  matrix of likelihood, N x M (matrix)
%   minthres    -  minimum threshold, 1 x 1 (double)
%   maxthres    -  maximum threshold, 1 x 1 (double)
%
% Output
%   nd_mat    -  matrix of noise detection, N x M (matrix)
%
% History
%   create  -  Yaning Han  (yn.han@siat.ac.cn), 03-03-2020

%% find maximum likelihood frame
lh_list = sum(lh_mat,2);
most_like_frame = find(lh_list == max(lh_list(:)));

%% calculate max distance
distance_mat = [];
for m = 2:size(X,2)
	for n = 2:size(Y,2)
		distance_mat = [distance_mat,...
			((X(most_like_frame,m) - X(most_like_frame,n)).^2+...
			(Y(most_like_frame,m) - Y(most_like_frame,n)).^2).^0.5];
	end
end
max_distance = max(distance_mat(:));

%% morphological noise detection
nd_mat = zeros(size(lh_mat));
for j = 1:size(X,1)
	for m = 1:size(X,2)
		temp_dist = [];
		for n = 1:size(Y,2)
			temp_dist = [temp_dist,...
				((X(j,m)-X(j,n)).^2+...
				(Y(j,m)-Y(j,n)).^2).^0.5];
		end
		%global limits
		if max(temp_dist(:))>(max_distance*maxthres)
			nd_mat(j,:) = 1;
		end
		temp_dist(temp_dist==0)=[];
		%local limits
		if min(temp_dist(:))>(max_distance/minthres)
			nd_mat(j,:) = 1;
		end
	end
end