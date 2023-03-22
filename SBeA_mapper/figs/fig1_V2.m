%{
    fig1, the framework of SBeA
%}
clear all
close all
addpath(genpath(pwd))
%% set path
rootpath = 'Z:\hanyaning\multi_mice_test\Social_analysis\data\figs\fig1';
rootpathfig2 = 'Z:\hanyaning\multi_mice_test\Social_analysis\data\figs\fig2';
%% load videos
vidobjm1_0 = VideoReader([rootpath,'\panel_1\rec1-A1-20220803-camera-0.avi']);
vidobjm1_1 = VideoReader([rootpath,'\panel_1\rec1-A1-20220803-camera-1.avi']);
vidobjm1_2 = VideoReader([rootpath,'\panel_1\rec1-A1-20220803-camera-2.avi']);
vidobjm1_3 = VideoReader([rootpath,'\panel_1\rec1-A1-20220803-camera-3.avi']);
vidobjm2_0 = VideoReader([rootpath,'\panel_1\rec2-A2-20220803-camera-0.avi']);
vidobjm2_1 = VideoReader([rootpath,'\panel_1\rec2-A2-20220803-camera-1.avi']);
vidobjm2_2 = VideoReader([rootpath,'\panel_1\rec2-A2-20220803-camera-2.avi']);
vidobjm2_3 = VideoReader([rootpath,'\panel_1\rec2-A2-20220803-camera-3.avi']);
vidobjm1m2_0 = VideoReader([rootpath,'\panel_1\rec11-A1A2-20220803-camera-0.avi']);
vidobjm1m2_1 = VideoReader([rootpath,'\panel_1\rec11-A1A2-20220803-camera-1.avi']);
vidobjm1m2_2 = VideoReader([rootpath,'\panel_1\rec11-A1A2-20220803-camera-2.avi']);
vidobjm1m2_3 = VideoReader([rootpath,'\panel_1\rec11-A1A2-20220803-camera-3.avi']);
%% load data
datarootpath = [rootpath,'\panel_2\show_seg_pos'];
fileFolder = fullfile(datarootpath);
dirOutput = dir(fullfile(fileFolder,'*caliParas.mat'));
calinamelist = {dirOutput.name}';
cam_num = 4;
mouse_num = 2;
dlc_name = 'DLC_resnet50_shank3resolution1kMay24shuffle1_1030000';
k=1;
% load one name
tempname = calinamelist{k,1}(1,1:(end-14));

%

videonamelist = {};
jsonnamelist = {};
csvnamelist = cell(cam_num,mouse_num);
for m = 1:cam_num
    videonamelist = [videonamelist;...
        [tempname,'-camera-',num2str(m-1),'.avi']];
    jsonnamelist = [jsonnamelist;...
        [tempname,'-camera-',num2str(m-1),'-correctedresult.json']];
    for n = 1:mouse_num
        csvnamelist{m,n} = ...
            [tempname,'-camera-',num2str(m-1),...
            '-masked-',num2str(n),dlc_name,'.csv'];
    end
end

raw3dname = [tempname,'-raw3d.mat'];
id3dname = [tempname,'-corrpredid.csv'];
new3dname = [tempname,'-id3d.mat'];
rot3dname = [tempname,'-rot3d.mat'];

