function fig2_panel_6(rootpath,cov1_c,cov2_c)
bias1 = 80;
bias2 = 10;
bias3 = 4;
thick = 0.5;
shrscale = 1;
subplot('Position',[0.57,0.51,0.15,0.12])
plotcube([thick 70 70]/shrscale,[0  0  0]/shrscale,.8,cov1_c)
plotcube([thick 60 60]/shrscale,[2  5  5]/shrscale,.8,cov1_c)
plotcube([thick 50 50]/shrscale,[4  10  10]/shrscale,.8,cov1_c)
plotcube([thick 40 40]/shrscale,[6  15  15]/shrscale,.8,cov1_c)
plotcube([thick 30 30]/shrscale,[8  20 20]/shrscale,.8,cov1_c)
plotcube([thick 50 50]/shrscale,[0+bias3 0+bias2 0+bias1]/shrscale,.8,cov2_c)
plotcube([thick 40 40]/shrscale,[2+bias3  5+bias2  5+bias1]/shrscale,.8,cov2_c)
plotcube([thick 30 30]/shrscale,[4+bias3  10+bias2  10+bias1]/shrscale,.8,cov2_c)
plotcube([thick 20 20]/shrscale,[6+bias3  15+bias2  15+bias1]/shrscale,.8,cov2_c)
plotcube([thick 10 10]/shrscale,[8+bias3  20+bias2 20+bias1]/shrscale,.8,cov2_c)
hold on
plot3([0+thick,2]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
hold on
plot3([2+thick,4]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
hold on
plot3([4+thick,6]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
hold on
plot3([6+thick,8]/shrscale,[35,35]/shrscale,[35,35]/shrscale,'k')
hold on
plot3([0+bias3+thick,2+bias3]/shrscale,[25+bias2,25+bias2]/shrscale,[25+bias1,25+bias1]/shrscale,'k')
hold on
plot3([2+bias3+thick,4+bias3]/shrscale,[25+bias2,25+bias2]/shrscale,[25+bias1,25+bias1]/shrscale,'k')
hold on
plot3([4+bias3+thick,6+bias3]/shrscale,[25+bias2,25+bias2]/shrscale,[25+bias1,25+bias1]/shrscale,'k')
hold on
plot3([6+bias3+thick,8+bias3]/shrscale,[25+bias2,25+bias2]/shrscale,[25+bias1,25+bias1]/shrscale,'k')
hold on
plot3([0.5*thick+4,0.5*thick+4]/shrscale,[35,35]/shrscale,[10+50,0+bias1]/shrscale,'k')
hold on
plot3([0.5*thick+6,0.5*thick+6]/shrscale,[35,35]/shrscale,[15+40,5+bias1]/shrscale,'k')
hold on
plot3([0.5*thick+8,0.5*thick+8]/shrscale,[35,35]/shrscale,[20+30,10+bias1]/shrscale,'k')
hold on
plot3([-2,0],[35,35],[35,35],'k')
hold on
plot3([-2,-2],[35,35],[35,25+0+bias1],'k')
hold on
plot3([-2,0+bias3],[35,35],[25+bias1,25+bias1],'k')
hold off
view(9,4)
axis off
% view(2)
title({'Self-Training','Instance Segmentation'},'Color','blue')