function fig2_panel_4(rootpath,mouse1_c,mouse2_c)
trajdata = readNPY([rootpath,'\panel_4\videos1_view1.npy']);
seltrajdata = trajdata(150:650,[1,2,4,5]);
subplot('Position',[0.35,0.63,0.1,0.1])
vidobj = VideoReader([rootpath,'\panel_2\rec1-group-20211207-camera-0.avi']);
imshow(read(vidobj,150))
hold on
plot(seltrajdata(:,1),seltrajdata(:,2),'Color',mouse1_c)
hold on
plot(seltrajdata(:,3),seltrajdata(:,4),'Color',mouse2_c)
hold off
% axis([0,640,0,480])
title('Trajectories Extraction','Color','blue')
text(640,480,' × n')
