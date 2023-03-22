%{
    create 3d datasets of body parts
%}
clear all
close all
%% set path
rootpath = 'Z:\hanyaning\multi_mice_test\Social_analysis\data\disc1_shank3\SBeA_id_data_20220602';
filename = 'rec1-K1-20220523';
%%  load data
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
%% process
frameidx = 1;

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

cell_3d = cell(2,1);

numCams = 4;
cam_mat = caliParams.cam_mat_all;

% calculate center reprojection

points = zeros(2,4);
for m = 1:4
    points(:,m) = csv_cell{m,1}(1,1:2);
end

for m = 1:2
    %
    A = zeros(numCams * 2, 4);

    for i = 1:numCams    
        idx = 2 * i;
        A(idx-1:idx,:) = points(:, i) * cam_mat(3,:,i) - cam_mat(1:2,:,i);
    end

    [~,~,V] = svd(A);
    X = V(:, end);
    X = X/X(end);
    X = X(1:3);


    reprojErr = nan(1,numCams);
    for i = 1:numCams  
      reprojPoint = cam_mat(:,:,i)*[X; 1];
      reprojPoint = reprojPoint/reprojPoint(end);
      reprojErr(i) = norm(points(:, i) - reprojPoint(1:2));
    end



    temp3d = pos3d(:,((m-1)*3+1):(m*3));
    
    X = temp3d';

    reprojPoint = nan(numCams,2);
    reprojErr = nan(1,numCams);
    for i = 1:numCams  
      tempreprojPoint = cam_mat(:,:,i)*[X; 1];
      tempreprojPoint = tempreprojPoint/tempreprojPoint(end);
      reprojPoint(i,:) = tempreprojPoint(1:2)';
      reprojErr(i) = norm(points(:, i) - reprojPoint(1:2));
    end


    cell_3d{m,1} = reprojPoint;
end

%% temp show
for m = 1:4
    subplot(2,2,m)
    imshow(frame_cell{4,1})
    hold on
    plot(cell_3d{1,1}(m,1),cell_3d{1,1}(m,2),'ro')
    hold on
    plot(cell_3d{2,1}(m,1),cell_3d{2,1}(m,2),'go')
    hold off
end


for m = 1:4
    subplot(2,2,m)
    imshow(frame_cell{m,1})
    hold on
    plot(csv_cell{m,1}(1,1),csv_cell{m,1}(1,2),'ro')
    hold on
    plot(csv_cell{m,1}(1,3),csv_cell{m,1}(1,4),'go')
    hold off
end


plotstr = 'k';
linestr = 'r';
X = coords3d(1,1:3:end)';
Y = coords3d(1,2:3:end)';
Z = coords3d(1,3:3:end)';
plot_skl(X,Y,Z,plotstr,linestr)





















