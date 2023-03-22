%{
    create 3d datasets of body parts
%}
clear all
% close all
%% set path
rootpath = 'Z:\hanyaning\multi_mice_test\Social_analysis\data\disc1_shank3\SBeA_id_data_20220602';
filename = 'rec10-B5-20220601';
%% load data
videonamelist = cell(4,1);
csvnamelist = cell(4,1);
jsonnamelist = cell(4,1);
raw3dname = [filename,'-raw3d.mat'];
caliname = [filename,'-caliParas.mat'];
for k = 1:4
    videonamelist{k,1} = [filename,'-camera-',num2str(k-1),'.avi'];
    csvnamelist{k,1} = [filename,'-camera-',num2str(k-1),...
        'DLC_resnet50_shank3resolution1kMay24shuffle1_1030000.csv'];
    jsonnamelist{k,1} = [filename,'-camera-',num2str(k-1),'-rawresult.json'];
end

videolist = cell(4,1);
csvlist = cell(4,1);
jsonlist = cell(4,1);

sel_data_idx = [5,6,8,9];
for k = 1:4
    vidobj = VideoReader([rootpath,'\',videonamelist{k,1}]);
    videolist{k,1} = vidobj;

    [csvdata,csvtitle] = xlsread([rootpath,'\',csvnamelist{k,1}]);
    csvlist{k,1} = csvdata(:,sel_data_idx);

    tempjson = loadjson([rootpath,'\',jsonnamelist{k,1}]);
    jsonlist{k,1} = tempjson;
end

load([rootpath,'\',raw3dname])
load([rootpath,'\',caliname])

sel_data3d_idx = [4,5,6,7,8,9];
raw3d = coords3d(:,sel_data3d_idx);
%% DCT process
frameidx = 1000;

frame_cell = cell(4,1);
csv_cell = cell(4,1);
mask_cell = cell(4,1);

pos3d = raw3d(frameidx,:);

for m = 1:4
    frame = read(videolist{m,1},frameidx);
    frame_cell{m,1} = frame;
    pos = csvlist{m,1}(frameidx,:);
    csv_cell{m,1} = pos;
    temprle = jsonlist{m,1}.annotations.segmentations(:,frameidx);
    mask1 = MaskApi.decode(temprle(1));
    mask2 = MaskApi.decode(temprle(2));
    rawmask = mask1 & mask2;
    mask_cell{m,1}= rawmask;
end

sel_frame_list = cell(4,2);
box_size = 30;

for m = 1:4
    tempframe = frame_cell{m,1};
%     imshow(tempframe)
    for n = 1:2
        cetpos = csv_cell{m,1}(1,((n-1)*2+1):(n*2));
        startx = round(cetpos(1,1) - box_size/2);
        starty = round(cetpos(1,2) - box_size/2);
        endx = round(cetpos(1,1) + box_size/2);
        endy = round(cetpos(1,2) + box_size/2);
        cropframe = tempframe(starty:endy,startx:endx);
        sel_frame_list{m,n} = cropframe;
    end
end

% DCT
res_list = cellfun(@(x) imresize(x,[256,256]),sel_frame_list,'UniformOutput',false);

DCT_list = cellfun(@(x) dct2(double(x)),res_list,'UniformOutput',false);


% temp show
% for m = 1:4
%     for n = 1:2
%         imagesc(log(DCT_list{m,n}))
%     end
% end
% sum
all_dct_list = zeros(256,256);
for m = 1:4
    for n = 1:2
        all_dct_list = all_dct_list + DCT_list{m,n};
    end
end

all_dct_list = all_dct_list/8;

all_raw_list = zeros(256,256);
for m = 1:4
    for n = 1:2
        all_raw_list = all_raw_list + double(res_list{m,n});
    end
end
all_raw_list = all_raw_list/8;

figure
subplot(121)
imagesc(log(all_dct_list))
axis square
subplot(122)
imshow(all_raw_list,[])
title(frameidx)

%%
idct_frame = idct2(all_dct_list);







































