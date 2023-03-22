function [out_X,out_Y] = nmf_ac(X,Y,nd,winw)
% local noise suppression by median filtering
%
% Input
%   X           -  matrix of X data, N x M (matrix)
%   Y           -  matrix of Y data, N x M (matrix)
%   nd          -  matrix of noise detection, N x M (matrix)
%   winw        -  window width, 1 x 1 (integral)
%
% Output
%   out_X           -  matrix of output X data, N x M (matrix)
%   out_Y           -  matrix of output Y data, N x M (matrix)
%
% History
%   create  -  Yaning Han  (yn.han@siat.ac.cn), 03-03-2020

% noise median filtering
out_X = X;
out_Y = Y;
for m = round((winw-1)/2+1):round(size(nd,1)-(winw-1)/2-1)
	for n = 1:size(nd,2)
		if nd(m,n) == 1
			startwin = m-round((winw-1)/2);
			endwin = m+round((winw-1)/2);
			out_X(m,n) = median(X(startwin:endwin,n));
			out_Y(m,n) = median(Y(startwin:endwin,n));
		end
	end
end
