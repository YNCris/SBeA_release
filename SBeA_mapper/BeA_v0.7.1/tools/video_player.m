function video_player(showVideo, showBodyFeat, showRange, auto_zoom)

% player video and body tracks
%
% Input
%   showVideo       -  bool, whether to show video
%   showBodyFeat    -  bool, whether to show body tracks
%   showRange       -  1x2 vector, define the time interval of body tracks showing
%   auto_zoom       -  bool, whether to auto zoom frame
%
% History
%   create  -  Kang Huang  (kang.huang@siat.ac.cn), 03-02-2020

global HBT

vidobj = HBT.DataInfo.VideoInfo;
% numFrames = round(vidobj.Duration.*vidobj.FrameRate);
fs = HBT.DataInfo.VideoInfo.FrameRate;
try
    cut_offset = HBT.PreproInfo.CutData.Start * fs;
catch
    cut_offset = 0;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%
startframe = round((1/fs)*fs); endframe = 600*fs;
downsamp = 5;
ampR = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%

data_len = size(HBT.RawData.X, 1);
nDim = size(HBT.RawData.X, 2);
timeLine = linspace(0, data_len/fs, data_len);

% raw XY data

if isfield(HBT, 'PreproData')
    raw_data = [HBT.PreproData.X, HBT.PreproData.Y];
%     raw_data = [HBT.HBT_DecData.XY(1:2:end, :); HBT.HBT_DecData.XY(2:2:end, :)]';
else
    raw_data = [HBT.RawData.X, HBT.RawData.Y];
end

% subtract mean value of each trace
ms_data = zeros(data_len, 2*nDim);
if isfield(HBT, 'PreproData')
    ms_data(:, 1:nDim) = HBT.PreproData.X - mean(HBT.PreproData.X);
    ms_data(:, nDim+1:end) = HBT.PreproData.Y - mean(HBT.PreproData.Y);
else
    ms_data(:, 1:nDim) = HBT.RawData.X - mean(HBT.RawData.X);
    ms_data(:, nDim+1:end) = HBT.RawData.Y - mean(HBT.RawData.Y);
end

zsdata = zscore(ms_data(:,:), [], 2) * ampR;
data_show = (zsdata(:,:) + double([1:2:nDim*2, 2:2:nDim*2]))';

% get body parts names
bodyPart_name = HBT.DataInfo.Skl;

% panel position
pos = {[0.04 0.1 0.42 0.8], [0.48 0.1 0.50 0.8]};

figure(1)
clr = cbrewer2('Spectral', nDim);
set(gcf, 'Position', [250, 300, 1200, 400])

subplot('Position', pos{2});
hold on
for li = 1:size(data_show, 1)/2
    for lii = 1:2
        plot(timeLine, data_show(li+(2-lii)*nDim, :)', 'Color', clr(li, :), 'LineWidth', 1);
    end
end
% set(gca, 'Color', [0.9 0.9 0.9], 'YLim', [-3*ampR, size(data_show, 1)+3*ampR], ...
%     'xtick',[], 'XColor', 'none', 'YColor', 'none', 'FontSize', 12)
set(gca, 'Color', [0.9 0.9 0.9], 'YLim', [-3*ampR, size(data_show, 1)+3*ampR], ...
    'YColor', 'none', 'FontSize', 12)

plt2 = plot([0/fs 0/fs], [-2, size(data_show, 1)+2], '--k');
hold off

%%
% writerObj = VideoWriter('/Users/huangkang/Desktop/temp/20191231文章初稿/manualscript/summary/20200312行为瞳孔分析总结/DLCTrackDemo.mp4', 'MPEG-4');
% writerObj.FrameRate = 6;
% open(writerObj);
%%


% plot loop
frame = read(vidobj, 1);
[yl, xl, ~] = size(frame);

tic
h1 = figure(1);
for fi = startframe:downsamp:endframe
    
    subplot('Position', pos{1});
    if showVideo
        frame = read(vidobj, fi+cut_offset);
        imshow(frame)
        if showBodyFeat
            hold on
        end
    end
    
    if showBodyFeat
        plot_skeleton(raw_data, fi+cut_offset, '.', 10, clr, bodyPart_name, auto_zoom)
        set(gca,'color', 'black')
        
        if ~showVideo
            axis([0, xl, 0, yl])
            set(gca,'color', 'black', 'YDir', 'reverse')
        end
    end
    
    title(['Time Lapse: ', num2str(round(round(1000*(fi-1)/fs, 2)/1000, 0)), 's'])
    
    subplot('Position', pos{2});
    xlim([(fi-1)/fs+showRange(1), (fi-1)/fs+showRange(2)])
    set(plt2, 'XData', [fi/fs, fi/fs])
    
%     f = getframe(h1);
%     writeVideo(writerObj, f.cdata);
    
    drawnow
    toc
end


% close(writerObj);











