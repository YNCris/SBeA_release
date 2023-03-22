%{
    check features of id images for recognition
%}
clear all
close all
%% set path
filepath = 'Z:\hanyaning\multi_mice_test\Social_analysis\data\disc1_shank3\sbea_shank3_disc1_20220602\datasets\id_images\part-left_ear-right_ear-multi-False\train\B1';
imgname = 'rec6-B1-20220601_0.jpg';
%% load image
I = rgb2gray(imread([filepath,'\',imgname]));
%%
points = detectSURFFeatures(I);
imshow(I); hold on;
plot(points.selectStrongest(50));