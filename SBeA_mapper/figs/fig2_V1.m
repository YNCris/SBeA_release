%{
    fig2, the framework of social mice tracking
%}
clear all
close all
addpath(genpath(pwd))
tic
%% plot canvas
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
set(h1,'color','white');
%% plot
rootpath = 'Z:\hanyaning\multi_mice_test\Social_analysis\data\figs\fig2';
%% set color
setcolor = cbrewer2('Spectral',11);
mouse1_c = setcolor(3,:);
mouse2_c = setcolor(9,:);
netcolorlist = cbrewer2('Set3',12);
cov1_c = netcolorlist(11,:);
cov2_c = netcolorlist(4,:);
att1_c = netcolorlist(10,:);
att2_c = netcolorlist(1,:);
%% draw arrow and line
close all
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
set(h1,'color','white');
fig2_arrow_line()
h1.Renderer = 'Painters';
print(h1,[rootpath,'\fig2_V1_al.pdf'],'-dpdf','-r0');
disp('save successful!')
%% 1. open field, two mice, four cameras
close all
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
set(h1,'color','white');
fig2_panel_1(rootpath)
h1.Renderer = 'Painters';
print(h1,[rootpath,'\fig2_V1_p1.pdf'],'-dpdf','-r0');
disp('save successful!')
%% 2. data from four cameras
close all
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
set(h1,'color','white');
fig2_panel_2(rootpath)
print(h1,[rootpath,'\fig2_V1_p2.pdf'],'-dpdf','-r1200');
disp('save successful!')
%% 3. backgrounds
close all
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
set(h1,'color','white');
fig2_panel_3(rootpath)
h1.Renderer = 'Painters';
print(h1,[rootpath,'\fig2_V1_p3.pdf'],'-dpdf','-r0');
disp('save successful!')
%% 4. trajectories
close all
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
set(h1,'color','white');
fig2_panel_4(rootpath,mouse1_c,mouse2_c)
h1.Renderer = 'Painters';
print(h1,[rootpath,'\fig2_V1_p4.pdf'],'-dpdf','-r0');
disp('save successful!')
%% 5. label frames
close all
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
set(h1,'color','white');
fig2_panel_5(rootpath)
h1.Renderer = 'Painters';
print(h1,[rootpath,'\fig2_V1_p5.pdf'],'-dpdf','-r0');
disp('save successful!')
%% 6. self training YOLACT
close all
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
set(h1,'color','white');
fig2_panel_6(rootpath,cov1_c,cov2_c)
h1.Renderer = 'Painters';
print(h1,[rootpath,'\fig2_V1_p6.pdf'],'-dpdf','-r0');
disp('save successful!')
%% 7. Synthetic Data
close all
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
set(h1,'color','white');
fig2_panel_7(rootpath,mouse1_c,mouse2_c)
h1.Renderer = 'Painters';
print(h1,[rootpath,'\fig2_V1_p7.pdf'],'-dpdf','-r0');
disp('save successful!')
%% 7.5. Synthetic Label
close all
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
set(h1,'color','white');
fig2_panel_7_5(rootpath,mouse1_c,mouse2_c)
h1.Renderer = 'Painters';
print(h1,[rootpath,'\fig2_V1_p7_5.pdf'],'-dpdf','-r0');
disp('save successful!')
%% 8. ViSTR
close all
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
set(h1,'color','white');
fig2_panel_8(rootpath,cov1_c,cov2_c,att1_c,att2_c)
h1.Renderer = 'Painters';
print(h1,[rootpath,'\fig2_V1_p8.pdf'],'-dpdf','-r0');
disp('save successful!')
%% 9. mask frames
close all
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
set(h1,'color','white');
fig2_panel_9(rootpath)
print(h1,[rootpath,'\fig2_V1_p9.pdf'],'-dpdf','-r1200');
disp('save successful!')
%% 10. calibration files
close all
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
set(h1,'color','white');
fig2_panel_10(rootpath)
h1.Renderer = 'Painters';
print(h1,[rootpath,'\fig2_V1_p10.pdf'],'-dpdf','-r0');
disp('save successful!')
%% 11. DLC
close all
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
set(h1,'color','white');
fig2_panel_11(rootpath,cov1_c)
h1.Renderer = 'Painters';
print(h1,[rootpath,'\fig2_V1_p11.pdf'],'-dpdf','-r0');
disp('save successful!')
%% 12. 3D mask reid
close all
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
% set(h1,'color','white');
fig2_panel_12(rootpath,mouse1_c,mouse2_c)
set(h1,'color','white');
% h1.Renderer = 'Painters';
% print(h1,[rootpath,'\fig2_V1_p12.pdf'],'-dpdf','-r1200');
disp('save successful!')
%% 13. single animal pose estimation
close all
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
set(h1,'color','white');
fig2_panel_13(rootpath,mouse1_c,mouse2_c)
h1.Renderer = 'Painters';
print(h1,[rootpath,'\fig2_V1_p13.pdf'],'-dpdf','-r0');
disp('save successful!')
%% 14. 3D poses
close all
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
set(h1,'color','white');
fig2_panel_14(rootpath,mouse1_c,mouse2_c)
h1.Renderer = 'Painters';
print(h1,[rootpath,'\fig2_V1_p14.pdf'],'-dpdf','-r0');
disp('save successful!')
%% save pdf
% h1.Renderer = 'Painters';
% print(h1,'C:\Users\Administrator\Desktop\fig2_V1_1.pdf','-dpdf','-r0');
% disp('save successful!')
toc




