%  load data
vidobj_list = cell(size(videonamelist));
jsonlist = cell(size(jsonnamelist));
for m = 1:cam_num
    vidobj_list{m,1} = VideoReader([datarootpath,'\',videonamelist{m,1}]);
    jsonlist{m,1} = loadjson([datarootpath,'\',jsonnamelist{m,1}]);
    disp(m)
end

csvlist = cell(size(csvnamelist));
for m = 1:size(csvlist,1)
    for n = 1:size(csvlist,2)
        [NUM,TXT,RAW] = xlsread([datarootpath,'\temp\',csvnamelist{m,n}]);
        csvlist{m,n} = NUM;
        csvlist{m,n}(:,1:3:end) = [];
    end
end

raw3d = load([datarootpath,'\',raw3dname]);
new3d = load([datarootpath,'\',new3dname]);
rot3d = load([datarootpath,'\',rot3dname]);

[NUM,TXT,RAW] = xlsread([datarootpath,'\',id3dname]);
id2d = TXT;

datalen = size(raw3d.coords3d,1);

temppair = raw3d.pair3d;
temperr = raw3d.err3d;

sklcenter = mean(new3d.coords3d,1);
sklcenter_x = mean(sklcenter(1:3:end));
sklcenter_y = mean(sklcenter(2:3:end));
sklcenter_z = mean(sklcenter(3:3:end));

load([rootpath,'\panel_3\SBeA_data_sample_cell_20220712.mat']);
load([rootpath,'\panel_3\SBeA_wc_struct_20220712.mat']);
%%
%% plot canvas
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
set(h1,'color','white');
setcolor = cbrewer2('Spectral',11);
mouse1_c = setcolor(3,:);
mouse2_c = setcolor(9,:);
% video capture
upbias = 0.05;
% 1. mice in cage
cagename = [rootpath,'\panel_1\cage_2mice.jpg'];
cageimg = imread(cagename);
subplot('Position',[0.03,0.75+upbias,0.12,0.12])
imshow(cageimg)
title('Mice in home-cage')

s_mouseimg = imread([rootpath,'\panel_1\mouse1.png']);
subplot('Position',[0.22,0.78+upbias,0.05,0.05])
imshow(s_mouseimg)

s_mouseimg = imread([rootpath,'\panel_1\mouse1.png']);
subplot('Position',[0.22,0.85+upbias,0.05,0.05])
imshow(s_mouseimg)

m_mouseimg = imread([rootpath,'\panel_1\mouse2.png']);
subplot('Position',[0.2,0.71+upbias,0.09,0.05])
imshow(m_mouseimg)

oft3dimg = imread([rootpath,'\panel_1\oft3d.png']);
subplot('Position',[0.34,0.7+upbias,0.3,0.2])
imshow(oft3dimg)
title('MouseVenue3D')

% m1
frame_idx = 1;
m1_size = 0.065;
m1_inter = 0.002;
m1_start_x = 0.7;
m1_start_y = 0.84+upbias;
subplot('Position',[m1_start_x,m1_start_y,m1_size,m1_size])
imshow(read(vidobjm1_0,frame_idx))
set(gca,'XTick',[],'YTick',[])
ylabel('M1')
subplot('Position',[m1_start_x+m1_inter+m1_size,m1_start_y,m1_size,m1_size])
imshow(read(vidobjm1_1,frame_idx))
set(gca,'XTick',[],'YTick',[])
subplot('Position',[m1_start_x+2*m1_inter+2*m1_size,m1_start_y,m1_size,m1_size])
imshow(read(vidobjm1_2,frame_idx))
set(gca,'XTick',[],'YTick',[])
subplot('Position',[m1_start_x+3*m1_inter+3*m1_size,m1_start_y,m1_size,m1_size])
imshow(read(vidobjm1_3,frame_idx))
set(gca,'XTick',[],'YTick',[])

% m2
frame_idx = 1;
% m1_size = 0.06;
% m1_inter = 0.01;
% m1_start_x = 0.7;
m1_start_y = 0.77+upbias;
subplot('Position',[m1_start_x,m1_start_y,m1_size,m1_size])
imshow(read(vidobjm2_0,frame_idx))
set(gca,'XTick',[],'YTick',[])
ylabel('M2')
subplot('Position',[m1_start_x+m1_inter+m1_size,m1_start_y,m1_size,m1_size])
imshow(read(vidobjm2_1,frame_idx))
set(gca,'XTick',[],'YTick',[])
subplot('Position',[m1_start_x+2*m1_inter+2*m1_size,m1_start_y,m1_size,m1_size])
imshow(read(vidobjm2_2,frame_idx))
set(gca,'XTick',[],'YTick',[])
subplot('Position',[m1_start_x+3*m1_inter+3*m1_size,m1_start_y,m1_size,m1_size])
imshow(read(vidobjm2_3,frame_idx))
set(gca,'XTick',[],'YTick',[])

% m1m2
frame_idx = 2265;
% m1_size = 0.06;
% m1_inter = 0.01;
% m1_start_x = 0.7;
m1_start_y = 0.7+upbias;
subplot('Position',[m1_start_x,m1_start_y,m1_size,m1_size])
imshow(read(vidobjm1m2_0,frame_idx))
set(gca,'XTick',[],'YTick',[])
ylabel('M1&2')
subplot('Position',[m1_start_x+m1_inter+m1_size,m1_start_y,m1_size,m1_size])
imshow(read(vidobjm1m2_1,frame_idx))
set(gca,'XTick',[],'YTick',[])
subplot('Position',[m1_start_x+2*m1_inter+2*m1_size,m1_start_y,m1_size,m1_size])
imshow(read(vidobjm1m2_2,frame_idx))
set(gca,'XTick',[],'YTick',[])
subplot('Position',[m1_start_x+3*m1_inter+3*m1_size,m1_start_y,m1_size,m1_size])
imshow(read(vidobjm1m2_3,frame_idx))
set(gca,'XTick',[],'YTick',[])

%% networks
% segmentation
netcolorlist = cbrewer2('Pastel1',9);
cov1_c = netcolorlist(4,:);
cov2_c = netcolorlist(4,:);
att1_c = netcolorlist(1,:);
netcolorlist = cbrewer2('Set3',12);
att2_c = netcolorlist(1,:);
subplot('Position',[0.03,0.53,0.17,0.17])
bias1 = 80;
bias2 = 10;
bias3 = 4;
thick = 3;
shrscale = 1;
inter1 = 10;
plotcube(fliplr([130 130 thick]),fliplr([-65  -65  4*inter1]),.8,cov1_c)
plotcube(fliplr([90 90 thick]),fliplr([-45  -45  3*inter1]),.8,cov1_c)
plotcube(fliplr([70 70 thick]),fliplr([-35  -35  2*inter1]),.8,cov1_c)
plotcube(fliplr([50 50 thick]),fliplr([-25  -25  inter1]),.8,cov1_c)
plotcube(fliplr([30 30 thick]),fliplr([-15  -15  0*inter1]),.8,cov1_c)

plotcube(fliplr([10 10 10]),fliplr([5  -5  -20]),.8,att1_c)
plotcube(fliplr([10 10 10]),fliplr([25  -5  -20]),.8,att1_c)
plotcube(fliplr([10 10 10]),fliplr([45  -5  -20]),.8,att1_c)
plotcube(fliplr([-10 10 10]),fliplr([-5  -5  -20]),.8,att1_c)
plotcube(fliplr([-10 10 10]),fliplr([-25  -5  -20]),.8,att1_c)
plotcube(fliplr([-10 10 10]),fliplr([-45  -5  -20]),.8,att1_c)

plotcube(fliplr([10 10 10]),fliplr([5  -5  -40]),.8,att2_c)
plotcube(fliplr([10 10 10]),fliplr([25  -5  -40]),.8,att2_c)
plotcube(fliplr([10 10 10]),fliplr([45  -5  -40]),.8,att2_c)
plotcube(fliplr([-10 10 10]),fliplr([-5  -5  -40]),.8,att2_c)
plotcube(fliplr([-10 10 10]),fliplr([-25  -5  -40]),.8,att2_c)
plotcube(fliplr([-10 10 10]),fliplr([-45  -5  -40]),.8,att2_c)

plotcube(fliplr([30 10 10]),fliplr([-15  -5  -60]),.8,att2_c)

hold on
plot3([0+thick,inter1],[0,0],[0,0],'k')
hold on
plot3([inter1+thick,2*inter1],[0,0],[0,0],'k')
hold on
plot3([2*inter1+thick,3*inter1],[0,0],[0,0],'k')
hold on
plot3([3*inter1+thick,4*inter1],[0,0],[0,0],'k')

hold on
plot3([0,-10],[0,0],[0,10],'k')
hold on
plot3([0,-10],[0,0],[0,30],'k')
hold on
plot3([0,-10],[0,0],[0,50],'k')
hold on
plot3([0,-10],[0,0],[0,-10],'k')
hold on
plot3([0,-10],[0,0],[0,-30],'k')
hold on
plot3([0,-10],[0,0],[0,-50],'k')

hold on
plot3([-20,-30],[0,0],[10,10],'k')
hold on
plot3([-20,-30],[0,0],[30,30],'k')
hold on
plot3([-20,-30],[0,0],[50,50],'k')
hold on
plot3([-20,-30],[0,0],[-10,-10],'k')
hold on
plot3([-20,-30],[0,0],[-30,-30],'k')
hold on
plot3([-20,-30],[0,0],[-50,-50],'k')

hold on
plot3([-40,-50],[0,0],[10,0],'k')
hold on
plot3([-40,-50],[0,0],[30,0],'k')
hold on
plot3([-40,-50],[0,0],[50,0],'k')
hold on
plot3([-40,-50],[0,0],[-10,0],'k')
hold on
plot3([-40,-50],[0,0],[-30,0],'k')
hold on
plot3([-40,-50],[0,0],[-50,0],'k')
hold off
% axis equal
% view(2)
view(-168,23)
% axis on
% xlabel('x')
% ylabel('y')
% zlabel('z')
axis off

% reid
subplot('Position',[0.2,0.62,0.17,0.1])

bias1 = 80;
bias2 = 10;
bias3 = 4;
thick = 0.5;
shrscale = 1;
bias4 = 0.5;
netcolorlist = cbrewer2('Pastel1',9);
cov1_c = netcolorlist(8,:);
cov2_c = netcolorlist(1,:);
cov3_c = netcolorlist(2,:);
cov4_c = netcolorlist(3,:);
% plotcube([thick 70 70]/shrscale,[0  0  0]/shrscale,.8,cov1_c)
% plotcube([thick 70 70]/shrscale,[2  0  0]/shrscale,.8,cov1_c)

plotcube([thick 60 60]/shrscale,[6  5  5]/shrscale,.8,cov1_c)
plotcube([thick 60 60]/shrscale,[8  5  5]/shrscale,.8,cov1_c)
plotcube([thick 60 60]/shrscale,[8+thick  5  5]/shrscale,.8,cov1_c)

plotcube([thick*2 40 40]/shrscale,[12+thick  15  15]/shrscale,.8,cov2_c)
plotcube([thick*2 40 40]/shrscale,[14+thick*2  15  15]/shrscale,.8,cov2_c)
plotcube([thick*2 40 40]/shrscale,[14+thick*4  15  15]/shrscale,.8,cov2_c)

plotcube([thick*3 20 20]/shrscale,[18+thick*6  25  25]/shrscale,.8,cov3_c)
plotcube([thick*3 20 20]/shrscale,[20+thick*9  25  25]/shrscale,.8,cov3_c)
plotcube([thick*3 20 20]/shrscale,[20+thick*12  25  25]/shrscale,.8,cov3_c)

plotcube([thick*4 10 10]/shrscale,[24+thick*15  30  30]/shrscale,.8,cov4_c)
plotcube([thick*4 10 10]/shrscale,[26+thick*19  30  30]/shrscale,.8,cov4_c)
plotcube([thick*4 10 10]/shrscale,[26+thick*23  30  30]/shrscale,.8,cov4_c)

% hold on
% plot3([0+thick,2]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
% hold on
% plot3([2+thick,6]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')

hold on
plot3([6+thick,8]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
hold on
plot3([8+thick,12+thick]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')

hold on
plot3([12+3*thick,14+thick*2]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
hold on
plot3([14+thick*6,18+thick*6]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')

hold on
plot3([18+thick*9,20+thick*9]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
hold on
plot3([20+thick*15,24+thick*15]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')

hold on
plot3([24+thick*19,26+thick*19]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
hold off

% xlabel('x')
% ylabel('y')
% zlabel('z')
view(2)
axis off
view(8,26)

% pose estimation
subplot('Position',[0.2,0.52,0.17,0.1])
view(-174,34)
bias1 = 80;
bias2 = 10;
bias3 = 4;
thick = 0.5;
shrscale = 1;
bias4 = 0.5;
netcolorlist = cbrewer2('Pastel1',9);
cov1_c = netcolorlist(2,:);
cov2_c = netcolorlist(2,:);
cov3_c = netcolorlist(1,:);
cov4_c = netcolorlist(4,:);
cov5_c = netcolorlist(4,:);
plotcube([thick 70 70]/shrscale,[0  0  0]/shrscale,.8,cov1_c)
plotcube([thick 60 60]/shrscale,[2  5  5]/shrscale,.8,cov2_c)
plotcube([thick 50 50]/shrscale,[4  10  10]/shrscale,.8,cov3_c)
plotcube([thick 60 60]/shrscale,[6  5  5]/shrscale,.8,cov4_c)
plotcube([thick 70 70]/shrscale,[8  0  0]/shrscale,.8,cov5_c)

hold on
plot3([0+thick,2]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
hold on
plot3([2+thick,4]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
hold on
plot3([4+thick,6]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
hold on
plot3([6+thick,8]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')

hold on
plot3([2-bias4,2-bias4]/shrscale,[35,35]/shrscale,[35,90]/shrscale,'k')
hold on
plot3([4-bias4,4-bias4]/shrscale,[35,35]/shrscale,[35,90]/shrscale,'k')
hold on
plot3([6-bias4,6-bias4]/shrscale,[35,35]/shrscale,[35,90]/shrscale,'k')

hold on
plot3([2+thick+bias4,2+thick+bias4]/shrscale,[35,35]/shrscale,[35,90]/shrscale,'k')
hold on
plot3([4+thick+bias4,4+thick+bias4]/shrscale,[35,35]/shrscale,[35,90]/shrscale,'k')
hold on
plot3([6+thick+bias4,6+thick+bias4]/shrscale,[35,35]/shrscale,[35,90]/shrscale,'k')

hold on
plot3([2-bias4,2+thick+bias4]/shrscale,[35,35]/shrscale,[90,90]/shrscale,'k')
hold on
plot3([4-bias4,4+thick+bias4]/shrscale,[35,35]/shrscale,[90,90]/shrscale,'k')
hold on
plot3([6-bias4,6+thick+bias4]/shrscale,[35,35]/shrscale,[90,90]/shrscale,'k')

hold off
% title({'Single Animal','Pose Estimation'},'Color','blue')
view(-171,15)
axis off

% segmentation and pose in 2D
start_plot_x = 0.4;
start_plot_y = 0.53;
plotsize = 0.09;
intersize = 0.002;
selidx = 2265;
mousename = cellstr(new3d.name3d);
mouseclr = [mouse1_c;mouse2_c];%[1,0,0;0,0,1];

m = selidx;
 % read frames
framelist = cell(size(vidobj_list));
for n = 1:size(framelist,1)
    framelist{n,1} = read(vidobj_list{n,1},m);
end

% read masks
masklist = cell(size(jsonlist,1),2);
for n = 1:size(masklist,1)
    temprle = jsonlist{n,1}.annotations.segmentations(:,m);
    mask1 = MaskApi.decode(temprle(1));
    mask2 = MaskApi.decode(temprle(2));
    masklist{n,1} = mask1;
    masklist{n,2} = mask2;
end

% read 2d poses
poslist = cell(size(csvlist));
for p = 1:size(csvlist,1)
    for q = 1:size(csvlist,2)
        poslist{p,q} = csvlist{p,q}(m,:);
    end
end
% read id
frameid = id2d(m,:);

% read frame pairs
framepair = reshape(temppair(m,:,:,:),[2,4,2]);
framepair_cell = {1,2};
for n = 1:2
    framepair_cell{1,n} = reshape(framepair(n,:,:),[4,2]);
    framepair_cell{1,n} = sortrows(framepair_cell{1,n},1);
end

framepair_list = zeros(4,2);
for n = 1:2
    framepair_list(:,n) = framepair_cell{1,n}(:,2);
end

% pair all pairs
pair_poslist = cell(size(poslist));
pair_masklist = cell(size(masklist));

for n = 1:size(pair_poslist,1)
    pair_poslist(n,:) = poslist(n,framepair_list(n,:));
    pair_masklist(n,:) = masklist(n,framepair_list(n,:));
end
% create one frame
show_frame_list = cell(size(framelist));
id_frame_list = cell(size(pair_masklist));
for n = 1:size(show_frame_list,1)
    %
    tempframe = framelist{n,1};
    tempmasklist = pair_masklist(n,:);
    tempposlist = pair_poslist(n,:);
    % create box list
    tempboxlist = cell(size(tempmasklist));
    for p = 1:mouse_num
        tempmask = tempmasklist{1,p};
        [x,y] = find(tempmask==1);
        tempboxlist{1,p} = [min(y),min(x),...
            max(y)-min(y),max(x)-min(x)];
    end
    % add masks
    for p = 1:mouse_num
        tempframe = labeloverlay(tempframe,tempmasklist{1,p},...
            'Colormap',mouseclr(strcmp(mousename,frameid{1,p}),:),...
            'Transparency',0.6);
    end
    % add boxes and names
    for p = 1:mouse_num
%         tempframe = insertShape(tempframe,'Rectangle',...
%             tempboxlist{1,p},...
%             'Color',255*mouseclr(strcmp(mousename,frameid{1,p}),:),'LineWidth',5);
%         tempframe = insertText(tempframe,tempboxlist{1,p}(1,1:2)-6,...
%             frameid{1,p},'AnchorPoint','LeftBottom',...
%             'TextColor',255*mouseclr(strcmp(mousename,frameid{1,p}),:),...
%             'FontSize',20);
    end
    
    boundsize = [100,250,250,200];

    % add poses
    for p = 1:mouse_num
        showpos = [tempposlist{1,p}(1:2:end)',tempposlist{1,p}(2:2:end)'];
        tempframe = insertShape(tempframe,'FilledCircle',...
            [showpos,ones(size(showpos,1),1)*3*boundsize(n)/100]);
%         tempframe = insertMarker(tempframe,showpos,'*','Size',4,'Color','yellow');
    end
    
    % create id frames
    for p = 1:mouse_num
        start_y = tempboxlist{1,p}(1,1);
        start_x = tempboxlist{1,p}(1,2);
        end_y = start_y + tempboxlist{1,p}(1,3);
        end_x = start_x + tempboxlist{1,p}(1,4);             
        id_frame_list{n,p} = framelist{n,1}(start_x:end_x,start_y:end_y,:);
    end
    
    % crop areas
    miny = min([tempboxlist{1,1}(1,1),tempboxlist{1,2}(1,1)]);
    minx = min([tempboxlist{1,1}(1,2),tempboxlist{1,2}(1,2)]);
    maxy = max([tempboxlist{1,1}(1,1)+tempboxlist{1,1}(1,3),...
                tempboxlist{1,2}(1,1)+tempboxlist{1,2}(1,3)]);
    maxx = max([tempboxlist{1,1}(1,2)+tempboxlist{1,1}(1,4),...
                tempboxlist{1,2}(1,2)+tempboxlist{1,2}(1,4)]);
    
    cent_x = (minx+maxx)/2;
    cent_y = (miny+maxy)/2;
    

    cropframe = tempframe((cent_x-boundsize(n)):(cent_x+boundsize(n)),...
        (cent_y-boundsize(n)):(cent_y+boundsize(n)),:);



    show_frame_list{n,1} = cropframe;
end
%1
subplot('Position',[start_plot_x,start_plot_y+plotsize+intersize,plotsize,plotsize])
imshow(show_frame_list{1})
% title('                         Identification and pose estimation in 2D')
%2
subplot('Position',[start_plot_x+plotsize+intersize,start_plot_y+plotsize+intersize,plotsize,plotsize])
imshow(show_frame_list{2})
%3
subplot('Position',[start_plot_x,start_plot_y,plotsize,plotsize])
imshow(show_frame_list{3})
%4
subplot('Position',[start_plot_x+plotsize+intersize,start_plot_y,plotsize,plotsize])
imshow(show_frame_list{4})
%% 3D poses
h14 = subplot('Position',[0.62,0.52,0.16,0.18]);
sel_frame = selidx;
dotsize = 10;
temppos = load([rootpath,'\panel_2\show_seg_pos\rec11-A1A2-20220803-id3d.mat']);
mouse2 = temppos.coords3d(:,1:48);
mouse1 = temppos.coords3d(:,49:96);
drawline = [ 1 2; 1 3;2 3; 4 5;4 6;5 7;6 8;7 14;8 14;...
    5 9;7 11;6 10; 8 12;14 15; 15 16];
nfeatures = 16;
colorclass = ones(256,1)*mouse1_c; %jet is default in DLC
color_map_self=colorclass(ceil(linspace(1,256,nfeatures)),:);
% h14 = subplot('Position',[0.06,0.28,0.17,0.17]);
mesh_mouse(mouse1, sel_frame)
hold on
temp = reshape(mouse1(sel_frame,:,1),3,nfeatures);
scatter3(temp(1,:),temp(2,:),temp(3,:),dotsize*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', h14);
hold on;
for l = 1:size(drawline,1)
    pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
    line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1,'Parent', h14)
end
hold on
colorclass = ones(256,1)*mouse2_c; %jet is default in DLC
color_map_self=colorclass(ceil(linspace(1,256,nfeatures)),:);
mesh_mouse(mouse2, sel_frame)
hold on
temp = reshape(mouse2(sel_frame,:,1),3,nfeatures);
scatter3(temp(1,:),temp(2,:),temp(3,:),dotsize*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', h14);
hold on;
for l = 1:size(drawline,1)
    pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
    line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1,'Parent', h14)
end
hold off
view(-44,46)
xlabel('x')
ylabel('y')
zlabel('z')
set(gca,'TickDir','none')
set(gca,'XTickLabel',[])
set(gca,'YTickLabel',[])
set(gca,'ZTickLabel',[])
% axis([-350,-170,50,250,-10,100])
grid on
% title('3D Poses','Color','blue')
%% trajectories
showtraj1 = mouse1(4000:5000,:)';
showtraj1 = zscore(showtraj1,1);
showtraj2 = mouse2(4000:5000,:)';
showtraj2 = zscore(showtraj2,1);
bias = 0.5;
filt_len = 30;
subplot('Position',[0.82,0.63,0.15,0.08])
for k = 1:6
    plot(medfilt1(showtraj1(k,:),filt_len)+k*bias,'-','Color',mouse1_c)
    hold on
end
hold on
axis off

for k = 43:48
    plot(medfilt1(showtraj1(k,:),filt_len)+(k-30)*bias,'-','Color',mouse1_c)
    hold on
end
hold off
box off

subplot('Position',[0.82,0.54,0.15,0.08])
for k = 1:6
    plot(medfilt1(showtraj2(k,:),filt_len)+k*bias,'-','Color',mouse2_c)
    hold on
end
hold on

for k = 43:48
    plot(medfilt1(showtraj2(k,:),filt_len)+(k-30)*bias,'-','Color',mouse2_c)
    hold on
end
hold off
box off
axis off
%% social behavior atlas
start_plot_x = 0.03;
start_plot_y = 0.25;
plotsize = 0.08;
intersize = 0.002;
% parallel decomposition
subplot('Position',[start_plot_x,start_plot_y+2*(intersize+plotsize),plotsize,plotsize])
imshow(s_mouseimg)
title('Locomotion')
subplot('Position',[start_plot_x+intersize+plotsize,start_plot_y+2*(intersize+plotsize),plotsize,plotsize])
imshow(s_mouseimg)
subplot('Position',[start_plot_x,start_plot_y+intersize+plotsize,plotsize,plotsize])
imshow(s_mouseimg)
title('Non-locomotor movement')
subplot('Position',[start_plot_x+intersize+plotsize,start_plot_y+intersize+plotsize,plotsize,plotsize])
imshow(s_mouseimg)
subplot('Position',[start_plot_x,start_plot_y,plotsize,plotsize])
imshow(s_mouseimg)
title('Distance')
subplot('Position',[start_plot_x+intersize+plotsize,start_plot_y,plotsize,plotsize])
imshow(s_mouseimg)
%% dynamic segmentation
start_plot_x = 0.23;
start_plot_y = 0.28;
plotsizex = 0.21;
plotsizey = 0.05;
intersize = 0.02;
cov1_c = netcolorlist(end,:);
try
    delete(hds1)
catch
end
hds1 = subplot('Position',[start_plot_x,start_plot_y+2*(intersize+plotsizey),plotsizex,plotsizey]);
total_len = 10;
segnum = 10;
rand_min = 0.1;
rand_max = 2;
boxsize = 10;
seglist = zeros(total_len*100,1);
count = 1;
while 1
    rand('seed',1234);
    temprand = randn(1)*total_len;
    if temprand<rand_max && temprand>rand_min
        seglist(count,1) = temprand;
        count = count+1;
        if count > total_len*100
            break
        end
    end
end
cumseglist = cumsum(seglist);
start_seglist = [0;cumseglist(1:find(cumseglist<total_len,1,'last'),1)];
end_seglist = [start_seglist(2:end,1);total_len];
for k = 1:size(start_seglist,1)
    thick = end_seglist(k,1)-start_seglist(k,1);
    plotcube([thick boxsize boxsize],[start_seglist(k,1)  0  0],.8,cov1_c)
end


axis([0,total_len,0,2*boxsize,0,boxsize])
axis off
view(9,25)

try
    delete(hds2)
catch
end
hds2 = subplot('Position',[start_plot_x,start_plot_y+intersize+plotsizey,plotsizex,plotsizey]);
total_len = 10;
segnum = 10;
rand_min = 0.1;
rand_max = 2;
boxsize = 10;
seglist = zeros(total_len*100,1);
count = 1;
while 1
    rand('seed',5678);
    temprand = randn(1)*total_len;
    if temprand<rand_max && temprand>rand_min
        seglist(count,1) = temprand;
        count = count+1;
        if count > total_len*100
            break
        end
    end
end
cumseglist = cumsum(seglist);
start_seglist = [0;cumseglist(1:find(cumseglist<total_len,1,'last'),1)];
end_seglist = [start_seglist(2:end,1);total_len];
for k = 1:size(start_seglist,1)
    thick = end_seglist(k,1)-start_seglist(k,1);
    plotcube([thick boxsize boxsize],[start_seglist(k,1)  0  0],.8,cov1_c)
end
axis([0,total_len,0,2*boxsize,0,boxsize])
axis off
view(9,25)

try
    delete(hds3)
catch
end
hds3 = subplot('Position',[start_plot_x,start_plot_y,plotsizex,plotsizey]);
total_len = 10;
segnum = 10;
rand_min = 0.1;
rand_max = 2;
boxsize = 10;
seglist = zeros(total_len*100,1);
count = 1;
while 1
    rand('seed',5678);
    temprand = randn(1)*total_len;
    if temprand<rand_max && temprand>rand_min
        seglist(count,1) = temprand;
        count = count+1;
        if count > total_len*100
            break
        end
    end
end
cumseglist = cumsum(seglist);
start_seglist = [0;cumseglist(1:find(cumseglist<total_len,1,'last'),1)];
end_seglist = [start_seglist(2:end,1);total_len];
for k = 1:size(start_seglist,1)
    thick = end_seglist(k,1)-start_seglist(k,1);
    plotcube([thick boxsize boxsize],[start_seglist(k,1)  0  0],.8,cov1_c)
end
axis([0,total_len,0,2*boxsize,0,boxsize])
axis off
view(9,25)
%% Behavior Atlas
dist_thres = 0.175;
temp_data_sample_cell = data_sample_cell(1:3:end,:);
%  noise filter
zscore_embed = cell2mat(temp_data_sample_cell(:,4));
tempdistlist = zeros(size(zscore_embed,1),1);
for k = 1:size(zscore_embed,1)
    tempdist = sort(pdist2(zscore_embed(k,:),zscore_embed));
    tempdistlist(k,1) = mean(tempdist(1:100));
end
temp_data_sample_cell(tempdistlist>dist_thres,:) = [];
zscore_embed = cell2mat(temp_data_sample_cell(:,4));
distlist = medfilt1(cellfun(@(x) min(x(:)),temp_data_sample_cell(:,7)),3);
normdistlist = round(mat2gray(distlist)*255+1);
%%
cmap = cbrewer2('spectral',256);
cmaplist = cmap(normdistlist,:);
subplot('Position',[0.5,0.27,0.2,0.2])
scatter(zscore_embed(:,1),zscore_embed(:,2),3*ones(size(zscore_embed,1),1),cmaplist,'filled');
axis square
set(gca,'XTickLabel',[])
set(gca,'YTickLabel',[])
set(gca,'TickDir','out')
xlabel('SBS 1')% social behavioral space
ylabel('SBS 2')% social behavioral space
hcmap = subplot('Position',[0.5,0.475,0.05,0.005]);
imagesc(1:100)
colormap(hcmap,cmap)
box on
set(gca,'XTick',[],'YTick',[])
xlabel('min   max')
%% Ethogram
subplot('Position',[0.76,0.27,0.21,0.2])
tempethogram = cell2mat(data_sample_cell(:,8));
ethogram = tempethogram(:,1);
unique_etho = unique(ethogram);
temp_etho_G = zeros(size(unique_etho,1),size(ethogram,1));
for k = 1:size(temp_etho_G,1)
    temp_etho_G(k,ethogram==k) = 1;
end
etho_G = temp_etho_G(:,1:100:(180*90));
etho_G(sum(etho_G,2)==0,:) = [];
etho_size = sum(sum(etho_G,2)>0);
cmap = cbrewer2('Set2',etho_size);
for m = 1:size(etho_G,1)
    for n = 2:size(etho_G,2)
        if etho_G(m,n) == 1
            tempp = plot([n,n],[m-0.25,m+0.25],'Color',cmap(m,:),'LineWidth',2);
            tempp.Color(4) = 1;
            hold on
        end
    end
end
inter_size = 2;
hold off
xlabel('Social ethogram')
set(gca,'TickDir','out')
set(gca,'YLim',[0.5,etho_size+0.5])
set(gca,'XLim',[0,size(etho_G,2)])
set(gca,'YTick',1:etho_size)
ylabel_cell = cell(etho_size,1);
ylabel_cell{1} = 1;
ylabel_cell{etho_size} = etho_size;
set(gca,'YTickLabel',ylabel_cell)
set(gca,'XTick',0:(size(etho_G,2)/inter_size):size(etho_G,2))
set(gca,'XTickLabel',{0:(180/inter_size):(180-(180/inter_size)),'180'})
ylabel('Classes')
box off































