function fig2_panel_11(rootpath,cov1_c)
bias1 = 80;
bias2 = 10;
bias3 = 4;
thick = 0.5;
shrscale = 1;
bias4 = 0.5;
subplot('Position',[0.65,0.315,0.1,0.1])
plotcube([thick 70 70]/shrscale,[0  0  0]/shrscale,.8,cov1_c)
plotcube([thick 60 60]/shrscale,[2  5  5]/shrscale,.8,cov1_c)
plotcube([thick 50 50]/shrscale,[4  10  10]/shrscale,.8,cov1_c)
plotcube([thick 60 60]/shrscale,[6  5  5]/shrscale,.8,cov1_c)
plotcube([thick 70 70]/shrscale,[8  0  0]/shrscale,.8,cov1_c)

hold on
plot3([0+thick,2]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
hold on
plot3([2+thick,4]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
hold on
plot3([4+thick,6]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
hold on
plot3([6+thick,8]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')

hold on
plot3([2-bias4,2-bias4]/shrscale,[35,35]/shrscale,[35,90]/shrscale,'k')
hold on
plot3([4-bias4,4-bias4]/shrscale,[35,35]/shrscale,[35,90]/shrscale,'k')
hold on
plot3([6-bias4,6-bias4]/shrscale,[35,35]/shrscale,[35,90]/shrscale,'k')

hold on
plot3([2+thick+bias4,2+thick+bias4]/shrscale,[35,35]/shrscale,[35,90]/shrscale,'k')
hold on
plot3([4+thick+bias4,4+thick+bias4]/shrscale,[35,35]/shrscale,[35,90]/shrscale,'k')
hold on
plot3([6+thick+bias4,6+thick+bias4]/shrscale,[35,35]/shrscale,[35,90]/shrscale,'k')

hold on
plot3([2-bias4,2+thick+bias4]/shrscale,[35,35]/shrscale,[90,90]/shrscale,'k')
hold on
plot3([4-bias4,4+thick+bias4]/shrscale,[35,35]/shrscale,[90,90]/shrscale,'k')
hold on
plot3([6-bias4,6+thick+bias4]/shrscale,[35,35]/shrscale,[90,90]/shrscale,'k')

hold off
title({'Single Animal','Pose Estimation'},'Color','blue')
view(-10,12)
axis off
