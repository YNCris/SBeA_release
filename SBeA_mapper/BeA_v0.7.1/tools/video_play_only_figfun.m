function video_play_only_figfun(handles)
global HBT video_key
  downsamp = 8;
  vidobj = HBT.DataInfo.VideoInfo;
  fs = HBT.DataInfo.VideoInfo.FrameRate;
  tt = HBT.DataInfo.VideoInfo.Duration;
  frame = read(vidobj, 1);
  [yl, xl, ~] = size(frame);
 while video_key.nowframe<round(tt*fs)
     switch video_key.status
         case 1
         frame = read(vidobj,video_key.nowframe);
         axes(handles.axes2)
         video_key.nowframe=round(get(handles.slider1,'value'));
         video_key.nowframe=video_key.nowframe+downsamp;
         if  video_key.nowframe>=(round(tt*fs)-downsamp)
             video_key.status=3;
         end
         set(handles.slider1,'value',min(video_key.nowframe,tt*fs))
         set(handles.time_start,'string',datestr(seconds(HBT.DataInfo.VideoInfo.Duration*video_key.nowframe/round(tt*fs)),'HH:MM:SS.FFF'))
         imshow(frame);
         case 2
           video_key.nowframe=video_key.nowframe;
                         break;
         case 3
              set(handles.slider1,'value',1,'enable','off');
              video_key.nowframe=1;
              set(handles.time_start,'string',datestr(seconds(0),'HH:MM:SS.FFF'))
              frame = read(vidobj,video_key.nowframe);
              imshow(frame);
              break;
     end
 end


