%{
    output id visualization
%}
clear all
close all
addpath('codegen')
addpath('function')
addpath('MatlabAPI')
%% set path
rootpath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'hcl_bird\sbea_data_20220919'];
savevideopath = rootpath;
%% load name list
fileFolder = fullfile(rootpath);
dirOutput = dir(fullfile(fileFolder,'*caliParas.mat'));
calinamelist = {dirOutput.name}';
cam_num = 4;
mouse_num = 2;
dlc_name = 'DLC_resnet50_dlcbirdOct7shuffle1_680000';
%% process
for k = 1:size(calinamelist,1)
    %% load one name
    tempname = calinamelist{k,1}(1,1:(end-14));
    %%
    
    videonamelist = {};
    jsonnamelist = {};
    csvnamelist = cell(cam_num,mouse_num);
    for m = 1:cam_num
        videonamelist = [videonamelist;...
            [tempname,'-camera-',num2str(m-1),'.avi']];
        jsonnamelist = [jsonnamelist;...
            [tempname,'-camera-',num2str(m-1),'-correctedresult.json']];
        for n = 1:mouse_num
            csvnamelist{m,n} = ...
                [tempname,'-camera-',num2str(m-1),...
                '-masked-',num2str(n-1),dlc_name,'.csv'];
        end
    end

    raw3dname = [tempname,'-raw3d.mat'];
    id3dname = [tempname,'-corrpredid.csv'];
    new3dname = [tempname,'-id3d.mat'];
    rot3dname = [tempname,'-rot3d.mat'];

    %%  load data
    vidobj_list = cell(size(videonamelist));
    jsonlist = cell(size(jsonnamelist));
    for m = 1:cam_num
        vidobj_list{m,1} = VideoReader([rootpath,'\',videonamelist{m,1}]);
        jsonlist{m,1} = loadjson([rootpath,'\',jsonnamelist{m,1}]);
        disp(m)
    end

    csvlist = cell(size(csvnamelist));
    for m = 1:size(csvlist,1)
        for n = 1:size(csvlist,2)
            [NUM,TXT,RAW] = xlsread(...
                [rootpath,'\temp\',csvnamelist{m,n}]);
            csvlist{m,n} = NUM;
            csvlist{m,n}(:,1:3:end) = [];
        end
    end
    
    raw3d = load([rootpath,'\',raw3dname]);
    new3d = load([rootpath,'\',new3dname]);
    rot3d = load([rootpath,'\',rot3dname]);

    [NUM,TXT,RAW] = xlsread([rootpath,'\',id3dname]);
    id2d = TXT;
    
    datalen = size(raw3d.coords3d,1);

    temppair = raw3d.pair3d;
    temperr = raw3d.err3d;

    sklcenter = mean(new3d.coords3d,1);
    sklcenter_x = mean(sklcenter(1:3:end));
    sklcenter_y = mean(sklcenter(2:3:end));
    sklcenter_z = mean(sklcenter(3:3:end));

    

    %% output to videos
    savevidobj_list = cell(size(vidobj_list));
    for m = 1:size(vidobj_list,1)
        tempsavename = [savevideopath,'\',...
            vidobj_list{m}.Name(1,1:(end-4)),'_labeled.avi'];
        savevidobj_list{m} = VideoWriter(tempsavename);
        open(savevidobj_list{m})
    end

    % save results
    mousename = cellstr(new3d.name3d);
    mouseclr = [1,0,0;0,0,1];


    for m = 1:1:datalen
        try
            %% read frames
            framelist = cell(size(vidobj_list));
            for n = 1:size(framelist,1)
                framelist{n,1} = read(vidobj_list{n,1},m);
            end
            
            %% read masks
            masklist = cell(size(jsonlist,1),2);
            for n = 1:size(masklist,1)
                temprle = jsonlist{n,1}.annotations.segmentations(:,m);
                mask1 = MaskApi.decode(temprle(1));
                mask2 = MaskApi.decode(temprle(2));
                masklist{n,1} = mask1;
                masklist{n,2} = mask2;
            end
            
            %% read 2d poses
            poslist = cell(size(csvlist));
            for p = 1:size(csvlist,1)
                for q = 1:size(csvlist,2)
                    poslist{p,q} = csvlist{p,q}(m,:);
                end
            end
            %% read id
            frameid = id2d(m,:);
            
            %% read frame pairs
            framepair = reshape(temppair(m,:,:,:),[2,4,2]);
            framepair_cell = {1,2};
            for n = 1:2
                framepair_cell{1,n} = reshape(framepair(n,:,:),[4,2]);
                framepair_cell{1,n} = sortrows(framepair_cell{1,n},1);
            end
    
            framepair_list = zeros(4,2);
            for n = 1:2
                framepair_list(:,n) = framepair_cell{1,n}(:,2)+1;
            end
    
            %% pair all pairs
            pair_poslist = cell(size(poslist));
            pair_masklist = cell(size(masklist));
            
            for n = 1:size(pair_poslist,1)
                pair_poslist(n,:) = poslist(n,framepair_list(n,:));
                pair_masklist(n,:) = masklist(n,framepair_list(n,:));
            end
            %% create one frame
            show_frame_list = cell(size(framelist));
            id_frame_list = cell(size(pair_masklist));
            for n = 1:size(show_frame_list,1)
                %%
                tempframe = framelist{n,1};
                tempmasklist = pair_masklist(n,:);
                tempposlist = pair_poslist(n,:);
                % create box list
                tempboxlist = cell(size(tempmasklist));
                for p = 1:mouse_num
                    tempmask = tempmasklist{1,p};
                    [x,y] = find(tempmask==1);
                    tempboxlist{1,p} = [min(y),min(x),...
                        max(y)-min(y),max(x)-min(x)];
                end
                % add masks
                for p = 1:mouse_num
                    tempframe = labeloverlay(tempframe,tempmasklist{1,p},...
                        'Colormap',mouseclr(strcmp(mousename,frameid{1,p}),:));
                end
                % add boxes and names
                for p = 1:mouse_num
                    tempframe = insertShape(tempframe,'Rectangle',...
                        tempboxlist{1,p},...
                        'Color',255*mouseclr(strcmp(mousename,frameid{1,p}),:),'LineWidth',5);
                    tempframe = insertText(tempframe,tempboxlist{1,p}(1,1:2)-6,...
                        frameid{1,p},'AnchorPoint','LeftBottom',...
                        'TextColor',255*mouseclr(strcmp(mousename,frameid{1,p}),:),...
                        'FontSize',20);
                end
    
                % add poses
                for p = 1:mouse_num
                    showpos = [tempposlist{1,p}(1:2:end)',tempposlist{1,p}(2:2:end)'];
                    tempframe = insertMarker(tempframe,showpos,'o','Size',4,'Color','yellow');
                    tempframe = insertMarker(tempframe,showpos,'*','Size',4,'Color','yellow');
                end
                
                % create id frames
                for p = 1:mouse_num
                    start_y = tempboxlist{1,p}(1,1);
                    start_x = tempboxlist{1,p}(1,2);
                    end_y = start_y + tempboxlist{1,p}(1,3);
                    end_x = start_x + tempboxlist{1,p}(1,4);             
                    id_frame_list{n,p} = framelist{n,1}(start_x:end_x,start_y:end_y,:);
                end
    
                show_frame_list{n,1} = tempframe;
    %             figure(5)
    %             imshow(tempframe)
            end
            %% write frames
            for n = 1:size(savevidobj_list,1)
                writeVideo(savevidobj_list{n},show_frame_list{n})
            end
            disp(m)
        catch
            % catch error frames with black frame
            errframe = uint8(zeros(vidobj_list{1}.Height,...
                vidobj_list{1}.Width,3));
            for n = 1:size(savevidobj_list,1)
                writeVideo(savevidobj_list{n},errframe)
            end
            disp(m)
        end
    end
    % close writeobj
    for n = 1:size(savevidobj_list,1)
        close(savevidobj_list{n})
    end
end






























