% function [sOpt, cOpt, objOpt] = acaFord(K, para, seg, T, lc, wFs)
% Forward step in ACA.
%
% There are two implementations:
%   Matlab version: acaFordSlow.m
%   C++ version:    acaFord.cpp
%
% Input
%   K       -  kernel matrix, n x n
%   seg     -  inital segmentation
%   para    -  segmentation parameter
%   T       -  pairwise DTAK, m x m
%   lc      -  local constraint (Sakoe and Chiba)
%              0 : not used
%              1 : used
%   wFs     -  frame weights, 1 x n
%
% Output
%   sOpt    -  optimum starting position, n x 1
%   cOpt    -  optimum label, n x 1
%   objOpt  -  optimum objective, n x 1
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 12-29-2008
%   modify  -  Feng Zhou (zhfe99@gmail.com), 01-12-2010
