function cut_data(CutData)
% cut needed data
%
% Input
%   CutData            -  parameters of cut data, 1 x 1 (struct)
%       Start          -  start position of cutting data, second
%       End            -  end position of cutting data, second
%
% Output
%   global HBT
%
% History
%   create  -  Yaning Han  (yn.han@siat.ac.cn), 03-02-2020

global HBT

% fs = HBT.DataInfo.VideoInfo.FrameRate;
fs = 30;

cut_data_start = round(CutData.Start * fs);
cut_data_end = round(CutData.End * fs);
cut_data_X = HBT.PreproData.X;
cut_data_Y = HBT.PreproData.Y;


%% cut data
save_cut_data_X = cut_data_X(cut_data_start:cut_data_end,:);
save_cut_data_Y = cut_data_Y(cut_data_start:cut_data_end,:);
save_noise = ones(size(cut_data_X));
save_noise(cut_data_start:cut_data_end,:) = 0;

HBT.PreproInfo.CutData = CutData;
HBT.PreproData.X = save_cut_data_X;
HBT.PreproData.Y = save_cut_data_Y;
HBT.PreproData.ND = save_noise;



