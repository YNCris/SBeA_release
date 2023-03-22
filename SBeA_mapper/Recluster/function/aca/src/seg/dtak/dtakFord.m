% function [v, P, KC] = dtakFord(K, lc, wF1s, wF2s)
% Move forward to construct the path matrix.
%
% There are two implementations:
%   Matlab version: dtakFordSlow.m
%   C++ version:    dtakFord.cpp
%
% Input
%   K       -  frame similarity matrix, n1 x n2
%   lc      -  local constraint (Sakoe and Chiba)
%              0 : not used
%              1 : used
%   wF1s    -  frame weight of 1st sequence, 1 x n1
%   wF2s    -  frame weight of 2nd sequence, 1 x n2
%
% Output
%   v       -  dtak value
%   P       -  path matrix, n1 x n2
%   KC      -  cummulative similarity matrix, n1 x n2
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 03-20-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 01-13-2010
