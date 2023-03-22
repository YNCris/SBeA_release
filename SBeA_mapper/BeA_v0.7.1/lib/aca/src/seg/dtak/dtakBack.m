% function [C, W] = dtakBack(P)
% Trace back to seek the optimum path.
%
% There are two implementations:
%   Matlab version: dtakBackSlow.m
%   C++ version:    dtakBack.cpp
%
% Input
%   P       -  path matrix, n1 x n2
%
% Output
%   C       -  frame correspondance matrix, 2 x m
%   W       -  warping matrix, n1 x n2
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-16-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-22-2009
