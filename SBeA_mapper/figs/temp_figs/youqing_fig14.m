%{
    fig 14
    free social + tpm
%}
clear all
close all
%% 绘制画布
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
%% 原始数据
img_num = 3910;
videopath = 'Z:\hanyaning\multi_mice_test\Social_analysis\data\MTPM_social_20220226\raw_video_20220226';
vidobj1 = VideoReader([videopath,'\seg-1-mouse-day1-camera-4.avi']);
img1 = read(vidobj1,img_num);
imgsize = 0.15;
subplot('Position',[0.25,0.7,imgsize,imgsize*0.75])
imshow(img1)
%%
img_num_2 = 9900;
vidobj2 = VideoReader([videopath,'\seg-2-mouse-day1-camera-3.avi']);
img2 = read(vidobj2,img_num_2);
imgsize = 0.15;
subplot('Position',[0.25,0.4,imgsize,imgsize*0.75])
imshow(img2)
%% tpm
tpmpath1 = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'MTPM_social_20220226\social_20220226\social_1\social_1\social_1 0.tif'];
tpmimg1 = zeros(512,512);
for k = 180:200
    tpmimg1 = tpmimg1 + double(imread(tpmpath1,k));
end
tpmimg1 = mat2gray(tpmimg1/k);

h1 = subplot('Position',[0.25,0.815,0.15,0.15]);
imshow(adapthisteq(tpmimg1),[]);
colormap(h1,flipud(cbrewer2('RdBu')))
%% tpm
tpmpath2 = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'MTPM_social_20220226\social_20220226\social_2\social_2\social_2 0.tif'];
tpmimg2 = zeros(512,512);
for k = 180:200
    tpmimg2 = tpmimg2 + double(imread(tpmpath2,k));
end
tpmimg2 = mat2gray(tpmimg2/k);

h2 = subplot('Position',[0.25,0.515,0.15,0.15]);
imshow(adapthisteq(tpmimg2),[])
colormap(h2,flipud(cbrewer2('RdBu')))
%% trajctories
tpmdatapath1 = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'MTPM_social_20220228_all\tpm_data\resample_tpm\free-seg1-1tpm-1wt-20220226.mat'];
tpmdata1 = load(tpmdatapath1);
%%
tpmneu1 = tpmdata1.F(tpmdata1.iscell(:,1)==1,:)-...
    0.7*tpmdata1.Fneu(tpmdata1.iscell(:,1)==1,:);
meanneu1 = mean(tpmneu1,2);
[~,sortlist] = sort(meanneu1);
% dffneu1 = (tpmneu1-mean(tpmneu1,2)*ones(1,size(tpmneu1,2)))./...
%     abs(mean(tpmneu1,2)*ones(1,size(tpmneu1,2)));
zneu1 = zscore(zscore(tpmneu1,1,2));
smoneu1 = zneu1;
for k = 1:size(zneu1,1)
    smoneu1(k,:) = medfilt1(zneu1(k,:),15);
end
h3 = subplot('Position',[0.45,0.815,0.4,0.15]);
imagesc(smoneu1(sortlist,:))
colormap(h3,cbrewer2('Blues'))
colorbar('position',[0.86,0.815,0.01,0.15])
caxis([-1,2])
set(gca,'TickDir','out')
set(gca,'XTickLabel',[])
set(gca,'YTick',[1,272])
box off
ylabel('Neurons')
%% tpm trajctories
tpmdatapath2 = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'MTPM_social_20220228_all\tpm_data\resample_tpm\fix-seg2-1tpm-2wt-20220226.mat'];
tpmdata2 = load(tpmdatapath2);
%%
tpmneu2 = tpmdata2.F(tpmdata2.iscell(:,1)==1,:)-...
    0.7*tpmdata2.Fneu(tpmdata2.iscell(:,1)==1,:);
meanneu2 = mean(tpmneu2,2);
[~,sortlist] = sort(meanneu2);
% dffneu1 = (tpmneu1-mean(tpmneu1,2)*ones(1,size(tpmneu1,2)))./...
%     abs(mean(tpmneu1,2)*ones(1,size(tpmneu1,2)));
zneu2 = zscore(zscore(tpmneu2,1,2));
smoneu2 = zneu2;
for k = 1:size(zneu2,1)
    smoneu2(k,:) = medfilt1(zneu2(k,:),15);
