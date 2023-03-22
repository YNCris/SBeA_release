%{
    显示四视角 或 八视角
%}
clear all
close all
%% set path
rootpath = ['Z:\hanyaning\multi_mice_test\Social_analysis\' ...
    'data\disc1_shank3\SBeA_data_20220602'];
videorootname = 'rec2-R6R2-20220531';
videonamelist = cell(4,1);
for k = 1:4
    videonamelist{k} = [videorootname,'-camera-',num2str(k-1),'.avi'];
end
%% load vidobj
vidobj_cell = cell(size(videonamelist));
for k = 1:size(vidobj_cell,1)
    vidobj_cell{k,1} = VideoReader([rootpath,'\',videonamelist{k,1}]);
end
%% show image
selframe = 300;
h1 = figure(1);
set(h1,'Position',[100,100,1280,720])
set(h1,'color','white');
for k = 1:size(vidobj_cell,1)
    subplot(2,2,k)
    frame = read(vidobj_cell{k},selframe);
    imshow(frame)
    title(['Camera view angle: ',num2str(k)])
end


%%
%% set path
% rootpath = ['X:\wangnan\dog\221020-2月龄马犬行为学原始视频' ...
%     '\maquan20221020-001'];
% videonamelist = cell(8,1);
% for k = 1:size(videonamelist,1)
%     videonamelist{k} = [num2str(k),'.avi'];
% end
% %% load vidobj
% vidobj_cell = cell(size(videonamelist));
% for k = 1:size(vidobj_cell,1)
%     vidobj_cell{k,1} = VideoReader([rootpath,'\',videonamelist{k,1}]);
% end
% %% show image
% selframe = 800;
% h1 = figure(1);
% set(h1,'Position',[100,100,1280,360])
% set(h1,'color','white');
% for k = 1:size(vidobj_cell,1)
%     subplot(2,4,k)
%     frame = read(vidobj_cell{k},selframe);
%     imshow(frame)
%     title(['Camera view angle: ',num2str(k)])
% end






