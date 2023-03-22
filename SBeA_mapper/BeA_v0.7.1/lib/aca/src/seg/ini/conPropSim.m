% function K = conPropSim(K0, nMa)
% Construct the progagative similarity matrix.
%
% There are two implementations:
%   Matlab version: conPropSimSlow.m
%   C++ version:    conPropSim.cpp
%
% Input
%   K0      -  frame similarity matrix, n x n
%   nMa     -  maximum width of motion
%
% Output
%   K       -  non-time-warping similarity matrix, n x n
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-13-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-22-2009
