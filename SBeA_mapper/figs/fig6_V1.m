%{
   SBeA for the applications across species  
%}
clear all
close all
addpath(genpath(pwd))
%% set path
rootpath = 'Z:\hanyaning\multi_mice_test\Social_analysis\data\figs\fig6';
%% plot canvas
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
set(h1,'color','white');
%% load data
vidobjb1 = VideoReader([rootpath,'\panel_1\rec1-B1-20220919-camera-0.avi']);
vidobjb2 = VideoReader([rootpath,'\panel_1\rec2-B2-20220919-camera-0.avi']);
imgb1b2 = imread([rootpath,'\panel_2\rec3-B1B2-20220919-camera-1_8002_160.png']);
jsonname = [rootpath,'\panel_2\rec3-B1B2-20220919-camera-1_8002_160.json'];
jsontext = fileread(jsonname);
jsonvalueb1b2 = jsondecode(jsontext);
poseb1 = imread([rootpath,'\panel_2\img2071.png']);
pospoints = importdata([rootpath,'\panel_2\CollectedData_hyn.csv']);
posdata = pospoints.data(15,:);
datab1b2.vidobj = VideoReader([rootpath,...
    '\panel_3\rec3-B1B2-20220919-camera-0.avi']);
jsonname = [rootpath,'\panel_3\rec3-B1B2-20220919-camera-0-correctedresult.json'];
jsontext = fileread(jsonname);
datab1b2.jsonvalue = jsondecode(jsontext);
datab1b2.pos1 = importdata([rootpath,'\panel_3\rec3-B1B2-20220919-camera-0' ...
    '-masked-0DLC_resnet50_dlcbirdOct7shuffle1_680000.csv']);
datab1b2.pos2 = importdata([rootpath,'\panel_3\rec3-B1B2-20220919-camera-0' ...
    '-masked-1DLC_resnet50_dlcbirdOct7shuffle1_680000.csv']);
camimg = imread([rootpath,'\panel_4\frame-17538_mouse-1.jpg']);

vidobjd1 = VideoReader([rootpath,'\panel_5\rec5-D1-20221009-camera-0.avi']);
vidobjd2 = VideoReader([rootpath,'\panel_5\rec6-D2-20221009-camera-0.avi']);
imgd1d2 = imread([rootpath,'\panel_6\rec3-D1D2-20221009-camera-0_8859_540.png']);
jsonname = [rootpath,'\panel_6\rec3-D1D2-20221009-camera-0_8859_540.json'];
jsontext = fileread(jsonname);
jsonvalued1d2 = jsondecode(jsontext);
posed1 = imread([rootpath,'\panel_6\img00568.png']);
pospoints = importdata([rootpath,'\panel_6\CollectedData_ljx.csv']);
posdatad1 = pospoints.data(2,:);
datad1d2.vidobj = VideoReader([rootpath,...
    '\panel_7\rec3-D1D2-20221009-camera-0.avi']);
jsonname = [rootpath,'\panel_7\rec3-D1D2-20221009-camera-0-correctedresult.json'];
jsontext = fileread(jsonname);
datad1d2.jsonvalue = jsondecode(jsontext);
datad1d2.pos1 = importdata([rootpath,'\panel_7\rec3-D1D2-20221009-camera-0' ...
    '-masked-0DLC_resnet50_dogsOct18shuffle1_1030000.csv']);
datad1d2.pos2 = importdata([rootpath,'\panel_7\rec3-D1D2-20221009-camera-0' ...
    '-masked-1DLC_resnet50_dogsOct18shuffle1_1030000.csv']);
