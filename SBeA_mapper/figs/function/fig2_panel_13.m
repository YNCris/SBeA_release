function fig2_panel_13(rootpath,mouse1_c,mouse2_c)
sel_frame_idx = 40;
start_x = 250;
end_x = 510;
start_y = 280;
end_y = start_y+(end_x-start_x)*(480/640);
vidobj = VideoReader([rootpath,'\panel_13\rec2-group-20211207-camera-0.avi']);
vidname1 = [rootpath,'\panel_9\rec2-group-20211207-camera-0-masked-1.avi'];
vidname2 = [rootpath,'\panel_9\rec2-group-20211207-camera-0-masked-2.avi'];
vidobj1 = VideoReader(vidname1);
vidobj2 = VideoReader(vidname2);
tempdata1 = importdata([rootpath,'\panel_13\rec2-group-20211207-camera-0-masked-1DLC_resnet50_HYN_projectDec17shuffle1_1030000.csv']);
tempdata2 = importdata([rootpath,'\panel_13\rec2-group-20211207-camera-0-masked-2DLC_resnet50_HYN_projectDec17shuffle1_1030000.csv']);
pos1 = tempdata1.data;
pos2 = tempdata2.data;
pos1(:,1:3:end) = [];
pos2(:,1:3:end) = [];
selpos1 = pos1(sel_frame_idx,:);
selpos2 = pos2(sel_frame_idx,:);
subplot('Position',[0.48,0.35,0.1,0.08])
selframe1 = read(vidobj1,sel_frame_idx);
imshow(selframe1)
hold on
plot(selpos1(1:2:end),selpos1(2:2:end),'o','Color',mouse1_c,'MarkerSize',1)
hold off
axis([start_x,end_x,start_y,end_y])
title('Single animal poses','Color','blue')
subplot('Position',[0.48,0.27,0.1,0.08])
selframe2 = read(vidobj2,sel_frame_idx);
imshow(selframe2)
hold on
plot(selpos2(1:2:end),selpos2(2:2:end),'o','Color',mouse2_c,'MarkerSize',1)
hold off
axis([start_x,end_x,start_y,end_y])
subplot('Position',[0.29,0.29,0.12,0.12])
selframe = read(vidobj,sel_frame_idx);
imshow(selframe)
hold on
plot(selpos1(1:2:end),selpos1(2:2:end),'o','Color',mouse1_c,'MarkerSize',1)
hold on
plot(selpos2(1:2:end),selpos2(2:2:end),'o','Color',mouse2_c,'MarkerSize',1)
hold off
axis([start_x,end_x,start_y,end_y])
title('Merge poses','Color','blue')