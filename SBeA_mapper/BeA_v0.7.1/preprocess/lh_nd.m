function nd_mat = lh_nd(lh_mat, thres)

% likelihood noise detection
%
% Input
%   lh_mat    -  matrix of likelihood, N x M (matrix)
%   thres     -  threshold, 1 x 1 (double)
%
% Output
%   nd_mat    -  matrix of noise detection, N x M (matrix)
%
% History
%   create  -  Yaning Han  (yn.han@siat.ac.cn), 03-03-2020

%% likelihood noise detection
nd_mat = lh_mat;
nd_mat(lh_mat<=thres) = 1;
nd_mat(lh_mat>thres) = 0;


