function fig2_panel_2(rootpath)
res_par = 1;
start_frame = 1;
end_frame = start_frame+4;
vidobj = VideoReader([rootpath,'\panel_2\rec1-group-20211207-camera-0.avi']);
frame_cell = cell(end_frame-start_frame+1,1);
for k = start_frame:end_frame
    frame_cell{k,1} = flipud(read(vidobj,k));
    frame_cell{k,1} = frame_cell{k,1}(1:res_par:end,1:res_par:end,:);
end
[X,Y] = meshgrid(1:size(frame_cell{1,1},1),1:size(frame_cell{1,1},2));
subplot('Position',[0.08,0.73,0.1,0.1])
bias = 0;
for k = 1:size(frame_cell,1)
    warp(X,ones(size(Y))+bias,Y,frame_cell{k,1});
    bias = bias+100/res_par;
    hold on
end
hold off
xlabel('x')
ylabel('y')
zlabel('z')
% title('Frame Sequences','Color','blue')
view(40,15)
axis off
% text(850/res_par,1100/res_par,'......','Rotation',90)
% text(930/res_par,1100/res_par,' × n cameras')
% text(550/res_par,0,350/res_par,'......')
% text(-650/res_par,0,100/res_par,'......')

