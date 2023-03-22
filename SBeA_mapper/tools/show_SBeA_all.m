%{
    显示SBeA全过程
%}
clear all
close all
%% set path
SBeA_struct_path = ['Z:\hanyaning\multi_mice_test\Social' ...
    '_analysis\data\' ...
    'hcl_bird\sbea_data_20220919\BeA_path\social_struct'];
fileNames = {'B1_B2_rec3-B1B2-20220919_social_struct.mat'};
videopath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'hcl_bird\sbea_data_20220919\BeA_path'];
dscpath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'hcl_bird\sbea_data_20220919\BeA_path\recluster_data'];
videoname = 'B1-rec3-B1B2-20220919.avi';
distmatname = 'SBeA_dist_mat_all_20221107.mat';
dscname = 'SBeA_data_sample_cell_20221107.mat';
savename = [videoname(1:(end-4)),'_sbea_all.avi'];
%% load data
ReMap_move_cell = cell(size(fileNames,1),1);
Seglist_move_cell = cell(size(fileNames,1),1);
ReMap_speed_cell = cell(size(fileNames,1),1);
Seglist_speed_cell = cell(size(fileNames,1),1);
ReMap_dist_cell = cell(size(fileNames,1),1);
Seglist_dist_cell = cell(size(fileNames,1),1);
data_move_cell = cell(size(fileNames,1),1);
data_speed_cell = cell(size(fileNames,1),1);
data_dist_cell = cell(size(fileNames,1),1);
for k = 1:size(fileNames,1)
    %% load data
    tempdata = load([SBeA_struct_path,'\',fileNames{k,1}]);
    %%
    fs = tempdata.SBeA.DataInfo.fs;
    ReMap_move_cell{k,1} = tempdata.SBeA.SBeA_DecData.L2.ReMap;
    Seglist_move_cell{k,1} = tempdata.SBeA.SBeA_DecData.L2.Seglist;
    ReMap_speed_cell{k,1} = tempdata.SBeA.SBeA_DecData_speed.L2.ReMap;
    Seglist_speed_cell{k,1} = tempdata.SBeA.SBeA_DecData_speed.L2.Seglist;
    ReMap_dist_cell{k,1} = tempdata.SBeA.SBeA_DecData_dist.L2.ReMap;
    Seglist_dist_cell{k,1} = tempdata.SBeA.SBeA_DecData_dist.L2.Seglist;
    data_move_cell{k,1} = tempdata.SBeA.RawData.selseg;
    data_speed_cell{k,1} = cell2mat(tempdata.SBeA.RawData.speed);
    data_dist_cell{k,1} = tempdata.SBeA.RawData.dist_body;
    disp(k)
    toc
end
load([dscpath,'\',distmatname]);
load([dscpath,'\',dscname]);
%%
traj1 = tempdata.SBeA.RawData.traj{1}';
traj2 = tempdata.SBeA.RawData.traj{2}';
full_len = size(traj1,1)/3;
X1 = traj1(1:full_len,:);
Y1 = traj1((full_len+1):(2*full_len),:);
Z1 = traj1((2*full_len+1):(3*full_len),:);
X2 = traj2(1:full_len,:);
Y2 = traj2((full_len+1):(2*full_len),:);
Z2 = traj2((2*full_len+1):(3*full_len),:);
mean_X = (mean(X1(:))+mean(X2(:)))/2;
mean_Y = (mean(Y1(:))+mean(Y2(:)))/2;
mean_Z = (mean(Z1(:))+mean(Z2(:)))/2;
axis_bias_x = 200;
axis_bias_y = 200;
axis_bias_z = 100;
min_X = mean_X-axis_bias_x;
min_Y = mean_Y-axis_bias_y;
min_Z = -50;
max_X = mean_X+axis_bias_x;
max_Y = mean_Y+axis_bias_y;
max_Z = mean_Z+axis_bias_z;

cent_traj1 = tempdata.SBeA.RawData.centered{1};
cent_traj2 = tempdata.SBeA.RawData.centered{2};
cent_X1 = cent_traj1(1:3:end,:);
cent_Y1 = cent_traj1(2:3:end,:);
cent_Z1 = cent_traj1(3:3:end,:);
cent_X2 = cent_traj2(1:3:end,:);
cent_Y2 = cent_traj2(2:3:end,:);
cent_Z2 = cent_traj2(3:3:end,:);
cent_mean_X = (mean(cent_X1(:))+mean(cent_X2(:)))/2;
cent_mean_Y = (mean(cent_Y1(:))+mean(cent_Y2(:)))/2;
cent_mean_Z = (mean(cent_Z1(:))+mean(cent_Z2(:)))/2;
cent_axis_bias_x = 50;
cent_axis_bias_y = 50;
cent_axis_bias_z = 100;
cent_min_X = cent_mean_X-cent_axis_bias_x;
cent_min_Y = cent_mean_Y-cent_axis_bias_y;
cent_min_Z = -50;
cent_max_X = cent_mean_X+cent_axis_bias_x;
cent_max_Y = cent_mean_Y+cent_axis_bias_y;
cent_max_Z = cent_mean_Z+cent_axis_bias_z;
%%
res_len = 2;
trans_6data = cell2mat(cellfun(@(x) x',data_sample_cell(:,1),...
    'UniformOutput',false));
dist_umap = trans_6data(1:res_len:end,1:2)';
speed_umap = trans_6data(1:res_len:end,3:4)';
move_umap = trans_6data(1:res_len:end,5:6)';
zs_embed = cell2mat(data_sample_cell(:,4));
%% load videos
vidobj = VideoReader([videopath,'\',videoname]);
%% create savelist
savelist_cell = recluster_savelist_3(...
    ReMap_move_cell,Seglist_move_cell,...
    ReMap_speed_cell,Seglist_speed_cell,...
    ReMap_dist_cell,Seglist_dist_cell);
%% resize distmat
res_dist = zeros(vidobj.NumFrames,vidobj.NumFrames);
res_label_1 = zeros(1,vidobj.NumFrames);
res_label_2 = zeros(1,vidobj.NumFrames);
res_embed = zeros(vidobj.NumFrames,2);
for m = 1:size(savelist_cell{1},1)
    templist = zeros(size(res_dist,1),1);
    for n = 1:size(savelist_cell{1},1)
        templist(savelist_cell{1}(n,1):savelist_cell{1}(n,2),1) = ...
            dist_mat_all(n,m);
    end
    templen = savelist_cell{1}(m,2)-savelist_cell{1}(m,1)+1;
    res_dist(:,savelist_cell{1}(m,1):savelist_cell{1}(m,2)) = ...
       templist*ones(1,templen); 
    res_label_1(:,savelist_cell{1}(m,1):savelist_cell{1}(m,2)) = ...
        data_sample_cell{m,8}(1,1);
    res_label_2(:,savelist_cell{1}(m,1):savelist_cell{1}(m,2)) = ...
        data_sample_cell{m,8}(1,2);
    res_embed(savelist_cell{1}(m,1):savelist_cell{1}(m,2),:) = ...
        ones(templen,1)*zs_embed(m,:);
end
res_res_dist = imresize(res_dist,[270,270]);
res_res_embed = res_embed(1:res_len:end,:); 
diff_res_label_2 = [0,diff(res_label_2)]~=0;
res_res_label_1 = res_label_1(1:res_len:end);
unique_label = unique(res_res_label_1);
label_cmap = cbrewer2('Spectral',length(unique_label));
label_cmap_list = zeros(size(res_res_label_1,1),3);
for k = 1:size(label_cmap,1)
    sel_idx = unique_label(k) == res_res_label_1;
    label_cmap_list(sel_idx,:) = ones(sum(sel_idx),1)*label_cmap(k,:);
end
%% show and save video
h1 = figure(1);
set(h1,'Position',[100,100,1280,720])
set(h1,'color','white');
mouseclr = [1,0,0;0,0,1];
show_map_len = 90;
writeobj = VideoWriter([dscpath,'\',savename]);
open(writeobj)
for k = 1:1:vidobj.NumFrames
    %% load data
    frame = read(vidobj,k);
    %% 
    subplot('Position',[0.01,0.68,0.2,0.3])
    imshow(frame)
    title(['Labeled frames: ',num2str(k)])
    %% 3D
    subplot('Position',[0.03,0.38,0.16,0.25])
    plot_skl_bird(X1(:,k),Y1(:,k),Z1(:,k),...
        mouseclr(1,:),...
        mouseclr(1,:))
    hold on
    plot_skl_bird(X2(:,k),Y2(:,k),Z2(:,k),...
        mouseclr(2,:),...
        mouseclr(2,:))
    hold off
    axis([min_X,max_X,min_Y,max_Y,min_Z,max_Z])
    grid on
    set(gca,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[])
    xlabel('x')
    ylabel('y')
    zlabel('z')
    title('Raw 3D')
    %% centered 3D
    subplot('Position',[0.03,0.04,0.16,0.25])
    plot_skl_bird(cent_X1(:,k),cent_Y1(:,k),cent_Z1(:,k),...
        mouseclr(1,:),...
        mouseclr(1,:))
    hold on
    plot_skl_bird(cent_X2(:,k),cent_Y2(:,k),cent_Z2(:,k),...
        mouseclr(2,:),...
        mouseclr(2,:))
    hold off
    axis([cent_min_X,cent_max_X,cent_min_Y,cent_max_Y,cent_min_Z,cent_max_Z])
    grid on
%     set(gca,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[])
    xlabel('x')
    ylabel('y')
    zlabel('z')
    title('Centered 3D')
    view(2)
    %% distmat
    subplot('Position',[0.25,0.69,0.7,0.27])
    imagesc(res_res_dist)
    hold on
    plot(k/100*ones(1,vidobj.NumFrames/100),1:(vidobj.NumFrames/100),...
        'r-','LineWidth',2)
    hold on
    plot(1:(vidobj.NumFrames/100),k/100*ones(1,vidobj.NumFrames/100),...
        'r-','LineWidth',2)
    hold off
    axis off
    title('Dist mat')
    %% watershed label 
    hl1 = subplot('Position',[0.25,0.64,0.7,0.03]);
    imagesc(res_label_1)
    colormap(hl1,label_cmap)
    box on
    set(gca,'XTick',[],'YTick',[])
    title('Social behavior classes H2')
    subplot('Position',[0.25,0.59,0.7,0.03])
    plot(diff_res_label_2,'Color',[1,1,1]*0.7)
    axis([1,length(diff_res_label_2),0,1])
    box on
    set(gca,'XTick',[],'YTick',[])
    title('Social behavior classes H1')
    %% 
    subplot('Position',[0.25,0.51,0.7,0.08])
    plot(dist_umap(1,:))
    hold on
    plot(dist_umap(2,:))
    hold on
    plot([k/res_len,k/res_len],[-3,3],'r-')
    hold off
    axis([1,size(dist_umap,2),-3,3])
    ylabel('dist umap')
    subplot('Position',[0.25,0.43,0.7,0.08])
    plot(speed_umap(1,:))
    hold on
    plot(speed_umap(2,:))
    hold on
    plot([k/res_len,k/res_len],[-3,3],'r-')
    hold off
    axis([1,size(speed_umap,2),-3,3])
    ylabel('speed umap')
    subplot('Position',[0.25,0.35,0.7,0.08])
    plot(move_umap(1,:))
    hold on
    plot(move_umap(2,:))
    hold on
    plot([k/res_len,k/res_len],[-3,3],'r-')
    hold off
    axis([1,size(move_umap,2),-3,3])
    ylabel('move umap')
    %% 2D map
    subplot('Position',[0.25,0.05,0.14,0.25])
    plot(dist_umap(1,:),dist_umap(2,:),'o','MarkerFaceColor',[0.5,0.5,0.5],...
        'MarkerEdgeColor',[0.5,0.5,0.5],'MarkerSize',2)
    hold on
    if k < show_map_len+1
        plot(dist_umap(1,ceil((1:k)/res_len)),dist_umap(2,ceil((1:k)/res_len)),...
            'g-','LineWidth',2)
    else
        plot(dist_umap(1,ceil(((k-show_map_len):k)/res_len)),...
            dist_umap(2,ceil(((k-show_map_len):k)/res_len)),'g-','LineWidth',2)
    end
    hold on
    plot(dist_umap(1,ceil(k/res_len)),dist_umap(2,ceil(k/res_len)),'+',...
        'MarkerEdgeColor','r','MarkerSize',10,'LineWidth',2)    
    hold off
    axis([-3,3,-3,3])
    ylabel('Dist 2D map')
    subplot('Position',[0.43,0.05,0.14,0.25])
    plot(speed_umap(1,:),speed_umap(2,:),'o','MarkerFaceColor',[0.5,0.5,0.5],...
        'MarkerEdgeColor',[0.5,0.5,0.5],'MarkerSize',2)
    hold on
    if k < show_map_len+1
        plot(speed_umap(1,ceil((1:k)/res_len)),speed_umap(2,ceil((1:k)/res_len)),...
            'g-','LineWidth',2)
    else
        plot(speed_umap(1,ceil(((k-show_map_len):k)/res_len)),...
            speed_umap(2,ceil(((k-show_map_len):k)/res_len)),'g-','LineWidth',2)
    end
    hold on
    plot(speed_umap(1,ceil(k/res_len)),speed_umap(2,ceil(k/res_len)),'+',...
        'MarkerEdgeColor','r','MarkerSize',10,'LineWidth',2)  
    hold off
    axis([-3,3,-3,3])
    ylabel('Speed 2D map')
    subplot('Position',[0.61,0.05,0.14,0.25])
    plot(move_umap(1,:),move_umap(2,:),'o','MarkerFaceColor',[0.5,0.5,0.5],...
        'MarkerEdgeColor',[0.5,0.5,0.5],'MarkerSize',2)
    hold on
    if k < show_map_len+1
        plot(move_umap(1,ceil((1:k)/res_len)),move_umap(2,ceil((1:k)/res_len)),...
            'g-','LineWidth',2)
    else
        plot(move_umap(1,ceil(((k-show_map_len):k)/res_len)),...
            move_umap(2,ceil(((k-show_map_len):k)/res_len)),'g-','LineWidth',2)
    end
    hold on
    plot(move_umap(1,ceil(k/res_len)),move_umap(2,ceil(k/res_len)),'+',...
        'MarkerEdgeColor','r','MarkerSize',10,'LineWidth',2)  
    hold off
    axis([-3,3,-3,3])
    ylabel('Move 2D map')
    subplot('Position',[0.81,0.05,0.14,0.25])
    scatter(res_res_embed(:,1),res_res_embed(:,2),...
        2*ones(size(res_res_embed,1),1),label_cmap_list)
%     plot(res_res_embed(:,1),res_res_embed(:,2),'o','MarkerFaceColor',[0.5,0.5,0.5],...
%         'MarkerEdgeColor',[0.5,0.5,0.5],'MarkerSize',2)
    hold on
    if k < show_map_len+1
        plot(res_res_embed(ceil((1:k)/res_len),1),res_res_embed(ceil((1:k)/res_len),2),...
            'g-','LineWidth',2)
    else
        plot(res_res_embed(ceil(((k-show_map_len):k)/res_len),1),...
            res_res_embed(ceil(((k-show_map_len):k)/res_len),2),'g-','LineWidth',2)
    end
    hold on
    plot(res_res_embed(ceil(k/res_len),1),res_res_embed(ceil(k/res_len),2),'+',...
        'MarkerEdgeColor','r','MarkerSize',10,'LineWidth',2)  
    hold off
    ylabel('Behavior atlas')
    %% save video
    showframe = getframe(h1);
    writeVideo(writeobj,showframe.cdata)
    %%
    pause(0.00000001)
end
close(writeobj)




