end
h4 = subplot('Position',[0.45,0.515,0.4,0.15]);
imagesc(smoneu2(sortlist,:))
colormap(h4,cbrewer2('Blues'))
caxis([-1,2])
set(gca,'TickDir','out')
set(gca,'XTickLabel',[])
set(gca,'YTick',[1,303])
box off
ylabel('Neurons')
%% behavior segmentations
datasamplepath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'MTPM_social_20220228_all\recluster_data\data_sample_cell.mat'];
load(datasamplepath);
seldata1 = data_sample_cell(strcmp(data_sample_cell(:,3), ...
    'free-seg1-1tpm-1wt-20220226_struct.mat'),:);
seldata2 = data_sample_cell(strcmp(data_sample_cell(:,3), ...
    'fix-seg2-1tpm-2wt-20220226_struct.mat'),:);
seg1 = cell2mat(seldata1(:,2));
seglist1 = zeros(1,27000);
for k = 1:size(seg1,1)
    seglist1(1,seg1(k,1):seg1(k,2)) = seg1(k,4);
end
seg2 = cell2mat(seldata2(:,2));
seglist2 = zeros(1,27000);
for k = 1:size(seg2,1)
    seglist2(1,seg2(k,1):seg2(k,2)) = seg2(k,4);
end
%%
h5 = subplot('Position',[0.45,0.8,0.4,0.01]);
imagesc(seglist1)
colormap(h5,cbrewer2('PRGn'))
axis off
set(gca,'YTick',[])
h6 = subplot('Position',[0.45,0.5,0.4,0.01]);
imagesc(seglist2)
set(gca,'YTick',[])
set(gca,'XTick',[1,27000])
set(gca,'XTickLabel',[0,15])
box off
colormap(h6,cbrewer2('PRGn'))
%% behavior trajs
behpath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'MTPM_social_20220228_all\behavior_data'];
beh1 = load([behpath,'\free-seg1-1tpm-1wt-20220226.mat']);
beh2 = load([behpath,'\fix-seg2-1tpm-2wt-20220226.mat']);
drawline = [ 1 2; 1 3;2 3; 4 5;4 6;5 7;6 8;7 14;8 14;...
    5 9;7 11;6 10; 8 12;14 15; 15 16];
nfeatures = 16;
colorclass = jet; %jet is default in DLC
color_map_self=colorclass(ceil(linspace(1,256,nfeatures)),:);
%%
iFrame1 = 10;
iFrame2 = 6740;
iFrame3 = 13530;
iFrame4 = 20500;
iFrame5 = 27000;
dotsize = 10;
view11 = -128;
view12 = 31;
view21 = -106;
view22 = 22;
view31 = 10;
view32 = 17;
view41 = -94;
view42 = -18;
view51 = 10;
view52 = 10;
h7 = subplot('Position',[0.45,0.7,0.08,0.08]);
mesh_mouse(beh1.coords3d, iFrame1)
hold on
temp = reshape(beh1.coords3d(iFrame1,:,1),3,nfeatures);
scatter3(temp(1,:),temp(2,:),temp(3,:),dotsize*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', h7);
hold on;
for l = 1:size(drawline,1)
    pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
    line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1,'Parent', h7)
end
hold off
view(view11,view12)
axis off

h8 = subplot('Position',[0.53,0.7,0.08,0.08]);
mesh_mouse(beh1.coords3d, iFrame2)
hold on
temp = reshape(beh1.coords3d(iFrame2,:,1),3,nfeatures);
scatter3(temp(1,:),temp(2,:),temp(3,:),dotsize*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', h8);
hold on;
for l = 1:size(drawline,1)
    pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
    line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1,'Parent', h8)
end
hold off
view(view21,view22)
axis off

h9 = subplot('Position',[0.61,0.7,0.08,0.08]);
mesh_mouse(beh1.coords3d, iFrame3)
hold on
temp = reshape(beh1.coords3d(iFrame3,:,1),3,nfeatures);
scatter3(temp(1,:),temp(2,:),temp(3,:),dotsize*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', h9);
hold on;
for l = 1:size(drawline,1)
    pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
    line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1,'Parent', h9)