camimgd = imread([rootpath,'\panel_7\frame-3_mouse-0.jpg']);
parrot_dsc = load([rootpath,'\panel_8\SBeA_data_sample_cell_20221107.mat']);
parrot_wc = load([rootpath,'\panel_8\SBeA_wc_struct_20221107.mat']);
dog_dsc = load([rootpath,'\panel_9\SBeA_data_sample_cell_20221130.mat']);
dog_wc = load([rootpath,'\panel_9\SBeA_wc_struct_20221130.mat']);
parrot_trajs = load([rootpath,'\panel_8\rec3-B1B2-20220919-id3d.mat']);
dog_trajs = load([rootpath,'\panel_9\rec3-D1D2-20221009-id3d.mat']);
parrot_ll_path = [rootpath,'\panel_10\bird'];
dog_ll_path = [rootpath,'\panel_10\dog'];
parrot_raw_path = [rootpath,'\panel_10\rec3-B1B2-20220919-raw3d.mat'];
dog_raw_path = [rootpath,'\panel_10\rec3-D1D2-20221009-raw3d.mat'];
parrot_eval_path = [rootpath,'\panel_10\parrot-body-test20221008-multi-True-eval.mat'];
dog_eval_path = [rootpath,'\panel_10\dog-body-test20221018-multi-True-eval.mat'];
parrot_distmat_path = [rootpath,'\panel_10\SBeA_dist_mat_all_20221107.mat'];
dog_distmat_path = [rootpath,'\panel_10\SBeA_dist_mat_all_20221130.mat'];
parrot_distmat = load(parrot_distmat_path);
dog_distmat = load(dog_distmat_path);
parrot_eval = load(parrot_eval_path);
dog_eval = load(dog_eval_path);
parrot_raw = load(parrot_raw_path);
dog_raw = load(dog_raw_path);
fileFolder = fullfile(parrot_ll_path);
dirOutput = dir(fullfile(fileFolder,'*.csv'));
parrot_ll_names = {dirOutput.name}';
fileFolder = fullfile(dog_ll_path);
dirOutput = dir(fullfile(fileFolder,'*.csv'));
dog_ll_names = {dirOutput.name}';
parrot_ll_cell = cell(size(parrot_ll_names,1),2);
dog_ll_cell = cell(size(dog_ll_names,1),2);
parrot_ll_cell(:,1) = parrot_ll_names;
dog_ll_cell(:,1) = dog_ll_names;
for k = 1:size(parrot_ll_cell,1)
    tempname = [parrot_ll_path,'\',parrot_ll_cell{k,1}];
    tempdata = importdata(tempname);
    tempdata.data(:,1) = [];
    parrot_ll_cell{k,2} = tempdata.data;
end
for k = 1:size(dog_ll_cell,1)
    tempname = [dog_ll_path,'\',dog_ll_cell{k,1}];
    tempdata = importdata(tempname);
    tempdata.data(:,1) = [];
    dog_ll_cell{k,2} = tempdata.data;
end

featpath_bird = [rootpath,'\panel_11\bird\feature\val'];
featpath_dog = [rootpath,'\panel_11\dog\feature\val'];
feat_bird_name = {};
feat_dog_name = {};
for k = 1:2
    fileFolder = fullfile(featpath_bird,['B',num2str(k)]);
    dirOutput = dir(fullfile(fileFolder,'*_cam.mat'));
    temphrname = {dirOutput.name}';
    temphrpath = {dirOutput.folder}';
    temphrsplname = cellfun(@(x) split(x,'\'),temphrpath,'UniformOutput',false);
    temphrendpath = cellfun(@(x) x{end},temphrsplname,'UniformOutput',false);
    temphrfirstpath = cellfun(@(x,y) x(1:(end-1-length(y))),temphrpath, ...
        temphrendpath,'UniformOutput',false);
    feat_bird_name = [feat_bird_name;[temphrfirstpath,temphrendpath,temphrname]];
end
for k = 1:2
    fileFolder = fullfile(featpath_dog,['D',num2str(k)]);
    dirOutput = dir(fullfile(fileFolder,'*_cam.mat'));
    temphrname = {dirOutput.name}';
    temphrpath = {dirOutput.folder}';
    temphrsplname = cellfun(@(x) split(x,'\'),temphrpath,'UniformOutput',false);
    temphrendpath = cellfun(@(x) x{end},temphrsplname,'UniformOutput',false);
    temphrfirstpath = cellfun(@(x,y) x(1:(end-1-length(y))),temphrpath, ...
        temphrendpath,'UniformOutput',false);
    feat_dog_name = [feat_dog_name;[temphrfirstpath,temphrendpath,temphrname]];
end
%% parrot
%% show single animal
subplot('Position',[0.05,0.85,0.1,0.1])
start_x = 400;
start_y = 400;
box_width = 500;
showsingle1 = read(vidobjb1,900);
imshow(showsingle1(start_x:(start_x+box_width),...
    start_y:(start_y+box_width),:))
subplot('Position',[0.16,0.85,0.1,0.1])
start_x = 350;
start_y = 530;
box_width = 520;
showsingle2 = read(vidobjb2,1330);
imshow(showsingle2(start_x:(start_x+box_width),...
    start_y:(start_y+box_width),:))
%% show two animals and annotations
subplot('Position',[0.05,0.74,0.1,0.1])
start_x = 280;
start_y = 350;
box_width = 550;
mouse1p = jsonvalueb1b2.shapes(1).points;
mouse2p = jsonvalueb1b2.shapes(2).points;
mouse1p = [mouse1p;mouse1p(1,:)];
mouse2p = [mouse2p;mouse2p(1,:)];
imshow(imgb1b2(start_x:(start_x+box_width),...
    start_y:(start_y+box_width),:))
hold on
plot(mouse1p(:,1)-start_y,mouse1p(:,2)-start_x,'-y','LineWidth',1)
hold on
plot(mouse2p(:,1)-start_y,mouse2p(:,2)-start_x,'-y','LineWidth',1)
hold off
subplot('Position',[0.16,0.74,0.1,0.1])
start_x = 300;
start_y = 420;
box_width = 650;
imshow(poseb1(start_x:(start_x+box_width),...
    start_y:(start_y+box_width),:))
posx = posdata(1:2:end)-start_y;
posy = posdata(2:2:end)-start_x;
hold on
plot(posx,posy,'y.','MarkerSize',10)
hold off
%% model segmentations and poses
% figure
selframe = 17591;
start_x = 180;
start_y = 310;
box_width = 750;
setcolor = cbrewer2('Spectral',11);
mouse1_c = setcolor(3,:);
mouse2_c = setcolor(9,:);
showimg = read(datab1b2.vidobj,selframe);
pos1 = datab1b2.pos1.data(selframe,2:end);
pos1x = pos1(1:3:end)-start_y;
pos1y = pos1(2:3:end)-start_x;
pos2 = datab1b2.pos2.data(selframe,2:end);
pos2x = pos2(1:3:end)-start_y;
pos2y = pos2(2:3:end)-start_x;
img_anno_1 = datab1b2.jsonvalue.annotations.segmentations(selframe,1);
img_anno_2 = datab1b2.jsonvalue.annotations.segmentations(selframe,2);
masks_1 = MaskApi.decode(img_anno_1);
masks_2 = MaskApi.decode(img_anno_2);
showframe = labeloverlay(showimg,masks_1,...
    'Colormap',mouse1_c,'Transparency',0.7);
showframe = labeloverlay(showframe,masks_2,...
    'Colormap',mouse2_c,'Transparency',0.7);
subplot('Position',[0.3,0.85,0.1,0.1])
imshow(showframe(start_x:(start_x+box_width),...
    start_y:(start_y+box_width),:))
hold on
plot(pos1x,pos1y,'.','Color',mouse1_c)
hold on
plot(pos2x,pos2y,'.','Color',mouse2_c)
hold off
%% model identities CAM
version = 'D:\anaconda\envs\matlab-py\pythonw.exe';
% pe = pyenv('Version',version);
[ret,modelout] = pyrun(...
["import torch"
"import numpy as np"
"from PIL import Image"
"from torchvision import transforms"
"from torchvision.transforms.functional import normalize, resize, to_pil_image"
"import torch.nn as nn"
"import torch.nn.functional as F"
"from torchcam.methods import LayerCAM, SmoothGradCAMpp"
"from efficientnet_pytorch import EfficientNet"
""
"def get_layer_cam(model,input_tensor,device,count, templayer):"
"    model.eval()"
"    extractor = LayerCAM(model, templayer)"
"    input_tensor = input_tensor.unsqueeze(0)"
"    input_tensor = input_tensor.to(device)"
"    out = model(input_tensor)"
"    cams = extractor(class_idx=count, scores=out)"
"    return cams[0].cpu().squeeze(0).numpy()"
""
"OUTPUT_DIM = 2"
"modelpath = r'Z:\hanyaning\multi_mice_test\Social_analysis\data\hcl_bird\sbea_bird_20220929\models\reid\reidmodel-body-test20221008-multi-True-effnet.pt'"
"model = EfficientNet.from_pretrained('efficientnet-b4', num_classes=OUTPUT_DIM)"
"device = torch.device('cpu')"
"print(device)"
"criterion = nn.CrossEntropyLoss()"
"model = model.to(device)"
"criterion = criterion.to(device)"
"model.load_state_dict(torch.load(modelpath,map_location=device))"
"#print(np.asarray(inputframe))"
"img = transforms.ToTensor()(np.asarray(inputframe))"
"#print(resize(img, (256, 256)) / 255.)"
"pretrained_means = [0.485,0.456,0.406]"
"pretrained_stds = [0.229,0.224,0.225]"
"input_tensor = normalize(resize(img, (224, 224)), pretrained_means, pretrained_stds)"
"# calculate layer cam"
"layer_list = list(np.int32(np.linspace(-1,31,33)))                #['-1','1','3','5','11']"
"layer_list = [str(l) for l in layer_list]"
"count = 0"
"maskcamlist = []"
"for templayer in layer_list:"
"    outcam = get_layer_cam(model, input_tensor, device, count, model._blocks[np.int32(templayer)])"
"    maskcam = np.array(to_pil_image(outcam, mode='F'))"
"    maskcamlist.append(maskcam)"
"    print(templayer)"
""
"input_tensor = input_tensor.unsqueeze(0)"
"input_tensor = input_tensor.to(device)"
"out = model(input_tensor)"
"y_prob = F.softmax(out, dim = -1).cpu().squeeze(0).detach().numpy()"
],["maskcamlist","y_prob"],inputframe = camimg);
%%
res_size = [256,256];
subplot('Position',[0.3,0.74,0.1,0.1])
maskcamlist = cell(length(ret),1);
summaskcam = zeros(res_size);
for k = 1:size(maskcamlist,1)
    ndmask = cell(ret(k));
    maskcamlist{k,1} = round(mat2gray(imresize(double(ndmask{1}),res_size))*255);
    summaskcam = summaskcam + maskcamlist{k,1};
end
summaskcam = round(mat2gray(summaskcam)*255);
showcamframe = labeloverlay(camimg,summaskcam,...
    'Colormap',flipud(cbrewer2('Spectral',256)));
imshow(showcamframe)
%% ethogram
ethogram_list = cell2mat(cellfun(@(x,y) ones(size(x,2),1)*y,...
    parrot_dsc.data_sample_cell(:,1),...
    parrot_dsc.data_sample_cell(:,8),'UniformOutput',false));
etho_unique_idx = unique(ethogram_list(:,1));
ethogram = zeros(length(etho_unique_idx),size(ethogram_list,1));
for k = 1:size(ethogram,1)
    ethogram(k,etho_unique_idx(k)==ethogram_list(:,1)) = 1;
end
tempcmap = cbrewer2('Spectral',length(etho_unique_idx));
rng(1234)
randdata=randperm(size(tempcmap,1));
extract_idx=randdata(1:size(tempcmap,1)); 
cmap = tempcmap(extract_idx,:);
subplot('Position',[0.44,0.9,0.15,0.05])
for k = 1:size(ethogram,1)
    %
    tempetho = [0,ethogram(k,:)];
    difftempetho = diff(tempetho);
    start_idx = find(difftempetho==1);
    end_idx = find(difftempetho==-1);
    if tempetho(end) == 1
        end_idx = [end_idx,length(tempetho)];
    end
    for m = 1:length(start_idx)
        plot([start_idx(m),end_idx(m)],[k,k],'Color',cmap(k,:),...
            'LineWidth',2)
        hold on
    end
end
hold off
box off
set(gca,'TickDir','out')
set(gca,'YTick',[1,length(etho_unique_idx)])
set(gca,'XTick',[0,size(ethogram_list,1)])
axis([0,size(ethogram_list,1),1,length(etho_unique_idx)])
title('Ethogram of birds')
set(gca,'XTickLabel',[0,15])
%% behavior atlas
mk_size = 3;
class_list = cell2mat(parrot_dsc.data_sample_cell(:,8));
embedding = cell2mat(parrot_dsc.data_sample_cell(:,4));
cmaplist = zeros(size(embedding,1),3);
for k = 1:length(etho_unique_idx)
    selidx = etho_unique_idx(k)==class_list(:,1);
    cmaplist(selidx,:) = ones(sum(selidx),1)*cmap(etho_unique_idx(k),:);
end
L_img = parrot_wc.wc_struct.L_much==0;
XX = parrot_wc.wc_struct.XX_much;
YY = parrot_wc.wc_struct.YY_much;
hba = subplot('Position',[0.44,0.74,0.15,0.15]);
scatter(embedding(:,1),embedding(:,2),mk_size*ones(size(embedding,1),1),...
    cmaplist,'filled') 
hold on
im = imagesc([min(XX(:)),max(XX(:))],[min(YY(:)),max(YY(:))],L_img);
im.AlphaData = L_img;
hold off
colormap(hba,0.7*[1,1,1])
axis([min(embedding(:,1)),max(embedding(:,1)),...
    min(embedding(:,2)),max(embedding(:,2))])
set(gca,'XTick',[])
set(gca,'YTick',[])
%% behavior example 3D
sel_beh_num_1 = 2840;%95s, kissing
sel_beh_num_2 = 4982;%166s, Anogenital touching
sel_beh_num_3 = 5045;%168s, Clamp on back

edge_x = 20;
edge_y = 20;
edge_z = 10;

sel_beh_1 = parrot_trajs.coords3d(sel_beh_num_1,:);
sel_beh_1_1 = sel_beh_1(1:(length(sel_beh_1)/2));
sel_beh_1_2 = sel_beh_1((1+(length(sel_beh_1)/2)):end);
sel_beh_2 = parrot_trajs.coords3d(sel_beh_num_2,:);
sel_beh_2_1 = sel_beh_2(1:(length(sel_beh_2)/2));
sel_beh_2_2 = sel_beh_2((1+(length(sel_beh_2)/2)):end);
sel_beh_3 = parrot_trajs.coords3d(sel_beh_num_3,:);
sel_beh_3_1 = sel_beh_3(1:(length(sel_beh_3)/2));
sel_beh_3_2 = sel_beh_3((1+(length(sel_beh_3)/2)):end);

start_x = 0.64;
start_y = 0.74;
inter_x = 0.01;
inter_y = 0.01;
box_size = 0.1;
%
subplot('Position',[start_x,start_y+box_size+inter_y,box_size,box_size])
min_x = min(sel_beh_1(1:3:end));
max_x = max(sel_beh_1(1:3:end));
min_y = min(sel_beh_1(2:3:end));
max_y = max(sel_beh_1(2:3:end));
min_z = min(sel_beh_1(3:3:end));
max_z = max(sel_beh_1(3:3:end));
plotstr = mouse1_c;
linestr = mouse1_c;
X = sel_beh_1_1(1:3:end)';
Y = sel_beh_1_1(2:3:end)';
Z = sel_beh_1_1(3:3:end)';
plot_skl_bird(X,Y,Z,plotstr,linestr)
hold on
plotstr = mouse2_c;
linestr = mouse2_c;
X = sel_beh_1_2(1:3:end)';
Y = sel_beh_1_2(2:3:end)';
Z = sel_beh_1_2(3:3:end)';
plot_skl_bird(X,Y,Z,plotstr,linestr)
hold off
box on
view(90,90)
xlabel({'Top view','x'})
title('Kissing')
set(gca,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[])
axis([min_x-edge_x,max_x+edge_x,...
    min_y-edge_y,max_y+edge_y,...
    min_z-edge_z/2,max_z+edge_z])
set(gca,'TickLength',[0,0])
%
subplot('Position',[start_x,start_y,box_size,box_size])
plotstr = mouse1_c;
linestr = mouse1_c;
X = sel_beh_1_1(1:3:end)';
Y = sel_beh_1_1(2:3:end)';
Z = sel_beh_1_1(3:3:end)';
plot_skl_bird(X,Y,Z,plotstr,linestr)
hold on
plotstr = mouse2_c;
linestr = mouse2_c;
X = sel_beh_1_2(1:3:end)';
Y = sel_beh_1_2(2:3:end)';
Z = sel_beh_1_2(3:3:end)';
plot_skl_bird(X,Y,Z,plotstr,linestr)
hold off
box on
view(90,0)
zlabel({'Side view','z'})
ylabel('y')
set(gca,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[])
axis([min_x-edge_x,max_x+edge_x,...
    min_y-edge_y,max_y+edge_y,...
    min_z-edge_z/2,max_z+edge_z])
set(gca,'TickLength',[0,0])
%
subplot('Position',[start_x+box_size+inter_x,start_y+box_size+inter_y,...
    box_size,box_size])
min_x = min(sel_beh_2(1:3:end));
max_x = max(sel_beh_2(1:3:end));
min_y = min(sel_beh_2(2:3:end));
max_y = max(sel_beh_2(2:3:end));
min_z = min(sel_beh_2(3:3:end));
max_z = max(sel_beh_2(3:3:end));
plotstr = mouse1_c;
linestr = mouse1_c;
X = sel_beh_2_1(1:3:end)';
Y = sel_beh_2_1(2:3:end)';
Z = sel_beh_2_1(3:3:end)';
plot_skl_bird(X,Y,Z,plotstr,linestr)
hold on
plotstr = mouse2_c;
linestr = mouse2_c;
X = sel_beh_2_2(1:3:end)';
Y = sel_beh_2_2(2:3:end)';
Z = sel_beh_2_2(3:3:end)';
plot_skl_bird(X,Y,Z,plotstr,linestr)
hold off
box on
view(90,90)
title({'Anogenital','touching'})
set(gca,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[])
axis([min_x-edge_x,max_x+edge_x,...
    min_y-edge_y,max_y+edge_y,...
    min_z-edge_z/2,max_z+edge_z])
set(gca,'TickLength',[0,0])
%
subplot('Position',[start_x+1*(box_size+inter_x),start_y,...
    box_size,box_size])
plotstr = mouse1_c;
linestr = mouse1_c;
X = sel_beh_2_1(1:3:end)';
Y = sel_beh_2_1(2:3:end)';
Z = sel_beh_2_1(3:3:end)';
plot_skl_bird(X,Y,Z,plotstr,linestr)
hold on
plotstr = mouse2_c;
linestr = mouse2_c;
X = sel_beh_2_2(1:3:end)';
Y = sel_beh_2_2(2:3:end)';
Z = sel_beh_2_2(3:3:end)';
plot_skl_bird(X,Y,Z,plotstr,linestr)
hold off
box on
view(90,0)
ylabel('y')
set(gca,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[])
axis([min_x-edge_x,max_x+edge_x,...
    min_y-edge_y,max_y+edge_y,...
    min_z-edge_z/2,max_z+edge_z+40])
set(gca,'TickLength',[0,0])
%
subplot('Position',[start_x+2*(box_size+inter_x),start_y+box_size+inter_y,...
    box_size,box_size])
min_x = min(sel_beh_3(1:3:end));
max_x = max(sel_beh_3(1:3:end));
min_y = min(sel_beh_3(2:3:end));
max_y = max(sel_beh_3(2:3:end));
min_z = min(sel_beh_3(3:3:end));
max_z = max(sel_beh_3(3:3:end));
plotstr = mouse1_c;
linestr = mouse1_c;
X = sel_beh_3_1(1:3:end)';
Y = sel_beh_3_1(2:3:end)';
Z = sel_beh_3_1(3:3:end)';
plot_skl_bird(X,Y,Z,plotstr,linestr)
hold on
plotstr = mouse2_c;
linestr = mouse2_c;
X = sel_beh_3_2(1:3:end)';
Y = sel_beh_3_2(2:3:end)';
Z = sel_beh_3_2(3:3:end)';
plot_skl_bird(X,Y,Z,plotstr,linestr)
hold off
box on
view(90,90)
title({'Clamping','on rectrix'})
set(gca,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[])
axis([min_x-edge_x,max_x+edge_x,...
    min_y-edge_y,max_y+edge_y,...
    min_z-edge_z/2,max_z+edge_z])
set(gca,'TickLength',[0,0])
%
subplot('Position',[start_x+2*(box_size+inter_x),start_y,...
    box_size,box_size])
plotstr = mouse1_c;
linestr = mouse1_c;
X = sel_beh_3_1(1:3:end)';
Y = sel_beh_3_1(2:3:end)';
Z = sel_beh_3_1(3:3:end)';
plot_skl_bird(X,Y,Z,plotstr,linestr)
hold on
plotstr = mouse2_c;
linestr = mouse2_c;
X = sel_beh_3_2(1:3:end)';
Y = sel_beh_3_2(2:3:end)';
Z = sel_beh_3_2(3:3:end)';
plot_skl_bird(X,Y,Z,plotstr,linestr)
hold off
box on
view(90,0)
ylabel('y')
set(gca,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[])
axis([min_x-edge_x,max_x+edge_x,...
    min_y-edge_y,max_y+edge_y,...
    min_z-edge_z/2,max_z+edge_z])
set(gca,'TickLength',[0,0])
%% dog
fig_bias_y = -0.27;
%% show single animal
subplot('Position',[0.05,0.85+fig_bias_y,0.1,0.1])
start_x = 80;
start_y = 250;
box_width = 170;
showsingle1 = read(vidobjd1,540);
imshow(showsingle1(start_x:(start_x+box_width),...
    start_y:(start_y+box_width),:))
subplot('Position',[0.16,0.85+fig_bias_y,0.1,0.1])
start_x = 150;
start_y = 170;
box_width = 210;
showsingle1 = read(vidobjd2,11430);
imshow(showsingle1(start_x:(start_x+box_width),...
    start_y:(start_y+box_width),:))
%% show two animals and annotations
subplot('Position',[0.05,0.74+fig_bias_y,0.1,0.1])
start_x = 80;
start_y = 100;
box_width = 180;
mouse1p = jsonvalued1d2.shapes(1).points;
mouse2p = jsonvalued1d2.shapes(2).points;
mouse1p = [mouse1p;mouse1p(1,:)];
mouse2p = [mouse2p;mouse2p(1,:)];
imshow(imgd1d2(start_x:(start_x+box_width),...
    start_y:(start_y+box_width),:))
hold on
plot(mouse1p(:,1)-start_y,mouse1p(:,2)-start_x,'-y','LineWidth',1)
hold on
plot(mouse2p(:,1)-start_y,mouse2p(:,2)-start_x,'-y','LineWidth',1)
hold off
subplot('Position',[0.16,0.74+fig_bias_y,0.1,0.1])
start_x = 150;
start_y = 220;
box_width = 170;
imshow(posed1(start_x:(start_x+box_width),...
    start_y:(start_y+box_width),:))
posx = posdatad1(1:2:end)-start_y;
posy = posdatad1(2:2:end)-start_x;
hold on
plot(posx,posy,'y.','MarkerSize',10)
hold off
%% model segmentations and poses
selframe = 8865;
start_x = 90;
start_y = 95;
box_width = 180;
setcolor = cbrewer2('Spectral',11);
mouse1_c = setcolor(3,:);
mouse2_c = setcolor(9,:);
showimg = read(datad1d2.vidobj,selframe);
pos1 = datad1d2.pos1.data(selframe,2:end);
pos1x = pos1(1:3:end)-start_y;
pos1y = pos1(2:3:end)-start_x;
pos2 = datad1d2.pos2.data(selframe,2:end);
pos2x = pos2(1:3:end)-start_y;
pos2y = pos2(2:3:end)-start_x;
img_anno_1 = datad1d2.jsonvalue.annotations.segmentations(selframe,1);
img_anno_2 = datad1d2.jsonvalue.annotations.segmentations(selframe,2);
masks_1 = MaskApi.decode(img_anno_1);
masks_2 = MaskApi.decode(img_anno_2);
showframe = labeloverlay(showimg,masks_1,...
    'Colormap',mouse1_c,'Transparency',0.7);
showframe = labeloverlay(showframe,masks_2,...
    'Colormap',mouse2_c,'Transparency',0.7);
subplot('Position',[0.3,0.85+fig_bias_y,0.1,0.1])
imshow(showframe(start_x:(start_x+box_width),...
    start_y:(start_y+box_width),:))
hold on
plot(pos1x,pos1y,'.','Color',mouse1_c)
hold on
plot(pos2x,pos2y,'.','Color',mouse2_c)
hold off
%% model identities CAM
[ret,modelout] = pyrun(...
["import torch"
"import numpy as np"
"from PIL import Image"
"from torchvision import transforms"
"from torchvision.transforms.functional import normalize, resize, to_pil_image"
"import torch.nn as nn"
"import torch.nn.functional as F"
"from torchcam.methods import LayerCAM, SmoothGradCAMpp"
"from efficientnet_pytorch import EfficientNet"
""
"def get_layer_cam(model,input_tensor,device,count, templayer):"
"    model.eval()"
"    extractor = LayerCAM(model, templayer)"
"    input_tensor = input_tensor.unsqueeze(0)"
"    input_tensor = input_tensor.to(device)"
"    out = model(input_tensor)"
"    cams = extractor(class_idx=count, scores=out)"
"    return cams[0].cpu().squeeze(0).numpy()"
""
"OUTPUT_DIM = 2"
"modelpath = r'Z:\hanyaning\multi_mice_test\Social_analysis\data\hcl_bird\sbea_bird_20220929\models\reid\reidmodel-body-test20221008-multi-True-effnet.pt'"
"model = EfficientNet.from_pretrained('efficientnet-b4', num_classes=OUTPUT_DIM)"
"device = torch.device('cpu')"
"print(device)"
"criterion = nn.CrossEntropyLoss()"
"model = model.to(device)"
"criterion = criterion.to(device)"
"model.load_state_dict(torch.load(modelpath,map_location=device))"
"#print(np.asarray(inputframe))"
"img = transforms.ToTensor()(np.asarray(inputframe))"
"#print(resize(img, (256, 256)) / 255.)"
"pretrained_means = [0.485,0.456,0.406]"
"pretrained_stds = [0.229,0.224,0.225]"
"input_tensor = normalize(resize(img, (224, 224)), pretrained_means, pretrained_stds)"
"# calculate layer cam"
"layer_list = list(np.int32(np.linspace(-1,31,33)))                #['-1','1','3','5','11']"
"layer_list = [str(l) for l in layer_list]"
"count = 0"
"maskcamlist = []"
"for templayer in layer_list:"
"    outcam = get_layer_cam(model, input_tensor, device, count, model._blocks[np.int32(templayer)])"
"    maskcam = np.array(to_pil_image(outcam, mode='F'))"
"    maskcamlist.append(maskcam)"
"    print(templayer)"
""
"input_tensor = input_tensor.unsqueeze(0)"
"input_tensor = input_tensor.to(device)"
"out = model(input_tensor)"
"y_prob = F.softmax(out, dim = -1).cpu().squeeze(0).detach().numpy()"
],["maskcamlist","y_prob"],inputframe = camimgd);
%%
res_size = [256,256];
subplot('Position',[0.3,0.74+fig_bias_y,0.1,0.1])
maskcamlist = cell(length(ret),1);
summaskcam = zeros(res_size);
for k = 1:size(maskcamlist,1)
    ndmask = cell(ret(k));
    maskcamlist{k,1} = round(mat2gray(imresize(double(ndmask{1}),res_size))*255);
    summaskcam = summaskcam + maskcamlist{k,1};
end
summaskcam = round(mat2gray(summaskcam)*255);
showcamframe = labeloverlay(camimgd,summaskcam,...
    'Colormap',flipud(cbrewer2('Spectral',256)));
imshow(showcamframe)
%% ethogram
ethogram_list = cell2mat(cellfun(@(x,y) ones(size(x,2),1)*y,...
    dog_dsc.data_sample_cell(:,1),...
    dog_dsc.data_sample_cell(:,8),'UniformOutput',false));
ethogram_list = ethogram_list(1:27000,:);
etho_unique_idx = unique(ethogram_list(:,1));
ethogram = zeros(length(etho_unique_idx),size(ethogram_list,1));
for k = 1:size(ethogram,1)
    ethogram(k,etho_unique_idx(k)==ethogram_list(:,1)) = 1;
end
tempcmap = cbrewer2('Spectral',length(etho_unique_idx));
rng(1234)
randdata=randperm(size(tempcmap,1));
extract_idx=randdata(1:size(tempcmap,1)); 
cmap = tempcmap(extract_idx,:);
subplot('Position',[0.44,0.9+fig_bias_y,0.15,0.05])
for k = 1:size(ethogram,1)
    %
    tempetho = [0,ethogram(k,:)];
    difftempetho = diff(tempetho);
    start_idx = find(difftempetho==1);
    end_idx = find(difftempetho==-1);
    if tempetho(end) == 1
        end_idx = [end_idx,length(tempetho)];
    end
    for m = 1:length(start_idx)
        plot([start_idx(m),end_idx(m)],[k,k],'Color',cmap(k,:),...
            'LineWidth',2)
        hold on
    end
end
hold off
box off
set(gca,'TickDir','out')
set(gca,'YTick',[1,length(etho_unique_idx)])
set(gca,'XTick',[0,size(ethogram_list,1)])
axis([0,size(ethogram_list,1),1,length(etho_unique_idx)])
title('Ethogram of dogs')
set(gca,'XTickLabel',[0,15])
%% behavior atlas
mk_size = 3;
class_list = cell2mat(dog_dsc.data_sample_cell(:,8));
embedding = cell2mat(dog_dsc.data_sample_cell(:,4));
cmaplist = zeros(size(embedding,1),3);
for k = 1:length(etho_unique_idx)
    selidx = etho_unique_idx(k)==class_list(:,1);
    cmaplist(selidx,:) = ones(sum(selidx),1)*cmap(etho_unique_idx(k),:);
end
L_img = dog_wc.wc_struct.L_much==0;
XX = dog_wc.wc_struct.XX_much;
YY = dog_wc.wc_struct.YY_much;
hba = subplot('Position',[0.44,0.74+fig_bias_y,0.15,0.15]);
scatter(embedding(:,1),embedding(:,2),mk_size*ones(size(embedding,1),1),...
    cmaplist,'filled') 
hold on
im = imagesc([min(XX(:)),max(XX(:))],[min(YY(:)),max(YY(:))],L_img);
im.AlphaData = L_img;
hold off
colormap(hba,0.7*[1,1,1])
axis([min(embedding(:,1)),max(embedding(:,1)),...
    min(embedding(:,2)),max(embedding(:,2))])
set(gca,'XTick',[])
set(gca,'YTick',[])
%% behavior example 3D
sel_beh_num_1 = 2485;%80s, Chasing
sel_beh_num_2 = 6541;%218s, Back touching
sel_beh_num_3 = 16419;%547s, Nose touching

edge_x = 100;
edge_y = 100;
edge_high_z = 400;
edge_low_z = 10;

sel_beh_1 = dog_trajs.coords3d(sel_beh_num_1,:);
sel_beh_1_1 = sel_beh_1(1:(length(sel_beh_1)/2));
sel_beh_1_2 = sel_beh_1((1+(length(sel_beh_1)/2)):end);
sel_beh_2 = dog_trajs.coords3d(sel_beh_num_2,:);
sel_beh_2_1 = sel_beh_2(1:(length(sel_beh_2)/2));
sel_beh_2_2 = sel_beh_2((1+(length(sel_beh_2)/2)):end);
sel_beh_3 = dog_trajs.coords3d(sel_beh_num_3,:);
sel_beh_3_1 = sel_beh_3(1:(length(sel_beh_3)/2));
sel_beh_3_2 = sel_beh_3((1+(length(sel_beh_3)/2)):end);


start_x = 0.64;
start_y = 0.74+fig_bias_y;
inter_x = 0.01;
inter_y = 0.01;
box_size = 0.1;
subplot('Position',[start_x,start_y+box_size+inter_y,box_size,box_size])
min_x = min(sel_beh_1(1:3:end));
max_x = max(sel_beh_1(1:3:end));
min_y = min(sel_beh_1(2:3:end));
max_y = max(sel_beh_1(2:3:end));
min_z = min(sel_beh_1(3:3:end));
max_z = max(sel_beh_1(3:3:end));
plotstr = mouse1_c;
linestr = mouse1_c;
X = sel_beh_1_1(1:3:end)';
Y = sel_beh_1_1(2:3:end)';
Z = sel_beh_1_1(3:3:end)';
plot_skl_dog(X,Y,Z,plotstr,linestr)
hold on
plotstr = mouse2_c;
linestr = mouse2_c;
X = sel_beh_1_2(1:3:end)';
Y = sel_beh_1_2(2:3:end)';
Z = sel_beh_1_2(3:3:end)';
plot_skl_dog(X,Y,Z,plotstr,linestr)
hold off
box on
view(90,90)
xlabel({'Top view','x'})
title({'Chasing'})
set(gca,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[])
axis([min_x-edge_x,max_x+edge_x,...
    min_y-edge_y,max_y+edge_y,...
    min_z-edge_low_z,max_z+edge_high_z])
set(gca,'TickLength',[0,0])
subplot('Position',[start_x,start_y,box_size,box_size])
plotstr = mouse1_c;
linestr = mouse1_c;
X = sel_beh_1_1(1:3:end)';
Y = sel_beh_1_1(2:3:end)';
Z = sel_beh_1_1(3:3:end)';
plot_skl_dog(X,Y,Z,plotstr,linestr)
hold on
plotstr = mouse2_c;
linestr = mouse2_c;
X = sel_beh_1_2(1:3:end)';
Y = sel_beh_1_2(2:3:end)';
Z = sel_beh_1_2(3:3:end)';
plot_skl_dog(X,Y,Z,plotstr,linestr)
hold off
box on
view(90,0)
zlabel({'Side view','z'})
ylabel('y')
set(gca,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[])
axis([min_x-edge_x,max_x+edge_x,...
    min_y-edge_y,max_y+edge_y,...
    min_z-edge_low_z,max_z+edge_high_z])
set(gca,'TickLength',[0,0])
subplot('Position',[start_x+box_size+inter_x,start_y+box_size+inter_y,...
    box_size,box_size])
min_x = min(sel_beh_2(1:3:end));
max_x = max(sel_beh_2(1:3:end));
min_y = min(sel_beh_2(2:3:end));
max_y = max(sel_beh_2(2:3:end));
min_z = min(sel_beh_2(3:3:end));
max_z = max(sel_beh_2(3:3:end));
plotstr = mouse1_c;
linestr = mouse1_c;
X = sel_beh_2_1(1:3:end)';
Y = sel_beh_2_1(2:3:end)';
Z = sel_beh_2_1(3:3:end)';
plot_skl_dog(X,Y,Z,plotstr,linestr)
hold on
plotstr = mouse2_c;
linestr = mouse2_c;
X = sel_beh_2_2(1:3:end)';
Y = sel_beh_2_2(2:3:end)';
Z = sel_beh_2_2(3:3:end)';
plot_skl_dog(X,Y,Z,plotstr,linestr)
hold off
box on
view(90,90)
title({'Back touching'})
set(gca,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[])
axis([min_x-edge_x,max_x+edge_x,...
    min_y-edge_y,max_y+edge_y,...
    min_z-edge_low_z,max_z+edge_high_z])
set(gca,'TickLength',[0,0])
subplot('Position',[start_x+1*(box_size+inter_x),start_y,...
    box_size,box_size])
plotstr = mouse1_c;
linestr = mouse1_c;
X = sel_beh_2_1(1:3:end)';
Y = sel_beh_2_1(2:3:end)';
Z = sel_beh_2_1(3:3:end)';
plot_skl_dog(X,Y,Z,plotstr,linestr)
hold on
plotstr = mouse2_c;
linestr = mouse2_c;
X = sel_beh_2_2(1:3:end)';
Y = sel_beh_2_2(2:3:end)';
Z = sel_beh_2_2(3:3:end)';
plot_skl_dog(X,Y,Z,plotstr,linestr)
hold off
box on
view(90,0)
ylabel('y')
set(gca,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[])
axis([min_x-edge_x,max_x+edge_x,...
    min_y-edge_y,max_y+edge_y,...
    min_z-edge_low_z,max_z+edge_high_z])
set(gca,'TickLength',[0,0])
subplot('Position',[start_x+2*(box_size+inter_x),start_y+box_size+inter_y,...
    box_size,box_size])
min_x = min(sel_beh_3(1:3:end));
max_x = max(sel_beh_3(1:3:end));
min_y = min(sel_beh_3(2:3:end));
max_y = max(sel_beh_3(2:3:end));
min_z = min(sel_beh_3(3:3:end));
max_z = max(sel_beh_3(3:3:end));
plotstr = mouse1_c;
linestr = mouse1_c;
X = sel_beh_3_1(1:3:end)';
Y = sel_beh_3_1(2:3:end)';
Z = sel_beh_3_1(3:3:end)';
plot_skl_dog(X,Y,Z,plotstr,linestr)
hold on
plotstr = mouse2_c;
linestr = mouse2_c;
X = sel_beh_3_2(1:3:end)';
Y = sel_beh_3_2(2:3:end)';
Z = sel_beh_3_2(3:3:end)';
plot_skl_dog(X,Y,Z,plotstr,linestr)
hold off
box on
view(90,90)
title({'Nose touching'})
set(gca,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[])
axis([min_x-edge_x,max_x+edge_x,...
    min_y-edge_y,max_y+edge_y,...
    min_z-edge_low_z,max_z+edge_high_z])
set(gca,'TickLength',[0,0])
subplot('Position',[start_x+2*(box_size+inter_x),start_y,...
    box_size,box_size])
plotstr = mouse1_c;
linestr = mouse1_c;
X = sel_beh_3_1(1:3:end)';
Y = sel_beh_3_1(2:3:end)';
Z = sel_beh_3_1(3:3:end)';
plot_skl_dog(X,Y,Z,plotstr,linestr)
hold on
plotstr = mouse2_c;
linestr = mouse2_c;
X = sel_beh_3_2(1:3:end)';
Y = sel_beh_3_2(2:3:end)';
Z = sel_beh_3_2(3:3:end)';
plot_skl_dog(X,Y,Z,plotstr,linestr)
hold off
box on
view(90,0)
ylabel('y')
set(gca,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[])
axis([min_x-edge_x,max_x+edge_x,...
    min_y-edge_y,max_y+edge_y,...
    min_z-edge_low_z,max_z+edge_high_z])
set(gca,'TickLength',[0,0])
%% quantification
%% likelihoods
bd = 0.1;
v_width = 0.3;
parrot_ll = cell(size(parrot_ll_cell,1),1);
dog_ll = cell(size(dog_ll_cell,1),1);
for k = 1:size(parrot_ll,1)
    parrot_ll{k,1} = parrot_ll_cell{k,2}(:,3:3:end);
end
for k = 1:size(dog_ll,1)
    dog_ll{k,1} = dog_ll_cell{k,2}(:,3:3:end);
end
parrot_ll = cell2mat(parrot_ll);
dog_ll = cell2mat(dog_ll);
mean_parrot_ll = mean(parrot_ll(:));
std_parrot_ll = std(parrot_ll(:));
mean_dog_ll = mean(dog_ll(:));
std_dog_ll = std(dog_ll(:));
parrot_tempy_all = reshape(parrot_ll,[1,...
    size(parrot_ll,1)*size(parrot_ll,2)]);
dog_tempy_all = reshape(dog_ll,[1,...
    size(dog_ll,1)*size(dog_ll,2)]);
tempx = ones(100,1);
parrot_tempy = zeros(size(tempx));
dog_tempy = zeros(size(tempx));
seg_parrot_len = length(parrot_tempy_all)/length(tempx);
seg_dog_len = length(dog_tempy_all)/length(tempx);
for k = 1:length(tempx)
    parrot_tempy(k) = mean(...
        parrot_tempy_all(...
        ((k-1)*seg_parrot_len+1):(k*seg_parrot_len)));
    dog_tempy(k) = mean(...
        dog_tempy_all(...
        ((k-1)*seg_dog_len+1):(k*seg_dog_len)));
end
hll = subplot('Position',[0.05,0.29,0.07,0.15]);
violinChart(hll,tempx,parrot_tempy,cbrewer2('Paired',1),v_width,bd);
hold on
violinChart(hll,tempx*2,dog_tempy,cbrewer2('Paired',1),v_width,bd);
hold on
plot(1,mean_parrot_ll,'o','MarkerFaceColor','w',...
    'MarkerEdgeColor','k')
hold on
plot(2,mean_dog_ll,'o','MarkerFaceColor','w',...
    'MarkerEdgeColor','k')
hold off
axis([0.5,2.5,0.2,1.4])
set(gca,'TickDir','out')
set(gca,'XTickLabel',{'Birds','Dogs'})
set(gca,'YTick',0.2:0.6:1.4)
ylabel('Tracking likelihoods')
%% reprojection error
bd = 3;
v_width = 0.3;
parrot_err = parrot_raw.err3d;
dog_err = dog_raw.err3d;
mean_parrot_err = mean(parrot_err(:));
std_parrot_err = std(parrot_err(:));
mean_dog_err = mean(dog_err(:));
std_dog_err = std(dog_err(:));
tempx = ones(100,1);
parrot_tempy = zeros(size(tempx));
dog_tempy = zeros(size(tempx));
seg_parrot_len = length(parrot_err)/length(tempx);
seg_dog_len = length(dog_err)/length(tempx);
for k = 1:length(tempx)
    parrot_tempy(k) = mean(...
        parrot_err(...
        ((k-1)*seg_parrot_len+1):(k*seg_parrot_len)));
    dog_tempy(k) = mean(...
        dog_err(...
        ((k-1)*seg_dog_len+1):(k*seg_dog_len)));
end
herr = subplot('Position',[0.17,0.29,0.07,0.15]);
violinChart(herr,tempx,parrot_tempy,cbrewer2('Paired',1),v_width,bd);
hold on
violinChart(herr,tempx*2,dog_tempy,cbrewer2('Paired',1),v_width,bd);
hold on
plot(1,mean_parrot_err,'o','MarkerFaceColor','w',...
    'MarkerEdgeColor','k')
hold on
plot(2,mean_dog_err,'o','MarkerFaceColor','w',...
    'MarkerEdgeColor','k')
hold off
axis([0.5,2.5,0,80])
set(gca,'TickDir','out')
set(gca,'XTickLabel',{'Birds','Dogs'})
% set(gca,'YTick',0.2:0.6:1.4)
ylabel('Reprojection error')
%% id precision (confusion matrix)
parrot_cm = double(parrot_eval.cm)./(sum(parrot_eval.cm,2)*ones(1,2));
dog_cm = double(dog_eval.cm)./(sum(dog_eval.cm,2)*ones(1,4));
dog_cm = dog_cm(1:2,1:2);
cmap = cbrewer2('Blues',10000);
cmap = cmap(1:size(cmap,1)/2,:);
hcm1 = subplot('Position',[0.05,0.17,0.07,0.07]);
imagesc(parrot_cm)
colormap(hcm1,cmap)
hold on
for m = 1:2
    for n = 1:2
        text(m-0.35,n,num2str(parrot_cm(m,n),'%.3f'),'FontSize',6)
        hold on
    end
end
hold off
box on
ylabel('Birds')
set(gca,'XTickLabel',{'B1','B2'})
set(gca,'YTickLabel',{'B1','B2'})
set(gca,'TickLength',[0,0])
title(...
    '                             Identity confusion matrix')
hcm2 = subplot('Position',[0.17,0.17,0.07,0.07]);
imagesc(dog_cm)
colormap(hcm2,cmap)
hold on
for m = 1:2
    for n = 1:2
        text(m-0.35,n,num2str(dog_cm(m,n),'%.3f'),'FontSize',6)
        hold on
    end
end
hold off
box on
ylabel('Dogs')
set(gca,'XTickLabel',{'D1','D2'})
set(gca,'YTickLabel',{'D1','D2'})
set(gca,'TickLength',[0,0])
% title(1)
%% behavior atlas quantify
feat_num = 100;
dist_mat_all = parrot_distmat.dist_mat_all;
all_labels = cell2mat(parrot_dsc.data_sample_cell(:,8));
[parrot_intra_cc_all_mat,parrot_inter_cc_all_mat] = ...
    intra_inter_cc(dist_mat_all,all_labels,feat_num);
dist_mat_all = dog_distmat.dist_mat_all;
all_labels = cell2mat(dog_dsc.data_sample_cell(:,8));
[dog_intra_cc_all_mat,dog_inter_cc_all_mat] = ...
    intra_inter_cc(dist_mat_all,all_labels,feat_num);
%%
parrot_intra_mean = mean(parrot_intra_cc_all_mat);
parrot_intra_median = median(parrot_intra_cc_all_mat);
parrot_intra_std = std(parrot_intra_cc_all_mat);
parrot_inter_mean = mean(parrot_inter_cc_all_mat);
parrot_inter_median = median(parrot_inter_cc_all_mat);
parrot_inter_std = std(parrot_inter_cc_all_mat);

stat_parrot_intra_cc_all_mat = parrot_intra_cc_all_mat';
stat_parrot_inter_cc_all_mat = parrot_inter_cc_all_mat';

dog_intra_mean = mean(dog_intra_cc_all_mat);
dog_intra_median = median(dog_intra_cc_all_mat);
dog_intra_std = std(dog_intra_cc_all_mat);
dog_inter_mean = mean(dog_inter_cc_all_mat);
dog_inter_median = median(dog_inter_cc_all_mat);
dog_inter_std = std(dog_inter_cc_all_mat);

stat_dog_intra_cc_all_mat = dog_intra_cc_all_mat';
stat_dog_inter_cc_all_mat = dog_inter_cc_all_mat';

hcc_parrot = subplot('Position',[0.3,0.33,0.66,0.1]);
bd = 0.2;
side_bias = 0.2;
for k = 1:size(parrot_intra_cc_all_mat,2)
    tempy = parrot_intra_cc_all_mat(:,k);
    tempx = (k-side_bias)*ones(length(tempy),1);
    violinChart(hcc_parrot,tempx,tempy,cbrewer2('Paired',1),0.15,bd);
    hold on
    plot(k-side_bias,parrot_intra_median(k),'o','MarkerFaceColor','w',...
        'MarkerEdgeColor','k','MarkerSize',2)
    hold on
    tempy = parrot_inter_cc_all_mat(:,k);
    tempx = (k+side_bias)*ones(length(tempy),1);
    violinChart(hcc_parrot,tempx,tempy,0.9*[1,1,1],0.15,bd);
    hold on
    plot(k+side_bias,parrot_inter_median(k),'o','MarkerFaceColor','w',...
        'MarkerEdgeColor','k','MarkerSize',2)
    hold on
end
hold off
ylabel({'Bird FC'})
set(gca,'XTick',1:size(cell2mat(parrot_dsc.data_sample_cell(:,8)),1))
% set(gca,'XTickLabel',new_unique_name)
box off
axis([0.3,34.7,-1.5,1.7])
set(gca,'TickDir','out')
set(gca,'XTickLabel',[])

parrot_all_labels = cell2mat(parrot_dsc.data_sample_cell(:,8));
parrot_unique_labels = unique(parrot_all_labels(:,1));
parrot_tempcmap = cbrewer2('Spectral',length(parrot_unique_labels));
dog_all_labels = cell2mat(dog_dsc.data_sample_cell(:,8));
dog_unique_labels = unique(dog_all_labels(:,1));
dog_tempcmap = cbrewer2('Spectral',length(dog_unique_labels));

subplot('Position',[0.3,0.31,0.66,0.01])
bar_w = 0.2;
line_w = 5;
for k = 1:size(parrot_tempcmap,1)
    plot([k-bar_w,k+bar_w],[1,1],'-','Color',parrot_tempcmap(k,:),...
        'LineWidth',line_w)
    hold on
end
hold off
axis([0.3,34.7,0,2])
axis off

hcc_dog = subplot('Position',[0.3,0.19,0.66,0.1]);
bd = 0.2;
side_bias = 0.2;
for k = 1:size(dog_intra_cc_all_mat,2)
    tempy = dog_intra_cc_all_mat(:,k);
    tempx = (k-side_bias)*ones(length(tempy),1);
    violinChart(hcc_parrot,tempx,tempy,cbrewer2('Paired',1),0.15,bd);
    hold on
    plot(k-side_bias,parrot_intra_median(k),'o','MarkerFaceColor','w',...
        'MarkerEdgeColor','k','MarkerSize',2)
    hold on
    tempy = dog_inter_cc_all_mat(:,k);
    tempx = (k+side_bias)*ones(length(tempy),1);
    violinChart(hcc_parrot,tempx,tempy,0.9*[1,1,1],0.15,bd);
    hold on
    plot(k+side_bias,parrot_inter_median(k),'o','MarkerFaceColor','w',...
        'MarkerEdgeColor','k','MarkerSize',2)
    hold on
end
hold off
ylabel({'Dog FC'})
set(gca,'XTick',1:size(cell2mat(parrot_dsc.data_sample_cell(:,8)),1))
% set(gca,'XTickLabel',new_unique_name)
box off
axis([0.3,15.7,-1.5,1.7])
set(gca,'TickDir','out')
set(gca,'XTickLabel',[])

subplot('Position',[0.3,0.17,0.66,0.01])
bar_w = 0.1;
line_w = 5;
for k = 1:size(dog_tempcmap,1)
    plot([k-bar_w,k+bar_w],[1,1],'-','Color',dog_tempcmap(k,:),...
        'LineWidth',line_w)
    hold on
end
hold off
axis([0.3,15.7,0,2])
axis off
%% CAM quantify
%% CAM calculation
feat_bird_mat = zeros(size(feat_bird_name,1),19);
feat_dog_mat = zeros(size(feat_dog_name,1),17);
tic
for k = 1:size(feat_bird_mat,1)
    tempcampath1 = feat_bird_name{k,1};
    tempcampath2 = feat_bird_name{k,2};
    tempcamname = feat_bird_name{k,3};
    tempcam = load([tempcampath1,'\',tempcampath2,'\',tempcamname]);
    tempcampos = load([tempcampath1,'\',tempcampath2,'\', ...
        tempcamname(1:(end-8)),'.mat']);
%     tempcamimg = imread([featpath_hr_img,'\',tempcampath2,'\', ...
%         tempcamname(1:(end-8)),'.jpg']);
    % quantify
    for m = 1:size(tempcampos.feat_pos,1)
        campart = reshape(tempcampos.feat_pos(m,:,:),...
            [size(tempcampos.feat_pos,2),size(tempcampos.feat_pos,3)]);
        all_meanselcam = 0;
        for n = 1:size(campart,1)
            % check campart
            box_s_x = campart(n,1);
            box_e_x = campart(n,2);
            box_s_y = campart(n,3);
            box_e_y = campart(n,4);
            if box_s_x < 1
                box_s_x = 1;
            end
            if box_s_y < 1
                box_s_y = 1;
            end
            if box_e_x < 1
                box_e_x = 1;
            end
            if box_e_y < 1
                box_e_y = 1;
            end
            if box_s_x > box_e_x
                box_s_x = box_e_x;
            end
            if box_s_y > box_e_y
                box_s_y = box_e_y;
            end
    
            selcam = tempcam.sum_cam(box_s_x:box_e_x,...
                box_s_y:box_e_y);
            meanselcam = mean(selcam(:));

            if isnan(meanselcam)
                meanselcam = 0;
                disp('NAN feature!')
            end

            all_meanselcam = all_meanselcam + meanselcam;
        end
        all_meanselcam = all_meanselcam/4;
        feat_bird_mat(k,m) = all_meanselcam;
    end    
    if rem(k,100) == 0
        disp(k)
        toc
    end
end
tic
for k = 1:size(feat_dog_mat,1)
    tempcampath1 = feat_dog_name{k,1};
    tempcampath2 = feat_dog_name{k,2};
    tempcamname = feat_dog_name{k,3};
    tempcam = load([tempcampath1,'\',tempcampath2,'\',tempcamname]);
    tempcampos = load([tempcampath1,'\',tempcampath2,'\', ...
        tempcamname(1:(end-8)),'.mat']);
%     tempcamimg = imread([featpath_hr_img,'\',tempcampath2,'\', ...
%         tempcamname(1:(end-8)),'.jpg']);
    % quantify
    for m = 1:size(tempcampos.feat_pos,1)
        campart = reshape(tempcampos.feat_pos(m,:,:),...
            [size(tempcampos.feat_pos,2),size(tempcampos.feat_pos,3)]);
        campart(campart==0) = 1;
        all_meanselcam = 0;
        for n = 1:size(campart,1)
            % check campart
            box_s_x = campart(n,1);
            box_e_x = campart(n,2);
            box_s_y = campart(n,3);
            box_e_y = campart(n,4);
            if box_s_x < 1
                box_s_x = 1;
            end
            if box_s_y < 1
                box_s_y = 1;
            end
            if box_e_x < 1
                box_e_x = 1;
            end
            if box_e_y < 1
                box_e_y = 1;
            end
            if box_s_x > box_e_x
                box_s_x = box_e_x;
            end
            if box_s_y > box_e_y
                box_s_y = box_e_y;
            end
            
            selcam = tempcam.sum_cam(box_s_x:box_e_x,...
                box_s_y:box_e_y);
            meanselcam = mean(selcam(:));

            if isnan(meanselcam)
                meanselcam = 0;
                disp('NAN feature!')
            end

            all_meanselcam = all_meanselcam + meanselcam;
        end
        all_meanselcam = all_meanselcam/4;
        feat_dog_mat(k,m) = all_meanselcam;
    end    
    if rem(k,100) == 0
        disp(k)
        toc
    end
end
%% CAM plot 
sel_len = 1:3600;
bin_time_win = 10;%s
fs = 30;
bin_frame_win = bin_time_win*fs;
sel_feat_bird_mat = feat_bird_mat(sel_len,:);
sel_feat_dog_mat = feat_dog_mat(sel_len,:);

new_len = length(sel_len(1):bin_frame_win:sel_len(end));
bin_feat_bird_mat = zeros(new_len,size(sel_feat_bird_mat,2));
bin_feat_dog_mat = zeros(new_len,size(sel_feat_dog_mat,2));

for k = 1:new_len
    bin_feat_bird_mat(k,:) = mean(sel_feat_bird_mat(...
        ((k-1)*bin_frame_win+1):(k*bin_frame_win),:));
    bin_feat_dog_mat(k,:) = mean(sel_feat_dog_mat(...
        ((k-1)*bin_frame_win+1):(k*bin_frame_win),:));
end


mean_feat_bird_mat = mean(bin_feat_bird_mat);
mean_feat_dog_mat = mean(bin_feat_dog_mat);
std_feat_bird_mat = std(bin_feat_bird_mat);
std_feat_dog_mat = std(bin_feat_dog_mat);
bird_body_name = {
'Beak'
'Calvaria'
'Left eye'
'Right eye'
'Neck'
'Left wing root'
'Left wing mid'
'Left wing tip'
'Right wing root'
'Right wing mid'
'Right wing tip'
'Left leg root'
'Left leg tip'
'Right leg root'
'Right leg tip'
'Back'
'Belly'
'Tail root'
'Tail tip'};
dog_body_name = {
'Nose'
'Left ear'
'Right ear'
'Neck'
'Left front limb'
'Left front paw'
'Right front limb'
'Right front paw'
'Left hind limb'
'Left hind paw'
'Right hind limb'
'Right hind paw'
'Front back'
'Mid back'
'Hind back'
'Tail root'
'Tail tip'};
cam_bird = subplot('Position',[0.05,0.03,0.43,0.12]);
bd = 0.3;
side_bias = 0.2;
for k = 1:size(mean_feat_bird_mat,2)
    tempy = mean_feat_bird_mat(:,k);
    bar(k,tempy,0.6,'FaceColor',cbrewer2('Paired',1))
    hold on
    plot(k*ones(1,size(bin_feat_bird_mat,1))+0.3,...
        bin_feat_bird_mat(:,k),'o','MarkerFaceColor','w',...
        'MarkerEdgeColor','k','MarkerSize',3)
    hold on
    errorbar(k,tempy,std_feat_bird_mat(:,k),'Color','k',...
        'CapSize',3)
    hold on
end
hold off
box off
axis([0.3,19.7,0,0.3])
set(gca,'TickDir','out')
set(gca,'XTick',1:length(bird_body_name))
set(gca,'XTickLabel',bird_body_name)
ylabel('Bird CAM')

subplot('Position',[0.53,0.03,0.43,0.12])
bd = 0.3;
side_bias = 0.2;
for k = 1:size(mean_feat_dog_mat,2)
    tempy = mean_feat_dog_mat(:,k);
    bar(k,tempy,0.6,'FaceColor',cbrewer2('Paired',1))
    hold on
    plot(k*ones(1,size(bin_feat_dog_mat,1))+0.3,...
        bin_feat_dog_mat(:,k),'o','MarkerFaceColor','w',...
        'MarkerEdgeColor','k','MarkerSize',3)
    hold on
    errorbar(k,tempy,std_feat_dog_mat(:,k),'Color','k',...
        'CapSize',3)
    hold on
end
hold off
box off
axis([0.3,17.7,0,0.4])
set(gca,'TickDir','out')
set(gca,'XTick',1:length(dog_body_name))
set(gca,'XTickLabel',dog_body_name)
ylabel('Bird CAM')
ylabel('Dog CAM')































