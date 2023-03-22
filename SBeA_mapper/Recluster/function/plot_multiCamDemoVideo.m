function plot_multiCamDemoVideo(mutiCam_videoPath, dataName, saveVideo_name)


writerObj = VideoWriter([saveVideo_name, '.mp4'], 'MPEG-4');
writerObj.FrameRate = 6;
open(writerObj);


load(dataName)
video_names = dir([mutiCam_videoPath, '*.avi']);
video_names = {video_names.name};

video_obj_1 = VideoReader([mutiCam_videoPath, video_names{1}]);
video_obj_2 = VideoReader([mutiCam_videoPath, video_names{2}]);
video_obj_3 = VideoReader([mutiCam_videoPath, video_names{3}]);
video_obj_4 = VideoReader([mutiCam_videoPath, video_names{4}]);

nfeatures = size(coords3d, 2)/3;
%0 : skeleton will not be drawn, Eg : [ 1 2; 2 3;], draws lines between features 1 and 2, 2 and 3
drawline = [ 1 2; 1 3;2 3; 4 5;4 6;5 7;6 8;7 14;8 14;...
    5 9;7 11;6 10; 8 12;14 15; 15 16];

%setting maximum and minimum of axis of visualization
xvals = coords3d(:,1:3:nfeatures*3,1);
yvals = coords3d(:,2:3:nfeatures*3,1);
zvals = coords3d(:,3:3:nfeatures*3,1);



disp('Loading your video data.')

figure1 = figure('units','normalized','OuterPosition',[0.3 0.3 0.3 0.35]);
colorclass = colormap(jet); %jet is default in DLC
color_map_self=colorclass(ceil(linspace(1,64,nfeatures)),:);

offset = 355; % need to be measured between frame and body parts coord
iFrame = 1;

for iFrame = 1:5:1800
    % camera1
    ha(1) = axes('Parent',figure1,'Position',[0.01 0.51 0.29 0.45]);
%     cla;
    frame1 = read(video_obj_1,iFrame);
    imagesc(frame1,'Parent', ha(1)); hold on;
    text(20, 25, 'Camera1', 'Color', 'w', 'FontSize', 14); hold off
    set(ha(1),'xtick',[],'ytick',[],'ztick',[]); axis off
    
    % camera2
    ha(3) = axes('Parent',figure1,'Position',[0.31 0.51 0.29 0.45]);
% 	cla;
    frame2 = read(video_obj_2,iFrame);
    imagesc(frame2,'Parent', ha(3));hold on;
    text(20, 25, 'Camera2', 'Color', 'w', 'FontSize', 14); hold off
    set(ha(3),'xtick',[],'ytick',[],'ztick',[]); axis off
    
    % camera3
    ha(5) = axes('Parent',figure1,'Position',[0.01 0.04 0.29 0.45]);
%     cla;
    frame3 = read(video_obj_3,iFrame);
    imagesc(frame3,'Parent', ha(5));hold on;
    text(20, 25, 'Camera3', 'Color', 'w', 'FontSize', 14); hold off
    set(ha(5),'xtick',[],'ytick',[],'ztick',[]); axis off
    
    % camera4
    ha(7) = axes('Parent',figure1,'Position',[0.31 0.04 0.29 0.45]);
%     cla;
    frame4 = read(video_obj_4,iFrame);
    imagesc(frame4,'Parent', ha(7));hold on;
    text(20, 25, 'Camera4', 'Color', 'w', 'FontSize', 14); hold off
    set(ha(7),'xtick',[],'ytick',[],'ztick',[]); axis off
    
    % 3d skeleton
    
    ha(8) = axes('Parent',figure1,'Position',[0.63 0.20 0.35 0.60]);
    mesh_mouse(coords3d, iFrame)
    
    temp = reshape(coords3d(iFrame,:,1),3,nfeatures);
    scatter3(temp(1,:),temp(2,:),temp(3,:),80*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', ha(8));
    hold on;
    
    for l = 1:size(drawline,1)
        pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
        line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1.5,'Parent', ha(8))
    end
    
    xmax = coords3d(iFrame, 37) + 120; xmin = coords3d(iFrame, 37) - 120;
    ymax = coords3d(iFrame, 38) + 120; ymin = coords3d(iFrame, 38) - 120;
    zmax = coords3d(iFrame, 39) + 90; zmin = coords3d(iFrame, 39) - 90;
    
    
    
    hold off ;
    set(ha(8),'xlim',[xmin xmax],'ylim',[ymin ymax],'zlim',[zmin zmax], 'TickLength',[0.01, 0.01]) ;
    set(ha(8),'view',[-70,25], 'xticklabel',{[]},'yticklabel',{[]},'zticklabel',{[]});
    
    drawnow;
    
    disp(iFrame)
    
    f = getframe(figure1);
    writeVideo(writerObj, f.cdata);
    clf;
    
end

disp('end')
close(writerObj);
