%{
    1. multi-3d to single 3d
    seperate videos include skeleton and names
    colors represent different groups of mice
%}
clear all
close all
genPath = genpath('./');
addpath(genPath)
%% Set path
id_3d_path = ['Z:\hanyaning\multi_mice_test\Social_analysis' ...
    '\data\shank3_wt\sbea_data_20221108'];
savepath = [id_3d_path,'\BeA_path'];
mkdir(savepath)
%% define group id
groups = {
    {'M1','M2','M3','M4','M5'};
    {'M6','M7','M8','M9','M10'}};
% groups = {'B1';
%     'B2'};
group_color_cmap = cbrewer2('Set2',size(groups,1));
%% set parameters
selcamidx = 0;
%% process
%% load 3d names
fileFolder = fullfile(id_3d_path);
dirOutput = dir(fullfile(fileFolder,'*-id3d.mat'));
file3dNames = {dirOutput.name}';
%% seperate data
for k = 1:size(file3dNames,1)
    %% load data
    tempname = file3dNames{k,1}(1,1:(end-9));
    tempiddata = load([id_3d_path,'\',file3dNames{k,1}]);
    temppairdata = load([id_3d_path,'\',tempname,'-raw3d.mat']);
    dirOutput = dir(fullfile(id_3d_path,'\temp\*.csv'));
    csvNames = {dirOutput.name}';
    %% load video
    videoname = [file3dNames{k,1}(1,1:(end-9)),'-camera-',...
        num2str(selcamidx),'.avi'];
    vidobj = VideoReader([id_3d_path,'\',videoname]);
    %% 
    dataname = cellstr(tempiddata.name3d);
    data3d = tempiddata.coords3d;
    datalen = size(data3d,2)/length(dataname);
    datapair = temppairdata.pair3d;
    %% search csv
    csvrootname = cellfun(@(x) x(1:(length(videoname)-4)),...
        csvNames,'UniformOutput',false);
    selidx = strcmp(csvrootname,videoname(1:(end-4)));
    selcsvnames = csvNames(selidx);
    %% load 2D data
    data2d_cell = cell(size(selcsvnames));
    for m = 1:length(selcsvnames)
        temp2ddata = importdata([id_3d_path,'\temp\',selcsvnames{m}]);
        tempdata = temp2ddata.data;
        tempdata(:,1) = [];
        tempdata(:,3:3:end) = [];
        data2d_cell{m,1} = tempdata;
    end
    %% load id list
    tempdata = readtable([id_3d_path,'\',tempname,'-corrpredid.csv']);
    idlist = table2cell(tempdata);
    idlist = idlist(2:end,:);
    %% output 3d data
    for m = 1:length(dataname)
        tempdataname = dataname{m};
        coords3d = data3d(:,((m-1)*datalen+1):(m*datalen));
        outdataname = [tempdataname,'-',file3dNames{k,1}(1,1:(end-9)),'.mat'];
        save([savepath,'\',outdataname],'coords3d')
        disp(outdataname)    
    end
    disp(k)
end
%% seperate videos
parfor k = 1:size(file3dNames,1)
    %% load data
    tempname = file3dNames{k,1}(1,1:(end-9));
    tempiddata = load([id_3d_path,'\',file3dNames{k,1}]);
    temppairdata = load([id_3d_path,'\',tempname,'-raw3d.mat']);
    dirOutput = dir(fullfile(id_3d_path,'\temp\*.csv'));
    csvNames = {dirOutput.name}';
    %% load video
    videoname = [file3dNames{k,1}(1,1:(end-9)),'-camera-',...
        num2str(selcamidx),'.avi'];
    vidobj = VideoReader([id_3d_path,'\',videoname]);
    %% 
    dataname = cellstr(tempiddata.name3d);
    data3d = tempiddata.coords3d;
    datalen = size(data3d,2)/length(dataname);
    datapair = temppairdata.pair3d;
    %% search csv
    csvrootname = cellfun(@(x) x(1:(length(videoname)-4)),...
        csvNames,'UniformOutput',false);
    selidx = strcmp(csvrootname,videoname(1:(end-4)));
    selcsvnames = csvNames(selidx);
    %% load 2D data
    data2d_cell = cell(size(selcsvnames));
    for m = 1:length(selcsvnames)
        temp2ddata = importdata([id_3d_path,'\temp\',selcsvnames{m}]);
        tempdata = temp2ddata.data;
        tempdata(:,1) = [];
        tempdata(:,3:3:end) = [];
        data2d_cell{m,1} = tempdata;
    end
    %% load id list
    tempdata = readtable([id_3d_path,'\',tempname,'-corrpredid.csv']);
    idlist = table2cell(tempdata);
    idlist = idlist(2:end,:);
    %% reid 2d points
    new_data_2d_cell = cell(vidobj.NumFrames,length(dataname));
    for m = 1:size(new_data_2d_cell,1)
        %% load id data
        tempdatapair = datapair(m,:,:,:);
        tempdatapair = reshape(tempdatapair,...
            [size(tempdatapair,2),...
            size(tempdatapair,3),...
            size(tempdatapair,4)]);
        framepair_cell = cell(size(dataname));
        for n = 1:length(framepair_cell)
            framepair_cell{n} = reshape(tempdatapair(n,:,:),[4,2]);
            framepair_cell{n} = sortrows(framepair_cell{n},1);
            framepair_cell{n} = ...
                framepair_cell{n}(selcamidx==framepair_cell{n}(:,1),2)+1;
        end
        for n = 1:size(new_data_2d_cell,2)
            new_data_2d_cell{m,n} = data2d_cell{framepair_cell{n}}(m,:);
        end
    end
    %% generate boxes
    new_box_2d_cell = new_data_2d_cell;
    for m = 1:size(new_box_2d_cell,1)
        for n = 1:size(new_box_2d_cell,2)
            tempx = new_data_2d_cell{m,n}(1:2:end);
            tempy = new_data_2d_cell{m,n}(2:2:end);
            box_x = min(tempx);
            box_y = min(tempy);
            box_width = max(tempx)-box_x;
            box_height = max(tempy)-box_y;
            new_box_2d_cell{m,n} = [box_x,box_y,box_width,box_height];
        end
    end
    %% create color_cell
    color_cell = cell(size(idlist));
    for m = 1:size(color_cell,1)
        for n = 1:size(color_cell,2)
            tempid = idlist(m,n);
            for p = 1:size(groups,1)
                tempgroupname = groups{p};
                selidx = sum(strcmp(tempid,tempgroupname));
                if selidx == 1
                    color_cell{m,n} = 255*group_color_cmap(p,:);
                end
            end
        end
    end
    %% create writeobj
    writeobj_cell = cell(size(dataname));
    for m = 1:length(dataname)
        tempdataname = dataname{m};
        outdataname = [tempdataname,'-',file3dNames{k,1}(1,1:(end-9)),'.avi'];
        writeobj_cell{m,1} = VideoWriter([savepath,'\',outdataname]);
        open(writeobj_cell{m,1})
    end
    %% output labeled videos
    for m = 1:size(new_data_2d_cell,1)
        %% load raw frame
        frame = read(vidobj,m);
        % plot dots
        tempboxes = new_box_2d_cell(m,:);
        temp2ddata = new_data_2d_cell(m,:);
        tempid = idlist(m,:);
        tempcolor = color_cell(m,:);
        for n = 1:length(temp2ddata)
            frame = insertMarker(frame,...
                [temp2ddata{n}(1:2:end)',temp2ddata{n}(2:2:end)'],...
                'o',...
                'Color',tempcolor{n});
            frame = insertShape(frame,'rectangle',tempboxes{n},...
                'Color',tempcolor{n},'LineWidth',3);
            frame = ....
                insertText(frame,tempboxes{n}(1:2),...
                tempid{n},'AnchorPoint','LeftBottom',...
                'TextColor',tempcolor{n},...
                'FontSize',30,'BoxOpacity',0);
        end
        for n = 1:length(writeobj_cell)
            writeVideo(writeobj_cell{n},frame)
        end
    end
    for m = 1:size(writeobj_cell,1)
        close(writeobj_cell{m,1})
    end
    disp(k)
end
























