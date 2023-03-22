function fig2_panel_1(rootpath)
mousename = [rootpath,'\panel_1\mouse_2d.png'];
cameraname = [rootpath,'\panel_1\camera_4.png'];
[mouse_img,~,mouse_alpha] = imread(mousename);
[camera_img,~,camera_alpha] = imread(cameraname);
[X,Y] = meshgrid(1:size(mouse_img,1),1:size(mouse_img,2));
subplot('Position',[0.05,0.55,0.17,0.1])
% warp_mouse1 = warp(X-200,Y-300,ones(size(Y)),mouse_img);
hold on
% warp_mouse2 = warp(X+50,Y+50-300,ones(size(Y)),mouse_img);
hold on
[X,Y] = meshgrid(1:size(camera_img,1),1:size(camera_img,2));
% warp_camera = warp((X-76.5)*14,ones(size(Y))*200-1000,-1*Y*4+2000,camera_img);
hold on
r = 600;
[Xbox, Ybox, Zbox] = cylinder(r, 50);
surf(Xbox, Ybox, Zbox*2000,'FaceAlpha',0.05,'FaceColor',[.1,.1,.1],'EdgeColor','none');
hold off
xlabel('x')
ylabel('y')
zlabel('z')
% himg = imshow(mouse_img);
% alpha(warp_mouse1,mouse_alpha)
view(0,53)
% title('Behavioral Video Capture','Position',[0,1200],'Color','blue')
axis off
