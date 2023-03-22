function import_video(video_name)
% import the video
%
% Input
%   video_name         -  path and name of video, 1 x 1 (string)
%
% Output
%   BeA                -  , saving all data, 1 x 1 (struct)
%
% History
%   create  -  Yaning Han  (yn.han@siat.ac.cn), 03-02-2020
%   modify  -  Yaning Han  (yn.han@siat.ac.cn), 07-16-2020

global BeA

%% transform video_name to path and name
for k = 1:size(video_name,2)
	if video_name(1,size(video_name,2)-k+1) == '/'||video_name(1,size(video_name,2)-k+1) == '\'
		BeA.DataInfo.VideoName = video_name(1,(size(video_name,2)-k+2):end);
		BeA.DataInfo.VideoPath = video_name(1,1:(size(video_name,2)-k+1));
		break;
	end
end

%% import video info
BeA.DataInfo.VideoInfo = VideoReader(video_name);

