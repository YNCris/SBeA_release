function fig2_panel_14(rootpath,mouse1_c,mouse2_c)
sel_frame = 40;
dotsize = 10;
temppos = load([rootpath,'\panel_14\rec1-group-20211207-reid3d.mat']);
mouse1 = reshape(temppos.coords3d(1,:,:),[1800,48]);
mouse2 = reshape(temppos.coords3d(2,:,:),[1800,48]);
drawline = [ 1 2; 1 3;2 3; 4 5;4 6;5 7;6 8;7 14;8 14;...
    5 9;7 11;6 10; 8 12;14 15; 15 16];
nfeatures = 16;
colorclass = ones(256,1)*mouse1_c; %jet is default in DLC
color_map_self=colorclass(ceil(linspace(1,256,nfeatures)),:);
h14 = subplot('Position',[0.06,0.28,0.17,0.17]);
mesh_mouse(mouse1, sel_frame)
hold on
temp = reshape(mouse1(sel_frame,:,1),3,nfeatures);
scatter3(temp(1,:),temp(2,:),temp(3,:),dotsize*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', h14);
hold on;
for l = 1:size(drawline,1)
    pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
    line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1,'Parent', h14)
end
hold on
colorclass = ones(256,1)*mouse2_c; %jet is default in DLC
color_map_self=colorclass(ceil(linspace(1,256,nfeatures)),:);
mesh_mouse(mouse2, sel_frame)
hold on
temp = reshape(mouse2(sel_frame,:,1),3,nfeatures);
scatter3(temp(1,:),temp(2,:),temp(3,:),dotsize*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', h14);
hold on;
for l = 1:size(drawline,1)
    pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
    line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1,'Parent', h14)
end
hold off
view(-74,72)
xlabel('x')
ylabel('y')
zlabel('z')
set(gca,'TickDir','none')
set(gca,'XTickLabel',[])
set(gca,'YTickLabel',[])
set(gca,'ZTickLabel',[])
axis([-350,-170,50,250,-10,100])
grid on
title('3D Poses','Color','blue')