function fig2_panel_9(rootpath)
res_par = 1;
start_frame = 30;
end_frame = start_frame+4;
start_x = 100/res_par;
end_x = 550/res_par;
start_y = 0;
end_y = start_y+(end_x-start_x)*(480/640);
vidname1 = [rootpath,'\panel_9\rec2-group-20211207-camera-0-masked-1.avi'];
vidname2 = [rootpath,'\panel_9\rec2-group-20211207-camera-0-masked-2.avi'];
vidobj1 = VideoReader(vidname1);
vidobj2 = VideoReader(vidname2);
frame_cell_1 = cell(end_frame-start_frame+1,1);
frame_cell_2 = cell(end_frame-start_frame+1,1);
for k = start_frame:end_frame
    frame_cell_1{k-start_frame+1,1} = flipud(read(vidobj1,k));
    frame_cell_2{k-start_frame+1,1} = flipud(read(vidobj2,k));
    frame_cell_1{k-start_frame+1,1} = frame_cell_1{k-start_frame+1,1}(1:res_par:end,1:res_par:end,:);
    frame_cell_2{k-start_frame+1,1} = frame_cell_2{k-start_frame+1,1}(1:res_par:end,1:res_par:end,:);
end
[X,Y] = meshgrid(1:size(frame_cell_1{1,1},1),1:size(frame_cell_1{1,1},2));
subplot('Position',[0.81,0.35,0.14,0.1])
bias = 0;
for k = 1:size(frame_cell_1,1)
    warp(X,ones(size(Y))+bias,Y,frame_cell_1{k,1});
    bias = bias+100;
    hold on
end
hold off
view(25,15)
xlabel('x')
ylabel('y')
axis([start_x,end_x,0,500,start_y,end_y])
axis off
% title('Masked Videos','Color','blue')
subplot('Position',[0.81,0.25,0.14,0.1])
bias = 0;
for k = 1:size(frame_cell_2,1)
    warp(X,ones(size(Y))+bias,Y,frame_cell_2{k,1});
    bias = bias+100;
    hold on
end
hold off
view(25,15)
axis([start_x,end_x,0,500,start_y,end_y])
axis off