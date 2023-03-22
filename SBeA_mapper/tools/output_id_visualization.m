%{
    output id visualization
%}
clear all
close all
addpath('codegen')
addpath('function')
addpath('MatlabAPI')
%% set path
rootpath = ['Z:\hanyaning\multi_mice_test\' ...
    'Social_analysis\data\shank3_wt\sbea_data_20221108'];
savevideopath = ['Z:\hanyaning\multi_mice_test\' ...
    'Social_analysis\data\shank3_wt\sbea_data_20221108'];
%% load name list
fileFolder = fullfile(rootpath);
dirOutput = dir(fullfile(fileFolder,'*caliParas.mat'));
calinamelist = {dirOutput.name}';
cam_num = 4;
mouse_num = 2;
dlc_name = 'DLC_resnet50_tm20Sep5shuffle1_1030000';
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
    tempsavename = [savevideopath,'\',tempname,'_visual.avi'];
    
    writeobj = VideoWriter(tempsavename);
    open(writeobj)


    % 3d skl filter
    xy_range = 1500;
    axis_range = [...
        sklcenter_x-xy_range,sklcenter_x+xy_range,...
        sklcenter_y-xy_range,sklcenter_y+xy_range,...
        sklcenter_z-900,sklcenter_z+1700];

    
    coords3d = new3d.coords3d;
    for m = 1:size(coords3d,2)
        coords3d(:,m) = medfilt1(coords3d(:,m),30);
    end
    % save results
    mousename = cellstr(new3d.name3d);

    setcolor = cbrewer2('Spectral',11);
    mouse1_c = setcolor(3,:);
    mouse2_c = setcolor(9,:);
    mouseclr = [mouse1_c;mouse2_c];
%     mouseclr = [1,0,0;0,0,1];

%     startframe = 1;
%     endframe = 27000;
%     subnum = 5;
%     tempsavepath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
%         'disc1_shank3\demo_results'];
%     tempsavename = [tempsavepath,'\a1a2_2100_4000.avi'];
%     writeobj = VideoWriter(tempsavename);
%     open(writeobj)


    h1 = figure(k);
    set(h1,'Position',[100,100,1280,720])
    set(h1,'color','white');


    for m = 1:1:datalen
        %%
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
            %% prepare 3d skl
    %         tempskl = raw3d.coords3d(m,:);
            tempskl = coords3d(m,:);
            data1 = tempskl(:,1:(size(tempskl,2)/2));
            data2 = tempskl(:,(1+(size(tempskl,2)/2)):end);
            X1 = data1(:,1:3:end)';
            Y1 = data1(:,2:3:end)';
            Z1 = data1(:,3:3:end)';
            X2 = data2(:,1:3:end)';
            Y2 = data2(:,2:3:end)';
            Z2 = data2(:,3:3:end)';
    
    %         mousename1 = frameid{1};
    %         mousename2 = frameid{2};
    
            mousename2 = mousename{2,1};
            mousename1 = mousename{1,1};% fix by tricks!!!! be careful!!!
            %% draw canvas
            % frame+box+pose+id+seg
            subplot('Position',[0.01,0.55,0.3,0.4])
            imshow(show_frame_list{1})
            title('camera 1')
            subplot('Position',[0.01,0.05,0.3,0.4])
            imshow(show_frame_list{3})
            title('camera 3')
            subplot('Position',[0.32,0.55,0.3,0.4])
            imshow(show_frame_list{2})
            title('camera 2')
            subplot('Position',[0.32,0.05,0.3,0.4])
            imshow(show_frame_list{4})
            title('camera 4')
            
            % id
            boxsize = [200,400];
            
            if strcmp(frameid{1},mousename1)
                subplot('Position',[0.65,0.86,0.1,0.08])
                imshow(imresize(id_frame_list{1,1},boxsize))
                title(frameid{1},'Color',mouseclr(strcmp(mousename,frameid{1}),:))
                ylabel('c1','position',[-0.13 boxsize(1)/2])
                subplot('Position',[0.65,0.76,0.1,0.08])
                imshow(imresize(id_frame_list{2,1},boxsize))
                ylabel('c2','position',[-0.13 boxsize(1)/2])
                subplot('Position',[0.65,0.66,0.1,0.08])
                imshow(imresize(id_frame_list{3,1},boxsize))
                ylabel('c3','position',[-0.13 boxsize(1)/2])
                subplot('Position',[0.65,0.56,0.1,0.08])
                imshow(imresize(id_frame_list{4,1},boxsize))
                ylabel('c4','position',[-0.13 boxsize(1)/2])
            else
                subplot('Position',[0.65,0.36,0.1,0.08])
                imshow(imresize(id_frame_list{1,1},boxsize))
                title(frameid{1},'Color',mouseclr(strcmp(mousename,frameid{1}),:))
                ylabel('c1','position',[-0.13 boxsize(1)/2])
                subplot('Position',[0.65,0.26,0.1,0.08])
                imshow(imresize(id_frame_list{2,1},boxsize))
                ylabel('c2','position',[-0.13 boxsize(1)/2])
                subplot('Position',[0.65,0.16,0.1,0.08])
                imshow(imresize(id_frame_list{3,1},boxsize))
                ylabel('c3','position',[-0.13 boxsize(1)/2])
                subplot('Position',[0.65,0.06,0.1,0.08])
                imshow(imresize(id_frame_list{4,1},boxsize))
                ylabel('c4','position',[-0.13 boxsize(1)/2])
            end
            
            if strcmp(frameid{2},mousename2)
                subplot('Position',[0.65,0.36,0.1,0.08])
                imshow(imresize(id_frame_list{1,2},boxsize))
                title(frameid{2},'Color',mouseclr(strcmp(mousename,frameid{2}),:))
                ylabel('c1','position',[-0.13 boxsize(1)/2])
                subplot('Position',[0.65,0.26,0.1,0.08])
                imshow(imresize(id_frame_list{2,2},boxsize))
                ylabel('c2','position',[-0.13 boxsize(1)/2])
                subplot('Position',[0.65,0.16,0.1,0.08])
                imshow(imresize(id_frame_list{3,2},boxsize))
                ylabel('c3','position',[-0.13 boxsize(1)/2])
                subplot('Position',[0.65,0.06,0.1,0.08])
                imshow(imresize(id_frame_list{4,2},boxsize))
                ylabel('c4','position',[-0.13 boxsize(1)/2])
            else
                subplot('Position',[0.65,0.86,0.1,0.08])
                imshow(imresize(id_frame_list{1,2},boxsize))
                title(frameid{2},'Color',mouseclr(strcmp(mousename,frameid{2}),:))
                ylabel('c1','position',[-0.13 boxsize(1)/2])
                subplot('Position',[0.65,0.76,0.1,0.08])
                imshow(imresize(id_frame_list{2,2},boxsize))
                ylabel('c2','position',[-0.13 boxsize(1)/2])
                subplot('Position',[0.65,0.66,0.1,0.08])
                imshow(imresize(id_frame_list{3,2},boxsize))
                ylabel('c3','position',[-0.13 boxsize(1)/2])
                subplot('Position',[0.65,0.56,0.1,0.08])
                imshow(imresize(id_frame_list{4,2},boxsize))
                ylabel('c4','position',[-0.13 boxsize(1)/2])
            end
    
    
    
            subplot('Position',[0.78,0.55,0.2,0.4])
            plot_skl_dog(X1,Y1,Z1,...
                mouseclr(strcmp(mousename,mousename1),:),...
                mouseclr(strcmp(mousename,mousename1),:))
            hold on
            plot_skl_dog(X2,Y2,Z2,...
                mouseclr(strcmp(mousename,mousename2),:),...
                mouseclr(strcmp(mousename,mousename2),:))
            hold off
            title(['3D skeletons, frame idx: ', num2str(m)])
            grid on
            axis(axis_range)
            axis square
            set(gca,'XTickLabel',[])
            set(gca,'YTickLabel',[])
            set(gca,'ZTickLabel',[])
            xlabel('x')
            ylabel('y')
            zlabel('z')
            
            subplot('Position',[0.78,0.05,0.2,0.4])
            plot_skl_dog(X1,Y1,Z1,...
                mouseclr(strcmp(mousename,mousename1),:),...
                mouseclr(strcmp(mousename,mousename1),:))
            hold on
            plot_skl_dog(X2,Y2,Z2,...
                mouseclr(strcmp(mousename,mousename2),:),...
                mouseclr(strcmp(mousename,mousename2),:))
            hold off
            title(['2D views, reproj err: ',num2str(temperr(m,:))])
            grid on
            axis(axis_range)
            axis square
            view(2)
            set(gca,'XTickLabel',[])
            set(gca,'YTickLabel',[])
            set(gca,'ZTickLabel',[])
            xlabel('x')
            ylabel('y')
            zlabel('z')
            pause(0.00000001)
    
            %% write frames
            showframe = getframe(h1);
            writeVideo(writeobj,showframe.cdata)
        catch
            disp('error frame')
            disp(m)
        end
    end
        close(writeobj)
end






























