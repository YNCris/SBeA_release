function fig2_panel_8(rootpath,cov1_c,cov2_c,att1_c,att2_c)
subplot('Position',[0.8,0.5,0.15,0.2])
bias1 = 80;
bias2 = 10;
bias3 = 4;
thick = 0.5;
shrscale = 1;
inter1 = 10;
plotcube([70 70 thick],[-35  -35  4*inter1],.8,cov1_c)
plotcube([60 60 thick],[-30  -30  3*inter1],.8,cov1_c)
plotcube([50 50 thick],[-25  -25  2*inter1],.8,cov1_c)
plotcube([40 40 thick],[-20  -20  inter1],.8,cov1_c)
plotcube([30 30 thick],[-15  -15  0*inter1],.8,cov1_c)

plotcube([10 10 10],[5  -5  -20],.8,att1_c)
plotcube([10 10 10],[25  -5  -20],.8,att1_c)
plotcube([10 10 10],[45  -5  -20],.8,att1_c)
plotcube([-10 10 10],[-5  -5  -20],.8,att1_c)
plotcube([-10 10 10],[-25  -5  -20],.8,att1_c)
plotcube([-10 10 10],[-45  -5  -20],.8,att1_c)

plotcube([10 10 10],[5  -5  -40],.8,att2_c)
plotcube([10 10 10],[25  -5  -40],.8,att2_c)
plotcube([10 10 10],[45  -5  -40],.8,att2_c)
plotcube([-10 10 10],[-5  -5  -40],.8,att2_c)
plotcube([-10 10 10],[-25  -5  -40],.8,att2_c)
plotcube([-10 10 10],[-45  -5  -40],.8,att2_c)

plotcube([30 10 10],[-15  -5  -60],.8,att2_c)

hold on
plot3([0,0],[0,0],[0+thick,inter1],'k')
hold on
plot3([0,0],[0,0],[inter1+thick,2*inter1],'k')
hold on
plot3([0,0],[0,0],[2*inter1+thick,3*inter1],'k')
hold on
plot3([0,0],[0,0],[3*inter1+thick,4*inter1],'k')

hold on
plot3([0,10],[0,0],[0,-10],'k')
hold on
plot3([0,30],[0,0],[0,-10],'k')
hold on
plot3([0,50],[0,0],[0,-10],'k')
hold on
plot3([0,-10],[0,0],[0,-10],'k')
hold on
plot3([0,-30],[0,0],[0,-10],'k')
hold on
plot3([0,-50],[0,0],[0,-10],'k')

hold on
plot3([10,10],[0,0],[-20,-40],'k')
hold on
plot3([30,30],[0,0],[-20,-40],'k')
hold on
plot3([50,50],[0,0],[-20,-40],'k')
hold on
plot3([-10,-10],[0,0],[-20,-40],'k')
hold on
plot3([-30,-30],[0,0],[-20,-40],'k')
hold on
plot3([-50,-50],[0,0],[-20,-40],'k')

hold on
plot3([10,0],[0,0],[-40,-50],'k')
hold on
plot3([30,0],[0,0],[-40,-50],'k')
hold on
plot3([50,0],[0,0],[-40,-50],'k')
hold on
plot3([-10,0],[0,0],[-40,-50],'k')
hold on
plot3([-30,0],[0,0],[-40,-50],'k')
hold on
plot3([-50,0],[0,0],[-40,-50],'k')
hold off
% axis equal
view(-35,15)
title('Spatio-temporal Learning','Color','blue')
axis off
