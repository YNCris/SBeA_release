function body_alignment(BA)
% animal body skeleton alignment
%
% Input
%   BA    -  body alignment parameters, 1 x 1 (struct)
%       - BA.Cen                - the flag of centering skeleton
%       - BA.VA                 - the flag of skeleton vector align
%       - BA.CenIndex           - the index of center point
%       - BA.VAIndex            - the index of vector point
%   data_dim      -  2d data or 3d data, you can input 2 or 3, 1 x 1(int)
%
% Output
%   global BeA.PreproData 
%
% History
%   create  -  Yaning Han  (yn.han@siat.ac.cn), 03-04-2020
%   modify  -  Yaning Han  (yn.han@siat.ac.cn), 07-16-2020

global BeA

%% varible connection--read

cenflag = BA.Cen;
VAflag = BA.VA;
CenIndex = BA.CenIndex;
VAIndex = BA.VAIndex;
SDSize = BA.SDSize;
SDSDimens = BA.SDSDimens;
BA_X = BeA.PreproData.X';
BA_Y = BeA.PreproData.Y';
BA_Z = BeA.PreproData.Z';

%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% varible re-assignment


raw_XY = [];
for k = 1:size(BA_X,1)
    raw_XY = [raw_XY;BA_X(k,:);BA_Y(k,:)];	
end


%% body alignment
if cenflag == 1 && VAflag ~=1
    mean_X = mean(raw_XY(1:2:(end-1),:));
    mean_Y = mean(raw_XY(2:2:end,:));
    white_XY = raw_XY;
    white_XY(1:2:(end-1),:) = white_XY(1:2:(end-1),:)-mean_X;
    white_XY(2:2:end,:) = white_XY(2:2:end,:)-mean_Y;
    back_X = white_XY((CenIndex*2-1),:);
    back_Y = white_XY((CenIndex*2),:);
    back_XY = white_XY;
    back_XY(1:2:(end-1),:) = back_XY(1:2:(end-1),:)-back_X;
    back_XY(2:2:end,:) = back_XY(2:2:end,:)-back_Y;
    out_XY = back_XY;
elseif cenflag == 1 && VAflag == 1
    mean_X = mean(raw_XY(1:2:(end-1),:));
    mean_Y = mean(raw_XY(2:2:end,:));
    white_XY = raw_XY;
    white_XY(1:2:(end-1),:) = white_XY(1:2:(end-1),:)-mean_X;
    white_XY(2:2:end,:) = white_XY(2:2:end,:)-mean_Y;
    back_X = white_XY((CenIndex*2-1),:);
    back_Y = white_XY((CenIndex*2),:);
    back_XY = white_XY;
    back_XY(1:2:(end-1),:) = back_XY(1:2:(end-1),:)-back_X;
    back_XY(2:2:end,:) = back_XY(2:2:end,:)-back_Y;
    root_tail_X = back_XY((VAIndex*2-1),:);
    root_tail_Y = back_XY((VAIndex*2),:);
    rot_alpha = -atan2(root_tail_Y,root_tail_X);
    rot_XY = zeros(size(back_XY));
    for m = 1:size(rot_alpha,2)
        rot_mat = [cos(rot_alpha(1,m)),sin(rot_alpha(1,m)),0;...
                    -1*sin(rot_alpha(1,m)),cos(rot_alpha(1,m)),0;...
                    0,0,1];
        temp_rot = ...
            [back_XY(1:2:(end-1),m),back_XY(2:2:end,m),ones(size(rot_XY,1)/2,1)]*rot_mat;
        rot_XY(1:2:(end-1),m) = temp_rot(:,1);
        rot_XY(2:2:end,m) = temp_rot(:,2);
    end
    out_XY = rot_XY;
else
    out_XY = raw_XY;
    newinfo = 'without alignment';
    addMes2log(1, newinfo, 0, 1, 0, 0, 0)
end

mean_Z = mean(BA_Z);
white_Z = BA_Z;
white_Z = white_Z-mean_Z;
out_XYZ = [];
for k = 1:size(BA_Z,1)
    out_XYZ = [out_XYZ;out_XY(k*2-1:k*2,:);white_Z(k,:)];	
end

%% body size correction
temp_XYZ = out_XYZ;
body_size = (temp_XYZ(SDSDimens(1,1),:).^2+temp_XYZ(SDSDimens(1,2),:).^2+temp_XYZ(SDSDimens(1,3),:).^2).^0.5;
median_index = median(body_size);
corr_prop = SDSize./median_index;
out_XYZ = temp_XYZ*corr_prop;

%% varible connection--write

BeA.BeA_DecParam.BA = BA;
BeA.BeA_DecData.XYZ = out_XYZ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
