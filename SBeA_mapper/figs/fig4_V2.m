%{
    fig4, behavior representation and state estimation
%}
clear all
close all
addpath(genpath(pwd))
tic
%% plot canvas
hall = figure(1);
set(hall,'Position',[900,100,800,800])
set(hall,'color','white');
%% set path
rootpath = 'Z:\hanyaning\multi_mice_test\Social_analysis\data\figs\fig4';
%% load data
trajs = load([rootpath,'\panel_1\rec11-A1A6-20220822-id3d.mat']);
sbea = load([rootpath,'\panel_2\A1_A6_rec11-A1A6-20220822_social_struct.mat']);
case_dsc = load([rootpath,'\panel_5\SBeA_data_sample_cell_20221130.mat']);
case_wc = load([rootpath,'\panel_5\SBeA_wc_struct_20221130.mat']);
case_dist_mat = load([rootpath,'\panel_5\SBeA_dist_mat_all_20221130.mat']);
pair24_social = load([rootpath,'\panel_9\SR1_SR2_rec1-SR1SR2-20210119_social_struct.mat']);
pair24_dsc = load([rootpath,'\panel_10\SBeA_data_sample_cell_20221123.mat']);
pair24_wc = load([rootpath,'\panel_10\SBeA_wc_struct_20221123.mat']);
label_path = [rootpath,'\panel_10\social_labels'];
sub_label_path = [rootpath,'\panel_10\sub_social_labels'];
label_video_path = [rootpath,'\panel_5\social_cluster_videos'];
social_struct_path = [rootpath,'\panel_5\social_struct'];
fileFolder = fullfile(social_struct_path);
dirOutput = dir(fullfile(fileFolder,'*.mat'));
social_struct_names = {dirOutput.name}';
fileFolder = fullfile(label_video_path);
dirOutput = dir(fullfile(fileFolder,'*.avi'));
labelvideonames = {dirOutput.name}';
fileFolder = fullfile(label_path);
dirOutput = dir(fullfile(fileFolder,'*.mat'));
socialnames = {dirOutput.name}';
social_struct_cell = cell(size(social_struct_names,1),2);
social_struct_cell(:,1) = social_struct_names;
smo_win = 30;
for k = 1:size(social_struct_cell,1)
    tempdata = load([social_struct_path,'\',social_struct_cell{k,1}]);
    temptrajcell = cell(size(tempdata.SBeA.RawData.traj));
    for m = 1:size(tempdata.SBeA.RawData.traj,1)
        temptraj = tempdata.SBeA.RawData.traj{m};
        for n = 1:size(temptraj,2)
            temptraj(:,n) = smooth(temptraj(:,n),smo_win);
        end
        temptrajcell{m} = temptraj;
    end
    social_struct_cell{k,2} = temptrajcell;
end
label_cell = cell(size(socialnames,1),3);
for k = 1:size(label_cell,1)
    tempdata = load([label_path,'\',socialnames{k,1}]);
    tempsubdata = load([sub_label_path,'\',socialnames{k,1}]);
    label_cell{k,1} = socialnames{k,1}(1,1:(end-4));
    label_cell{k,2} = tempdata.social_labels(1:4:end,:);
    label_cell{k,3} = tempsubdata.sub_social_labels(1:4:end,:);
end
% create label_sample_cell
label_sample_list = zeros(size(pair24_dsc.data_sample_cell,1),1);
for k = 1:size(pair24_dsc.data_sample_cell,1)
    % load name
    tempname = pair24_dsc.data_sample_cell{k,3};
    splname = split(tempname,'_');
    dataname = splname{3};
    % sel data
    selidx = find(strcmp(dataname,label_cell(:,1)));
    sellabel = label_cell{selidx,2};
    sellabel(isnan(sellabel)) = 0;
    % sel seg label
    start_idx = pair24_dsc.data_sample_cell{k,2}(1,1);
    end_idx = pair24_dsc.data_sample_cell{k,2}(1,2);
    templabel = mode(sellabel(start_idx:end_idx));
    label_sample_list(k,1) = templabel;
end
% create sub_label_sample_cell
sub_label_sample_list = zeros(size(pair24_dsc.data_sample_cell,1),1);
for k = 1:size(pair24_dsc.data_sample_cell,1)
    % load name
    tempname = pair24_dsc.data_sample_cell{k,3};
    splname = split(tempname,'_');
    dataname = splname{3};
    % sel data
    selidx = find(strcmp(dataname,label_cell(:,1)));
    sellabel = label_cell{selidx,3};
    sellabel(isnan(sellabel)) = 0;
    % sel seg label
    start_idx = pair24_dsc.data_sample_cell{k,2}(1,1);
    end_idx = pair24_dsc.data_sample_cell{k,2}(1,2);
    templabel = mode(sellabel(start_idx:end_idx));
    sub_label_sample_list(k,1) = templabel;
end
setcolor = cbrewer2('Spectral',11);
mouse1_c = setcolor(3,:);
mouse2_c = setcolor(9,:);
%% 1. trajectories
xbias_t = 0.06;
sel_time_len = 1:1800;
traj_m1 = trajs.coords3d(sel_time_len,1:48);
traj_m2 = trajs.coords3d(sel_time_len,49:96);
subplot('Position',[xbias_t,0.78,0.1,0.18]);
for k = 1:size(traj_m1,2)
    plot(sel_time_len,mat2gray(traj_m1(:,k))+k,'-','Color',mouse1_c)
    hold on
end
hold off
axis([sel_time_len(1),sel_time_len(end),0,size(traj_m1,2)+1])
set(gca,'XTickLabel',[])
set(gca,'TickDir','out')
set(gca,'YTick',(1:3:size(traj_m1,2))+1)
set(gca,'YTickLabel',[])
set(gca,'XTick',[sel_time_len(1),...
    sel_time_len(length(sel_time_len)/2),sel_time_len(end)])
box off
ylabel('M1')
title('Trajectories')
subplot('Position',[xbias_t,0.59,0.1,0.18]);
for k = 1:size(traj_m2,2)
    plot(sel_time_len,mat2gray(traj_m2(:,k))+k,'-','Color',mouse2_c)
    hold on
end
hold off
axis([sel_time_len(1),sel_time_len(end),0,size(traj_m1,2)+1])
set(gca,'XTickLabel',[])
set(gca,'TickDir','out')
set(gca,'YTick',(1:3:size(traj_m1,2))+1)
set(gca,'YTickLabel',[])
set(gca,'XTick',[sel_time_len(1),...
    sel_time_len(length(sel_time_len)/2),sel_time_len(end)])
box off
set(gca,'XTickLabel',[0,30,60])
ylabel('M2')
xlabel('Time (s)')
%% 2. parallel decompostion
xbias_p = 0.2;
smo_win = 15;
alpha_c = 0.05;
alpha_l = 0.8;
dotsize = 10;
selframe = 22;
drawline = [ 1 2; 1 3;2 3; 4 5;4 6;5 7;6 8;7 14;8 14;...
    5 9;7 11;6 10; 8 12;14 15; 15 16;5,13;6,13;7,13;8,13;...
    2 4;3 4;5,6;7,8];
subplot('Position',[xbias_p,0.84,0.1,0.1]);
cent_traj1 = sbea.SBeA.RawData.centered{1}(:,selframe);
cent_traj2 = sbea.SBeA.RawData.centered{2}(:,selframe);
tempx = cent_traj1(1:3:end,:);
tempy = cent_traj1(2:3:end,:);
tempz = cent_traj1(3:3:end,:);
clrstr = mouse1_c;
new_mesh_mouse(cent_traj1(:,1)', alpha_c, clrstr)
hold on
plot_skl_dl(tempx(:,1),tempy(:,1),tempz(:,1),...
    'k','k',drawline)
hold on
tempx = cent_traj2(1:3:end,:);
tempy = cent_traj2(2:3:end,:);
tempz = cent_traj2(3:3:end,:);
clrstr = mouse2_c;
new_mesh_mouse(cent_traj2(:,1)', alpha_c, clrstr)
hold on
plot_skl_dl(tempx(:,1),tempy(:,1),tempz(:,1),...
    'k','k',drawline)
hold off
view(2)
set(gca,'XTick',[],'YTick',[])
box on
ylabel({'Non-locomotor','movement'})
axis square
title({'Parallel','decomposition'})

subplot('Position',[xbias_p,0.73,0.1,0.1]);
alpha_c = 0.1;
selframe = 22;
lat_len = 10;
traj1 = sbea.SBeA.RawData.traj{1}(selframe,:)';
traj2 = sbea.SBeA.RawData.traj{2}(selframe,:)';
traj1_time = sbea.SBeA.RawData.traj{1}(lat_len:selframe,:)';
traj2_time = sbea.SBeA.RawData.traj{2}(lat_len:selframe,:)';
temp_traj1_time = traj1_time;
temp_traj2_time = traj2_time;
temp_traj1_time(1:3:end) = traj1_time(1:16,:);
temp_traj1_time(2:3:end) = traj1_time(17:32,:);
temp_traj1_time(3:3:end) = traj1_time(33:48,:);
temp_traj2_time(1:3:end) = traj2_time(1:16,:);
temp_traj2_time(2:3:end) = traj2_time(17:32,:);
temp_traj2_time(3:3:end) = traj2_time(33:48,:);
tempx = traj1(1:16,:);
tempy = traj1(17:32,:);
tempz = traj1(33:48,:);
clrstr = mouse1_c;
temptraj1 = traj1;
temptraj1(1:3:end) = tempx;
temptraj1(2:3:end) = tempy;
temptraj1(3:3:end) = tempz;
for k = 1:16
    a = plot3(smooth(temp_traj1_time((k-1)*3+1,:)),...
          smooth(temp_traj1_time((k-1)*3+2,:)),...
          smooth(temp_traj1_time((k-1)*3+3,:)),'-','Color',mouse1_c);
    a.Color(4) = alpha_l;
    hold on
end
new_mesh_mouse(temptraj1(:,1)', alpha_c, clrstr)
hold on
plot_skl_dl(tempx(:,1),tempy(:,1),tempz(:,1),...
    'k','k',drawline)
hold on
tempx = traj2(1:16,:);
tempy = traj2(17:32,:);
tempz = traj2(33:48,:);
clrstr = mouse2_c;
temptraj2 = traj2;
temptraj2(1:3:end) = tempx;
temptraj2(2:3:end) = tempy;
temptraj2(3:3:end) = tempz;
for k = 1:16
    a = plot3(smooth(temp_traj2_time((k-1)*3+1,:)),...
          smooth(temp_traj2_time((k-1)*3+2,:)),...
          smooth(temp_traj2_time((k-1)*3+3,:)),'-','Color',mouse2_c);
    a.Color(4) = alpha_l;
    hold on
end
new_mesh_mouse(temptraj2(:,1)', alpha_c, clrstr)
hold on
plot_skl_dl(tempx(:,1),tempy(:,1),tempz(:,1),...
    'k','k',drawline)
hold off
view(2)
axis square
set(gca,'XTick',[],'YTick',[])
box on
ylabel('Locomotion')

subplot('Position',[xbias_p,0.62,0.1,0.1]);
alpha_c = 0.1;
selframe = 22;
traj1 = sbea.SBeA.RawData.traj{1}(selframe,:)';
traj2 = sbea.SBeA.RawData.traj{2}(selframe,:)';
tempx1 = traj1(1:16,:);
tempy1 = traj1(17:32,:);
tempz1 = traj1(33:48,:);
tempx2 = traj2(1:16,:);
tempy2 = traj2(17:32,:);
tempz2 = traj2(33:48,:);
for k = 1:16
    a = plot3([tempx1(k),tempx2(k)],...
          [tempy1(k),tempy2(k)],...
          [tempz1(k),tempz2(k)],'k-');
    a.Color(4) = 0.3;
    hold on
end
tempx = traj1(1:16,:);
tempy = traj1(17:32,:);
tempz = traj1(33:48,:);
clrstr = mouse1_c;
temptraj1 = traj1;
temptraj1(1:3:end) = tempx;
temptraj1(2:3:end) = tempy;
temptraj1(3:3:end) = tempz;
new_mesh_mouse(temptraj1(:,1)', alpha_c, clrstr)
hold on
plot_skl_dl(tempx(:,1),tempy(:,1),tempz(:,1),...
    'k','k',drawline)
hold on
tempx = traj2(1:16,:);
tempy = traj2(17:32,:);
tempz = traj2(33:48,:);
clrstr = mouse2_c;
temptraj2 = traj2;
temptraj2(1:3:end) = tempx;
temptraj2(2:3:end) = tempy;
temptraj2(3:3:end) = tempz;
new_mesh_mouse(temptraj2(:,1)', alpha_c, clrstr)
hold on
plot_skl_dl(tempx(:,1),tempy(:,1),tempz(:,1),...
    'k','k',drawline)
hold off
view(2)
axis square
set(gca,'XTick',[],'YTick',[])
box on
ylabel('Distance')
%% 3. dynamic decompostion
xbias_d = 0.35;
box_c = cbrewer2('Paired');
box_c = box_c(11,:);
box_w = 1;
dist_range = 240:5:390;
axis_range = [1,(dist_range(end)-dist_range(1))/(dist_range(2)-dist_range(1))];
cmap1 = mat2gray(imresize(cbrewer2('RdBu'),[256,3]));
cmap1 = cmap1(32:216,:);
nm_dist = sbea.SBeA.SBeA_DecData.K(dist_range,dist_range);
speed_dist = sbea.SBeA.SBeA_DecData_speed.K(dist_range,dist_range);
dist_dist = sbea.SBeA.SBeA_DecData_dist.K(dist_range,dist_range);
nm_seglist = sbea.SBeA.SBeA_DecData.L2.Seglist(dist_range);
speed_seglist = sbea.SBeA.SBeA_DecData_speed.L2.Seglist(dist_range);
dist_seglist = sbea.SBeA.SBeA_DecData_dist.L2.Seglist(dist_range);
nm_diff_seglist = diff(nm_seglist)~=0;
speed_diff_seglist = diff(speed_seglist)~=0;
dist_diff_seglist = diff(dist_seglist)~=0;
nm_diff_seglist_11 = nm_diff_seglist;
speed_diff_seglist_11 = speed_diff_seglist;
dist_diff_seglist_11 = dist_diff_seglist;
nm_diff_seglist_11(1) = 1;
nm_diff_seglist_11 = [nm_diff_seglist_11,1];
speed_diff_seglist_11(1) = 1;
speed_diff_seglist_11 = [speed_diff_seglist_11,1];
dist_diff_seglist_11(1) = 1;
dist_diff_seglist_11 = [dist_diff_seglist_11,1];
nm_box = find(nm_diff_seglist_11==1);
speed_box = find(speed_diff_seglist_11==1);
dist_box = find(dist_diff_seglist_11==1);
hd11 = subplot('Position',[xbias_d,0.86,0.1,0.08]);
imagesc(nm_dist)
hold on
for k = 1:(length(nm_box)-1)
    prpx = nm_box(k);
    prpy = nm_box(k);
    popx = nm_box(k+1);
    popy = nm_box(k+1);
    plot([prpx,prpx],[prpy,popy],'-','Color',box_c,'LineWidth',box_w)
    hold on
    plot([popx,prpx],[prpy,prpy],'-','Color',box_c,'LineWidth',box_w)
    hold on
    plot([popx,prpx],[popy,popy],'-','Color',box_c,'LineWidth',box_w)
    hold on
    plot([popx,popx],[popy,prpy],'-','Color',box_c,'LineWidth',box_w)
    hold on
end
hold off
colormap(hd11,cmap1)
set(gca,'XTick',[],'YTick',[])
box on
title({'Dynamic','decomposition'})
subplot('Position',[xbias_d,0.845,0.1,0.012]);
plot([axis_range(1)+0.3,axis_range(2)+1],[0.5,0.5],'-','Color',0.9*ones(1,3),...
    'LineWidth',6)
hold on
stem(axis_range(1):axis_range(2),nm_diff_seglist,'k','Marker','none')
hold off
axis([axis_range(1),axis_range(2)+1,0,1])
set(gca,'XTick',1:6:31)
box off
set(gca,'TickDir','out')
set(gca,'XTickLabel',[])
set(gca,'YTick',[])
ax = axes('Position',get(gca,'Position'),...
          'XAxisLocation','top',...
          'YAxisLocation','right',...
          'Color','none');
set(ax,'XTick',[])
set(ax,'YTick',[])

hd21 = subplot('Position',[xbias_d,0.75,0.1,0.08]);
imagesc(speed_dist)
hold on
for k = 1:(length(speed_box)-1)
    prpx = speed_box(k);
    prpy = speed_box(k);
    popx = speed_box(k+1);
    popy = speed_box(k+1);
    plot([prpx,prpx],[prpy,popy],'-','Color',box_c,'LineWidth',box_w)
    hold on
    plot([popx,prpx],[prpy,prpy],'-','Color',box_c,'LineWidth',box_w)
    hold on
    plot([popx,prpx],[popy,popy],'-','Color',box_c,'LineWidth',box_w)
    hold on
    plot([popx,popx],[popy,prpy],'-','Color',box_c,'LineWidth',box_w)
    hold on
end
hold off
colormap(hd21,cmap1)
set(gca,'XTick',[],'YTick',[])
box on
subplot('Position',[xbias_d,0.735,0.1,0.012]);
plot([axis_range(1)+0.3,axis_range(2)+1],[0.5,0.5],'-','Color',0.9*ones(1,3),...
    'LineWidth',6)
hold on
stem(axis_range(1):axis_range(2),speed_diff_seglist,'k','Marker','none')
hold off
axis([axis_range(1),axis_range(2)+1,0,1])
set(gca,'XTick',1:6:31)
box off
set(gca,'TickDir','out')
set(gca,'XTickLabel',[])
set(gca,'YTick',[])
ax = axes('Position',get(gca,'Position'),...
          'XAxisLocation','top',...
          'YAxisLocation','right',...
          'Color','none');
set(ax,'XTick',[])
set(ax,'YTick',[])

hd31 = subplot('Position',[xbias_d,0.64,0.1,0.08]);
imagesc(dist_dist)
hold on
for k = 1:(length(dist_box)-1)
    prpx = dist_box(k);
    prpy = dist_box(k);
    popx = dist_box(k+1);
    popy = dist_box(k+1);
    plot([prpx,prpx],[prpy,popy],'-','Color',box_c,'LineWidth',box_w)
    hold on
    plot([popx,prpx],[prpy,prpy],'-','Color',box_c,'LineWidth',box_w)
    hold on
    plot([popx,prpx],[popy,popy],'-','Color',box_c,'LineWidth',box_w)
    hold on
    plot([popx,popx],[popy,prpy],'-','Color',box_c,'LineWidth',box_w)
    hold on
end
hold off
colormap(hd31,cmap1)
set(gca,'XTick',[],'YTick',[])
box on
subplot('Position',[xbias_d,0.625,0.1,0.012]);
plot([axis_range(1)+0.3,axis_range(2)+1],[0.5,0.5],'-','Color',0.9*ones(1,3),...
    'LineWidth',6)
hold on
stem(axis_range(1):axis_range(2),dist_diff_seglist,'k','Marker','none')
hold off
axis([axis_range(1),axis_range(2)+1,0,1])
box off
set(gca,'TickDir','out')
set(gca,'YTick',[])
set(gca,'XTick',1:6:31)
set(gca,'XTickLabel',0:5)
xlabel('Time (s)')
ax = axes('Position',get(gca,'Position'),...
          'XAxisLocation','top',...
          'YAxisLocation','right',...
          'Color','none');
set(ax,'XTick',[])
set(ax,'YTick',[])
%% 4. social behavior metric
mk_size = 2;
all_seg_list = nm_diff_seglist|speed_diff_seglist|dist_diff_seglist;
subplot('Position',[0.5,0.945,0.15,0.012]);
plot([axis_range(1)+0.3,axis_range(2)+0.7],[0.5,0.5],'-','Color',0.9*ones(1,3),...
    'LineWidth',6)
hold on
stem(axis_range(1):axis_range(2),all_seg_list,'k','Marker','none')
hold off
axis([axis_range(1),axis_range(2)+1,0,1])
set(gca,'YTick',[])
set(gca,'Tickdir','out')
title('Social behavior metric')
set(gca,'XTick',1:6:31)
set(gca,'XTickLabel',0:5)
box off
ax = axes('Position',get(gca,'Position'),...
          'XAxisLocation','top',...
          'YAxisLocation','right',...
          'Color','none');
set(ax,'XTick',[])
set(ax,'YTick',[])
% distance low dimensional representation
sub_num = 1000:2000;
dist_dy = cell2mat(cellfun(@(x) x',case_dsc.data_sample_cell(:,1), ...
    'UniformOutput',false));
dist_dist = mean(cell2mat(cellfun(@(x) x',case_dsc.data_sample_cell(:,7), ...
    'UniformOutput',false)),2);
sub_dist_dy = dist_dy(sub_num,:);
sub_dist_dist = round(dist_dist(sub_num,:));
unique_dist = unique(sub_dist_dist);
cmap = cbrewer2('Spectral',length(unique_dist));
cmaplist = zeros(size(sub_dist_dist,1),3);
for k = 1:size(unique_dist,1)
    selidx = sub_dist_dist==unique_dist(k);
    cmaplist(selidx,:) = ones(sum(selidx),1)*cmap(k,:);
end
subplot('Position',[0.5,0.82,0.08,0.08]);
plot(sub_dist_dy(:,1),sub_dist_dy(:,2),'-','Color',[0.7,0.7,0.7])
hold on
scatter(sub_dist_dy(:,1),sub_dist_dy(:,2),...
    mk_size*ones(size(sub_dist_dy,1),1),...
    cmaplist,'filled')
hold off
set(gca,'TickDir','out')
set(gca,'XTick',[])
set(gca,'YTick',[])
xlabel('UMAP 1')
ylabel('UMAP 2')
box off
title('Distance dynamics')
h4 = subplot('Position',[0.5,0.79,0.08,0.005]);
imagesc(1:size(cmap,1))
colormap(h4,cmap)
set(gca,'XTick',[1,size(cmap,1)/2,size(cmap,1)])
set(gca,'XTickLabel',{'Min','Distance','Max'})
set(gca,'XTickLabelRotation',0)
set(gca,'TickLength',[0,0])
set(gca,'YTick',[])
box on
subplot('Position',[0.6,0.82,0.08,0.08]);
title('ResMLP')
%% 5. social behavior atlas
mk_size = 1;
edge_x = 0.1;
edge_y = 0.1;
case_embed = cell2mat(case_dsc.data_sample_cell(:,4));
classes_list = cell2mat(case_dsc.data_sample_cell(:,8));
little_class = classes_list(:,1);
much_class =classes_list(:,2);
unique_little_class = unique(little_class);
unique_much_class = unique(much_class);
cmap = cbrewer2('Spectral',length(unique_little_class));
cmaplist = zeros(length(little_class),3);
for k = 1:size(unique_little_class,1)
    selidx = unique_little_class(k)==little_class;
    cmaplist(selidx,:) = ones(sum(selidx),1)*cmap(k,:);
end
L_img = case_wc.wc_struct.L_much==0;
XX = case_wc.wc_struct.XX_much;
YY = case_wc.wc_struct.YY_much;
hba = subplot('Position',[0.5,0.6,0.15,0.15]);
scatter(case_embed(:,1),case_embed(:,2),mk_size*ones(size(case_embed,1),1),...
    cmaplist,'filled')
hold on
im = imagesc([min(XX(:)),max(XX(:))],[min(YY(:)),max(YY(:))],L_img);
im.AlphaData = L_img;
hold off
colormap(hba,0.7*[1,1,1])
title('Social behavior atlas')
set(gca,'TickDir','out')
max_x = max(case_embed(:,1));
min_x = min(case_embed(:,1));
max_y = max(case_embed(:,2));
min_y = min(case_embed(:,2));
axis([min_x-edge_x,max_x+edge_x,min_y-edge_y,max_y+edge_y])
set(gca,'XTickLabel',[])
set(gca,'YTickLabel',[])
xlabel('Dimension 1')
ylabel('Dimension 2')
%% 6. behavior cases
box_x = 0.085;
box_y = box_x;
inter_x = 0.03;
inter_y = 0.005;
x_num = 2;
y_num = 4;
x_start = 0.65;
y_start = 0.51;
edge_x = 10;
edge_y = 10;
edge_z = [10,30,10,30];
h_cell = cell(x_num,y_num);
beh_case_idx = [...
    8309,9;...%allogrooming 278
    3882,30;...%anogenital sniffing 269
    3882,61;...%back touching 280
    1692,10;...%chasing contact 260
%     8454,1;%hunching contact 337
    ];
beh_name_list = {...
    'Allogrooming';...
    'Anogenital sniffing';...
    'Back touching';...
    'Chasing contact'};
unique_data_names = unique(case_dsc.data_sample_cell(:,3));
for n = 1:y_num
    tempidx = beh_case_idx(n,:);
    tempdataidx = case_dsc.data_sample_cell{tempidx,2};
    tempdataname = case_dsc.data_sample_cell{tempidx,3};
    seltrajsidx = find(strcmp(social_struct_cell(:,1),tempdataname)==1);
    seltrajs = social_struct_cell{seltrajsidx,2};
    selframes = cell(size(seltrajs));
    for m = 1:length(seltrajs)
        selframes{m} = seltrajs{m}(tempdataidx(1)+tempidx(2)-1,:);
    end
    for m = 1:x_num   
        xlist = [selframes{1}(1:16),selframes{2}(1:16)];
        ylist = [selframes{1}(17:32),selframes{2}(17:32)];
        zlist = [selframes{1}(33:48),selframes{2}(33:48)];
        min_x = min(xlist);
        min_y = min(ylist);
        min_z = min(zlist);
        max_x = max(xlist);
        max_y = max(ylist);
        max_z = max(zlist);
        h_cell{m,n} = subplot('Position',[...
            x_start+m*(inter_x+box_x),...
            y_start+n*(inter_y+box_y),...
            box_x,box_y]);
        clrstr = mouse1_c;
        traj1 = selframes{1}';
        tempx = traj1(1:16,:);
        tempy = traj1(17:32,:);
        tempz = traj1(33:48,:);
        temptraj1 = traj1;
        temptraj1(1:3:end) = tempx;
        temptraj1(2:3:end) = tempy;
        temptraj1(3:3:end) = tempz;
        new_mesh_mouse(temptraj1', alpha_c, clrstr)
        hold on
        plot_skl_dl(tempx(:,1),tempy(:,1),tempz(:,1),...
            'k','k',drawline)
        hold on
        clrstr = mouse2_c;
        traj1 = selframes{2}';
        tempx = traj1(1:16,:);
        tempy = traj1(17:32,:);
        tempz = traj1(33:48,:);
        temptraj1 = traj1;
        temptraj1(1:3:end) = tempx;
        temptraj1(2:3:end) = tempy;
        temptraj1(3:3:end) = tempz;
        new_mesh_mouse(temptraj1', alpha_c, clrstr)
        hold on
        plot_skl_dl(tempx(:,1),tempy(:,1),tempz(:,1),...
            'k','k',drawline)
        hold off
        axis([min_x-edge_x,max_x+edge_x,...
            min_y-edge_y,max_y+edge_y,...
            min_z-edge_z(n)/5,max_z+edge_z(n)])
        if m == 1
            view(-90,90)
%             xlabel('x')
%             ylabel('z')
            xlabel({beh_name_list{n},'x'})
        else
            view(-180,0)
%             xlabel('x')
%             ylabel('z')
            zlabel('z')
        end
        axis square
        box on
        set(gca,'XTick',[],'YTick',[],'ZTick',[])
    end
end
title(h_cell{1,end},'Top view')
title(h_cell{2,end},'Side view')
ylabel(h_cell{1,1},'y')
xlabel(h_cell{2,1},'x')
%% 7. time length distribution
fs = 30;
bar_num = 20;
bin_edge = 0:0.1:2;
bar_c = cbrewer2('Paired',1);
case_length = cellfun(@(x) size(x,2),case_dsc.data_sample_cell(:,1));
case_time_len = case_length/fs;
xdlist = case_time_len;
ker_xlist = linspace(0,2,1000);
ker_pdf = pdf(fitdist(xdlist,'kernel'),...
    ker_xlist);
ker_pdf = ker_pdf/sum(case_time_len)*1000/2;
subplot('Position',[0.06,0.43,0.385,0.1]);
temph = histogram(case_time_len,bin_edge,'FaceColor',bar_c,'FaceAlpha',1,...
    'Normalization','probability');
hold on
plot(ker_xlist,ker_pdf,'Color',[0,0,0])
hold off
axis([0,1.5,0,0.2])
box off
ylabel('Probability')
xlabel('Segment durations  [s]')
set(gca,'TickDir','out')
set(gca,'Xtick',0:0.3:1.5)
%% 8. number and class correlations
splname = cellfun(@(x) split(x,'_'),labelvideonames,...
    'UniformOutput',false);
splname1 = cellfun(@(x) str2double(x{1}),splname,...
    'UniformOutput',false);
splname = cellfun(@(x) split(x(2),'.'),splname,...
    'UniformOutput',false);
splname = cellfun(@(x) x{1},splname,...
    'UniformOutput',false);
unique_name = unique(splname);
delete_class = {'Breaking contact';'Noise'};
merge_class = {...
    'Close hunching','Synchronous behaving';...
    'Chasing','Chasing contact';...
    'Close rearing','Synchronous behaving';...
    'Grooming together','Synchronous behaving';...
    'Grooming with rearing','Moving contact';...
    'Hunching together','Synchronous behaving';...
    'Micromovement','Moving contact';...
    'Rearing together','Synchronous behaving';...
    'Rising together','Synchronous behaving';...
    'Sniffing together','Synchronous behaving';...
    };
rep_name = splname;
for k = 1:size(merge_class,1)
    selidx = strcmp(rep_name,merge_class{k,1});
    rep_name(selidx,:) = merge_class(k,2);
end
new_unique_name = unique(rep_name);
for k = 1:length(delete_class)
    selidx = strcmp(new_unique_name,delete_class{k});
    new_unique_name(selidx) = [];
end
frame_count_list = zeros(length(new_unique_name),1);
for k = 1:length(new_unique_name)
    tempname = new_unique_name{k};
    selidx = strcmp(rep_name,tempname);
    selvideonames = labelvideonames(selidx);
    tempframenum = 0;
    for m = 1:length(selvideonames)
        vidobj = VideoReader([label_video_path,'\',selvideonames{m}]);
        tempframenum = tempframenum + vidobj.NumFrames;
    end
    frame_count_list(k) = tempframenum;
    disp(k)
end
full_len = 27000*3;
frame_prop_list = frame_count_list/full_len;
%% calculate correlation coefficient
dist_mat_all = case_dist_mat.dist_mat_all;
all_labels = cell2mat(case_dsc.data_sample_cell(:,8));
sel_social_idx = all_labels(:,1)==12;
social_labels = all_labels(sel_social_idx,2);
social_dist_mat = dist_mat_all(sel_social_idx,:);
non_social_dist_mat = dist_mat_all(~sel_social_idx,:);
intra_cc_all = cell(length(new_unique_name),1);%内部相关系数
inter_cc_all = cell(length(new_unique_name),1);%外部相关系数
feat_num = 100;
for k = 1:size(intra_cc_all,1)
    %% load social cluster name
    tempname = new_unique_name{k};
    selidx = strcmp(rep_name,tempname);
    sel_class_num = splname1(selidx);
    %% select features
    sel_cc_idx = zeros(size(social_labels,1),1);
    for m = 1:length(sel_class_num)
        sel_cc_idx = sel_cc_idx | (sel_class_num{m}==social_labels);
    end
    sel_social_feat = social_dist_mat(sel_cc_idx,:);
    rand('seed',1234)
    sel_social_feat_idx = randi(size(sel_social_feat,1),1,feat_num)';
    sel_social_feat_1 = sel_social_feat(sel_social_feat_idx,:);
    rand('seed',5678)
    sel_social_feat_idx = randi(size(sel_social_feat,1),1,feat_num)';
    sel_social_feat_2 = sel_social_feat(sel_social_feat_idx,:);
    rand('seed',3456)
    sel_social_feat_idx = randi(size(non_social_dist_mat,1),1,feat_num)';
    sel_non_social_feat = non_social_dist_mat(sel_social_feat_idx,:);
    %% calculate intra cc
    temp_intra_list = zeros(feat_num,1);
    for m = 1:feat_num
        R = corrcoef(sel_social_feat_1(m,:),sel_social_feat_2(m,:));
        temp_intra_list(m,1) = R(1,2);
    end
    %% calculate inter cc
    temp_inter_list = zeros(feat_num,1);
    for m = 1:feat_num
        R = corrcoef(sel_social_feat_1(m,:),sel_non_social_feat(m,:));
        temp_inter_list(m,1) = R(1,2);
    end
    %% append data
    intra_cc_all{k,1} = temp_intra_list';
    inter_cc_all{k,1} = temp_inter_list';
end
%%
intra_cc_all_mat = cell2mat(intra_cc_all)';
inter_cc_all_mat = cell2mat(inter_cc_all)';
intra_mean = mean(intra_cc_all_mat);
intra_median = median(intra_cc_all_mat);
intra_std = std(intra_cc_all_mat);
inter_mean = mean(inter_cc_all_mat);
inter_median = median(inter_cc_all_mat);
inter_std = std(inter_cc_all_mat);
subplot('Position',[0.06,0.27,0.385,0.12]);
bar(1:length(new_unique_name),frame_prop_list,0.8,...
    'FaceColor',cbrewer2('Paired',1))
ylabel('Time proportion')
box off
set(gca,'TickDir','out')
set(gca,'XTick',1:length(new_unique_name))
set(gca,'XTickLabel',[])
axis([0.3,16.7,0,0.15])
hcc = subplot('Position',[0.06,0.12,0.385,0.12]);
bd = 0.1;
side_bias = 0.2;
for k = 1:length(intra_cc_all)
    tempy = intra_cc_all{k};
    tempx = (k-side_bias)*ones(length(tempy),1);
    violinChart(hcc,tempx,tempy,cbrewer2('Paired',1),0.2,bd);
    hold on
    plot(k-side_bias,intra_median(k),'o','MarkerFaceColor','w',...
        'MarkerEdgeColor','k','MarkerSize',2)
    hold on
    tempy = inter_cc_all{k};
    tempx = (k+side_bias)*ones(length(tempy),1);
    violinChart(hcc,tempx,tempy,0.9*[1,1,1],0.2,bd);
    hold on
    plot(k+side_bias,inter_median(k),'o','MarkerFaceColor','w',...
        'MarkerEdgeColor','k','MarkerSize',2)
    hold on
end
hold off
ylabel('Feature correlations')
set(gca,'XTick',1:length(new_unique_name))
set(gca,'XTickLabel',new_unique_name)
box off
axis([0.3,16.7,-0.9,1.3])
set(gca,'TickDir','out')
%% 9. pairr24m case data
sel_frame_idx = 9445;
edge_x = 20;
edge_y = 20;
edge_z = 10;
pair24_traj = pair24_social.SBeA.RawData.traj;
pair24_traj_1 = pair24_traj{1}(sel_frame_idx,:);
pair24_traj_2 = pair24_traj{2}(sel_frame_idx,:);
subplot('Position',[0.5,0.48,0.07,0.07]);
X1 = pair24_traj_1(1:12)';
Y1 = pair24_traj_1(13:24)';
Z1 = pair24_traj_1(25:36)';
X2 = pair24_traj_2(1:12)';
Y2 = pair24_traj_2(13:24)';
Z2 = pair24_traj_2(25:36)';
plotstr1 = mouse1_c;
linestr1 = mouse1_c;
plotstr2 = mouse2_c;
linestr2 = mouse2_c;
lw = 1;
plot_skl_pair24(X1,Y1,Z1,plotstr1,linestr1,lw)
hold on
plot_skl_pair24(X2,Y2,Z2,plotstr2,linestr2,lw)
hold off
axis([min([X1;X2])-edge_x,max([X1;X2])+edge_x,...
    min([Y1;Y2])-edge_y,max([Y1;Y2])+edge_y,...
    min([Z1;Z2]),max([Z1;Z2])+edge_z])
zlabel('3D view')
box on
grid on
set(gca,'XTickLabel',[])
set(gca,'YTickLabel',[])
set(gca,'ZTickLabel',[])
title('Pair-r24m')
subplot('Position',[0.5,0.4,0.07,0.07]);
plot_skl_pair24(X1,Y1,Z1,plotstr1,linestr1,lw)
hold on
plot_skl_pair24(X2,Y2,Z2,plotstr2,linestr2,lw)
hold off
view(2)
ylabel('2D view')
axis([min([X1;X2])-edge_x,max([X1;X2])+edge_x,...
    min([Y1;Y2])-edge_y,max([Y1;Y2])+edge_y,...
    min([Z1;Z2]),max([Z1;Z2])+edge_z])
box on
grid on
set(gca,'XTickLabel',[])
set(gca,'YTickLabel',[])
%% 10. pairr24m atlas with social label
mk_size = 1;
res_num = 1;
edge_x = 0.1;
edge_y = 0.1;
class_list = label_sample_list+1;
class_list = class_list(1:res_num:end,:);
embedding = cell2mat(pair24_dsc.data_sample_cell(:,4));
embedding =embedding(1:res_num:end,:);
etho_unique_idx = unique(class_list(:,1));
temptempcmap = cbrewer2('Paired',12);
tempcmap = [[0.7,0.7,0.7];...
    temptempcmap(2,:);...
    temptempcmap(5,:);...
    temptempcmap(12,:)];
rand('seed',1234)
randdata=1:4;%randperm(size(tempcmap,1));
extract_idx=randdata(1:size(tempcmap,1)); 
cmap = tempcmap(extract_idx,:);
cmaplist = zeros(size(embedding,1),3);
for k = 1:length(etho_unique_idx)
    selidx = etho_unique_idx(k)==class_list(:,1);
    cmaplist(selidx,:) = ones(sum(selidx),1)*cmap(etho_unique_idx(k),:);
end
L_img = pair24_wc.wc_struct.L_much==0;
XX = pair24_wc.wc_struct.XX_much;
YY = pair24_wc.wc_struct.YY_much;
hba = subplot('Position',[0.62,0.4,0.15,0.15]);
re_resize_list = [20,5,10,1];
for k = 1:4
    sel_idx = class_list==k;
    sel_embedding = embedding(sel_idx,:);
    sel_embedding = sel_embedding(1:re_resize_list(k):end,:);
    % draw ellipse
    gm = fitgmdist(sel_embedding,1);
    gmPDF = @(x,y) arrayfun(@(x0,y0) pdf(gm,[x0 y0]),x,y);

    sel_cmaplist = cmaplist(sel_idx,:);
    sel_cmaplist = sel_cmaplist(1:re_resize_list(k):end,:);
    scatter(sel_embedding(:,1),sel_embedding(:,2),...
        mk_size*ones(size(sel_embedding,1),1),...
        sel_cmaplist,'filled') 
    hold on
    if k>1
        h = fcontour(gmPDF,'LineColor',sel_cmaplist(1,:),...
            'LineWidth',1);
%         disp(sel_cmaplist(1,:))
        h.LevelList = h.LevelList(1);
    end
    hold on
end
hold on
im = imagesc([min(XX(:)),max(XX(:))],[min(YY(:)),max(YY(:))],L_img);
im.AlphaData = L_img;
hold off
colormap(hba,0.7*[1,1,1])
axis([min(embedding(:,1))-edge_x,max(embedding(:,1))+edge_x,...
    min(embedding(:,2))-edge_y,max(embedding(:,2))+edge_y])
set(gca,'TickDir','out')
set(gca,'XTickLabel',[])
set(gca,'YTickLabel',[])
title('Social behavior atlas')
% create class bar
big_class_list = {'Others','Close','Explore','Chase'};
pos_list = [0,0;0,1;1,0;1,1];
subplot('Position',[0.62,0.38,0.15,0.01])
for k = 1:length(big_class_list)
    plot(pos_list(k,1),pos_list(k,2),'.',...
        'Color',tempcmap(k,:),'MarkerSize',15)
    hold on
    text(pos_list(k,1)+0.1,pos_list(k,2),big_class_list{k},'FontSize',8)
end
hold off
axis([-0.1,2,0,1])
axis off
%% 11. pairr24m small label
unique_label = unique(sub_label_sample_list);
cmap = flipud((cbrewer2('Spectral',size(unique_label,1))));
cmaplist = zeros(size(sub_label_sample_list,1),3);
for k = 1:size(cmaplist,1)
    cmaplist(k,:) = cmap(sub_label_sample_list(k)==unique_label,:);
end
h11p = subplot('Position',[0.82,0.4,0.15,0.15]);
subsize = 10;
scatter(embedding(1:subsize:end,1),embedding(1:subsize:end,2),...
    1*ones(size(embedding(1:subsize:end,:),1),1),...
    cmaplist(1:subsize:end,:),'filled');
hold on
im = imagesc([min(XX(:)),max(XX(:))],[min(YY(:)),max(YY(:))],L_img);
im.AlphaData = L_img;
colormap(h11p,0.7*[1,1,1])
hold off
axis([min(embedding(:,1))-edge_x,max(embedding(:,1))+edge_x,...
    min(embedding(:,2))-edge_y,max(embedding(:,2))+edge_y])
set(gca,'TickDir','out')
set(gca,'XTickLabel',[])
set(gca,'YTickLabel',[])
title('Atlas with all labels')
h11 = subplot('Position',[0.82,0.38,0.15,0.01]);
imagesc(fliplr(1:length(unique_label)))
colormap(h11,cmap)
% xlabel('Label indexes')
set(gca,'XTick',[1,length(unique_label)/2,length(unique_label)])
set(gca,'XTickLabel',{1,'Label indexes',length(unique_label)})
set(gca,'XTickLabelRotation',0)
set(gca,'TickLength',[0,0])
set(gca,'YTick',[])
box on
%% 12. pairr24m distmap
zscore_embed = cell2mat(pair24_dsc.data_sample_cell(:,4));
zscore_embed = zscore_embed(1:res_num:end,:);
distlist = medfilt1(cellfun(@(x) min(x(:)),pair24_dsc.data_sample_cell(:,7)),3);
distlist = distlist(1:res_num:end,:);
normdistlist = round(mat2gray(distlist)*255+1);
cmap = cbrewer2('Spectral',256);
cmaplist = cmap(normdistlist,:);
subplot('Position',[0.5,0.2,0.15,0.15]);
scatter(zscore_embed(:,1),zscore_embed(:,2),...
    mk_size*ones(size(zscore_embed,1),1),cmaplist,'filled');
axis square
title('Distance map')
axis([min(zscore_embed(:,1))-edge_x,max(zscore_embed(:,1))+edge_x,...
    min(zscore_embed(:,2))-edge_y,max(zscore_embed(:,2))+edge_y])
set(gca,'TickDir','out')
set(gca,'XTickLabel',[])
set(gca,'YTickLabel',[])
h11 = subplot('Position',[0.5,0.18,0.15,0.01]);
imagesc(1:256)
colormap(h11,cmap)
set(gca,'XTick',[1,128,256])
set(gca,'YTick',[])
set(gca,'XTickLabel',{'Min','Distance','Max'})
set(gca,'XTickLabelRotation',0)
set(gca,'TickLength',[0,0])
box on
%% 13. social label purity
c1 = label_sample_list;
pair24_all_sbea_label = cell2mat(pair24_dsc.data_sample_cell(:,8));
unique_data_name = unique(pair24_dsc.data_sample_cell(:,3));
much_label = pair24_all_sbea_label(:,1);
unique_much_label = unique(much_label);
pur_list = -1*ones(size(unique_much_label,1),length(unique_data_name))';
for m = 1:size(pur_list,1)
    selname = unique_data_name{m};
    selnameidx = strcmp(pair24_dsc.data_sample_cell(:,3),selname);
    for n = 1:size(pur_list,2)
        sellabelidx = unique_much_label(n)==much_label;
        selidx = sellabelidx.*selnameidx;
        sel_c1 = c1(selidx==1);
        sel_c2 = much_label(selidx==1);
        sel_c2(:) = mode(sel_c1);
        try
            pur = sum(sel_c1==sel_c2(1))/length(sel_c2);
            pur_list(m,n) = pur;
        catch
            disp('error cluster!')
        end
    end
end
%
xlist = 1:size(pur_list,2);
stat_cell = cell(length(xlist),1);
subplot('Position',[0.7,0.2,0.28,0.15]);
pur_mean_list = zeros(length(xlist),1);
for k = 1:length(xlist)
    % mean and std
    temp_pur_list = pur_list(:,k);
    temp_pur_list(temp_pur_list==-1) = [];
    stat_cell{k,1} = temp_pur_list;
    tempmean = mean(temp_pur_list);
    pur_mean_list(k,1) = tempmean;
    tempstd = std(temp_pur_list);
    % plot
    bar(xlist(k),tempmean,0.6,'FaceColor',cbrewer2('Paired',1))
    hold on
    errorbar(xlist(k),tempmean,tempstd,'CapSize',3,'Color','k')
    hold on
    plot(0.3+xlist(k)*ones(size(temp_pur_list)),temp_pur_list,'o',...
        'MarkerEdgeColor','k','MarkerFaceColor','w',...
        'MarkerSize',2)
    hold on
end
hold off
box off
axis([0.5,size(pur_list,2)+0.5,0,1.2])
set(gca,'XTick',xlist)
set(gca,'TickDir','out')
set(gca,'XTickLabelRotation',0)
ylabel('Cluster purity')
xlabel('Social classes')
%% sub class label purity distribution
c1 = sub_label_sample_list;
pair24_all_sbea_label = cell2mat(pair24_dsc.data_sample_cell(:,8));
unique_data_name = unique(pair24_dsc.data_sample_cell(:,3));
much_label = pair24_all_sbea_label(:,2);
unique_much_label = unique(much_label);
pur_list = -1*ones(size(unique_much_label,1),length(unique_data_name))';
for m = 1:size(pur_list,1)
    selname = unique_data_name{m};
    selnameidx = strcmp(pair24_dsc.data_sample_cell(:,3),selname);
    for n = 1:size(pur_list,2)
        sellabelidx = unique_much_label(n)==much_label;
        selidx = sellabelidx.*selnameidx;
        sel_c1 = c1(selidx==1);
        sel_c2 = much_label(selidx==1);
        sel_c2(:) = mode(sel_c1);
        try
            pur = sum(sel_c1==sel_c2(1))/length(sel_c2);
            pur_list(m,n) = pur;
        catch
            disp('error cluster!')
        end
    end
end
%%
prec = 0.05;
hist_edge = (0:prec:1)';
pur_hist = zeros(size(pur_list,1),(size(hist_edge,1))-1);
for k = 1:size(pur_list,1)
    %%
    temppurlist = pur_list(k,:);
    temppurlist(temppurlist==-1) = [];
    pur_hist(k,:) = histcounts(temppurlist, hist_edge);
end
pur_hist = pur_hist./(sum(pur_hist,2)*ones(1,size(pur_hist,2)));
%%
mean_hist_pur = mean(pur_hist);
std_hist_pur = std(pur_hist);
xlist = 1:size(pur_hist,2);
subplot('Position',[0.5,0.05,0.48,0.1])
bar(xlist,mean_hist_pur,1,'FaceColor',cbrewer2('Paired',1))
hold on
errorbar(xlist,mean_hist_pur,std_hist_pur,'.','CapSize',3,'Color','k',...
    'Marker','none')
hold on
for k = 1:size(pur_hist,2)
    plot(0.3+xlist(k)*ones(size(pur_hist,1)),pur_hist(:,k),'o',...
        'MarkerEdgeColor','k','MarkerFaceColor','w',...
        'MarkerSize',2)
    hold on
end
hold off
box off
axis([1.5,1/prec+0.5,0,0.3])
set(gca,'YTick',0:0.1:0.3)
set(gca,'XTick',0.5:2:21)
set(gca,'XTickLabel',hist_edge(1:2:end))
set(gca,'XTickLabelRotation',0)
set(gca,'TickDir','out')
xlabel('Purity of all labels')
ylabel('Probability')


























