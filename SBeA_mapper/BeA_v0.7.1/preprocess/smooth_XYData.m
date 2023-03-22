function smooth_XYData(SM)
% import the video
%
% Input
%   SM                 -  parameters for smoothing
%       Method         -  string, smoothing method, see 'help smooth'
%       Window         -  double, smoothing window time length
%       ErrCrit        -  double, err criteria
%
% Output
%   globel HBT
%
% History
%   create  -  Kang Huang  (kang.huang@siat.ac.cn), 03-02-2020

global HBT

% fs = HBT.DataInfo.VideoInfo.FrameRate;
fs = 30;

Method = SM.Method;
Window = SM.Window * fs;
ErrCrit = SM.ErrCrit;

X = HBT.PreproData.X;
Y = HBT.PreproData.Y;

nDim = size(X, 2);

for i = 1:nDim
    [smX(:, i), ~] = smooth_XYadapt(X(:, i), Method, Window, ErrCrit);
    [smY(:, i), ~] = smooth_XYadapt(Y(:, i), Method, Window, ErrCrit);
end

HBT.PreproData.X = smX;
HBT.PreproData.Y = smY;