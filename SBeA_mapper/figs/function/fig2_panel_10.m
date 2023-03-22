function fig2_panel_10(rootpath)
sel_cb_idx = 2;

startx1 = 250;
starty1 = 100;
bias_1 = 300;

startx2 = 250;
starty2 = 100;
bias_2 = 300;

startx3 = 100;
starty3 = 150;
bias_3 = 300;

startx4 = 150;
starty4 = 50;
bias_4 = 300;

endx1 = startx1+bias_1;
endy1 = starty1+bias_1;
endx2 = startx2+bias_2;
endy2 = starty2+bias_2;
endx3 = startx3+bias_3;
endy3 = starty3+bias_3;
endx4 = startx4+bias_4;
endy4 = starty4+bias_4;
cbimg1 = imread([rootpath,'\panel_10\Imagesforcalibration\PrimarySecondary1\Primary\frame',...
    num2str(sel_cb_idx),'.png']);
cbimg2 = imread([rootpath,'\panel_10\Imagesforcalibration\PrimarySecondary1\Secondary1\frame',...
    num2str(sel_cb_idx),'.png']);
cbimg3 = imread([rootpath,'\panel_10\Imagesforcalibration\PrimarySecondary2\Secondary2\frame',...
    num2str(sel_cb_idx),'.png']);
cbimg4 = imread([rootpath,'\panel_10\Imagesforcalibration\PrimarySecondary3\Secondary3\frame',...
    num2str(sel_cb_idx),'.png']);
cali1 = load([rootpath,'\panel_10\CalibSessionFiles\PrimarySecondary1\calibrationSession.mat']);
cali2 = load([rootpath,'\panel_10\CalibSessionFiles\PrimarySecondary2\calibrationSession.mat']);
cali3 = load([rootpath,'\panel_10\CalibSessionFiles\PrimarySecondary3\calibrationSession.mat']);
for k = 1:size(cali1.calibrationSession.PatternSet.FullPathNames,2)
    tempname = cali1.calibrationSession.PatternSet.FullPathNames{1,k};
    tempsplname = split(tempname,'\');
    if strcmp(tempsplname{end},['frame',num2str(sel_cb_idx),'.png'])
        selnum1 = k;
        break;
    end
end
for k = 1:size(cali1.calibrationSession.PatternSet.FullPathNames,2)
    tempname = cali1.calibrationSession.PatternSet.FullPathNames{2,k};
    tempsplname = split(tempname,'\');
    if strcmp(tempsplname{end},['frame',num2str(sel_cb_idx),'.png'])
        selnum2 = k;
        break;
    end
end
for k = 1:size(cali2.calibrationSession.PatternSet.FullPathNames,2)
    tempname = cali2.calibrationSession.PatternSet.FullPathNames{2,k};
    tempsplname = split(tempname,'\');
    if strcmp(tempsplname{end},['frame',num2str(sel_cb_idx),'.png'])
        selnum3 = k;
        break;
    end
end
for k = 1:size(cali3.calibrationSession.PatternSet.FullPathNames,2)
    tempname = cali3.calibrationSession.PatternSet.FullPathNames{2,k};
    tempsplname = split(tempname,'\');
    if strcmp(tempsplname{end},['frame',num2str(sel_cb_idx),'.png'])
        selnum4 = k;
        break;
    end
end
calip1 = cali1.calibrationSession.PatternSet.PatternPoints(:,:,selnum1,1);
calip2 = cali1.calibrationSession.PatternSet.PatternPoints(:,:,selnum2,2);
calip3 = cali2.calibrationSession.PatternSet.PatternPoints(:,:,selnum3,2);
calip4 = cali3.calibrationSession.PatternSet.PatternPoints(:,:,selnum4,2);
first_fig_pos = [0.65,0.15,0.05,0.05];
subplot('Position',first_fig_pos)
imshow(cbimg1)
hold on
plot(calip1(:,1),calip1(:,2),'go','MarkerSize',1)
hold off
axis([startx1,endx1,starty1,endy1])
title('             Calibration Files','Color','blue')
subplot('Position',[first_fig_pos(1)+0.05,first_fig_pos(2:end)])
imshow(cbimg2)
hold on
plot(calip2(:,1),calip2(:,2),'go','MarkerSize',1)
hold off
axis([startx2,endx2,starty2,endy2])
subplot('Position',[first_fig_pos(1),first_fig_pos(2)-0.05,first_fig_pos(3:end)])
imshow(cbimg3)
hold on
plot(calip3(:,1),calip3(:,2),'go','MarkerSize',1)
hold off
axis([startx3,endx3,starty3,endy3])
subplot('Position',[first_fig_pos(1)+0.05,first_fig_pos(2)-0.05,first_fig_pos(3:end)])
imshow(cbimg4)
hold on
plot(calip4(:,1),calip4(:,2),'go','MarkerSize',1)
hold off
axis([startx4,endx4,starty4,endy4])
% annotation('arrow',[0.54,0.25],[0.38,0.38])
