function video_play_with_data_figfun(handles)
global HBT video_key
try
    vidobj = HBT.DataInfo.VideoInfo;
    fs = HBT.DataInfo.VideoInfo.FrameRate;
catch
    fs=1;
end
try
    cut_offset = HBT.PreproInfo.CutData.Start * fs;
catch
    cut_offset = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%
startframe = (1/fs)*fs;
endframe =size(HBT.RawData.X, 1);
downsamp = 8;
ampR = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_len = size(HBT.RawData.X, 1);
nDim = size(HBT.RawData.X, 2);
timeLine = linspace(0, data_len/fs, data_len);
% raw XY data
raw_data = [HBT.RawData.X, HBT.RawData.Y];
% subtract mean value of each trace
ms_data = zeros(data_len, 2*nDim);
ms_data(:, 1:nDim) = HBT.RawData.X - mean(HBT.RawData.X);
ms_data(:, nDim+1:end) = HBT.RawData.Y - mean(HBT.RawData.Y);
zsdata = zscore(ms_data(:,:), [], 2) * ampR;
data_show = (zsdata(:,:) + double([1:2:nDim*2, 2:2:nDim*2]))';
% get body parts names
bodyPart_name = HBT.DataInfo.Skl;
% panel position

axes(handles.axes1)
hold on
clr = jet(size(data_show, 1)/2);
for li = 1:size(data_show, 1)/2
    for lii = 1:2
        plot(timeLine, data_show(li+(2-lii)*nDim, :)', 'Color', clr(li, :), 'LineWidth', 1);
    end
end
events_key=str2num(get(handles.events_text,'string'));
ylabel_str=cell(size(HBT.DataInfo.Skl,1)*2,1);
i=1;
for j=1:1:size(HBT.DataInfo.Skl,1)
    ylabel_str{i}=[HBT.DataInfo.Skl{j},'_X'];
    ylabel_str{i+1}=[HBT.DataInfo.Skl{j},'_Y'];
    i=i+2;
end
set(gca, 'Color', [0.9 0.9 0.9], 'YLim', [-3*ampR, size(data_show, 1)+5*ampR], ...
    'xtick',[], 'XColor', 'none', 'FontSize', 6,'YTick',linspace(0,size(data_show, 1),size(HBT.DataInfo.Skl,1)*2),'YTickLabel',ylabel_str)
hh= plot([0/fs 0/fs], [-2, size(data_show, 1)+2], '--k');
if events_key  
    for i=1:1:events_key
    patch([HBT.Exp_Info.Event(i).Start,HBT.Exp_Info.Event(i).Stop,HBT.Exp_Info.Event(i).Stop,HBT.Exp_Info.Event(i).Start], [-3*ampR,-3*ampR,size(data_show, 1)+3*ampR,size(data_show, 1)+3*ampR], [0.5 0.5 0.5]);
    alpha(0.5) 
    text((HBT.Exp_Info.Event(i).Start+HBT.Exp_Info.Event(i).Stop)/2,size(data_show, 1)+4*ampR,HBT.Exp_Info.Event(i).Name,'FontSize',8,'HorizontalAlignment','center','Color','red')
    end
end
hold off
try
    frame = read(vidobj, 1);
    [yl, xl, ~] = size(frame);
catch
end
while video_key.nowframe<endframe
     showVideo=get(handles.radiobutton1,'value');
     showBodyFeat=get(handles.radiobutton2,'value');
     auto_zoom=get(handles.radiobutton3,'value');
     showRange(1)=str2num(get(handles.left_cut,'string'));
     showRange(2)=str2num(get(handles.right_cut,'string'));
     video_key.showVideo=showVideo; 
     video_key.showBodyFeat=showBodyFeat;
     video_key.auto_zoom=auto_zoom;
     video_key.showRange=showRange;
    switch video_key.status
        case 1
            if video_key.showVideo
                frame = read(vidobj, video_key.nowframe+cut_offset);
                axes(handles.axes2)
                video_key.nowframe=round(get(handles.slider1,'value'));
                video_key.nowframe=video_key.nowframe+downsamp;
                if  video_key.nowframe>=(round(data_len)-downsamp)
                    video_key.status=3;
                end
                set(handles.slider1,'value',min(video_key.nowframe,data_len))
                set(handles.time_start,'string',datestr(seconds(HBT.DataInfo.VideoInfo.Duration*video_key.nowframe/round(data_len)),'HH:MM:SS.FFF'))
                set(handles.text15,'string',datestr(seconds(HBT.DataInfo.VideoInfo.Duration*video_key.nowframe/round(data_len)),'HH:MM:SS.FFF'))
                imshow(frame)
                if video_key.showBodyFeat
                    hold on
                end
            end
            if video_key.showBodyFeat
                axes(handles.axes2)
                plot_skeleton_figfun(raw_data, video_key.nowframe+cut_offset, '.', 10, clr, bodyPart_name, video_key.auto_zoom,handles)
                set(gca,'color', 'black')
                if ~video_key.showVideo
                    axis([0, xl, 0, yl])
                    set(gca,'color', 'black', 'YDir', 'reverse')
                end
            end
            video_key.nowframe=video_key.nowframe+downsamp;
            axes(handles.axes1)
            xlim([(video_key.nowframe-1)/fs+video_key.showRange(1), (video_key.nowframe-1)/fs+video_key.showRange(2)])
            set(hh, 'XData', [video_key.nowframe/fs, video_key.nowframe/fs])
            hold off
        case 2
            video_key.nowframe=video_key.nowframe;
                          break;
        case 3
            set(handles.slider1,'value',1,'enable','off');
            video_key.nowframe=1;
            set(handles.time_start,'string',datestr(seconds(0),'HH:MM:SS.FFF'))
            axes(handles.axes2)
            frame = read(vidobj,video_key.nowframe);
            imshow(frame);
            axes(handles.axes1)
            xlim([1, timeLine(end)])

            break;
    end
end

