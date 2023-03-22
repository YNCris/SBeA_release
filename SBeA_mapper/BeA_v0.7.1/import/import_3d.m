function import_3d(data_3d_name)
% import the data from dlc
%
% Input
%   data_3d_name       -  path and name of csv file, 1 x 1 (string)
%
% Output
%   BeA                -  saving all data, 1 x 1 (struct)
%
% History
%   create  -  Yaning Han  (yn.han@siat.ac.cn), 03-02-2020
%   modify  -  Yaning Han  (yn.han@siat.ac.cn), 07-16-2020

global BeA

%% transform data_3d_name to path and name

for k = 1:size(data_3d_name,2)
    if data_3d_name(1,size(data_3d_name,2)-k+1) == '/'||data_3d_name(1,size(data_3d_name,2)-k+1) == '\'
        BeA.DataInfo.FileName = data_3d_name(1,(size(data_3d_name,2)-k+2):end);
        BeA.DataInfo.FilePath = data_3d_name(1,1:(size(data_3d_name,2)-k+1));
        break;
    end
end

%% import data
tempdata = importdata(data_3d_name);
tempdata = fillmissing(tempdata, 'linear');
BeA.RawData.X = tempdata(:,1:3:(end-2));
BeA.RawData.Y = tempdata(:,2:3:(end-1));
BeA.RawData.Z = tempdata(:,3:3:(end));

%% import skeleton
BeA.DataInfo.Skl = cell(size(BeA.RawData.X,2),1);
BeA.DataInfo.Skl{1,1} = 'nose';
BeA.DataInfo.Skl{2,1} = 'left_ear';
BeA.DataInfo.Skl{3,1} = 'right_ear';
BeA.DataInfo.Skl{4,1} = 'neck';
BeA.DataInfo.Skl{5,1} = 'left_front_limb';
BeA.DataInfo.Skl{6,1} = 'right_front_limb';
BeA.DataInfo.Skl{7,1} = 'left_hind_limb';
BeA.DataInfo.Skl{8,1} = 'right_hind_limb';
BeA.DataInfo.Skl{9,1} = 'left_front_claw';
BeA.DataInfo.Skl{10,1} = 'right_front_claw';
BeA.DataInfo.Skl{11,1} = 'left_hind_claw';
BeA.DataInfo.Skl{12,1} = 'right_hind_claw';
BeA.DataInfo.Skl{13,1} = 'back';
BeA.DataInfo.Skl{14,1} = 'root_tail';
BeA.DataInfo.Skl{15,1} = 'mid_tail';
BeA.DataInfo.Skl{16,1} = 'tip_tail';
%% indicate the data source
BeA.DataInfo.Source = '3D';


% BeA