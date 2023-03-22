function [isDef, T, eigMi] = segDef(K, seg, lc)
% Testify whether the DTAK kernel is definite or not.
% If the minimum eigenvalue of the DTAK kernel matrix is negative, 
% we conclude that the kernel is indefinite.
%
% Input
%   K       -  frame similarity matrix, n x n
%   seg     -  segmentation
%   lc      -  local constraint (Sakoe and Chiba)
%              0 : not used
%              1 : used
%
% Output
%   isDef   -  definiteness flag
%   T       -  DTAK matrix, m x m
%   eigMi   -  minimum eigen value
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-12-2010
%   modify  -  Feng Zhou (zhfe99@gmail.com), 01-12-2010

if nargin < 3
    lc = 0;
end

T = dtaksFord(K, seg, lc);
[V, D] = eig(T);
eigMi = min(diag(D));

isDef = eigMi >= 0;
