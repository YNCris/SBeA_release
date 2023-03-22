%{

%}
clear all
close all
%%
rootpath = 'Z:\hanyaning\multi_mice_test\Social_analysis\data\disc1_shank3\SBeA_id_data_20220602';
jsonname = 'rec4-K4-20220523-camera-0-rawresult.json';
%%
tempjson = loadjson([rootpath,'\',jsonname]);
%% show
frameidx = 24564;
sel_rles = tempjson.annotations.segmentations(:,frameidx);
mask1 = MaskApi.decode(sel_rles(1));
mask2 = MaskApi.decode(sel_rles(2));

masks = mask1|mask2;

imshow(masks)