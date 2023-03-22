function decomposing_viewer(showVideo, showBodyFeat, showRange, auto_zoom)

% viewer of bahavior decomposition
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
startframe = round((1/fs)*fs); endframe = 200*fs;
downsamp = 12;
ampR = 0.5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%

data_len = size(HBT.RawData.X, 1);
nDim = size(HBT.RawData.X, 2);
timeLine = linspace(0, data_len/fs, data_len);
DP_sR = 1:data_len+1;

% raw XY data
raw_data = [HBT.RawData.X, HBT.RawData.Y];

% subtract mean value of each trace
data_show = HBT.HBT_DecData.XY';
data_show = (ampR*data_show(:,:)/40 + double(1:1:size(data_show,2)))';

% ms_data = zeros(data_len, 2*nDim);
% ms_data(:, 1:nDim) = HBT.RawData.X - mean(HBT.RawData.X);
% ms_data(:, nDim+1:end) = HBT.RawData.Y - mean(HBT.RawData.Y);
% 
% zsdata = zscore(ms_data(:,:), [], 2) * ampR;
% data_show = (zsdata(:,:) + double([1:2:nDim*2, 2:2:nDim*2]))';

% get body parts names
bodyPart_name = HBT.DataInfo.Skl;

% panel position
pos = {[0.04 0.40 0.42 0.56], [0.48 0.40 0.50 0.56],...
    [0.48 0.12 0.50 0.08], [0.48 0.26 0.50 0.08]};


figure(1)
clr = cbrewer2('Spectral', nDim);
set(gcf, 'Position', [250, 300, 1550, 600])

% plot body traces
subplot('Position', pos{2});
hold on
for li = 1:size(data_show, 1)/2
    for lii = 1:2
%         plot(timeLine, data_show(li+(2-lii)*nDim, :)', 'Color', clr(li, :), 'LineWidth', 1);
        plot(timeLine, data_show((li-1)*2 + lii, :)', 'Color', clr(li, :), 'LineWidth', 1);
    end
end
set(gca, 'Color', [0.9 0.9 0.9], 'YLim', [-2*ampR, size(data_show, 1)+2*ampR], ...
    'xtick',[], 'XColor', 'none', 'YColor', 'none', 'FontSize', 12)
plt2 = plot([0/fs 0/fs], [-2, size(data_show, 1)+2], '--k');
hold off

% plot behavior layers
subplot('Position',pos{3});
plotSegBar(HBT.HBT_DecData.L1.MedData, DP_sR, fs, startframe, endframe)
colormap(gca, clr)
set(gca, 'ytick',[], 'FontSize', 16, 'TickDir', 'out', 'TickLength',[0, 0], 'LineWidth', 2, 'Box', 'off')
xlabel('Time (s)')
hold on
plt3 = plot([0/fs 0/fs], [0 1], '--k');
hold off

subplot('Position',pos{4});
plotSegBar(HBT.HBT_DecData.L2.reClusData, DP_sR, fs, startframe, endframe)
colormap(gca, clr)
set(gca, 'ytick',[], 'xtick',[], 'FontSize', 16, 'TickDir', 'out', 'TickLength',[0, 0], 'LineWidth', 2, 'Box', 'off')
hold on
plt4 = plot([0/fs 0/fs], [0 1], '--k');
hold off
% axis off


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
    
    
    subplot('Position', pos{3});
    xlim([(fi-1)/fs+showRange(1), (fi-1)/fs+showRange(2)])
    set(plt3, 'XData', [fi/fs, fi/fs])
    
    subplot('Position', pos{4});
    xlim([(fi-1)/fs+showRange(1), (fi-1)/fs+showRange(2)])
    set(plt4, 'XData', [fi/fs, fi/fs])

    
    drawnow
    toc
end