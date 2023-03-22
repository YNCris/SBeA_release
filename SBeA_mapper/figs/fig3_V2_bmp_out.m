%{
    fig2,  multi-animal reid
%}
clear all
close all
addpath(genpath(pwd))
%% set path
rootpath = 'Z:\hanyaning\multi_mice_test\Social_analysis\data\figs\fig3';
%% load data
vidobj = VideoReader([rootpath,'\panel_2\rec1-A1-20220803-camera-0.avi']);
single_name = 'rec1-A1-20220803';
load([rootpath,'\panel_3\',single_name,'-caliParas.mat']);
cam_num = 4;
vidobj_cell = cell(cam_num,1);
json_cell = cell(cam_num,1);
for k = 1:size(vidobj_cell,1)
    tempvid = VideoReader([rootpath,...
        '\panel_3\',single_name,'-camera-',num2str(k-1),'.avi']);
    vidobj_cell{k,1} = tempvid;
    jsonname = [rootpath,'\panel_3\',single_name,'-camera-',num2str(k-1),'-rawresult.json'];
    jsontext = fileread(jsonname);
    jsonvalue = jsondecode(jsontext);
    json_cell{k,1} = jsonvalue;
end

multi_name = 'rec11-A1A2-20220803';
multi_vidobj_cell = cell(cam_num,1);
multi_json_cell = cell(cam_num,1);
for k = 1:cam_num
    tempvid = VideoReader([rootpath,...
        '\panel_2\',multi_name,'-camera-',num2str(k-1),'.avi']);
    multi_vidobj_cell{k,1} = tempvid;
    jsonname = [rootpath,'\panel_2\',multi_name,'-camera-',num2str(k-1),'-correctedresult.json'];
    jsontext = fileread(jsonname);
    jsonvalue = jsondecode(jsontext);
    multi_json_cell{k,1} = jsonvalue;
end

raw3d = load([rootpath,'\panel_2\',multi_name,'-raw3d.mat']);

evaldata = load([rootpath,'\panel_31\eval.mat']);

datarootpath = [rootpath,'\panel_31'];
fileFolder = fullfile(datarootpath);
dirOutput = dir(fullfile(fileFolder,'*3D.xls'));
err3dname = {dirOutput.name}';
dirOutput = dir(fullfile(fileFolder,'*pic.xls'));
errpicname = {dirOutput.name}';

% errdata_cell = cell(size(err3dname,1),3);
% for k = 1:size(err3dname,1)
%     %
%     splname = split(err3dname{k,1},'_');
%     errname = splname{1};
%     errname(errname=='A') = 'M';
%     tempxls3d = xlsread([datarootpath,'\',err3dname{k,1}]);
%     tempxlspic = xlsread([datarootpath,'\',errpicname{k,1}]);
%     %
%     errdata_cell{k,1} = errname;
%     errdata_cell{k,2} = tempxlspic;
%     errdata_cell{k,3} = tempxls3d;
% end
%% plot canvas
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
set(h1,'color','white');
%% video capture
subplot('Position',[0.03,0.87,0.1,0.08])
mousename = [rootpath,'\panel_1\mouse1.png'];
cameraname = [rootpath,'\panel_1\camera_4.png'];
[mouse_img,~,mouse_alpha] = imread(mousename);
[camera_img,~,camera_alpha] = imread(cameraname);
[X,Y] = meshgrid(1:size(mouse_img,1),1:size(mouse_img,2));
warp_mouse1 = warp(X-200,Y-300,ones(size(Y)),mouse_img);
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
subplot('Position',[0.15,0.87,0.1,0.08])
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
% %% segmentation
% subplot('Position',[0.27,0.87,0.1,0.08])
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
% %% four segmentation
% start_plot_x = 0.38;
% start_plot_y = 0.865;
% inter_x = 0.002;
% inter_y = inter_x;
% box_x = 0.06;
% box_y = box_x*(240/320);
% sel_frame = start_frame;
% setcolor = cbrewer2('Spectral',11);
% mouse1_c = setcolor(3,:);
% mouse2_c = setcolor(9,:);
% mouses_c = att2_c;
% subplot('Position',[start_plot_x,start_plot_y+box_y+inter_y,box_x,box_y])
% showcamidx = 1;
% tempframe = read(vidobj_cell{showcamidx,1},sel_frame);
% temprle = json_cell{showcamidx, 1}.annotations.segmentations(sel_frame,:);
% masks_1 = MaskApi.decode(temprle(1));
% masks_2 = MaskApi.decode(temprle(1));
% masks_all = masks_1|masks_2;
% [tempx,tempy] = find(masks_all==1);
% start_x = min(tempx)-20;
% start_y = min(tempy)-60;
% end_x = start_x+140;
% end_y = round((end_x-start_x)*(320/240))+start_y;
% showframe = labeloverlay(tempframe,masks_all,...
%     'Colormap',mouses_c,'Transparency',0.6);
% cropframe = showframe(start_x:end_x,start_y:end_y,:);
% imshow(cropframe)
% subplot('Position',[start_plot_x+box_x+inter_x,start_plot_y+box_y+inter_y,box_x,box_y])
% showcamidx = 2;
% tempframe = read(vidobj_cell{showcamidx,1},sel_frame);
% temprle = json_cell{showcamidx, 1}.annotations.segmentations(sel_frame,:);
% masks_1 = MaskApi.decode(temprle(1));
% masks_2 = MaskApi.decode(temprle(1));
% masks_all = masks_1|masks_2;
% [tempx,tempy] = find(masks_all==1);
% start_x = min(tempx)-110;
% start_y = min(tempy)-20;
% end_x = start_x+250;
% end_y = round((end_x-start_x)*(320/240))+start_y;
% showframe = labeloverlay(tempframe,masks_all,...
%     'Colormap',mouses_c,'Transparency',0.6);
% cropframe = showframe(start_x:end_x,start_y:end_y,:);
% imshow(cropframe)
% subplot('Position',[start_plot_x,start_plot_y,box_x,box_y])
% showcamidx = 3;
% tempframe = read(vidobj_cell{showcamidx,1},sel_frame);
% temprle = json_cell{showcamidx, 1}.annotations.segmentations(sel_frame,:);
% masks_1 = MaskApi.decode(temprle(1));
% masks_2 = MaskApi.decode(temprle(1));
% masks_all = masks_1|masks_2;
% [tempx,tempy] = find(masks_all==1);
% start_x = min(tempx)-90;
% start_y = min(tempy)-20;
% end_x = start_x+240;
% end_y = round((end_x-start_x)*(320/240))+start_y;
% showframe = labeloverlay(tempframe,masks_all,...
%     'Colormap',mouses_c,'Transparency',0.6);
% cropframe = showframe(start_x:end_x,start_y:end_y,:);
% imshow(cropframe)
% subplot('Position',[start_plot_x+box_x+inter_x,start_plot_y,box_x,box_y])
% showcamidx = 4;
% tempframe = read(vidobj_cell{showcamidx,1},sel_frame);
% temprle = json_cell{showcamidx, 1}.annotations.segmentations(sel_frame,:);
% masks_1 = MaskApi.decode(temprle(1));
% masks_2 = MaskApi.decode(temprle(1));
% masks_all = masks_1|masks_2;
% [tempx,tempy] = find(masks_all==1);
% start_x = min(tempx)-20;
% start_y = min(tempy)-70;
% end_x = start_x+200;
% end_y = round((end_x-start_x)*(320/240))+start_y;
% showframe = labeloverlay(tempframe,masks_all,...
%     'Colormap',mouses_c,'Transparency',0.6);
% cropframe = showframe(start_x:end_x,start_y:end_y,:);
% imshow(cropframe)
% %% hstack
% res_size = [224,224];
% cropframe_all = [];
% for k = 1:size(vidobj_cell,1)
%     showcamidx = k;
%     tempframe = read(vidobj_cell{showcamidx,1},sel_frame);
%     temprle = json_cell{showcamidx, 1}.annotations.segmentations(sel_frame,:);
%     masks_1 = MaskApi.decode(temprle(1));
%     masks_2 = MaskApi.decode(temprle(1));
%     masks_all = masks_1|masks_2;
%     [tempx,tempy] = find(masks_all==1);
%     start_x = min(tempx);
%     start_y = min(tempy);
%     end_x = max(tempx);
%     end_y = max(tempy);
%     showframe = tempframe;
%     showframe(:,:,1) = uint8(double(tempframe(:,:,1)).*double(masks_all));
%     showframe(:,:,2) = uint8(double(tempframe(:,:,2)).*double(masks_all));
%     showframe(:,:,3) = uint8(double(tempframe(:,:,3)).*double(masks_all));
%     cropframe = showframe(start_x:end_x,start_y:end_y,:);
%     resframe = imresize(cropframe,res_size);
%     cropframe_all = [cropframe_all,resframe];
% end
% cropframe_all = imresize(cropframe_all,res_size);
% subplot('Position',[0.52,0.865,0.09,0.09])
% imshow(cropframe_all)
% title('M1','Color',mouses_c)
% %% effnet
% subplot('Position',[0.62,0.86,0.09,0.09])
% bias1 = 80;
% bias2 = 10;
% bias3 = 4;
% thick = 0.5;
% shrscale = 1;
% bias4 = 0.5;
% netcolorlist = cbrewer2('Pastel1',9);
% cov1_c = netcolorlist(8,:);
% cov2_c = netcolorlist(1,:);
% cov3_c = netcolorlist(2,:);
% cov4_c = netcolorlist(3,:);
% % plotcube([thick 70 70]/shrscale,[0  0  0]/shrscale,.8,cov1_c)
% % plotcube([thick 70 70]/shrscale,[2  0  0]/shrscale,.8,cov1_c)
% 
% plotcube([thick 60 60]/shrscale,[6  5  5]/shrscale,.8,cov1_c)
% plotcube([thick 60 60]/shrscale,[8  5  5]/shrscale,.8,cov1_c)
% plotcube([thick 60 60]/shrscale,[8+thick  5  5]/shrscale,.8,cov1_c)
% 
% plotcube([thick*2 40 40]/shrscale,[12+thick  15  15]/shrscale,.8,cov2_c)
% plotcube([thick*2 40 40]/shrscale,[14+thick*2  15  15]/shrscale,.8,cov2_c)
% plotcube([thick*2 40 40]/shrscale,[14+thick*4  15  15]/shrscale,.8,cov2_c)
% 
% plotcube([thick*3 20 20]/shrscale,[18+thick*6  25  25]/shrscale,.8,cov3_c)
% plotcube([thick*3 20 20]/shrscale,[20+thick*9  25  25]/shrscale,.8,cov3_c)
% plotcube([thick*3 20 20]/shrscale,[20+thick*12  25  25]/shrscale,.8,cov3_c)
% 
% plotcube([thick*4 10 10]/shrscale,[24+thick*15  30  30]/shrscale,.8,cov4_c)
% plotcube([thick*4 10 10]/shrscale,[26+thick*19  30  30]/shrscale,.8,cov4_c)
% plotcube([thick*4 10 10]/shrscale,[26+thick*23  30  30]/shrscale,.8,cov4_c)
% 
% % hold on
% % plot3([0+thick,2]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
% % hold on
% % plot3([2+thick,6]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
% 
% hold on
% plot3([6+thick,8]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
% hold on
% plot3([8+thick,12+thick]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
% 
% hold on
% plot3([12+3*thick,14+thick*2]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
% hold on
% plot3([14+thick*6,18+thick*6]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
% 
% hold on
% plot3([18+thick*9,20+thick*9]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
% hold on
% plot3([20+thick*15,24+thick*15]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
% 
% hold on
% plot3([24+thick*19,26+thick*19]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
% hold off
% 
% % xlabel('x')
% % ylabel('y')
% % zlabel('z')
% view(2)
% axis off
% view(8,26)
% %% load python model and cam
% version = 'D:\anaconda\envs\matlab-py\pythonw.exe';
% % pe = pyenv('Version',version);
% [ret,modelout] = pyrun(...
% ["import torch"
% "import numpy as np"
% "from PIL import Image"
% "from torchvision import transforms"
% "from torchvision.transforms.functional import normalize, resize, to_pil_image"
% "import torch.nn as nn"
% "import torch.nn.functional as F"
% "from torchcam.methods import LayerCAM, SmoothGradCAMpp"
% "from efficientnet_pytorch import EfficientNet"
% ""
% "def get_layer_cam(model,input_tensor,device,count, templayer):"
% "    model.eval()"
% "    extractor = LayerCAM(model, templayer)"
% "    input_tensor = input_tensor.unsqueeze(0)"
% "    input_tensor = input_tensor.to(device)"
% "    out = model(input_tensor)"
% "    cams = extractor(class_idx=count, scores=out)"
% "    return cams[0].cpu().squeeze(0).numpy()"
% ""
% "OUTPUT_DIM = 10"
% "modelpath = r'Z:\hanyaning\multi_mice_test\Social_analysis\data\disc1_shank3\sbea_shank3_disc1_20220602\models\reid\reidmodel-body-test20220803-multi-True-effnet.pt'"
% "model = EfficientNet.from_pretrained('efficientnet-b4', num_classes=OUTPUT_DIM)"
% "device = torch.device('cpu')"
% "print(device)"
% "criterion = nn.CrossEntropyLoss()"
% "model = model.to(device)"
% "criterion = criterion.to(device)"
% "model.load_state_dict(torch.load(modelpath,map_location=device))"
% "#print(np.asarray(inputframe))"
% "img = transforms.ToTensor()(np.asarray(inputframe))"
% "#print(resize(img, (256, 256)) / 255.)"
% "pretrained_means = [0.485,0.456,0.406]"
% "pretrained_stds = [0.229,0.224,0.225]"
% "input_tensor = normalize(resize(img, (224, 224)), pretrained_means, pretrained_stds)"
% "# calculate layer cam"
% "layer_list = list(np.int32(np.linspace(-1,31,33)))                #['-1','1','3','5','11']"
% "layer_list = [str(l) for l in layer_list]"
% "count = 0"
% "maskcamlist = []"
% "for templayer in layer_list:"
% "    outcam = get_layer_cam(model, input_tensor, device, count, model._blocks[np.int32(templayer)])"
% "    maskcam = np.array(to_pil_image(outcam, mode='F'))"
% "    maskcamlist.append(maskcam)"
% "    print(templayer)"
% ""
% "input_tensor = input_tensor.unsqueeze(0)"
% "input_tensor = input_tensor.to(device)"
% "out = model(input_tensor)"
% "y_prob = F.softmax(out, dim = -1).cpu().squeeze(0).detach().numpy()"
% ],["maskcamlist","y_prob"],inputframe = cropframe_all);
% disp(modelout)
% %%
% % figure(2)
% maskcamlist = cell(length(ret),1);
% summaskcam = zeros(res_size);
% for k = 1:size(maskcamlist,1)
%     ndmask = cell(ret(k));
%     maskcamlist{k,1} = round(mat2gray(imresize(double(ndmask{1}),res_size))*255);
%     summaskcam = summaskcam + maskcamlist{k,1};
% %     imshow(imresize(labeloverlay(cropframe_all,maskcamlist{k,1},'Colormap',jet),[1000,1000]))
% %     title(k)
% %     pause
% end
% summaskcam = round(mat2gray(summaskcam)*255);
% subplot('Position',[0.73,0.865,0.09,0.09])
% showcamidx = 24;
% showcamframe = labeloverlay(cropframe_all,summaskcam,...
%     'Colormap',flipud(cbrewer2('Spectral',256)));
% imshow(showcamframe)
% hcmap = subplot('Position',[0.78,0.96,0.04,0.005]);
% imagesc(1:100)
% colormap(hcmap,flipud(cbrewer2('Spectral',256)))
% set(gca,'XTick',[])
% set(gca,'YTick',[])
% title('0       1')
% %% prediction
% showprec = double(modelout);
% hlabel = subplot('Position',[0.85,0.86,0.02,0.1]);
% imagesc(showprec',[0,1])
% colormap(hlabel,cbrewer2('OrRd',256))
% hold on
% for k = 1:(length(showprec)-1)
%     plot([0,2],[k,k]+0.5,'-k')
%     hold on
% end
% hold off
% ylabelname = {};
% for k = 1:length(showprec)
%     ylabelname = [ylabelname;['M',num2str(k)]];
% end
% set(gca,'XTick',[])
% set(gca,'YTick',1:10)
% set(gca,'TickLength',[0,0])
% set(gca,'YAxisLocation','right')
% set(gca,'YTickLabel',ylabelname)
% 
% hlabelc = subplot('Position',[0.85,0.965,0.02,0.005]);
% imagesc(1:100)
% colormap(hlabelc,cbrewer2('OrRd',256))
% set(gca,'XTick',[])
% set(gca,'YTick',[])
% title('0       1')
% %% 3D skeleton
% start_pos_x = -50;
% start_pos_y = 180;
% inter_pos_xy = 250;
% start_frame = 302;
% h14 = subplot('Position',[0.03,0.72,0.11,0.11]);
% sel_frame = start_frame;
% dotsize = 6;
% temppos = load([rootpath,'\panel_2\rec11-A1A2-20220803-id3d.mat']);
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
% view(-24,49)
% % title('3D Poses','Color','blue')
% % 2D view
% %% show 3d reid to 2d 
% start_plot_x = 0.17;
% start_plot_y = 0.73;
% plot_size_x = 0.06;
% plot_size_y = plot_size_x/1288*964;
% inter_y = 0.002;
% inter_x = inter_y;
% 
% selpair = raw3d.pair3d(sel_frame,:,:,:);
% selpair1 = reshape(selpair(:,1,:,:),[4,2]);
% selpair1 = sortrows(selpair1,1);
% selpair2 = reshape(selpair(:,2,:,:),[4,2]);
% selpair2 = sortrows(selpair2,1);
% selpair_cell = {selpair1,selpair2};
% 
% multi_mask_cell = cell(size(multi_json_cell,1),2);
% for k = 1:size(multi_json_cell,1)
%     temprle = multi_json_cell{k, 1}.annotations.segmentations(sel_frame,:);
%     masks_1 = MaskApi.decode(temprle(1));
%     masks_2 = MaskApi.decode(temprle(2));
% 
%     multi_mask_cell{k,1} = masks_1;
%     multi_mask_cell{k,2} = masks_2;
% end
% 
% multi_sort_mask_cell = cell(size(selpair_cell));
% for k = 1:size(multi_sort_mask_cell,2)
%     tempselpair = selpair_cell{1,k};
%     tempmaskcell = cell(size(tempselpair,1),1);
%     for m = 1:size(tempselpair,1)
%         idx1 = tempselpair(m,1)+1;
%         idx2 = tempselpair(m,2);
%         selmask = multi_mask_cell{idx1,idx2};
%         tempmaskcell{m,1} = selmask;
%     end
%     multi_sort_mask_cell{1,k} = tempmaskcell;
% end
% %
% subplot('Position',[start_plot_x,start_plot_y+(inter_y+plot_size_y),...
%     plot_size_x,plot_size_y])
% start_x = 530;
% start_y = 500;
% end_x = start_x+430;
% end_y = round((end_x-start_x)*(320/240))+start_y;
% sel_frame_idx = sel_frame;
% tempframe = read(multi_vidobj_cell{1,1},sel_frame_idx);
% mask1 = multi_sort_mask_cell{1}{1};
% mask2 = multi_sort_mask_cell{2}{1};
% showframe = labeloverlay(tempframe,mask1,...
%     'Colormap',mouse2_c);
% showframe = labeloverlay(showframe,mask2,...
%     'Colormap',mouse1_c);
% cropframe = showframe(start_x:end_x,start_y:end_y,:);
% imshow(cropframe)
% subplot('Position',[start_plot_x+(inter_x+plot_size_x),...
%     start_plot_y+(inter_y+plot_size_y),...
%     plot_size_x,plot_size_y])
% start_x = 440;
% start_y = 790;
% end_x = start_x+200;
% end_y = round((end_x-start_x)*(320/240))+start_y;
% sel_frame_idx = sel_frame;
% tempframe = read(multi_vidobj_cell{2,1},sel_frame_idx);
% mask1 = multi_sort_mask_cell{1}{2};
% mask2 = multi_sort_mask_cell{2}{2};
% showframe = labeloverlay(tempframe,mask1,...
%     'Colormap',mouse2_c);
% showframe = labeloverlay(showframe,mask2,...
%     'Colormap',mouse1_c);
% cropframe = showframe(start_x:end_x,start_y:end_y,:);
% imshow(cropframe)
% subplot('Position',[start_plot_x,start_plot_y,...
%     plot_size_x,plot_size_y])
% start_x = 490;
% start_y = 100;
% end_x = start_x+230;
% end_y = round((end_x-start_x)*(320/240))+start_y;
% sel_frame_idx = sel_frame;
% tempframe = read(multi_vidobj_cell{3,1},sel_frame_idx);
% mask1 = multi_sort_mask_cell{1}{3};
% mask2 = multi_sort_mask_cell{2}{3};
% showframe = labeloverlay(tempframe,mask1,...
%     'Colormap',mouse2_c);
% showframe = labeloverlay(showframe,mask2,...
%     'Colormap',mouse1_c);
% cropframe = showframe(start_x:end_x,start_y:end_y,:);
% imshow(cropframe)
% subplot('Position',[start_plot_x+1*(inter_x+plot_size_x),...
%     start_plot_y,plot_size_x,plot_size_y])
% start_x = 360;
% start_y = 420;
% end_x = start_x+230;
% end_y = round((end_x-start_x)*(320/240))+start_y;
% sel_frame_idx = sel_frame;
% tempframe = read(multi_vidobj_cell{4,1},sel_frame_idx);
% mask1 = multi_sort_mask_cell{1}{4};
% mask2 = multi_sort_mask_cell{2}{4};
% showframe = labeloverlay(tempframe,mask1,...
%     'Colormap',mouse2_c);
% showframe = labeloverlay(showframe,mask2,...
%     'Colormap',mouse1_c);
% cropframe = showframe(start_x:end_x,start_y:end_y,:);
% imshow(cropframe)
% %% show cascade
% start_plot_x = 0.32;
% start_plot_y = 0.73;
% plot_size_x = 0.09;
% inter_x = 0.002;
% cas_frame_cell = cell(size(multi_sort_mask_cell));
% for k = 1:size(cas_frame_cell,2)
%     tempframecell = multi_sort_mask_cell{k};
%     tempcasframe = [];
%     for m = 1:size(tempframecell,1)
%         tempmask = tempframecell{m};
%         tempframe = read(multi_vidobj_cell{m},sel_frame_idx);
%         [tempx,tempy] = find(tempmask==1);
%         start_x = min(tempx);
%         start_y = min(tempy);
%         end_x = max(tempx);
%         end_y = max(tempy);
%         showframe = tempframe;
%         showframe(:,:,1) = uint8(double(tempframe(:,:,1)).*double(tempmask));
%         showframe(:,:,2) = uint8(double(tempframe(:,:,2)).*double(tempmask));
%         showframe(:,:,3) = uint8(double(tempframe(:,:,3)).*double(tempmask));
%         cropframe = showframe(start_x:end_x,start_y:end_y,:);
%         resframe = imresize(cropframe,res_size);
%         tempcasframe = [tempcasframe,resframe];
%     end
%     cas_frame_cell{k} = imresize(tempcasframe,res_size);
% end
% 
% subplot('Position',[start_plot_x,start_plot_y,plot_size_x,plot_size_x])
% imshow(cas_frame_cell{1})
% title('Mp','Color',mouse2_c)
% subplot('Position',[start_plot_x+inter_x+plot_size_x,...
%     start_plot_y,plot_size_x,plot_size_x])
% imshow(cas_frame_cell{2})
% title('Mq','Color',mouse1_c)
% %% calculate layercam
% [ret1,modelout1] = pyrun(...
% ["import torch"
% "import numpy as np"
% "from PIL import Image"
% "from torchvision import transforms"
% "from torchvision.transforms.functional import normalize, resize, to_pil_image"
% "import torch.nn as nn"
% "import torch.nn.functional as F"
% "from torchcam.methods import LayerCAM, SmoothGradCAMpp"
% "from efficientnet_pytorch import EfficientNet"
% ""
% "def get_layer_cam(model,input_tensor,device,count, templayer):"
% "    model.eval()"
% "    extractor = LayerCAM(model, templayer)"
% "    input_tensor = input_tensor.unsqueeze(0)"
% "    input_tensor = input_tensor.to(device)"
% "    out = model(input_tensor)"
% "    cams = extractor(class_idx=count, scores=out)"
% "    return cams[0].cpu().squeeze(0).numpy()"
% ""
% "OUTPUT_DIM = 10"
% "modelpath = r'Z:\hanyaning\multi_mice_test\Social_analysis\data\disc1_shank3\sbea_shank3_disc1_20220602\models\reid\reidmodel-body-test20220803-multi-True-effnet.pt'"
% "model = EfficientNet.from_pretrained('efficientnet-b4', num_classes=OUTPUT_DIM)"
% "device = torch.device('cpu')"
% "print(device)"
% "criterion = nn.CrossEntropyLoss()"
% "model = model.to(device)"
% "criterion = criterion.to(device)"
% "model.load_state_dict(torch.load(modelpath,map_location=device))"
% "#print(np.asarray(inputframe))"
% "img = img_tensor=transforms.ToTensor()(np.asarray(inputframe))"
% "#print(resize(img, (224, 224)) / 255.)"
% "pretrained_means = [0.485,0.456,0.406]"
% "pretrained_stds = [0.229,0.224,0.225]"
% "input_tensor = normalize(resize(img, (224, 224)), pretrained_means, pretrained_stds)"
% "# calculate layer cam"
% "layer_list = list(np.int32(np.linspace(-1,31,33)))                #['-1','1','3','5','11']"
% "layer_list = [str(l) for l in layer_list]"
% "count = 0"
% "maskcamlist = []"
% "for templayer in layer_list:"
% "    outcam = get_layer_cam(model, input_tensor, device, count, model._blocks[np.int32(templayer)])"
% "    maskcam = np.array(to_pil_image(outcam, mode='F'))"
% "    maskcamlist.append(maskcam)"
% "    print(templayer)"
% ""
% "input_tensor = input_tensor.unsqueeze(0)"
% "input_tensor = input_tensor.to(device)"
% "out = model(input_tensor)"
% "y_prob = F.softmax(out, dim = -1).cpu().squeeze(0).detach().numpy()"
% ],["maskcamlist","y_prob"],inputframe = cas_frame_cell{1});
% disp(modelout1)
% [ret2,modelout2] = pyrun(...
% ["import torch"
% "import numpy as np"
% "from PIL import Image"
% "from torchvision import transforms"
% "from torchvision.transforms.functional import normalize, resize, to_pil_image"
% "import torch.nn as nn"
% "import torch.nn.functional as F"
% "from torchcam.methods import LayerCAM, SmoothGradCAMpp"
% "from efficientnet_pytorch import EfficientNet"
% ""
% "def get_layer_cam(model,input_tensor,device,count, templayer):"
% "    model.eval()"
% "    extractor = LayerCAM(model, templayer)"
% "    input_tensor = input_tensor.unsqueeze(0)"
% "    input_tensor = input_tensor.to(device)"
% "    out = model(input_tensor)"
% "    cams = extractor(class_idx=count, scores=out)"
% "    return cams[0].cpu().squeeze(0).numpy()"
% ""
% "OUTPUT_DIM = 10"
% "modelpath = r'Z:\hanyaning\multi_mice_test\Social_analysis\data\disc1_shank3\sbea_shank3_disc1_20220602\models\reid\reidmodel-body-test20220803-multi-True-effnet.pt'"
% "model = EfficientNet.from_pretrained('efficientnet-b4', num_classes=OUTPUT_DIM)"
% "device = torch.device('cpu')"
% "print(device)"
% "criterion = nn.CrossEntropyLoss()"
% "model = model.to(device)"
% "criterion = criterion.to(device)"
% "model.load_state_dict(torch.load(modelpath,map_location=device))"
% "#print(np.asarray(inputframe))"
% "img = img_tensor=transforms.ToTensor()(np.asarray(inputframe))"
% "#print(resize(img, (224, 224)) / 255.)"
% "pretrained_means = [0.485,0.456,0.406]"
% "pretrained_stds = [0.229,0.224,0.225]"
% "input_tensor = normalize(resize(img, (224, 224)), pretrained_means, pretrained_stds)"
% "# calculate layer cam"
% "layer_list = list(np.int32(np.linspace(-1,31,33)))                #['-1','1','3','5','11']"
% "layer_list = [str(l) for l in layer_list]"
% "count = 1"
% "maskcamlist = []"
% "for templayer in layer_list:"
% "    outcam = get_layer_cam(model, input_tensor, device, count, model._blocks[np.int32(templayer)])"
% "    maskcam = np.array(to_pil_image(outcam, mode='F'))"
% "    maskcamlist.append(maskcam)"
% "    print(templayer)"
% ""
% "input_tensor = input_tensor.unsqueeze(0)"
% "input_tensor = input_tensor.to(device)"
% "out = model(input_tensor)"
% "y_prob = F.softmax(out, dim = -1).cpu().squeeze(0).detach().numpy()"
% ],["maskcamlist","y_prob"],inputframe = cas_frame_cell{2});
% disp(modelout2)
% %
% maskcamlist2m = cell(length(ret1),2);
% summask1 = zeros(res_size);
% summask2 = zeros(res_size);
% for k = 1:size(maskcamlist2m,1)
%     ndmask1 = cell(ret1(k));
%     ndmask2 = cell(ret2(k));
%     maskcamlist2m{k,1} = round(mat2gray(imresize(double(ndmask1{1}),res_size))*255);
%     maskcamlist2m{k,2} = round(mat2gray(imresize(double(ndmask2{1}),res_size))*255);
%     summask1 = summask1+maskcamlist2m{k,1};
%     summask2 = summask2+maskcamlist2m{k,2};
% %     imshow(imresize(labeloverlay(cropframe_all,maskcamlist{k,1},'Colormap',jet),[1000,1000]))
% %     title(k)
% %     pause
% end
% summask1 = round(mat2gray(summask1)*255);
% summask2 = round(mat2gray(summask2)*255);
% %% cam 2
% start_plot_x = 0.52;
% start_plot_y = 0.73;
% plot_size_x = 0.09;
% inter_x = 0.002;
% 
% showcamidx = 25;
% showcamframe1 = labeloverlay(cas_frame_cell{1},...
%     summask1,...
%     'Colormap',flipud(cbrewer2('Spectral',256)));
% showcamframe2 = labeloverlay(cas_frame_cell{2},...
%     summask2,...
%     'Colormap',flipud(cbrewer2('Spectral',256)));
% 
% subplot('Position',[start_plot_x,start_plot_y,plot_size_x,plot_size_x])
% imshow(showcamframe1)
% subplot('Position',[start_plot_x+inter_x+plot_size_x,...
%     start_plot_y,plot_size_x,plot_size_x])
% imshow(showcamframe2)
% %% pred prob 2
% showprec = double(modelout1);
% hlabel1 = subplot('Position',[0.73,0.725,0.02,0.1]);
% imagesc(showprec',[0,1])
% colormap(hlabel1,cbrewer2('OrRd',256))
% hold on
% for k = 1:(length(showprec)-1)
%     plot([0,2],[k,k]+0.5,'-k')
%     hold on
% end
% hold off
% ylabelname = {};
% for k = 1:length(showprec)
%     ylabelname = [ylabelname;['M',num2str(k)]];
% end
% set(gca,'XTick',[])
% set(gca,'YTick',1:10)
% set(gca,'TickLength',[0,0])
% set(gca,'YAxisLocation','right')
% set(gca,'YTickLabel',[])
% 
% showprec = double(modelout2);
% hlabel1 = subplot('Position',[0.77,0.725,0.02,0.1]);
% imagesc(showprec',[0,1])
% colormap(hlabel1,cbrewer2('OrRd',256))
% hold on
% for k = 1:(length(showprec)-1)
%     plot([0,2],[k,k]+0.5,'-k')
%     hold on
% end
% hold off
% ylabelname = {};
% for k = 1:length(showprec)
%     ylabelname = [ylabelname;['M',num2str(k)]];
% end
% set(gca,'XTick',[])
% set(gca,'YTick',1:10)
% set(gca,'TickLength',[0,0])
% set(gca,'YAxisLocation','right')
% set(gca,'YTickLabel',ylabelname)
% %%
% start_pos_x = -50;
% start_pos_y = 180;
% inter_pos_xy = 250;
% start_frame = 302;
% h14 = subplot('Position',[0.84,0.72,0.11,0.11]);
% sel_frame = start_frame;
% dotsize = 6;
% temppos = load([rootpath,'\panel_2\rec11-A1A2-20220803-id3d.mat']);
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
% view(-24,49)
% % title('3D Poses','Color','blue')
% % 2D view
% text(mouse1(sel_frame,1),mouse1(sel_frame,2),mouse1(sel_frame,3),'M2','Color',mouse1_c)
% text(mouse2(sel_frame,1),mouse2(sel_frame,2),mouse2(sel_frame,3),'M1','Color',mouse2_c)
% %% show confusion matrix
% tempcm = double(evaldata.cm);
% labelseq = {'A1','A2','A3','A4','A5','A6','A7','A8','A9','A10'};
% templabel = cellstr(evaldata.cm_label)';
% resort_cm = tempcm;
% for m = 1:size(resort_cm,1)
%     for n = 1:size(resort_cm,2)
%         rawname1 = templabel{m};
%         rawname2 = templabel{n};
%         matchpos1 = find(strcmp(rawname1,labelseq)==1);
%         matchpos2 = find(strcmp(rawname2,labelseq)==1);
%         resort_cm(matchpos1,matchpos2) = tempcm(m,n);
%     end
% end
% classlabel = labelseq;
% for k = 1:length(classlabel)
%     classlabel{k}(classlabel{k}=='A') = 'M';
% end
% hcm = subplot('Position',[0.05,0.49,0.18,0.18]);
% imagesc(resort_cm/1800)
% colormap(hcm,cbrewer2('OrRd',256))
% set(gca,'TickDir','out')
% sellabel = [1,10];
% set(gca,'XTick',sellabel)
% set(gca,'YTick',sellabel)
% set(gca,'TickLength',[0,0])
% set(gca,'XTickLabel',classlabel(sellabel))
% set(gca,'YTickLabel',classlabel(sellabel))
% set(gca,'XTickLabelRotation',0)
% %% show representation
% tsne_rep = evaldata.output_tsne_data;
% rawclasses = cellstr(evaldata.classes)';
% rawlabels = double(evaldata.labels)+1;
% rawlabellist = rawclasses(rawlabels)';
% cmap = cbrewer2('Paired',10);
% resortcmap = cmap;
% for k = 1:size(rawclasses,2)
%     rawname = rawclasses{k};
%     matchpos = find(strcmp(rawname,labelseq)==1);
%     resortcmap(matchpos,:) = cmap(k,:);
% end
% cmaplist = resortcmap(rawlabels,:);
% subplot('Position',[0.27,0.49,0.18,0.18])
% scatter(tsne_rep(:,1),tsne_rep(:,2),2*ones(length(tsne_rep(:,1)),1),...
%     cmaplist,'filled');
% xmin = min(tsne_rep(:,1));
% xmax = max(tsne_rep(:,1));
% ymin = min(tsne_rep(:,2));
% ymax = max(tsne_rep(:,2));
% axis([xmin,xmax,ymin,ymax])
% set(gca,'XTick',[])
% set(gca,'YTick',[])
% xlabel('t-SNE 1')
% ylabel('t-SNE 2')
% %% mouse label
% dot_x = [1:5,1:5];
% dot_y = [5*ones(1,5),3*ones(1,5)];
% body_parts = classlabel;
% subplot('Position',[0.27,0.67,0.18,0.02])
% for k = 1:length(classlabel)
%     plot(dot_x(k),dot_y(k),'ko','MarkerFaceColor',resortcmap(k,:),'MarkerSize',4)
%     hold on
% end
% text(dot_x+0.04,dot_y,body_parts)
% hold off
% box on
% axis([1,6,2,5])
% axis off
% %% precision list
% prec_list = zeros(length(classlabel),1);
% count = 1;
% for m = 1:length(prec_list)
%     for n = 1:length(prec_list)
%         if m == n
%             prec_list(count) = resort_cm(m,n)/1800;
%             count = count + 1;
%         end
%     end
% end
% [sort_prec_list,I] = sort(prec_list,'ascend');
% sort_class_label = classlabel(I);
% sort_cmap = resortcmap(I,:);
% hbar = subplot('Position',[0.5,0.49,0.08,0.18]);
% for k = 1:size(sort_prec_list,1)
%     barh(k,sort_prec_list(k),0.7,'FaceColor',sort_cmap(k,:))
%     hold on
% end
% hold off
% box off
% set(gca,'TickDir','out')
% set(gca,'YTick',1:10)
% set(gca,'YTickLabel',sort_class_label)
% xlabel('Precision')
% axis([0,1,0.4,10.6])
% %% silhouette coefficient
% sil = silhouette(tsne_rep,rawlabels');
% silmat = zeros(1800,length(sort_class_label));
% for k = 1:size(silmat,2)
%     silmat(:,k) = sil(rawlabels==k,1);
% end
% 
% tempsortlabel = cellfun(@(x)  strrep(x,'M','A'),sort_class_label,'UniformOutput',false);
% resortsilmat = silmat;
% for k = 1:size(rawclasses,2)
%     rawname = rawclasses{k};
%     matchpos = find(strcmp(rawname,tempsortlabel)==1);
%     resortsilmat(:,matchpos) = silmat(:,k);
% end
% 
% sil_mean = mean(resortsilmat);
% sil_std = std(resortsilmat);
% 
% sel_num = 100;
% subplot('Position',[0.6,0.49,0.08,0.18])
% for k = 1:size(sort_prec_list,1)
%     barh(k,sil_mean(k),0.7,'FaceColor',sort_cmap(k,:))
%     hold on
%     errorbar(sil_mean(k),k,sil_std(k),'horizontal','Color','k',...
%         'CapSize',3)
%     hold on
%     sel_x = resortsilmat(1:round(size(resortsilmat,1)/sel_num):end,k);
%     sel_y = k*ones(length(sel_x),1);
%     plot(sel_x,sel_y+0.3,'o','MarkerSize',2,'MarkerFaceColor','w',...
%         'MarkerEdgeColor','k','LineWidth',0.25)
%     hold on
% end
% hold off
% box off
% axis([-1,1,0.4,10.6])
% set(gca,'TickDir','out')
% set(gca,'YTick',1:10)
% set(gca,'YTickLabel',[])
% xlabel({'Silhouette','coefficient'})
% %% human identify two mice
% errlabel = errdata_cell(:,1);
% errlenpic = cellfun(@(x) 1-sum((x(:,2)-x(:,1)+1))/27000,errdata_cell(:,2));
% errlen3d = cellfun(@(x) 1-sum((x(:,2)-x(:,1)+1))/27000,errdata_cell(:,3));
% 
% bar_w = 5;
% bar_bias = 0.5;
% bar_d = 2.5;
% 
% barc = flipud(cbrewer2('Paired',2));
% subplot('Position',[0.75,0.49,0.18,0.18])
% for k = 1:size(errlabel,1)
%     barh(bar_d*k+bar_bias,errlenpic(k),0.7,'FaceColor',barc(1,:),'BarWidth',bar_w)
%     hold on
%     barh(bar_d*k-bar_bias,errlen3d(k),0.7,'FaceColor',barc(2,:),'BarWidth',bar_w)
%     hold on
% end
% hold off
% box off
% set(gca,'TickDir','out')
% set(gca,'YTick',(1:size(errlabel,1))*bar_d)
% set(gca,'YTickLabel',errlabel)
% axis([0.8,1,1,14])
% set(gca,'XTick',0.8:0.05:1)
% set(gca,'XTickLabelRotation',0)
% xlabel('Precision')





















































