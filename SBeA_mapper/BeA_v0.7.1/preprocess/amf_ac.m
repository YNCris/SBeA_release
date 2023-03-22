function [out_X,out_Y] = amf_ac(X,Y,winw)
% global noise suppression by adaptive median filtering
%
% Input
%   X           -  matrix of X data, N x M (matrix)
%   Y           -  matrix of Y data, N x M (matrix)
%   winw        -  window width, 1 x 1 (integral)
%
% Output
%   out_X           -  matrix of output X data, N x M (matrix)
%   out_Y           -  matrix of output Y data, N x M (matrix)
%
% History
%   create  -  Yaning Han  (yn.han@siat.ac.cn), 03-03-2020

%% adaptive median filtering
out_X = X;
out_Y = Y;
for k = 1:size(X,2)
	out_X(:,k) = amf1(X(:,k),winw);
	out_Y(:,k) = amf1(Y(:,k),winw);
end
