%{
    show camera pose
%}
clear all
close all
%% set path
calipath = 'X:\wangnan';
caliname = 'calibrationParas.mat';
%% load data
load([calipath,'\',caliname]);
%% show cam pose
cam_size = 50;
show_cam_pose_old(caliParams,cam_size)