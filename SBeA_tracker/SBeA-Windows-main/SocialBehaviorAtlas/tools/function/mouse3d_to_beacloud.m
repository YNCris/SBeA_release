%{
    mouse3d格式转beacloud
%}
clear all
close all
%% 设置路径
% mouse3dpath = '/home/yaninghan/sbeaTestEnv/trainvideopath/videos2/mouse_3d';
mouse3dpath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'disc1_shank3\raw_data\Data_for_20220523\calibrationimages_20220523_2'];
savepath = [mouse3dpath,'/caliParas.mat'];
%% 读取标定文件
mouse3d_cell = cell(3,1);
for k = 1:3
    tempdata = load([mouse3dpath,'/CalibSessionFiles/PrimarySecondary',...
        num2str(k),'/calibrationSession.mat']);
    mouse3d_cell{k,1} = tempdata.calibrationSession;
end
%% 转换格式
camera_cell = cell(4,1);
cb_cell = cell(4,1);
camera_cell{1,1} = mouse3d_cell{1,1}.CameraParameters.CameraParameters1;
camera_cell{2,1} = mouse3d_cell{1,1}.CameraParameters.CameraParameters2;
camera_cell{3,1} = mouse3d_cell{2,1}.CameraParameters.CameraParameters2;
camera_cell{4,1} = mouse3d_cell{3,1}.CameraParameters.CameraParameters2;
cb_cell{1,1} = mouse3d_cell{1,1}.PatternSet.FullPathNames(1,:);
cb_cell{2,1} = mouse3d_cell{1,1}.PatternSet.FullPathNames(2,:);
cb_cell{3,1} = mouse3d_cell{2,1}.PatternSet.FullPathNames(2,:);
cb_cell{4,1} = mouse3d_cell{3,1}.PatternSet.FullPathNames(2,:);
%% 提取共享棋盘格
cb_short_cell = cell(4,1);
for k = 1:size(cb_short_cell,1)
    tempcb = cb_cell{k,1};
    tempnewcb = cell(size(tempcb));
    for m = 1:size(tempcb,2)
        splcb = strsplit(tempcb{1,m},'\');
        tempnewcb{1,m} = splcb{end};
    end
    cb_short_cell{k,1} = tempnewcb;
end
allframecell = cell(50,1);
for k = 1:size(allframecell,1)
    allframecell{k,1} = ['frame',num2str(k),'.png'];
end
equal_mat = zeros(size(allframecell,1),4);
for k = 1:size(cb_short_cell,1)
    tempcb = cb_short_cell{k,1};
    for m = 1:size(tempcb,2)
        for n = 1:size(allframecell,1)
            if strcmp(tempcb{1,m},allframecell{n,1}) == 1
                equal_mat(n,k) = 1;
            end
        end
    end
end
mean_equal_mat = mean(equal_mat,2);
%% 根据mean_equal_mat设置棋盘格号
frameidx = 2;
framestr = ['frame',num2str(frameidx),'.png'];
cb_idx_cell = cell(4,1);
for k = 1:size(cb_idx_cell,1)
    tempidxlist = zeros(size(cb_short_cell{k,1}));
    for m = 1:size(cb_short_cell{k,1},2)
        if strcmp(cb_short_cell{k,1}{1,m},framestr) == 1
            tempidxlist(1,m) = 1;
        end
    end
    cb_idx_cell{k,1} = tempidxlist;
end
%% 转换格式
caliParams.single_cam_mat = cell(4,1);
caliParams.single_rotation = cell(4,1);
caliParams.single_translation = cell(4,1);
for k = 1:size(camera_cell,1)
    caliParams.single_cam_mat{k,1} = camera_cell{k,1}.IntrinsicMatrix;
    caliParams.single_rotation{k,1} = camera_cell{k,1}.RotationMatrices(:,:,cb_idx_cell{k,1}==1);
    caliParams.single_translation{k,1} = camera_cell{k,1}.TranslationVectors(cb_idx_cell{k,1}==1,:);
end
% show camera pose
cam_size = 50;
show_cam_pose(caliParams,cam_size)
hold on
% uncalibrated camera pose calculation
for k = 1:size(caliParams.single_rotation,1)
    if isempty(caliParams.single_rotation{k,1}) == 1
        if k == 1
            disp('please select successful calibration checkboard frameidx of camera 1!')
        else
            stereo_param = mouse3d_cell{k-1,1}.CameraParameters;
            R12 = stereo_param.RotationOfCamera2;
            T12 = stereo_param.TranslationOfCamera2;
            R1 = caliParams.single_rotation{1,1};
            T1 = caliParams.single_translation{1,1};
            R2 = R1*R12;
            T2 = (T1-R2/R12);
            T2 = T2(1,:)';
            caliParams.single_rotation{k,1} = R2;
            caliParams.single_translation{k,1} = T2';
        end
    end
end

% show camera pose
cam_size = 50;
hold on
show_cam_pose(caliParams,cam_size)
title('reletive')
hold off
%% 存储重建姿态结构
ncams = 4;
stereoParams = cell(ncams-1,1);
cam_mat_all = nan(3,4,ncams);
for icams = 1:ncams-1 % since calibration is done pairwise, primary camera parameters need not be loaded separately
    %'Loading the stereoCalib file for primary and secondary camera #' num2str(i)
    load([mouse3dpath,'/CalibSessionFiles/PrimarySecondary',...
        num2str(icams),'/calibrationSession.mat']);
    stereoParams = calibrationSession.CameraParameters;
    cam_mat =[stereoParams.RotationOfCamera2; stereoParams.TranslationOfCamera2]*stereoParams.CameraParameters2.IntrinsicMatrix; %setting secondary camera characteristics
    cam_mat_all(:,:,icams) = cam_mat';
    if icams == ncams-1
        cam_mat = [eye(3); [0 0 0]]*stereoParams.CameraParameters1.IntrinsicMatrix;
        cam_mat_all(:,:,icams+1) = cam_mat';
        %Loading 2d data csv folder from DLC for primary camera
    end
end
load([mouse3dpath,'/CalibSessionFiles/PrimarySecondary',...
        num2str(1),'/calibrationSession.mat']);
rotation = calibrationSession.CameraParameters.CameraParameters1.RotationMatrices(:,:,cb_idx_cell{1,1}==1);
translation = calibrationSession.CameraParameters.CameraParameters1.TranslationVectors(cb_idx_cell{1,1}==1,:);
caliParams.cam_mat_all = cam_mat_all;
caliParams.rotation = {rotation};
caliParams.translation = {translation};
%% 保存
save(savepath,'caliParams');
disp('保存完成！')







































