function fig2_panel_5(rootpath)
subplot('Position',[0.35,0.51,0.1,0.1])
imgname = [rootpath,'\panel_5\videos2_view1_1633_251.png'];
jsonname = [rootpath,'\panel_5\videos2_view1_1633_251.json'];
jsontext = fileread(jsonname);
jsonvalue = jsondecode(jsontext);
img = imread(imgname);
mouse1p = jsonvalue.shapes(1).points;
mouse2p = jsonvalue.shapes(2).points;
imshow(img)
hold on
plot(mouse1p(:,1),mouse1p(:,2),'-y')
hold on
plot(mouse2p(:,1),mouse2p(:,2),'-y')
hold off
start_x = 250;
end_x = 500;
start_y = 250;
end_y = start_y+(end_x-start_x)*(480/640);
axis([start_x,end_x,start_y,end_y])
% text(end_x,end_y,' × m')
title('Label Frames','Color','blue')
