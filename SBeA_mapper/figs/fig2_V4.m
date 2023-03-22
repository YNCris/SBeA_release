%{
    fig2,  multi-animal tracking
%}
clear all
close all
addpath(genpath(pwd))
%% set path
% rootpath = 'C:\Users\Dell\OneDrive\tempdata\figs\fig2';
rootpath = 'Z:\hanyaning\multi_mice_test\Social_analysis\data\figs\fig2';
%% load data
% vidobj = VideoReader([rootpath,'\panel_2\rec11-A1A2-20220803-camera-0.avi']);
% vidobjt = VideoReader([rootpath,'\panel_2\rec11-A1A2-20220803-camera-0.avi']);
% trajdata = readNPY([rootpath,'\panel_3\rec5-group-20220531-camera-3.npy']);
tempdata1 = importdata([rootpath,...
    '\panel_9\rec11-A1A2-20220803-camera-0-masked-1DLC_resnet50_shank3resolution1kMay24shuffle1_1030000.csv']);
tempdata2 = importdata([rootpath,...
    '\panel_9\rec11-A1A2-20220803-camera-0-masked-2DLC_resnet50_shank3resolution1kMay24shuffle1_1030000.csv']);
err_dist = load([rootpath,'\panel_comp\dist_cell.mat']);
err_slp = load([rootpath,'\panel_comp\slp_err_nid_cell.mat']);
err_sbea = load([rootpath,'\panel_comp\sbea_err_nid_cell.mat']);
err_dlc = load([rootpath,'\panel_comp\dlc_err_nid_cell.mat']);
%% load 3d reid data
% caliname = 'rec11-A1A2-20220803-caliParas.mat';
% camnum = 4;
% masknum = 2;
% dlcname = 'DLC_resnet50_shank3resolution1kMay24shuffle1_1030000.csv';
% splnamelist = split(caliname,'-');
% rootname = [splnamelist{1},'-',splnamelist{2},'-',splnamelist{3}];
% csv_cell = cell(camnum*masknum,2);
% count = 1;
% for m = [2,3,4,1]
%     for n = 1:masknum
%         tempcsvname = [rootname,'-camera-',num2str(m-1),'-masked-',...
%             num2str(n),dlcname];
%         csv_cell{count,1} = tempcsvname;
%         tempcsv = importdata([rootpath,'\panel_13\',tempcsvname]);
%         tempcsvdata = tempcsv.data;
%         tempcsvdata(:,1) = [];
%         tempcsvdata(:,3:3:end) = [];
%         csv_cell{count,2} = tempcsvdata;
%         count = count+1;
%     end
% end
% load([rootpath,'\panel_13\',caliname])
% cam_mat = caliParams.cam_mat_all;
%% set color
setcolor = cbrewer2('Spectral',11);
mouse1_c = setcolor(3,:);
mouse2_c = setcolor(9,:);
%% plot canvas
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
set(h1,'color','white');
%% multi-animal tracking framework
% subplot('Position',[0.03,0.87,0.1,0.08])
% mousename = [rootpath,'\panel_1\mouse_2d.png'];
% cameraname = [rootpath,'\panel_1\camera_4.png'];
% [mouse_img,~,mouse_alpha] = imread(mousename);
% [camera_img,~,camera_alpha] = imread(cameraname);
% [X,Y] = meshgrid(1:size(mouse_img,1),1:size(mouse_img,2));
% warp_mouse1 = warp(X-200,Y-300,ones(size(Y)),mouse_img);
% hold on
% warp_mouse2 = warp(X+50,Y+50-300,ones(size(Y)),mouse_img);
% hold on
% [X,Y] = meshgrid(1:size(camera_img,1),1:size(camera_img,2));
% warp_camera = warp((X-76.5)*14,ones(size(Y))*200-1000,-1*Y*4+2000,camera_img);
% hold on
% r = 600;
% [Xbox, Ybox, Zbox] = cylinder(r, 50);
% surf(Xbox, Ybox, Zbox*2000,'FaceAlpha',0.1,'FaceColor',[.1,.1,.1],'EdgeColor','none');
% hold off
% xlabel('x')
% ylabel('y')
% zlabel('z')
% view(0,53)
% axis off
%% video stream
% subplot('Position',[0.03,0.77,0.1,0.08])
% res_par = 1;
% start_frame = 1;
% end_frame = start_frame+4;
% frame_cell = cell(end_frame-start_frame+1,1);
% for k = start_frame:end_frame
%     frame_cell{k,1} = flipud(read(vidobj,k));
%     frame_cell{k,1} = frame_cell{k,1}(1:res_par:end,1:res_par:end,:);
% end
% [X,Y] = meshgrid(1:size(frame_cell{1,1},1),1:size(frame_cell{1,1},2));
% bias = 0;
% for k = 1:size(frame_cell,1)
%     warp(X,ones(size(Y))+bias,Y,frame_cell{k,1});
%     bias = bias+100/res_par;
%     hold on
% end
% hold off
% xlabel('x')
% ylabel('y')
% zlabel('z')
% view(40,15)
% axis off
%% background
% start_x = 0.15;
% start_y = 0.75;
% plotsize_x = 0.09;
% plotsize_y = 0.07;
% inter_y = 0.001;
% bkimg = imread([rootpath,'\panel_3\rec5-group-20220531-camera-3.png']);
% subplot('Position',[start_x,start_y+2*(inter_y+plotsize_y),plotsize_x,plotsize_y])
% imshow(bkimg)
% % trajectories
% sel_pos = 150;
% seltrajdata = trajdata(150:650,[1,2,4,5]);
% subplot('Position',[start_x,start_y+inter_y+plotsize_y,plotsize_x,plotsize_y])
% imshow(read(vidobj,sel_pos))
% hold on
% plot(seltrajdata(:,1),seltrajdata(:,2),'Color',mouse1_c)
% hold on
% plot(seltrajdata(:,3),seltrajdata(:,4),'Color',mouse2_c)
% hold off
% subplot('Position',[start_x,start_y,plotsize_x,plotsize_y])
% imgname = [rootpath,'\panel_5\rec5-group-20220531-camera-1_1087_99.png'];
% jsonname = [rootpath,'\panel_5\rec5-group-20220531-camera-1_1087_99.json'];
% jsontext = fileread(jsonname);
% jsonvalue = jsondecode(jsontext);
% img = imread(imgname);
% mouse1p = jsonvalue.shapes(1).points;
% mouse2p = jsonvalue.shapes(2).points;
% imshow(img)
% hold on
% plot(mouse1p(:,1),mouse1p(:,2),'-y')
% hold on
% plot(mouse2p(:,1),mouse2p(:,2),'-y')
% hold off
% start_x = 260;
% end_x = 700;
% start_y = 250;
% end_y = start_y+(end_x-start_x)*(964/1288);
% axis([start_x,end_x,start_y,end_y])
%% synthetic data
% start_x = 0.26;
% start_y = 0.891;
% plotsize_x = 0.09;
% plotsize_y = 0.07;
% inter_x = 0.001;
% sel_name = 'zone_13_50_51_2';
% sel_frame_num = 10;
% imgname = [rootpath,'\panel_7\',sel_name,'\',num2str(sel_frame_num),'.jpg'];
% jsonname = [rootpath,'\panel_7\instances_valid_sub.json'];
% jsontext = fileread(jsonname);
% jsonvalue = jsondecode(jsontext);
% img = imread(imgname);
% for k = 1:size(jsonvalue.videos,1)
%     %
%     tempnamecell = jsonvalue.videos(k).file_names;
%     for m = 1:size(tempnamecell,1)
%         %
%         tempname = tempnamecell{m,1};
%         splname = split(tempname,'/');
%         if strcmp(splname{1},sel_name)
%             sel_num = k;
%             break
%         end
%     end
% end
% sel_anno_idx = [jsonvalue.annotations.video_id]==sel_num;
% anno_cell = jsonvalue.annotations(sel_anno_idx);
% mask_traj_1 = [anno_cell(1).bboxes(:,1)+anno_cell(1).bboxes(:,3)/1.5,...
%     anno_cell(1).bboxes(:,2)+anno_cell(1).bboxes(:,4)/2];
% mask_traj_2 = [anno_cell(2).bboxes(:,1)+anno_cell(2).bboxes(:,3)/1.5,...
%     anno_cell(2).bboxes(:,2)+anno_cell(2).bboxes(:,4)/2];
% 
% img_anno_1 = anno_cell(1).segmentations(sel_frame_num);
% img_anno_2 = anno_cell(2).segmentations(sel_frame_num);
% masks_1 = MaskApi.decode(img_anno_1);
% masks_2 = MaskApi.decode(img_anno_2);
% show_mask = double(masks_1)+2*double(masks_2);
% subplot('Position',[start_x,start_y,plotsize_x,plotsize_y])
% imshow(img)
% hold on
% plot(mask_traj_1(:,1),mask_traj_1(:,2),'Color',mouse1_c)
% hold on
% plot(mask_traj_2(:,1),mask_traj_2(:,2),'Color',mouse2_c)
% hold off
% start_img_x = 640;
% end_img_x = 1100;
% start_img_y = 580;
% end_img_y = start_img_y+(end_img_x-start_img_x)*(964/1288);
% axis([start_img_x,end_img_x,start_img_y,end_img_y])
% 
% h75 = subplot('Position',[start_x+inter_x+plotsize_x,start_y,plotsize_x,plotsize_y]);
% imagesc(show_mask)
% end_img_y = start_img_y+(end_img_x-start_img_x)*(964/1288);
% axis([start_img_x,end_img_x,start_img_y,end_img_y])
% % axis equal
% % axis off
% box on
% set(gca,'XTick',[])
% set(gca,'YTick',[])
% colormap(h75,[1,1,1;...
%         mouse1_c;...
%         mouse2_c])
%% network
% yolact
% subplot('Position',[0.26,0.78,0.08,0.07])
% bias1 = 80;
% bias2 = 10;
% bias3 = 4;
% thick = 0.5;
% shrscale = 1;
% netcolorlist = cbrewer2('Pastel1',9);
% cov1_c = netcolorlist(4,:);
% cov2_c = netcolorlist(1,:);
% plotcube([thick 70 70]/shrscale,[0  0  0]/shrscale,.8,cov1_c)
% plotcube([thick 60 60]/shrscale,[2  5  5]/shrscale,.8,cov1_c)
% plotcube([thick 50 50]/shrscale,[4  10  10]/shrscale,.8,cov1_c)
% plotcube([thick 40 40]/shrscale,[6  15  15]/shrscale,.8,cov1_c)
% plotcube([thick 30 30]/shrscale,[8  20 20]/shrscale,.8,cov1_c)
% plotcube([thick 50 50]/shrscale,[0+bias3 0+bias2 0+bias1]/shrscale,.8,cov2_c)
% plotcube([thick 40 40]/shrscale,[2+bias3  5+bias2  5+bias1]/shrscale,.8,cov2_c)
% plotcube([thick 30 30]/shrscale,[4+bias3  10+bias2  10+bias1]/shrscale,.8,cov2_c)
% plotcube([thick 20 20]/shrscale,[6+bias3  15+bias2  15+bias1]/shrscale,.8,cov2_c)
% plotcube([thick 10 10]/shrscale,[8+bias3  20+bias2 20+bias1]/shrscale,.8,cov2_c)
% hold on
% plot3([0+thick,2]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
% hold on
% plot3([2+thick,4]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
% hold on
% plot3([4+thick,6]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
% hold on
% plot3([6+thick,8]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
% hold on
% plot3([0+bias3+thick,2+bias3]/shrscale,[25+bias2,25+bias2]/shrscale,[25+bias1,25+bias1]/shrscale,'k')
% hold on
% plot3([2+bias3+thick,4+bias3]/shrscale,[25+bias2,25+bias2]/shrscale,[25+bias1,25+bias1]/shrscale,'k')
% hold on
% plot3([4+bias3+thick,6+bias3]/shrscale,[25+bias2,25+bias2]/shrscale,[25+bias1,25+bias1]/shrscale,'k')
% hold on
% plot3([6+bias3+thick,8+bias3]/shrscale,[25+bias2,25+bias2]/shrscale,[25+bias1,25+bias1]/shrscale,'k')
% hold on
% plot3([0.5*thick+4,0.5*thick+4]/shrscale,[35,35]/shrscale,[10+50,0+bias1]/shrscale,'k')
% hold on
% plot3([0.5*thick+6,0.5*thick+6]/shrscale,[35,35]/shrscale,[15+40,5+bias1]/shrscale,'k')
% hold on
% plot3([0.5*thick+8,0.5*thick+8]/shrscale,[35,35]/shrscale,[20+30,10+bias1]/shrscale,'k')
% hold on
% plot3([-2,0],[35,35],[35,35],'k')
% hold on
% plot3([-2,-2],[35,35],[35,25+0+bias1],'k')
% hold on
% plot3([-2,0+bias3],[35,35],[25+bias1,25+bias1],'k')
% hold off
% view(9,4)
% axis off
% % vistr
% subplot('Position',[0.36,0.77,0.08,0.09])
% netcolorlist = cbrewer2('Pastel1',9);
% cov1_c = netcolorlist(4,:);
% cov2_c = netcolorlist(4,:);
% att1_c = netcolorlist(1,:);
% netcolorlist = cbrewer2('Set3',12);
% att2_c = netcolorlist(1,:);
% bias1 = 80;
% bias2 = 10;
% bias3 = 4;
% thick = 3;
% shrscale = 1;
% inter1 = 10;
% plotcube(fliplr([130 130 thick]),fliplr([-65  -65  4*inter1]),.8,cov1_c)
% plotcube(fliplr([90 90 thick]),fliplr([-45  -45  3*inter1]),.8,cov1_c)
% plotcube(fliplr([70 70 thick]),fliplr([-35  -35  2*inter1]),.8,cov1_c)
% plotcube(fliplr([50 50 thick]),fliplr([-25  -25  inter1]),.8,cov1_c)
% plotcube(fliplr([30 30 thick]),fliplr([-15  -15  0*inter1]),.8,cov1_c)
% 
% plotcube(fliplr([10 10 10]),fliplr([5  -5  -20]),.8,att1_c)
% plotcube(fliplr([10 10 10]),fliplr([25  -5  -20]),.8,att1_c)
% plotcube(fliplr([10 10 10]),fliplr([45  -5  -20]),.8,att1_c)
% plotcube(fliplr([-10 10 10]),fliplr([-5  -5  -20]),.8,att1_c)
% plotcube(fliplr([-10 10 10]),fliplr([-25  -5  -20]),.8,att1_c)
% plotcube(fliplr([-10 10 10]),fliplr([-45  -5  -20]),.8,att1_c)
% 
% plotcube(fliplr([10 10 10]),fliplr([5  -5  -40]),.8,att2_c)
% plotcube(fliplr([10 10 10]),fliplr([25  -5  -40]),.8,att2_c)
% plotcube(fliplr([10 10 10]),fliplr([45  -5  -40]),.8,att2_c)
% plotcube(fliplr([-10 10 10]),fliplr([-5  -5  -40]),.8,att2_c)
% plotcube(fliplr([-10 10 10]),fliplr([-25  -5  -40]),.8,att2_c)
% plotcube(fliplr([-10 10 10]),fliplr([-45  -5  -40]),.8,att2_c)
% 
% plotcube(fliplr([30 10 10]),fliplr([-15  -5  -60]),.8,att2_c)
% 
% hold on
% plot3([0+thick,inter1],[0,0],[0,0],'k')
% hold on
% plot3([inter1+thick,2*inter1],[0,0],[0,0],'k')
% hold on
% plot3([2*inter1+thick,3*inter1],[0,0],[0,0],'k')
% hold on
% plot3([3*inter1+thick,4*inter1],[0,0],[0,0],'k')
% 
% hold on
% plot3([0,-10],[0,0],[0,10],'k')
% hold on
% plot3([0,-10],[0,0],[0,30],'k')
% hold on
% plot3([0,-10],[0,0],[0,50],'k')
% hold on
% plot3([0,-10],[0,0],[0,-10],'k')
% hold on
% plot3([0,-10],[0,0],[0,-30],'k')
% hold on
% plot3([0,-10],[0,0],[0,-50],'k')
% 
% hold on
% plot3([-20,-30],[0,0],[10,10],'k')
% hold on
% plot3([-20,-30],[0,0],[30,30],'k')
% hold on
% plot3([-20,-30],[0,0],[50,50],'k')
% hold on
% plot3([-20,-30],[0,0],[-10,-10],'k')
% hold on
% plot3([-20,-30],[0,0],[-30,-30],'k')
% hold on
% plot3([-20,-30],[0,0],[-50,-50],'k')
% 
% hold on
% plot3([-40,-50],[0,0],[10,0],'k')
% hold on
% plot3([-40,-50],[0,0],[30,0],'k')
% hold on
% plot3([-40,-50],[0,0],[50,0],'k')
% hold on
% plot3([-40,-50],[0,0],[-10,0],'k')
% hold on
% plot3([-40,-50],[0,0],[-30,0],'k')
% hold on
% plot3([-40,-50],[0,0],[-50,0],'k')
% hold off
% % axis equal
% % view(2)
% view(-168,23)
% % axis on
% % xlabel('x')
% % ylabel('y')
% % zlabel('z')
% axis off
%% masked video frames
% res_par = 1;
% start_frame = 302;
% end_frame = start_frame+4;
% start_x = 330/res_par;
% end_x = 900/res_par;
% start_y = 20;
% end_y = start_y+(end_x-start_x)*(964/1288);
% vidname1 = [rootpath,'\panel_9\rec11-A1A2-20220803-camera-0-masked-1.avi'];
% vidname2 = [rootpath,'\panel_9\rec11-A1A2-20220803-camera-0-masked-2.avi'];
% vidobj1 = VideoReader(vidname1);
% vidobj2 = VideoReader(vidname2);
% frame_cell_1 = cell(end_frame-start_frame+1,1);
% frame_cell_2 = cell(end_frame-start_frame+1,1);
% for k = start_frame:end_frame
%     frame_cell_1{k-start_frame+1,1} = flipud(read(vidobj1,k));
%     frame_cell_2{k-start_frame+1,1} = flipud(read(vidobj2,k));
%     frame_cell_1{k-start_frame+1,1} = frame_cell_1{k-start_frame+1,1}(1:res_par:end,1:res_par:end,:);
%     frame_cell_2{k-start_frame+1,1} = frame_cell_2{k-start_frame+1,1}(1:res_par:end,1:res_par:end,:);
% end
% [X,Y] = meshgrid(1:size(frame_cell_1{1,1},1),1:size(frame_cell_1{1,1},2));
% subplot('Position',[0.455,0.89,0.09,0.07])
% bias = 0;
% for k = 1:size(frame_cell_1,1)
%     warp(X,ones(size(Y))+bias,Y,frame_cell_1{k,1});
%     bias = bias+100;
%     hold on
% end
% hold off
% view(25,15)
% xlabel('x')
% ylabel('y')
% axis([start_x,end_x,0,500,start_y,end_y])
% axis off
% % title('Masked Videos','Color','blue')
% subplot('Position',[0.455,0.82,0.09,0.07])
% bias = 0;
% for k = 1:size(frame_cell_2,1)
%     warp(X,ones(size(Y))+bias,Y,frame_cell_2{k,1});
%     bias = bias+100;
%     hold on
% end
% hold off
% view(25,15)
% axis([start_x,end_x,0,500,start_y,end_y])
% axis off
% % pose net
% subplot('Position',[0.45,0.76,0.09,0.06])
% view(-174,34)
% bias1 = 80;
% bias2 = 10;
% bias3 = 4;
% thick = 0.5;
% shrscale = 1;
% bias4 = 0.5;
% netcolorlist = cbrewer2('Pastel1',9);
% cov1_c = netcolorlist(2,:);
% cov2_c = netcolorlist(2,:);
% cov3_c = netcolorlist(1,:);
% cov4_c = netcolorlist(4,:);
% cov5_c = netcolorlist(4,:);
% plotcube([thick 70 70]/shrscale,[0  0  0]/shrscale,.8,cov1_c)
% plotcube([thick 60 60]/shrscale,[2  5  5]/shrscale,.8,cov2_c)
% plotcube([thick 50 50]/shrscale,[4  10  10]/shrscale,.8,cov3_c)
% plotcube([thick 60 60]/shrscale,[6  5  5]/shrscale,.8,cov4_c)
% plotcube([thick 70 70]/shrscale,[8  0  0]/shrscale,.8,cov5_c)
% 
% hold on
% plot3([0+thick,2]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
% hold on
% plot3([2+thick,4]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
% hold on
% plot3([4+thick,6]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
% hold on
% plot3([6+thick,8]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
% 
% hold on
% plot3([2-bias4,2-bias4]/shrscale,[35,35]/shrscale,[35,90]/shrscale,'k')
% hold on
% plot3([4-bias4,4-bias4]/shrscale,[35,35]/shrscale,[35,90]/shrscale,'k')
% hold on
% plot3([6-bias4,6-bias4]/shrscale,[35,35]/shrscale,[35,90]/shrscale,'k')
% 
% hold on
% plot3([2+thick+bias4,2+thick+bias4]/shrscale,[35,35]/shrscale,[35,90]/shrscale,'k')
% hold on
% plot3([4+thick+bias4,4+thick+bias4]/shrscale,[35,35]/shrscale,[35,90]/shrscale,'k')
% hold on
% plot3([6+thick+bias4,6+thick+bias4]/shrscale,[35,35]/shrscale,[35,90]/shrscale,'k')
% 
% hold on
% plot3([2-bias4,2+thick+bias4]/shrscale,[35,35]/shrscale,[90,90]/shrscale,'k')
% hold on
% plot3([4-bias4,4+thick+bias4]/shrscale,[35,35]/shrscale,[90,90]/shrscale,'k')
% hold on
% plot3([6-bias4,6+thick+bias4]/shrscale,[35,35]/shrscale,[90,90]/shrscale,'k')
% 
% hold off
% % title({'Single Animal','Pose Estimation'},'Color','blue')
% view(-171,15)
% axis off
% %% pose estimation two mice
% start_plot_x = 0.565;
% start_plot_y = 0.75;
% plotsize_x = 0.09;
% plotsize_y = 0.07;
% inter_y = 0.001;
% start_x = 490;
% end_x = 1060;
% start_y = 530;
% end_y = start_y+(end_x-start_x)*(964/1288);
% sel_frame_idx = start_frame;
% pos1 = tempdata1.data;
% pos2 = tempdata2.data;
% pos1(:,1:3:end) = [];
% pos2(:,1:3:end) = [];
% selpos1 = pos1(sel_frame_idx,:);
% selpos2 = pos2(sel_frame_idx,:);
% subplot('Position',[start_plot_x,start_plot_y+2*(inter_y+plotsize_y),plotsize_x,plotsize_y])
% selframe1 = read(vidobj1,sel_frame_idx);
% imshow(selframe1)
% hold on
% plot(selpos1(1:2:end),selpos1(2:2:end),'o','Color',mouse1_c,'MarkerSize',1)
% hold off
% axis([start_x,end_x,start_y,end_y])
% subplot('Position',[start_plot_x,start_plot_y+inter_y+plotsize_y,plotsize_x,plotsize_y])
% selframe2 = read(vidobj2,sel_frame_idx);
% imshow(selframe2)
% hold on
% plot(selpos2(1:2:end),selpos2(2:2:end),'o','Color',mouse2_c,'MarkerSize',1)
% hold off
% axis([start_x,end_x,start_y,end_y])
% subplot('Position',[start_plot_x,start_plot_y,plotsize_x,plotsize_y])
% selframe = read(vidobj,sel_frame_idx);
% imshow(selframe)
% hold on
% plot(selpos1(1:2:end),selpos1(2:2:end),'o','Color',mouse1_c,'MarkerSize',1)
% hold on
% plot(selpos2(1:2:end),selpos2(2:2:end),'o','Color',mouse2_c,'MarkerSize',1)
% hold off
% axis([start_x,end_x,start_y,end_y])
%% 3D reconstruction
% calibration
% sel_cb_idx = 2;
% 
% startx1 = 250;
% starty1 = 100;
% bias_1 = 300;
% 
% startx2 = 250;
% starty2 = 100;
% bias_2 = 300;
% 
% startx3 = 100;
% starty3 = 150;
% bias_3 = 300;
% 
% startx4 = 150;
% starty4 = 50;
% bias_4 = 300;
% 
% endx1 = startx1+bias_1;
% endy1 = starty1+bias_1;
% endx2 = startx2+bias_2;
% endy2 = starty2+bias_2;
% endx3 = startx3+bias_3;
% endy3 = starty3+bias_3;
% endx4 = startx4+bias_4;
% endy4 = starty4+bias_4;
% cbimg1 = imread([rootpath,'\panel_10\Imagesforcalibration\PrimarySecondary1\Primary\frame',...
%     num2str(sel_cb_idx),'.png']);
% cbimg2 = imread([rootpath,'\panel_10\Imagesforcalibration\PrimarySecondary1\Secondary1\frame',...
%     num2str(sel_cb_idx),'.png']);
% cbimg3 = imread([rootpath,'\panel_10\Imagesforcalibration\PrimarySecondary2\Secondary2\frame',...
%     num2str(sel_cb_idx),'.png']);
% cbimg4 = imread([rootpath,'\panel_10\Imagesforcalibration\PrimarySecondary3\Secondary3\frame',...
%     num2str(sel_cb_idx),'.png']);
% cali1 = load([rootpath,'\panel_10\CalibSessionFiles\PrimarySecondary1\calibrationSession.mat']);
% cali2 = load([rootpath,'\panel_10\CalibSessionFiles\PrimarySecondary2\calibrationSession.mat']);
% cali3 = load([rootpath,'\panel_10\CalibSessionFiles\PrimarySecondary3\calibrationSession.mat']);
% for k = 1:size(cali1.calibrationSession.PatternSet.FullPathNames,2)
%     tempname = cali1.calibrationSession.PatternSet.FullPathNames{1,k};
%     tempsplname = split(tempname,'\');
%     if strcmp(tempsplname{end},['frame',num2str(sel_cb_idx),'.png'])
%         selnum1 = k;
%         break;
%     end
% end
% for k = 1:size(cali1.calibrationSession.PatternSet.FullPathNames,2)
%     tempname = cali1.calibrationSession.PatternSet.FullPathNames{2,k};
%     tempsplname = split(tempname,'\');
%     if strcmp(tempsplname{end},['frame',num2str(sel_cb_idx),'.png'])
%         selnum2 = k;
%         break;
%     end
% end
% for k = 1:size(cali2.calibrationSession.PatternSet.FullPathNames,2)
%     tempname = cali2.calibrationSession.PatternSet.FullPathNames{2,k};
%     tempsplname = split(tempname,'\');
%     if strcmp(tempsplname{end},['frame',num2str(sel_cb_idx),'.png'])
%         selnum3 = k;
%         break;
%     end
% end
% for k = 1:size(cali3.calibrationSession.PatternSet.FullPathNames,2)
%     tempname = cali3.calibrationSession.PatternSet.FullPathNames{2,k};
%     tempsplname = split(tempname,'\');
%     if strcmp(tempsplname{end},['frame',num2str(sel_cb_idx),'.png'])
%         selnum4 = k;
%         break;
%     end
% end
% calip1 = cali1.calibrationSession.PatternSet.PatternPoints(:,:,selnum1,1);
% calip2 = cali1.calibrationSession.PatternSet.PatternPoints(:,:,selnum2,2);
% calip3 = cali2.calibrationSession.PatternSet.PatternPoints(:,:,selnum3,2);
% calip4 = cali3.calibrationSession.PatternSet.PatternPoints(:,:,selnum4,2);
% 
% start_plot_x = 0.67;
% start_plot_y = 0.905;
% plotsize_x = 0.04;
% plotsize_y = 0.07;
% inter_x = 0.001;
% 
% subplot('Position',[start_plot_x,start_plot_y,plotsize_x,plotsize_y])
% imshow(cbimg1)
% hold on
% plot(calip1(:,1),calip1(:,2),'go','MarkerSize',0.5)
% hold off
% axis([startx1,endx1,starty1,endy1])
% subplot('Position',[start_plot_x+inter_x+plotsize_x,start_plot_y,plotsize_x,plotsize_y])
% imshow(cbimg2)
% hold on
% plot(calip2(:,1),calip2(:,2),'go','MarkerSize',0.5)
% hold off
% axis([startx2,endx2,starty2,endy2])
% subplot('Position',[start_plot_x+2*(inter_x+plotsize_x),start_plot_y,plotsize_x,plotsize_y])
% imshow(cbimg3)
% hold on
% plot(calip3(:,1),calip3(:,2),'go','MarkerSize',0.5)
% hold off
% axis([startx3,endx3,starty3,endy3])
% subplot('Position',[start_plot_x+3*(inter_x+plotsize_x),start_plot_y,plotsize_x,plotsize_y])
% imshow(cbimg4)
% hold on
% plot(calip4(:,1),calip4(:,2),'go','MarkerSize',0.5)
% hold off
% axis([startx4,endx4,starty4,endy4])
%% 3d reid
% start_pos_x = 0.665;
% start_pos_y = 0.75;
% plot_size = 0.03;
% inter_size = 0.0;
% linecmap = cbrewer2('Set1',9);
% sel_frame_idx = start_frame;
% sort_recomb_cell = csv2recomb3d(csv_cell,sel_frame_idx,camnum,cam_mat);
% mean_err_list = cell2mat(sort_recomb_cell(:,3));
% axeserr = subplot('Position',[0.69,0.75,0.15,0.15]);
% plot(mean_err_list,'-','Color',linecmap(9,:),'LineWidth',1)
% hold on
% plot(mean_err_list,'o','Color',linecmap(4,:),'LineWidth',1,'MarkerSize',3)
% hold off
% box off
% set(gca,'TickDir','out')
% set(gca,'YTick',[0,75])
% set(gca,'XTick',1:8)
% ylabel('Re-projection error')
% xlabel('Pairs')
% axis([0,9,0,75])
% 
% axes('position',[0.695,0.8,plot_size,plot_size])
% sel_idx = 1;
% X = sort_recomb_cell{sel_idx,4}{1,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{1,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{1,1}(3,:)';
% plotstr = mouse1_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold on
% X = sort_recomb_cell{sel_idx,4}{2,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{2,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{2,1}(3,:)';
% plotstr = mouse2_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold off
% view(2)
% set(gca,'XTick',[],'YTick',[],'ZTick',[])
% box on
% title(sel_idx)
% 
% axes('position',[0.695,0.86,plot_size,plot_size])
% sel_idx = 2;
% X = sort_recomb_cell{sel_idx,4}{1,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{1,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{1,1}(3,:)';
% plotstr = mouse1_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold on
% X = sort_recomb_cell{sel_idx,4}{2,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{2,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{2,1}(3,:)';
% plotstr = mouse2_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold off
% view(2)
% set(gca,'XTick',[],'YTick',[],'ZTick',[])
% box on
% title(sel_idx)
% 
% axes('position',[0.71,0.76,plot_size,plot_size])
% sel_idx = 3;
% X = sort_recomb_cell{sel_idx,4}{1,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{1,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{1,1}(3,:)';
% plotstr = mouse1_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold on
% X = sort_recomb_cell{sel_idx,4}{2,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{2,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{2,1}(3,:)';
% plotstr = mouse2_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold off
% view(2)
% set(gca,'XTick',[],'YTick',[],'ZTick',[])
% box on
% title(sel_idx)
% 
% axes('position',[0.73,0.85,plot_size,plot_size])
% sel_idx = 4;
% X = sort_recomb_cell{sel_idx,4}{1,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{1,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{1,1}(3,:)';
% plotstr = mouse1_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold on
% X = sort_recomb_cell{sel_idx,4}{2,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{2,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{2,1}(3,:)';
% plotstr = mouse2_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold off
% view(2)
% set(gca,'XTick',[],'YTick',[],'ZTick',[])
% box on
% title(sel_idx)
% 
% axes('position',[0.745,0.785,plot_size,plot_size])
% sel_idx = 5;
% X = sort_recomb_cell{sel_idx,4}{1,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{1,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{1,1}(3,:)';
% plotstr = mouse1_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold on
% X = sort_recomb_cell{sel_idx,4}{2,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{2,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{2,1}(3,:)';
% plotstr = mouse2_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold off
% view(2)
% set(gca,'XTick',[],'YTick',[],'ZTick',[])
% box on
% title(sel_idx)
% 
% axes('position',[0.765,0.845,plot_size,plot_size])
% sel_idx = 6;
% X = sort_recomb_cell{sel_idx,4}{1,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{1,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{1,1}(3,:)';
% plotstr = mouse1_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold on
% X = sort_recomb_cell{sel_idx,4}{2,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{2,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{2,1}(3,:)';
% plotstr = mouse2_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold off
% view(2)
% set(gca,'XTick',[],'YTick',[],'ZTick',[])
% box on
% title(sel_idx)
% 
% axes('position',[0.78,0.765,plot_size,plot_size])
% sel_idx = 7;
% X = sort_recomb_cell{sel_idx,4}{1,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{1,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{1,1}(3,:)';
% plotstr = mouse1_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold on
% X = sort_recomb_cell{sel_idx,4}{2,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{2,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{2,1}(3,:)';
% plotstr = mouse2_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold off
% view(2)
% set(gca,'XTick',[],'YTick',[],'ZTick',[])
% box on
% title(sel_idx)
% 
% axes('position',[0.8,0.83,plot_size,plot_size])
% sel_idx = 8;
% X = sort_recomb_cell{sel_idx,4}{1,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{1,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{1,1}(3,:)';
% plotstr = mouse1_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold on
% X = sort_recomb_cell{sel_idx,4}{2,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{2,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{2,1}(3,:)';
% plotstr = mouse2_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold off
% view(2)
% set(gca,'XTick',[],'YTick',[],'ZTick',[])
% box on
% title(sel_idx)
%%

% 
% subplot('Position',[start_pos_x,start_pos_y+plot_size+inter_size,...
%     plot_size,plot_size])
% sel_idx = 1;
% X = sort_recomb_cell{sel_idx,4}{1,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{1,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{1,1}(3,:)';
% plotstr = mouse1_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold on
% X = sort_recomb_cell{sel_idx,4}{2,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{2,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{2,1}(3,:)';
% plotstr = mouse2_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold off
% view(2)
% set(gca,'XTick',[],'YTick',[],'ZTick',[])
% subplot('Position',[start_pos_x+plot_size+inter_size,start_pos_y+plot_size+inter_size,...
%     plot_size,plot_size])
% sel_idx = 2;
% X = sort_recomb_cell{sel_idx,4}{1,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{1,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{1,1}(3,:)';
% plotstr = mouse1_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold on
% X = sort_recomb_cell{sel_idx,4}{2,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{2,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{2,1}(3,:)';
% plotstr = mouse2_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold off
% view(2)
% set(gca,'XTick',[],'YTick',[],'ZTick',[])
% subplot('Position',[start_pos_x+2*(plot_size+inter_size),start_pos_y+plot_size+inter_size,...
%     plot_size,plot_size])
% sel_idx = 3;
% X = sort_recomb_cell{sel_idx,4}{1,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{1,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{1,1}(3,:)';
% plotstr = mouse1_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold on
% X = sort_recomb_cell{sel_idx,4}{2,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{2,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{2,1}(3,:)';
% plotstr = mouse2_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold off
% view(2)
% set(gca,'XTick',[],'YTick',[],'ZTick',[])
% subplot('Position',[start_pos_x+3*(plot_size+inter_size),start_pos_y+plot_size+inter_size,...
%     plot_size,plot_size])
% sel_idx = 4;
% X = sort_recomb_cell{sel_idx,4}{1,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{1,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{1,1}(3,:)';
% plotstr = mouse1_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold on
% X = sort_recomb_cell{sel_idx,4}{2,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{2,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{2,1}(3,:)';
% plotstr = mouse2_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold off
% view(2)
% set(gca,'XTick',[],'YTick',[],'ZTick',[])
% subplot('Position',[start_pos_x,start_pos_y,plot_size,plot_size])
% sel_idx = 5;
% X = sort_recomb_cell{sel_idx,4}{1,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{1,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{1,1}(3,:)';
% plotstr = mouse1_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold on
% X = sort_recomb_cell{sel_idx,4}{2,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{2,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{2,1}(3,:)';
% plotstr = mouse2_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold off
% view(2)
% set(gca,'XTick',[],'YTick',[],'ZTick',[])
% subplot('Position',[start_pos_x+plot_size+inter_size,start_pos_y,...
%     plot_size,plot_size])
% sel_idx = 6;
% X = sort_recomb_cell{sel_idx,4}{1,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{1,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{1,1}(3,:)';
% plotstr = mouse1_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold on
% X = sort_recomb_cell{sel_idx,4}{2,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{2,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{2,1}(3,:)';
% plotstr = mouse2_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold off
% view(2)
% set(gca,'XTick',[],'YTick',[],'ZTick',[])
% subplot('Position',[start_pos_x+2*(plot_size+inter_size),start_pos_y,...
%     plot_size,plot_size])
% sel_idx = 7;
% X = sort_recomb_cell{sel_idx,4}{1,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{1,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{1,1}(3,:)';
% plotstr = mouse1_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold on
% X = sort_recomb_cell{sel_idx,4}{2,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{2,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{2,1}(3,:)';
% plotstr = mouse2_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold off
% view(2)
% set(gca,'XTick',[],'YTick',[],'ZTick',[])
% subplot('Position',[start_pos_x+3*(plot_size+inter_size),start_pos_y,...
%     plot_size,plot_size])
% sel_idx = 8;
% X = sort_recomb_cell{sel_idx,4}{1,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{1,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{1,1}(3,:)';
% plotstr = mouse1_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold on
% X = sort_recomb_cell{sel_idx,4}{2,1}(1,:)';
% Y = sort_recomb_cell{sel_idx,4}{2,1}(2,:)';
% Z = sort_recomb_cell{sel_idx,4}{2,1}(3,:)';
% plotstr = mouse2_c;
% linestr = 'k';
% markersize = 5;
% linewidth = 0.5;
% plot_skl_size(X,Y,Z,plotstr,linestr,markersize,linewidth)
% hold off
% view(2)
% set(gca,'XTick',[],'YTick',[],'ZTick',[])
%% 3D poses
% 3D view
% start_pos_x = -50;
% start_pos_y = 180;
% inter_pos_xy = 250;
% plot_size_h = 0.11;
% h14 = subplot('Position',[0.86,0.865,plot_size_h,plot_size_h]);
% sel_frame = start_frame;
% dotsize = 6;
% temppos = load([rootpath,'\panel_9\rec11-A1A2-20220803-id3d.mat']);
% mouse2 = temppos.coords3d(:,1:48);
% mouse1 = temppos.coords3d(:,49:96);
% drawline = [ 1 2; 1 3;2 3; 4 5;4 6;5 7;6 8;7 14;8 14;...
%     5 9;7 11;6 10; 8 12;14 15; 15 16];
% nfeatures = 16;
% colorclass = ones(256,1)*mouse1_c; %jet is default in DLC
% color_map_self=colorclass(ceil(linspace(1,256,nfeatures)),:);
% % h14 = subplot('Position',[0.06,0.28,0.17,0.17]);
% mesh_mouse(mouse1, sel_frame)
% hold on
% temp = reshape(mouse1(sel_frame,:,1),3,nfeatures);
% scatter3(temp(1,:),temp(2,:),temp(3,:),dotsize*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', h14);
% hold on;
% for l = 1:size(drawline,1)
%     pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
%     line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1,'Parent', h14)
% end
% hold on
% colorclass = ones(256,1)*mouse2_c; %jet is default in DLC
% color_map_self=colorclass(ceil(linspace(1,256,nfeatures)),:);
% mesh_mouse(mouse2, sel_frame)
% hold on
% temp = reshape(mouse2(sel_frame,:,1),3,nfeatures);
% scatter3(temp(1,:),temp(2,:),temp(3,:),dotsize*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', h14);
% hold on;
% for l = 1:size(drawline,1)
%     pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
%     line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1,'Parent', h14)
% end
% hold off
% view(-24,49)
% xlabel('x')
% ylabel('y')
% zlabel('z')
% set(gca,'TickDir','none')
% set(gca,'XTickLabel',[])
% set(gca,'YTickLabel',[])
% set(gca,'ZTickLabel',[])
% axis([start_pos_x,start_pos_x+inter_pos_xy,...
%     start_pos_y,start_pos_y+inter_pos_xy,-10,100])
% grid on
% % title('3D Poses','Color','blue')
% % 2D view
% h15 = subplot('Position',[0.86,0.75,plot_size_h,plot_size_h]);
% sel_frame = start_frame;
% temppos = load([rootpath,'\panel_9\rec11-A1A2-20220803-id3d.mat']);
% drawline = [ 1 2; 1 3;2 3; 4 5;4 6;5 7;6 8;7 14;8 14;...
%     5 9;7 11;6 10; 8 12;14 15; 15 16];
% nfeatures = 16;
% colorclass = ones(256,1)*mouse1_c; %jet is default in DLC
% color_map_self=colorclass(ceil(linspace(1,256,nfeatures)),:);
% % h14 = subplot('Position',[0.06,0.28,0.17,0.17]);
% mesh_mouse(mouse1, sel_frame)
% hold on
% temp = reshape(mouse1(sel_frame,:,1),3,nfeatures);
% scatter3(temp(1,:),temp(2,:),temp(3,:),dotsize*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', h15);
% hold on;
% for l = 1:size(drawline,1)
%     pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
%     line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1,'Parent', h15)
% end
% hold on
% colorclass = ones(256,1)*mouse2_c; %jet is default in DLC
% color_map_self=colorclass(ceil(linspace(1,256,nfeatures)),:);
% mesh_mouse(mouse2, sel_frame)
% hold on
% temp = reshape(mouse2(sel_frame,:,1),3,nfeatures);
% scatter3(temp(1,:),temp(2,:),temp(3,:),dotsize*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', h15);
% hold on;
% for l = 1:size(drawline,1)
%     pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
%     line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1,'Parent', h15)
% end
% hold off
% view(2)
% xlabel('x')
% ylabel('y')
% zlabel('z')
% set(gca,'TickDir','none')
% set(gca,'XTickLabel',[])
% set(gca,'YTickLabel',[])
% set(gca,'ZTickLabel',[])
% axis([start_pos_x,start_pos_x+inter_pos_xy,...
%     start_pos_y,start_pos_y+inter_pos_xy,-10,100])
% grid on
% % title('3D Poses','Color','blue')
%% trends of label data 
mark_ratio = 1000;
mouse_num = 1:4;
per_label_num = 1:25;
all_label_num_dlc = zeros(length(mouse_num),length(per_label_num));
all_label_num_sbea = zeros(length(mouse_num),length(per_label_num));
for m = 1:length(mouse_num)
    for p = 1:length(per_label_num)
        all_label_num_dlc(m,p) = mouse_num(m)*per_label_num(p);
        all_label_num_sbea(m,p) = 1*per_label_num(p);
    end
end
% hl1 = subplot('Position',[0.15,0.715,0.1,0.005]);
% imagesc(1:max(all_label_num_dlc(:)))
% clim(hl1,[1,max(all_label_num_dlc(:))])
% set(gca,'XTick',[1,max(all_label_num_dlc(:))])
% set(gca,'XAxisLocation','top')
% xlabel('Total points')
hl3 = subplot('Position',[0.06,0.55,0.11,0.11]);
% imagesc(all_label_num_dlc)
% clim(hl3,[1,max(all_label_num_dlc(:))])
mesh(all_label_num_dlc)
hold on
mesh(all_label_num_sbea)
hold off
view(42,14)
xlabel('Body points')
ylabel('Animals')
zlabel('Total pose labels')
colormap(hl3,cbrewer2('Greens',256))
%% show all and close
hpc = subplot('Position',[0.48,0.22,0.15,0.25]);

body_parts = {...
    'Nose','Left ear','Right ear','Neck',...
    'Left front limb','Right front limb','Left hind limb','Right hind limb',...
    'Left front paw','Right front paw','Left hind paw','Right hind paw',...
    'Back','Root tail','Mid tail','Tip tail'};

cmap = cbrewer2('RdBu',10);
cmap_sbea = cmap(2,:);
cmap_dlc = cmap(10,:);

all_dist_data = cell2mat(err_dist.dist_cell(:,2));
[IDX, C] = kmeans(all_dist_data,3);
xdlist = all_dist_data;
temppdfx = linspace(min(xdlist),max(xdlist),1000);
temppdfy = mat2gray(pdf(fitdist(xdlist,'kernel'),temppdfx))';
sel_pos_x = [];
for k = 1:length(C)
    find_pos = abs(temppdfx-C(k));
    min_pos = find(find_pos==min(find_pos));
    sel_pos_x = [sel_pos_x;min_pos];
end
cut_pos_x = temppdfx(round(sel_pos_x));
cut_pos_y = temppdfy(round(sel_pos_x))';

y_sbea = [];
y_dlc = [];
y_slp = [];
y_dist = [];
for k = 1:size(err_sbea.err_nid_cell,1)
    temperr = err_sbea.err_nid_cell{k,2};
    y_sbea = [y_sbea;temperr(:,1:16);temperr(:,17:32)];
    temperr = err_dlc.err_nid_cell{k,2};
    y_dlc = [y_dlc;temperr(:,1:16);temperr(:,17:32)];
    temperr = err_slp.err_nid_cell{k,2};
    y_slp = [y_slp;temperr(:,1:16);temperr(:,17:32)];
    tempdist = err_dist.dist_cell{k,2};
    y_dist = [y_dist;tempdist;tempdist];
end

min_c = min(C);

y_sel_sbea = y_sbea(y_dist<min_c,:);
% y_sel_dlc = y_dlc(y_dist<min_c,:);

mean_raw_sbea = mean(y_sbea)';
mean_raw_dlc = mean(y_sel_sbea)';
sd_raw_sbea = std(y_sbea)';
sd_raw_dlc = std(y_sel_sbea)';
N_raw_sbea = ones(size(y_sbea,2),1)*size(y_sbea,1);
N_raw_dlc = ones(size(y_sel_sbea,2),1)*size(y_sel_sbea,1);
group_data = [mean_raw_sbea,sd_raw_sbea,N_raw_sbea,...
    mean_raw_dlc,sd_raw_dlc,N_raw_dlc];

npoints = 1000;
kd_sbea_x = zeros(npoints,size(y_sbea,2));
kd_dlc_x = zeros(npoints,size(y_sel_sbea,2));
kd_sbea_y = zeros(npoints,size(y_sbea,2));
kd_dlc_y = zeros(npoints,size(y_sel_sbea,2));

mean_raw_sbea_y = zeros(size(mean_raw_sbea));
mean_raw_dlc_y = zeros(size(mean_raw_dlc));

for k = 1:size(kd_sbea_y,2)
    
    xdlist = y_sbea(:,k);
    temppdfx = linspace(min(xdlist),max(xdlist),1000);
    temppdfy = mat2gray(pdf(fitdist(xdlist,'kernel'),temppdfx))';
    kd_sbea_x(:,k) = temppdfx';
    kd_sbea_y(:,k) = temppdfy;
    
    find_pos = abs(temppdfx-mean_raw_sbea(k));
    min_pos = find_pos==min(find_pos);
    mean_raw_sbea_y(k) = temppdfy(min_pos);
    
    xdlist = y_dlc(:,k);
    temppdfx = linspace(min(xdlist),max(xdlist),1000);
    temppdfy = mat2gray(pdf(fitdist(xdlist,'kernel'),temppdfx))';
    kd_dlc_x(:,k) = temppdfx';
    kd_dlc_y(:,k) = temppdfy;
    
    find_pos = abs(temppdfx-mean_raw_dlc(k));
    min_pos = find_pos==min(find_pos);
    mean_raw_dlc_y(k) = temppdfy(min_pos);
    
end

x_sbea_dlc = 1:16;
shri_size = 2.5;
maxy = 20;
mk_size = 3;
line_len = 0.3;

for k = x_sbea_dlc
    show_x_sbea = k-kd_sbea_y(:,k)/shri_size;
    show_x_dlc = kd_dlc_y(:,k)/shri_size+k;
    plot([0,maxy],[k,k],'k-')
    hold on
    plot(kd_sbea_x(:,k),show_x_sbea,'Color',cmap_sbea)
    hold on
    plot([mean_raw_sbea(k),mean_raw_sbea(k)],[k-mean_raw_sbea_y(k)/shri_size-line_len,k],'Color',cmap_sbea)
    hold on
    plot(mean_raw_sbea(k),k-mean_raw_sbea_y(k)/shri_size,'ko',...
        'MarkerFaceColor','w','MarkerEdgeColor',cmap_sbea,...
        'MarkerSize',mk_size)
    hold on
    plot(kd_dlc_x(:,k),show_x_dlc,'Color',cmap_dlc)
    hold on
    plot([mean_raw_dlc(k),mean_raw_dlc(k)],[k+mean_raw_dlc_y(k)/shri_size+line_len,k],'Color',cmap_dlc)
    hold on
    plot(mean_raw_dlc(k),k+mean_raw_dlc_y(k)/shri_size,'ko',...
        'MarkerFaceColor','w','MarkerEdgeColor',cmap_dlc,...
        'MarkerSize',mk_size)
    hold on
end
hold off
axis([0,maxy,0.5,16.5])
set(gca,'TickDir','out')
xlabel('RMSE (pixels)')
set(gca,'Ytick',1:16)
set(gca,'YTickLabel',body_parts)
box off














































