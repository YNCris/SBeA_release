function fig2_panel_3(rootpath)
res_par = 1;
subplot('Position',[0.35,0.75,0.1,0.1])
bkframe = imread([rootpath,'\panel_3\videos1_view1.png']);
imshow(bkframe)
title('Backgrounds Extraction','Color','blue')
text(640,480,' × n')

