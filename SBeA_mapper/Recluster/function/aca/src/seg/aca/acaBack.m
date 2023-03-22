% function seg = acaBack(k, sOpt, cOpt)
% Trace back to determine the segmentation.
%
% There are two implementations:
%   Matlab version: acaBackSlow.m
%   C++ version:    acaBack.cpp
%
% Input
%   k       -  #class
%   sOpt    -  optimum starting position, 1 x n
%   cOpt    -  optimum label, 1 x n
%
% Output
%   seg     -  segmentation
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 07-28-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-22-2009
