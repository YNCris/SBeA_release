clear all
close all
%% load data
cell_3d = cell(64,1);
for k = 1:size(cell_3d,1)
    cell_3d{k,1} = load(['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
        'disc1_shank3\temp_data\temp3d_',num2str(k-1),'.mat']);
end
calipath = 'Z:\hanyaning\multi_mice_test\Social_analysis\data\disc1_shank3\SBeA_data_20220602';
caliname = 'rec1-R7R9-20220606-caliParas.mat';
load([calipath,'\',caliname]);
%%
colorlist = jet(4);
show_cell_3d_line(cell_3d{1,1}.data(1,:),'k',5)
hold on
show_cell_3d_line(cell_3d{1,1}.data(3,:),'m',5)
hold on
show_cell_3d_line(cell_3d{1,1}.data(4,:),'c',5)
hold on
show_cell_3d_line(cell_3d{1,1}.data(5,:),'k',5)
% hold on
% show_cell_3d(cell_3d{1,1}.data,'r')
% hold on
% show_cell_3d(cell_3d{2,1}.data,'g')
hold on
show_cell_3d(cell_3d{3,1}.data,'r')
hold on
show_cell_3d(cell_3d{4,1}.data,'g')
hold on
% show_cell_3d(cell_3d{26,1}.data,'b')
% hold on
show_cell_3d(cell_3d{5,1}.data,'g')
hold on
show_cell_3d(cell_3d{6,1}.data,'r')
% hold on
% show_cell_3d(cell_3d{7,1}.data,colorlist(4,:))
% hold on
% show_cell_3d(cell_3d{8,1}.data,colorlist(4,:))
hold on
cam_size = 50;
show_cam_pose(caliParams,cam_size)
hold off
axis([-1000,1000,-1000,1000,-500,200])
view(22,-68)
























