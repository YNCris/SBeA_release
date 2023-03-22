% function fig2_panel_12(rootpath,mouse1_c,mouse2_c)
res_par = 1;
sel_frame_id = 4620;
z_s = -30;
z_e = 100;
camnum = 4;
res_len = 500;
caliparamname = [rootpath,'\panel_12\temp\rec7-R1K3-20220531-caliParas.mat'];
caliparam = load(caliparamname);
x_s_cell = cell(camnum,2);
x_e_cell = cell(camnum,2);
y_s_cell = cell(camnum,2);
y_e_cell = cell(camnum,2);
z_s_cell = cell(camnum,2);
z_e_cell = cell(camnum,2);
frames_cell = cell(camnum,2);
masks_cell = cell(camnum,2);
framesize = [1288,964];
[X,Y] = meshgrid(1:framesize(1),1:framesize(2));
XY = [reshape(X-framesize(1)/2,[],1),reshape(Y-framesize(2)/2,[],1)];
campos_frame = [XY,0*ones(size(XY,1),1)]';
campos_mask = [XY,-100*ones(size(XY,1),1)]';
tic
for camidx = 1:camnum
    %%
    E0 = caliparam.caliParams.single_cam_mat{camidx,1};
    R0 = caliparam.caliParams.single_rotation{camidx,1};
    T0 = caliparam.caliParams.single_translation{camidx,1};
    %%
    jsonname = [rootpath,'\panel_12\temp\',num2str(camidx),'.json'];
    jsontext = fileread(jsonname);
    jsonvalue = jsondecode(jsontext);
    %%
    img_anno_1 = jsonvalue.annotations.segmentations(sel_frame_id,1);
    img_anno_2 = jsonvalue.annotations.segmentations(sel_frame_id,2);
    reid_1 = jsonvalue.annotations.reidlist(sel_frame_id,1)+1;
    reid_2 = jsonvalue.annotations.reidlist(sel_frame_id,2)+1;
    masks_1 = MaskApi.decode(img_anno_1);
    masks_2 = MaskApi.decode(img_anno_2);
    all_masks = reid_1*double(masks_1)+reid_2*double(masks_2);
    
    vidobj = VideoReader([rootpath,'\panel_12\temp\',num2str(camidx),'.avi']);
    
    XYZ_frame  = cam2world(R0, T0, campos_frame);
    XYZ_mask  = cam2world(R0, T0, campos_mask);
    frames_cell{camidx,1} = XYZ_frame;
    frames_cell{camidx,2} = imrotate(read(vidobj,sel_frame_id),90);
    masks_cell{camidx,1} = XYZ_mask;
    masks_cell{camidx,2} = imrotate(all_masks,90);
    [y1,x1] = find(masks_1==1);
    [y2,x2] = find(masks_2==1);
    point2d_1 = [x1,y1];
    point2d_2 = [x2,y2];
    randnum_1 = randperm(size(point2d_1,1));
    randnum_2 = randperm(size(point2d_2,1));
    res_point2d_1 = point2d_1(randnum_1(1:res_len),:);
    res_point2d_2 = point2d_2(randnum_2(1:res_len),:);
    [dir_vec, p0] = ertp2kd(E0, R0, T0, res_point2d_1);
    [x_s, x_e, y_s, y_e] = kp2tp(dir_vec,p0,z_s,z_e);
    x_s_cell{camidx,reid_1} = x_s;
    x_e_cell{camidx,reid_1} = x_e;
    y_s_cell{camidx,reid_1} = y_s;
    y_e_cell{camidx,reid_1} = y_e;
    z_s_cell{camidx,reid_1} = z_s*ones(size(x_s));
    z_e_cell{camidx,reid_1} = z_e*ones(size(x_e));
    [dir_vec, p0] = ertp2kd(E0, R0, T0, res_point2d_2);
    [x_s, x_e, y_s, y_e] = kp2tp(dir_vec,p0,z_s,z_e);
    x_s_cell{camidx,reid_2} = x_s;
    x_e_cell{camidx,reid_2} = x_e;
    y_s_cell{camidx,reid_2} = y_s;
    y_e_cell{camidx,reid_2} = y_e;
    z_s_cell{camidx,reid_2} = z_s*ones(size(x_s));
    z_e_cell{camidx,reid_2} = z_e*ones(size(x_e));

    
%     plot3(XYZ(1,:),XYZ(2,:),XYZ(3,:),'o')

%     plot(XY(1,:),XY(2,:),'o');
end
%
% relativeCameraPose
cmap = [1,1,1;...
        mouse1_c;...
        mouse2_c];
% subplot('Position',[0.32,0.07,0.18,0.18])
% figure(3)
for camidx = 1:camnum
    plot3([x_s_cell{camidx,1},x_e_cell{camidx,1}]',...
        [y_s_cell{camidx,1},y_e_cell{camidx,1}]',...
        [z_s_cell{camidx,1},z_e_cell{camidx,1}]','Color',mouse1_c)
    hold on
    plot3([x_s_cell{camidx,2},x_e_cell{camidx,2}]',...
        [y_s_cell{camidx,2},y_e_cell{camidx,2}]',...
        [z_s_cell{camidx,2},z_e_cell{camidx,2}]','Color',mouse2_c)
    hold on
    showx1 = reshape(frames_cell{camidx,1}(1,:),fliplr(framesize))';
    showy1 = reshape(frames_cell{camidx,1}(2,:),fliplr(framesize))';
    showz1 = reshape(frames_cell{camidx,1}(3,:),fliplr(framesize))';
    showf1 = imresize(frames_cell{camidx,2},framesize);
    showx1 = showx1(1:res_par:end,1:res_par:end);
    showy1 = showy1(1:res_par:end,1:res_par:end);
    showz1 = showz1(1:res_par:end,1:res_par:end);
    showf1 = showf1(1:res_par:end,1:res_par:end,:);
    warp(showx1,showy1,showz1,showf1);
    hold on
    showx2 = reshape(masks_cell{camidx,1}(1,:),fliplr(framesize))';
    showy2 = reshape(masks_cell{camidx,1}(2,:),fliplr(framesize))';
    showz2 = reshape(masks_cell{camidx,1}(3,:),fliplr(framesize))';
    showf2 = uint8(imresize(masks_cell{camidx,2},framesize));
    showx2 = showx2(1:res_par:end,1:res_par:end);
    showy2 = showy2(1:res_par:end,1:res_par:end);
    showz2 = showz2(1:res_par:end,1:res_par:end);
    showf2 = showf2(1:res_par:end,1:res_par:end,:);
    hw = warp(showx2,showy2,showz2,showf2,cmap);
    alpha(hw,0.5)
    hold on
end
hold off
axis equal
view(-64,65)
xlabel('x')
ylabel('y')
zlabel('z')
% disp(get(gca,'XAxis'))
% disp(get(gca,'YAxis'))
% disp(get(gca,'ZAxis'))
% axis([-911.1558 680.3020 -662.6384 892.9531 -30 643.1749])
set(gca,'XTickLabel',[])
set(gca,'YTickLabel',[])
set(gca,'ZTickLabel',[])
% set(gca,'Tickdir','none')
% set(gcf,'color','none')
% set(gca,'color','none')
axis off
grid on
% title('3D Mask Re-ID','Color','blue')
toc
