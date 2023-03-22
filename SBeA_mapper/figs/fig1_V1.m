%{
    fig1, the framework of SBeA
%}
clear all
close all
addpath(genpath(pwd))
%% plot canvas
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
set(h1,'color','white');
%% plot
rootpath = 'Z:\hanyaning\multi_mice_test\Social_analysis\data\figs\fig1';
rootpathfig2 = 'Z:\hanyaning\multi_mice_test\Social_analysis\data\figs\fig2';
%% video capture
% 1. mice in cage
cagename = [rootpath,'\panel_1\cage_2mice.jpg'];
cageimg = imread(cagename);
subplot('Position',[0.07,0.75,0.2,0.2])
imshow(cageimg)
title('Mice in home-cage','Color','blue')
annotation('arrow',[0.3,0.36],[0.84,0.84])
annotation('arrow',[0.17,0.17],[0.78,0.74])
% 2. single mouse
singlename = [rootpath,'\panel_1\oft_1mouse.jpg'];
singleimg = imread(singlename);
subplot('Position',[0.37,0.75,0.2,0.2])
imshow(singleimg)
title('Video capture of single mouse','Color','blue')
annotation('arrow',[0.57,0.63],[0.84,0.84])
% 3. multi mice
multiname = [rootpath,'\panel_1\oft_2mice.jpg'];
multiimg = imread(multiname);
subplot('Position',[0.07,0.53,0.2,0.2])
imshow(multiimg)
title('Video capture of multi-mice','Color','blue')
annotation('arrow',[0.3,0.36],[0.64,0.64])
%% reid
reidname1 = [rootpath,'\panel_2\cam_17_layer3_9.jpg'];
reidname2 = [rootpath,'\panel_2\cam_L02_layer3_2581.jpg'];
reidimg1 = imread(reidname1);
reidimg2 = imread(reidname2);
subplot('Position',[0.65,0.725,0.24,0.24])
imshow([reidimg1(140:end,:,:),reidimg2(140:end,:,:)])
xlabel(' Mouse 1 (M1)     Mouse 2 (M2)')
title('Markerless image ID','Color','blue')
annotation('arrow',[0.77,0.58],[0.64,0.64])
annotation('line',[0.77,0.77],[0.64,0.7])
annotation('line',[0.71,0.83],[0.7,0.7])
annotation('line',[0.71,0.71],[0.7,0.72])
annotation('line',[0.83,0.83],[0.7,0.72])
text(-500,3600,'Re-Identification')
%% tracking
setcolor = cbrewer2('Spectral',11);
mouse1_c = setcolor(3,:);
mouse2_c = setcolor(9,:);
sel_frame = 10;
dotsize = 10;
temppos = load([rootpathfig2,'\panel_14\rec1-group-20211207-reid3d.mat']);
mouse1 = reshape(temppos.coords3d(1,:,:),[1800,48]);
mouse2 = reshape(temppos.coords3d(2,:,:),[1800,48]);
drawline = [ 1 2; 1 3;2 3; 4 5;4 6;5 7;6 8;7 14;8 14;...
    5 9;7 11;6 10; 8 12;14 15; 15 16];
