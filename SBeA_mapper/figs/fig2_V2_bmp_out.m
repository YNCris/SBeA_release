%{
    fig2,  multi-animal tracking
%}
clear all
close all
addpath(genpath(pwd))
%% set path
rootpath = 'Z:\hanyaning\multi_mice_test\Social_analysis\data\figs\fig2';
%% load data
vidobj = VideoReader([rootpath,'\panel_2\rec11-A1A2-20220803-camera-0.avi']);
vidobjt = VideoReader([rootpath,'\panel_2\rec11-A1A2-20220803-camera-0.avi']);
trajdata = readNPY([rootpath,'\panel_3\rec5-group-20220531-camera-3.npy']);
tempdata1 = importdata([rootpath,...
    '\panel_9\rec11-A1A2-20220803-camera-0-masked-1DLC_resnet50_shank3resolution1kMay24shuffle1_1030000.csv']);
tempdata2 = importdata([rootpath,...
    '\panel_9\rec11-A1A2-20220803-camera-0-masked-2DLC_resnet50_shank3resolution1kMay24shuffle1_1030000.csv']);
err_dist = load([rootpath,'\panel_comp\dist_cell.mat']);
err_slp = load([rootpath,'\panel_comp\slp_err_nid_cell.mat']);
err_sbea = load([rootpath,'\panel_comp\sbea_err_nid_cell.mat']);
err_dlc = load([rootpath,'\panel_comp\dlc_err_nid_cell.mat']);
%% load 3d reid data
caliname = 'rec11-A1A2-20220803-caliParas.mat';
camnum = 4;
masknum = 2;
dlcname = 'DLC_resnet50_shank3resolution1kMay24shuffle1_1030000.csv';
splnamelist = split(caliname,'-');
rootname = [splnamelist{1},'-',splnamelist{2},'-',splnamelist{3}];
csv_cell = cell(camnum*masknum,2);
count = 1;
for m = [2,3,4,1]
    for n = 1:masknum
        tempcsvname = [rootname,'-camera-',num2str(m-1),'-masked-',...
            num2str(n),dlcname];
        csv_cell{count,1} = tempcsvname;
        tempcsv = importdata([rootpath,'\panel_13\',tempcsvname]);
        tempcsvdata = tempcsv.data;
        tempcsvdata(:,1) = [];
        tempcsvdata(:,3:3:end) = [];
        csv_cell{count,2} = tempcsvdata;
        count = count+1;
    end
end
load([rootpath,'\panel_13\',caliname])
cam_mat = caliParams.cam_mat_all;
%% set color
setcolor = cbrewer2('Spectral',11);
mouse1_c = setcolor(3,:);
mouse2_c = setcolor(9,:);
%% plot canvas
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
set(h1,'color','white');
%% multi-animal tracking framework
subplot('Position',[0.03,0.87,0.1,0.08])
mousename = [rootpath,'\panel_1\mouse_2d.png'];
cameraname = [rootpath,'\panel_1\camera_4.png'];
[mouse_img,~,mouse_alpha] = imread(mousename);
[camera_img,~,camera_alpha] = imread(cameraname);
[X,Y] = meshgrid(1:size(mouse_img,1),1:size(mouse_img,2));
warp_mouse1 = warp(X-200,Y-300,ones(size(Y)),mouse_img);
hold on
warp_mouse2 = warp(X+50,Y+50-300,ones(size(Y)),mouse_img);
hold on
[X,Y] = meshgrid(1:size(camera_img,1),1:size(camera_img,2));
warp_camera = warp((X-76.5)*14,ones(size(Y))*200-1000,-1*Y*4+2000,camera_img);
hold on
r = 600;
[Xbox, Ybox, Zbox] = cylinder(r, 50);
surf(Xbox, Ybox, Zbox*2000,'FaceAlpha',0.1,'FaceColor',[.1,.1,.1],'EdgeColor','none');
hold off
xlabel('x')
ylabel('y')
zlabel('z')
view(0,53)
axis off
%% video stream
subplot('Position',[0.03,0.77,0.1,0.08])
res_par = 1;
start_frame = 1;
end_frame = start_frame+4;
frame_cell = cell(end_frame-start_frame+1,1);
for k = start_frame:end_frame
    frame_cell{k,1} = flipud(read(vidobj,k));
    frame_cell{k,1} = frame_cell{k,1}(1:res_par:end,1:res_par:end,:);
end
[X,Y] = meshgrid(1:size(frame_cell{1,1},1),1:size(frame_cell{1,1},2));
bias = 0;
for k = 1:size(frame_cell,1)
    warp(X,ones(size(Y))+bias,Y,frame_cell{k,1});
    bias = bias+100/res_par;
    hold on
end
hold off
xlabel('x')
ylabel('y')
zlabel('z')
view(40,15)
axis off
% % %% background
% % start_x = 0.15;
% % start_y = 0.75;
% % plotsize_x = 0.09;
% % plotsize_y = 0.07;
% % inter_y = 0.001;
% % bkimg = imread([rootpath,'\panel_3\rec5-group-20220531-camera-3.png']);
% % subplot('Position',[start_x,start_y+2*(inter_y+plotsize_y),plotsize_x,plotsize_y])
% % imshow(bkimg)
% % % trajectories
% % sel_pos = 150;
% % seltrajdata = trajdata(150:650,[1,2,4,5]);
% % subplot('Position',[start_x,start_y+inter_y+plotsize_y,plotsize_x,plotsize_y])
% % imshow(read(vidobj,sel_pos))
% % hold on
% % plot(seltrajdata(:,1),seltrajdata(:,2),'Color',mouse1_c)
% % hold on
% % plot(seltrajdata(:,3),seltrajdata(:,4),'Color',mouse2_c)
% % hold off
% % subplot('Position',[start_x,start_y,plotsize_x,plotsize_y])
% % imgname = [rootpath,'\panel_5\rec5-group-20220531-camera-1_1087_99.png'];
% % jsonname = [rootpath,'\panel_5\rec5-group-20220531-camera-1_1087_99.json'];
% % jsontext = fileread(jsonname);
% % jsonvalue = jsondecode(jsontext);
% % img = imread(imgname);
% % mouse1p = jsonvalue.shapes(1).points;
% % mouse2p = jsonvalue.shapes(2).points;
% % imshow(img)
% % hold on
% % plot(mouse1p(:,1),mouse1p(:,2),'-y')
% % hold on
% % plot(mouse2p(:,1),mouse2p(:,2),'-y')
% % hold off
% % start_x = 260;
% % end_x = 700;
% % start_y = 250;
% % end_y = start_y+(end_x-start_x)*(964/1288);
% % axis([start_x,end_x,start_y,end_y])
% % %% synthetic data
% % start_x = 0.26;
% % start_y = 0.891;
% % plotsize_x = 0.09;
% % plotsize_y = 0.07;
% % inter_x = 0.001;
% % sel_name = 'zone_13_50_51_2';
% % sel_frame_num = 10;
% % imgname = [rootpath,'\panel_7\',sel_name,'\',num2str(sel_frame_num),'.jpg'];
% % jsonname = [rootpath,'\panel_7\instances_valid_sub.json'];
% % jsontext = fileread(jsonname);
% % jsonvalue = jsondecode(jsontext);
% % img = imread(imgname);
% % for k = 1:size(jsonvalue.videos,1)
% %     %
% %     tempnamecell = jsonvalue.videos(k).file_names;
% %     for m = 1:size(tempnamecell,1)
% %         %
% %         tempname = tempnamecell{m,1};
% %         splname = split(tempname,'/');
% %         if strcmp(splname{1},sel_name)
% %             sel_num = k;
% %             break
% %         end
% %     end
% % end
% % sel_anno_idx = [jsonvalue.annotations.video_id]==sel_num;
% % anno_cell = jsonvalue.annotations(sel_anno_idx);
% % mask_traj_1 = [anno_cell(1).bboxes(:,1)+anno_cell(1).bboxes(:,3)/1.5,...
% %     anno_cell(1).bboxes(:,2)+anno_cell(1).bboxes(:,4)/2];
% % mask_traj_2 = [anno_cell(2).bboxes(:,1)+anno_cell(2).bboxes(:,3)/1.5,...
% %     anno_cell(2).bboxes(:,2)+anno_cell(2).bboxes(:,4)/2];
% % 
% % img_anno_1 = anno_cell(1).segmentations(sel_frame_num);
% % img_anno_2 = anno_cell(2).segmentations(sel_frame_num);
% % masks_1 = MaskApi.decode(img_anno_1);
% % masks_2 = MaskApi.decode(img_anno_2);
% % show_mask = double(masks_1)+2*double(masks_2);
% % subplot('Position',[start_x,start_y,plotsize_x,plotsize_y])
% % imshow(img)
% % hold on
% % plot(mask_traj_1(:,1),mask_traj_1(:,2),'Color',mouse1_c)
% % hold on
% % plot(mask_traj_2(:,1),mask_traj_2(:,2),'Color',mouse2_c)
% % hold off
% % start_img_x = 640;
% % end_img_x = 1100;
% % start_img_y = 580;
% % end_img_y = start_img_y+(end_img_x-start_img_x)*(964/1288);
% % axis([start_img_x,end_img_x,start_img_y,end_img_y])
% % 
% % h75 = subplot('Position',[start_x+inter_x+plotsize_x,start_y,plotsize_x,plotsize_y]);
% % imagesc(show_mask)
% % end_img_y = start_img_y+(end_img_x-start_img_x)*(964/1288);
% % axis([start_img_x,end_img_x,start_img_y,end_img_y])
% % % axis equal
% % % axis off
% % box on
% % set(gca,'XTick',[])
% % set(gca,'YTick',[])
% % colormap(h75,[1,1,1;...
% %         mouse1_c;...
% %         mouse2_c])
% % %% network
% % % yolact
% % subplot('Position',[0.26,0.78,0.08,0.07])
% % bias1 = 80;
% % bias2 = 10;
% % bias3 = 4;
% % thick = 0.5;
% % shrscale = 1;
% % netcolorlist = cbrewer2('Pastel1',9);
% % cov1_c = netcolorlist(4,:);
% % cov2_c = netcolorlist(1,:);
% % plotcube([thick 70 70]/shrscale,[0  0  0]/shrscale,.8,cov1_c)
% % plotcube([thick 60 60]/shrscale,[2  5  5]/shrscale,.8,cov1_c)
% % plotcube([thick 50 50]/shrscale,[4  10  10]/shrscale,.8,cov1_c)
% % plotcube([thick 40 40]/shrscale,[6  15  15]/shrscale,.8,cov1_c)
% % plotcube([thick 30 30]/shrscale,[8  20 20]/shrscale,.8,cov1_c)
% % plotcube([thick 50 50]/shrscale,[0+bias3 0+bias2 0+bias1]/shrscale,.8,cov2_c)
% % plotcube([thick 40 40]/shrscale,[2+bias3  5+bias2  5+bias1]/shrscale,.8,cov2_c)
% % plotcube([thick 30 30]/shrscale,[4+bias3  10+bias2  10+bias1]/shrscale,.8,cov2_c)
% % plotcube([thick 20 20]/shrscale,[6+bias3  15+bias2  15+bias1]/shrscale,.8,cov2_c)
% % plotcube([thick 10 10]/shrscale,[8+bias3  20+bias2 20+bias1]/shrscale,.8,cov2_c)
% % hold on
% % plot3([0+thick,2]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
% % hold on
% % plot3([2+thick,4]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
% % hold on
% % plot3([4+thick,6]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
% % hold on
% % plot3([6+thick,8]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
% % hold on
% % plot3([0+bias3+thick,2+bias3]/shrscale,[25+bias2,25+bias2]/shrscale,[25+bias1,25+bias1]/shrscale,'k')
% % hold on
% % plot3([2+bias3+thick,4+bias3]/shrscale,[25+bias2,25+bias2]/shrscale,[25+bias1,25+bias1]/shrscale,'k')
% % hold on
% % plot3([4+bias3+thick,6+bias3]/shrscale,[25+bias2,25+bias2]/shrscale,[25+bias1,25+bias1]/shrscale,'k')
% % hold on
% % plot3([6+bias3+thick,8+bias3]/shrscale,[25+bias2,25+bias2]/shrscale,[25+bias1,25+bias1]/shrscale,'k')
% % hold on
% % plot3([0.5*thick+4,0.5*thick+4]/shrscale,[35,35]/shrscale,[10+50,0+bias1]/shrscale,'k')
% % hold on
% % plot3([0.5*thick+6,0.5*thick+6]/shrscale,[35,35]/shrscale,[15+40,5+bias1]/shrscale,'k')
% % hold on
% % plot3([0.5*thick+8,0.5*thick+8]/shrscale,[35,35]/shrscale,[20+30,10+bias1]/shrscale,'k')
% % hold on
% % plot3([-2,0],[35,35],[35,35],'k')
% % hold on
% % plot3([-2,-2],[35,35],[35,25+0+bias1],'k')
% % hold on
% % plot3([-2,0+bias3],[35,35],[25+bias1,25+bias1],'k')
% % hold off
% % view(9,4)
% % axis off
% % % vistr
% % subplot('Position',[0.36,0.77,0.08,0.09])
% % netcolorlist = cbrewer2('Pastel1',9);
% % cov1_c = netcolorlist(4,:);
% % cov2_c = netcolorlist(4,:);
% % att1_c = netcolorlist(1,:);
% % netcolorlist = cbrewer2('Set3',12);
% % att2_c = netcolorlist(1,:);
% % bias1 = 80;
% % bias2 = 10;
% % bias3 = 4;
% % thick = 3;
% % shrscale = 1;
% % inter1 = 10;
% % plotcube(fliplr([130 130 thick]),fliplr([-65  -65  4*inter1]),.8,cov1_c)
% % plotcube(fliplr([90 90 thick]),fliplr([-45  -45  3*inter1]),.8,cov1_c)
% % plotcube(fliplr([70 70 thick]),fliplr([-35  -35  2*inter1]),.8,cov1_c)
% % plotcube(fliplr([50 50 thick]),fliplr([-25  -25  inter1]),.8,cov1_c)
% % plotcube(fliplr([30 30 thick]),fliplr([-15  -15  0*inter1]),.8,cov1_c)
% % 
% % plotcube(fliplr([10 10 10]),fliplr([5  -5  -20]),.8,att1_c)
% % plotcube(fliplr([10 10 10]),fliplr([25  -5  -20]),.8,att1_c)
% % plotcube(fliplr([10 10 10]),fliplr([45  -5  -20]),.8,att1_c)
% % plotcube(fliplr([-10 10 10]),fliplr([-5  -5  -20]),.8,att1_c)
% % plotcube(fliplr([-10 10 10]),fliplr([-25  -5  -20]),.8,att1_c)
% % plotcube(fliplr([-10 10 10]),fliplr([-45  -5  -20]),.8,att1_c)
% % 
% % plotcube(fliplr([10 10 10]),fliplr([5  -5  -40]),.8,att2_c)
% % plotcube(fliplr([10 10 10]),fliplr([25  -5  -40]),.8,att2_c)
% % plotcube(fliplr([10 10 10]),fliplr([45  -5  -40]),.8,att2_c)
% % plotcube(fliplr([-10 10 10]),fliplr([-5  -5  -40]),.8,att2_c)
% % plotcube(fliplr([-10 10 10]),fliplr([-25  -5  -40]),.8,att2_c)
% % plotcube(fliplr([-10 10 10]),fliplr([-45  -5  -40]),.8,att2_c)
% % 
% % plotcube(fliplr([30 10 10]),fliplr([-15  -5  -60]),.8,att2_c)
% % 
% % hold on
% % plot3([0+thick,inter1],[0,0],[0,0],'k')
% % hold on
% % plot3([inter1+thick,2*inter1],[0,0],[0,0],'k')
% % hold on
% % plot3([2*inter1+thick,3*inter1],[0,0],[0,0],'k')
% % hold on
% % plot3([3*inter1+thick,4*inter1],[0,0],[0,0],'k')
% % 
% % hold on
% % plot3([0,-10],[0,0],[0,10],'k')
% % hold on
% % plot3([0,-10],[0,0],[0,30],'k')
% % hold on
% % plot3([0,-10],[0,0],[0,50],'k')
% % hold on
% % plot3([0,-10],[0,0],[0,-10],'k')
% % hold on
% % plot3([0,-10],[0,0],[0,-30],'k')
% % hold on
% % plot3([0,-10],[0,0],[0,-50],'k')
% % 
% % hold on
% % plot3([-20,-30],[0,0],[10,10],'k')
% % hold on
% % plot3([-20,-30],[0,0],[30,30],'k')
% % hold on
% % plot3([-20,-30],[0,0],[50,50],'k')
% % hold on
% % plot3([-20,-30],[0,0],[-10,-10],'k')
% % hold on
% % plot3([-20,-30],[0,0],[-30,-30],'k')
% % hold on
% % plot3([-20,-30],[0,0],[-50,-50],'k')
% % 
% % hold on
% % plot3([-40,-50],[0,0],[10,0],'k')
% % hold on
% % plot3([-40,-50],[0,0],[30,0],'k')
% % hold on
% % plot3([-40,-50],[0,0],[50,0],'k')
% % hold on
% % plot3([-40,-50],[0,0],[-10,0],'k')
% % hold on
% % plot3([-40,-50],[0,0],[-30,0],'k')
% % hold on
% % plot3([-40,-50],[0,0],[-50,0],'k')
% % hold off
% % % axis equal
% % % view(2)
% % view(-168,23)
% % % axis on
% % % xlabel('x')
% % % ylabel('y')
% % % zlabel('z')
% % axis off
%% masked video frames
res_par = 1;
start_frame = 302;
end_frame = start_frame+4;
start_x = 330/res_par;
end_x = 900/res_par;
start_y = 20;
end_y = start_y+(end_x-start_x)*(964/1288);
vidname1 = [rootpath,'\panel_9\rec11-A1A2-20220803-camera-0-masked-1.avi'];
vidname2 = [rootpath,'\panel_9\rec11-A1A2-20220803-camera-0-masked-2.avi'];
vidobj1 = VideoReader(vidname1);
vidobj2 = VideoReader(vidname2);
frame_cell_1 = cell(end_frame-start_frame+1,1);
frame_cell_2 = cell(end_frame-start_frame+1,1);
for k = start_frame:end_frame
    frame_cell_1{k-start_frame+1,1} = flipud(read(vidobj1,k));
    frame_cell_2{k-start_frame+1,1} = flipud(read(vidobj2,k));
    frame_cell_1{k-start_frame+1,1} = frame_cell_1{k-start_frame+1,1}(1:res_par:end,1:res_par:end,:);
    frame_cell_2{k-start_frame+1,1} = frame_cell_2{k-start_frame+1,1}(1:res_par:end,1:res_par:end,:);
end
[X,Y] = meshgrid(1:size(frame_cell_1{1,1},1),1:size(frame_cell_1{1,1},2));
subplot('Position',[0.455,0.89,0.09,0.07])
bias = 0;
for k = 1:size(frame_cell_1,1)
    warp(X,ones(size(Y))+bias,Y,frame_cell_1{k,1});
    bias = bias+100;
    hold on
end
hold off
view(25,15)
xlabel('x')
ylabel('y')
axis([start_x,end_x,0,500,start_y,end_y])
axis off
% title('Masked Videos','Color','blue')
subplot('Position',[0.455,0.82,0.09,0.07])
bias = 0;
for k = 1:size(frame_cell_2,1)
    warp(X,ones(size(Y))+bias,Y,frame_cell_2{k,1});
    bias = bias+100;
    hold on
end
hold off
view(25,15)
axis([start_x,end_x,0,500,start_y,end_y])
axis off









