end
hold off
view(view31,view32)
axis off

h10 = subplot('Position',[0.69,0.7,0.08,0.08]);
mesh_mouse(beh1.coords3d, iFrame4)
hold on
temp = reshape(beh1.coords3d(iFrame4,:,1),3,nfeatures);
scatter3(temp(1,:),temp(2,:),temp(3,:),dotsize*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', h10);
hold on;
for l = 1:size(drawline,1)
    pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
    line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1,'Parent', h10)
end
hold off
view(view41,view42)
axis off

h11 = subplot('Position',[0.77,0.7,0.08,0.08]);
mesh_mouse(beh1.coords3d, iFrame5)
hold on
temp = reshape(beh1.coords3d(iFrame5,:,1),3,nfeatures);
scatter3(temp(1,:),temp(2,:),temp(3,:),dotsize*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', h11);
hold on;
for l = 1:size(drawline,1)
    pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
    line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1,'Parent', h11)
end
hold off
view(view51,view52)
axis off

%%
iFrame1 = 10;
iFrame2 = 6740;
iFrame3 = 13500;
iFrame4 = 20500;
iFrame5 = 27000;
dotsize = 10;
view11 = -213;
view12 = -14;
view21 = 79;
view22 = 22;
view31 = 114;
view32 = 22;
view41 = -88;
view42 = 90;
view51 = -193;
view52 = 36;
h7 = subplot('Position',[0.45,0.4,0.08,0.08]);
mesh_mouse(beh2.coords3d, iFrame1)
hold on
temp = reshape(beh2.coords3d(iFrame1,:,1),3,nfeatures);
scatter3(temp(1,:),temp(2,:),temp(3,:),dotsize*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', h7);
hold on;
for l = 1:size(drawline,1)
    pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
    line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1,'Parent', h7)
end
hold off
view(view11,view12)
axis off

h8 = subplot('Position',[0.53,0.4,0.08,0.08]);
mesh_mouse(beh2.coords3d, iFrame2)
hold on
temp = reshape(beh2.coords3d(iFrame2,:,1),3,nfeatures);
scatter3(temp(1,:),temp(2,:),temp(3,:),dotsize*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', h8);
hold on;
for l = 1:size(drawline,1)
    pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
    line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1,'Parent', h8)
end
hold off
view(view21,view22)
axis off

h9 = subplot('Position',[0.61,0.4,0.08,0.08]);
mesh_mouse(beh2.coords3d, iFrame3)
hold on
temp = reshape(beh2.coords3d(iFrame3,:,1),3,nfeatures);
scatter3(temp(1,:),temp(2,:),temp(3,:),dotsize*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', h9);
hold on;
for l = 1:size(drawline,1)
    pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
    line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1,'Parent', h9)
end
hold off
view(view31,view32)
axis off

h10 = subplot('Position',[0.69,0.4,0.08,0.08]);
mesh_mouse(beh2.coords3d, iFrame4)
hold on
temp = reshape(beh2.coords3d(iFrame4,:,1),3,nfeatures);
scatter3(temp(1,:),temp(2,:),temp(3,:),dotsize*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', h10);
hold on;
for l = 1:size(drawline,1)
    pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
    line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1,'Parent', h10)
end
hold off
view(view41,view42)
axis off

h11 = subplot('Position',[0.77,0.4,0.08,0.08]);
mesh_mouse(beh2.coords3d, iFrame5)
hold on
temp = reshape(beh2.coords3d(iFrame5,:,1),3,nfeatures);
scatter3(temp(1,:),temp(2,:),temp(3,:),dotsize*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', h11);
hold on;
for l = 1:size(drawline,1)
    pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
    line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1,'Parent', h11)
end
hold off
view(view51,view52)
axis off
% subplot('Position',[0.45,0.4,0.08,0.08])
% subplot('Position',[0.53,0.4,0.08,0.08])
% subplot('Position',[0.61,0.4,0.08,0.08])
% subplot('Position',[0.69,0.4,0.08,0.08])
% subplot('Position',[0.77,0.4,0.08,0.08])





