nfeatures = 16;
colorclass = ones(256,1)*mouse1_c; %jet is default in DLC
color_map_self=colorclass(ceil(linspace(1,256,nfeatures)),:);
h14 = subplot('Position',[0.38,0.525,0.19,0.19]);
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
view(-113,36)
set(gca,'TickDir','none')
set(gca,'XTickLabel',[])
set(gca,'YTickLabel',[])
set(gca,'ZTickLabel',[])
axis([-420,-140,-30,250,-10,100])
grid on
title('3D Poses','Color','blue')
title('3D pose estimation','Color','blue')
annotation('line',[0.47,0.47],[0.51,0.53])
annotation('line',[0.17,0.77],[0.51,0.51])
annotation('arrow',[0.47,0.47],[0.51,0.48])
annotation('arrow',[0.77,0.77],[0.51,0.48])
annotation('arrow',[0.17,0.17],[0.51,0.48])
%% segmentation
dataname = [rootpath,'\panel_3\SBeA_data_sample_cell_20220607.mat'];
load(dataname);
raw_struct_name = [rootpath,'\panel_3\Black_White_207_social_struct.mat'];
load(raw_struct_name);
%%
sel_num_list = [8,9,10,11,12];
sel_data_sample_cell = data_sample_cell(sel_num_list,:);
kinetics_trace = cell2mat(sel_data_sample_cell(:,1)');
kinetics_trace(3,:) = kinetics_trace(3,:);
kinetics_trace(4,:) = kinetics_trace(4,:);
start_frame = sel_data_sample_cell{1,2}(1,1);
end_frame = sel_data_sample_cell{end,2}(1,2);
sel_raw_data = cell2mat(cellfun(@(x) x(:,start_frame:end_frame),...
    SBeA.RawData.centered,'UniformOutput',false));
sel_raw_data([37,38,39,85,86,87],:) =  [];
cmap_m1 = cbrewer2('YlGnBu',size(sel_raw_data,1));
cmap_m2 = cbrewer2('YlOrBr',size(sel_raw_data,1));
cmap_m1 = cmap_m1((1+round(size(sel_raw_data,1)/2)):end,:);
cmap_m2 = cmap_m2((1+round(size(sel_raw_data,1)/2)):end,:);
sel_raw_data_m1 = sel_raw_data(1:round(size(sel_raw_data,1)/2),:);
sel_raw_data_m2 = sel_raw_data((1+round(size(sel_raw_data,1)/2)):end,:);
subplot('Position',[0.07,0.35,0.2,0.1])
for k = 1:3:size(sel_raw_data_m1,1)
    plot(sel_raw_data_m1(k,:)+k*20,'Color',cmap_m1(k,:))
    hold on
end
hold on
for k = 1:3:size(sel_raw_data_m2,1)
    plot(sel_raw_data_m2(k,:)-900+k*20,'Color',cmap_m2(k,:))
    hold on
end
hold off
axis([0,size(sel_raw_data,2),-1000,1000])
axis off
text(-30,500,'M1')
text(-30,-500,'M2')
text(55,-1040,'Trajectories')
annotation('arrow',[0.17,0.17],[0.33,0.3])
title('Social behavior decomposition','Color','blue')
%
subplot('Position',[0.07,0.2,0.2,0.1])
bias = [1,1,2,2,3,3]*2;
cmap_feat = [cmap_m2(1,:);cmap_m1(1,:);...
             cmap_m2(10,:);cmap_m1(10,:);...
             cmap_m2(20,:);cmap_m1(20,:)];
for k = 1:6
    plot(kinetics_trace(k,:)+1*k+bias(k),'color',cmap_feat(k,:))
    hold on
end
hold off
axis([0,size(sel_raw_data,2),0,15])
axis off
text(70,0,'Kinetics')
text(-30,12,'NM')
text(-20,8,'L')
text(-20,4,'D')
annotation('arrow',[0.17,0.17],[0.18,0.15])
%
savelist = cell2mat(sel_data_sample_cell(:,2));
seg_list = savelist(2:end,1)-start_frame+1;
hb = subplot('Position',[0.07,0.12,0.2,0.02]);
imagesc(ones(1,size(sel_raw_data,2)))
colormap(hb,[0.8,0.8,0.8])
hold on
for k = 1:size(seg_list,1)
    plot([seg_list(k,1),seg_list(k,1)],[0.5,1.5],'w','Linewidth',2)
    hold on
end
hold off
axis([0,size(sel_raw_data,2),0.5,1.5])
text(25,2,'Behavior segments')
set(gca,'XTick',[])
set(gca,'YTick',[])
axis off
%% mapping
wcname = [rootpath,'\panel_4\SBeA_wc_struct_20220607.mat'];
load(wcname);
%%
h12 = subplot('Position',[0.55,0.35,0.01,0.1]);
cmap_length = length(unique(wc_struct.L_ittie))-1;
showlabel = labeloverlay(ones(cmap_length,1),(1:cmap_length)','Transparency',0.9);
imshow(showlabel)
subplot('Position',[0.39,0.3,0.15,0.15])
coloredImage = ind2rgb(round(mat2gray(wc_struct.image_much)*255), cmap);
showimg = labeloverlay(coloredImage,wc_struct.L_ittie,'Transparency',0.9);
showimg1 = showimg(:,:,1);
showimg2 = showimg(:,:,2);
showimg3 = showimg(:,:,3);
showimg1(wc_struct.L_much==0) = 150;
showimg2(wc_struct.L_much==0) = 150;
showimg3(wc_struct.L_much==0) = 150;
allshowimg = showimg;
allshowimg(:,:,1) = showimg1;
allshowimg(:,:,2) = showimg2;
allshowimg(:,:,3) = showimg3;
imshow(imresize(allshowimg,[150,150]))
axis square
title('Behavior mapping and clustering','Color','blue')
annotation('rectangle',[0.41,0.335,0.01,0.01])
annotation('rectangle',[0.45,0.38,0.01,0.01])
annotation('rectangle',[0.5,0.37,0.01,0.01])
annotation('line',[0.415,0.35],[0.335,0.22])
annotation('line',[0.455,0.46],[0.38,0.22])
annotation('line',[0.505,0.57],[0.37,0.22])
text(-50,340,'Elaborate behavior classifications')
sel_frame = 1;
setcolor = cbrewer2('Spectral',11);
mouse1_c = setcolor(3,:);
mouse2_c = setcolor(9,:);
h15 = subplot('Position',[0.3,0.12,0.1,0.1]);
colorclass = ones(256,1)*mouse1_c; %jet is default in DLC
color_map_self=colorclass(ceil(linspace(1,256,nfeatures)),:);
mesh_mouse(mouse1, sel_frame)
hold on
temp = reshape(mouse1(sel_frame,:,1),3,nfeatures);
scatter3(temp(1,:),temp(2,:),temp(3,:),dotsize*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', h15);
hold on;
for l = 1:size(drawline,1)
    pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
    line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1,'Parent', h15)
end
hold on
colorclass = ones(256,1)*mouse2_c; %jet is default in DLC
color_map_self=colorclass(ceil(linspace(1,256,nfeatures)),:);
mesh_mouse(mouse2, sel_frame)
hold on
temp = reshape(mouse2(sel_frame,:,1),3,nfeatures);
scatter3(temp(1,:),temp(2,:),temp(3,:),dotsize*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', h15);
hold on;
for l = 1:size(drawline,1)
    pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
    line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1,'Parent', h15)
end
hold off
axis off
view(-64,90)
h16 = subplot('Position',[0.41,0.12,0.1,0.1]);
sel_frame = 1547;
colorclass = ones(256,1)*mouse1_c; %jet is default in DLC
color_map_self=colorclass(ceil(linspace(1,256,nfeatures)),:);
mesh_mouse(mouse1, sel_frame)
hold on
temp = reshape(mouse1(sel_frame,:,1),3,nfeatures);
scatter3(temp(1,:),temp(2,:),temp(3,:),dotsize*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', h16);
hold on;
for l = 1:size(drawline,1)
    pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
    line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1,'Parent', h16)
end
hold on
colorclass = ones(256,1)*mouse2_c; %jet is default in DLC
color_map_self=colorclass(ceil(linspace(1,256,nfeatures)),:);
mesh_mouse(mouse2, sel_frame)
hold on
temp = reshape(mouse2(sel_frame,:,1),3,nfeatures);
scatter3(temp(1,:),temp(2,:),temp(3,:),dotsize*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', h16);
hold on;
for l = 1:size(drawline,1)
    pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
    line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1,'Parent', h16)
end
hold off
axis off
view(-49,70)
h17 = subplot('Position',[0.52,0.12,0.1,0.1]);
sel_frame = 1560;
colorclass = ones(256,1)*mouse1_c; %jet is default in DLC
color_map_self=colorclass(ceil(linspace(1,256,nfeatures)),:);
mesh_mouse(mouse1, sel_frame)
hold on
temp = reshape(mouse1(sel_frame,:,1),3,nfeatures);
scatter3(temp(1,:),temp(2,:),temp(3,:),dotsize*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', h17);
hold on;
for l = 1:size(drawline,1)
    pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
    line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1,'Parent', h17)
end
hold on
colorclass = ones(256,1)*mouse2_c; %jet is default in DLC
color_map_self=colorclass(ceil(linspace(1,256,nfeatures)),:);
mesh_mouse(mouse2, sel_frame)
hold on
temp = reshape(mouse2(sel_frame,:,1),3,nfeatures);
scatter3(temp(1,:),temp(2,:),temp(3,:),dotsize*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', h17);
hold on;
for l = 1:size(drawline,1)
    pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
    line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1,'Parent', h17)
end
hold off
axis off
view(-41,30)
%% relationship
subplot('Position',[0.72,0.35,0.1,0.1])
title('Behavioral relationship network','Color','blue')
subplot('Position',[0.68,0.3,0.05,0.05])
subplot('Position',[0.73,0.3,0.05,0.05])
title('3D animal demo')
subplot('Position',[0.78,0.3,0.05,0.05])


































