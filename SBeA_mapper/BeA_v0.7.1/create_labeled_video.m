%{
    DLC不好用的时�?�用这个生成标记的视�?
%}
clear all
close all
%% 设置路径
filepath = 'Z:\hanyaning\mulldling_data_analysis\liuhaoyi_analysis\raw_data\20221130\20221130';
%% 获取视频和CSV
videoFolder = fullfile(filepath);
dirOutput = dir(fullfile(videoFolder,'*avi'));
videoNames = {dirOutput.name}';
DLC_file = 'DLC_resnet50_fstNov14shuffle1_1030000.csv';
%% 生成标记视频
for k = 5%1:size(videoNames,1)
    %% 读取视频
    vidobj = VideoReader([filepath,'\',videoNames{k,1}]);
    %% 读取对应CSV
    tempdata = importdata([filepath,'\',videoNames{k,1}(1,(1:(end-4))),DLC_file]);
    %% 数据处理
    csvdata = tempdata.data;
    csvdata(:,1:3:end) = [];
    lldata = tempdata.data(:,1:3:end);
    lldata(:,1) = [];
    mean_lldata = mean(lldata,2);
    cmap = imresize(colormap('jet'),[(size(csvdata,2)/2),3]); 
    %% 设置保存视频
%     writeobj = VideoWriter([filepath,'\',videoNames{k,1}(1,1:(end-4)),...
%         DLC_file(1,1:(end-4)),'_labeled_new.mp4']);
%     writeobj.FrameRate = vidobj.FrameRate;
%     open(writeobj)
    %% 临时显示
    for m = 1:size(csvdata,1)
        %%
        frame = read(vidobj,m);
        %% 
        temppos = csvdata(m,:);
        showpos = [temppos(1:2:(end-1))',temppos(2:2:end)'];
        %%
        markframe = insertMarker(frame,showpos,'o','Size',4,'Color',uint8(255*cmap));
        markframe = insertMarker(markframe,showpos,'*','Size',2,'Color',uint8(255*cmap));
        imshow(markframe)
        title(mean_lldata(m))
        
        
%         pause(0.0000001)
        %% 显示
%         imshow(markframe)
        %% 保存视频�?
%          writeVideo(writeobj,markframe);
    end
%     close(writeobj)
    disp(k)
end
