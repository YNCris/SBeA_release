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
%% plot
rootpath = 'Z:\hanyaning\multi_mice_test\Social_analysis\data\figs\fig4';
%% 1. distance representation of LDE
p1name = [rootpath,'\panel_1\SBeA_data_sample_cell_20220623.mat'];
wcname = [rootpath,'\panel_1\SBeA_wc_struct_20220623.mat'];
load(wcname);
load(p1name);

idxall = cell2mat(data_sample_cell(:,8));
idx_little = idxall(:,1);
idx_much = idxall(:,2);
%%
bound_xy = 0.1;
zscore_embed = cell2mat(data_sample_cell(:,4));
distlist = medfilt1(cellfun(@(x) min(x(:)),data_sample_cell(:,7)),3);
normdistlist = round(mat2gray(distlist)*255+1);
cmap = cbrewer2('BuPu',384);%turbo(256);
cmap = cmap(129:end,:);
cmaplist = cmap(normdistlist,:);
h11 = subplot('Position',[0.06,0.7,0.23,0.23]);
scatter(zscore_embed(:,1),zscore_embed(:,2),4*ones(size(zscore_embed,1),1),cmaplist,'filled');
axis square
hold on
tempmuch = wc_struct.L_much;
bwtempmuch = tempmuch==0;
hclass = imagesc(wc_struct.XX_much(1,:),wc_struct.YY_much(:,1)',bwtempmuch);
colormap(h11,[1,1,1;0.5*[1,1,1]])
set(hclass,'AlphaData',bwtempmuch==1)
% alpha(0.1)
hold off
set(gca,'XLim',[min(zscore_embed(:,1))-bound_xy,max(zscore_embed(:,1))+bound_xy])
set(gca,'YLim',[min(zscore_embed(:,2))-bound_xy,max(zscore_embed(:,2))+bound_xy])
set(gca,'XTick',[])
set(gca,'YTick',[])
xlabel('UMAP 1')
ylabel('UMAP 2')
% colorbar
h12 = subplot('Position',[0.2,0.93,0.05,0.01]);
imagesc(1:100)
colormap(h12,cmap)
axis off
text(-60,0.5,'min')
text(110,0.5,'max')
title('Distance')
%% 2. Social behavior
subplot('Position',[0.06,0.55,0.1,0.1])
subplot('Position',[0.06,0.45,0.1,0.1])
subplot('Position',[0.06,0.35,0.1,0.1])
subplot('Position',[0.06,0.25,0.1,0.1])
subplot('Position',[0.06,0.15,0.1,0.1])
%% 3. Non-social behavior
subplot('Position',[0.19,0.55,0.1,0.1])
subplot('Position',[0.19,0.45,0.1,0.1])
subplot('Position',[0.19,0.35,0.1,0.1])
subplot('Position',[0.19,0.25,0.1,0.1])
subplot('Position',[0.19,0.15,0.1,0.1])
%% 21  27 45 70 75  95 103  112  113    
% 3 11 13 35 44 65 68 71 73 76 78 84 86 88 99 101 104 106 115 122 125 154
% 158 171 174 179 183 188 191 193 
% 195 210 211 213 217(very good) 219 221(very good) 227 234 239 241 245 261
%% 4. distance representation of raw data, dynamics representation
sel_far = [21,27,45,70,75,95,103,112,113];
sel_mid = [3,11,13,35,44,65,68,71,73,76,78,84,86,88,99,101,...
    104,106,115,122,125,154,158,171,174,179,183,188,191,193];
sel_close = [195,210,211,213,217,219,221,227,234,239,241,245,261];
sel_list = [sel_far,sel_mid,sel_close];
sel_sel_list = [11,106,158,217];
%{'Running away','Wandering','Approaching','Moving contact'}
down_sample = 2;
arrow_resize = 2;
traj_cmap = cbrewer2('ORRD',256);
traj_cmap = traj_cmap(129:end,:);
sel_cmap_list = traj_cmap(1:size(traj_cmap,1)/length(sel_sel_list):end,:);
count = 1;

subplot('Position',[0.36,0.7,0.23,0.23])

tempdata = cellfun(@(x) x',data_sample_cell(:,1),'UniformOutput',false);
raw_embed = cell2mat(tempdata);
tempdata = cellfun(@(x) x',data_sample_cell(:,7),'UniformOutput',false);
raw_dist = cell2mat(tempdata);
min_raw_dist = min(raw_dist,[],2);
normdistlist = round(mat2gray(min_raw_dist)*255+1);
cmap = cbrewer2('BuPu',384);%turbo(256);
cmap = cmap(129:end,:);
% cmap = cmap(129:384,:);
cmaplist = cmap(normdistlist,:);
scatter(raw_embed(:,1),raw_embed(:,2),4*ones(size(raw_embed,1),1),cmaplist,'filled');
axis square
hold on
for p = sel_sel_list
    sel_class_idx = p;
    sel_data = cell(size(sel_class_idx));
    for k = 1:size(sel_data,2)
        sel_data{k} = data_sample_cell(idx_much==sel_class_idx(k),:);
    end
    %plot trajs
    for m = 1:size(sel_data,2)
        temp_sel_data = sel_data{m};
        len_tempdata = cellfun(@(x) size(x,2),temp_sel_data(:,1));
        temp_sel_data(len_tempdata<2,:) = [];
        arrow_pos = cell2mat(cellfun(@(x) [x(:,end-1)',x(:,end)'],...
            temp_sel_data(:,1),'UniformOutput',false));
        for n = 1:down_sample:size(temp_sel_data,1)
            temptraj = temp_sel_data{n,1};
            plot(temptraj(1,:),temptraj(2,:),'-','Color',sel_cmap_list(count,:))
            hold on
        end
        X = arrow_pos(1:down_sample:end,1);
        Y = arrow_pos(1:down_sample:end,2);
        U = arrow_pos(1:down_sample:end,3)-arrow_pos(1:down_sample:end,1);
        V = arrow_pos(1:down_sample:end,4)-arrow_pos(1:down_sample:end,2);
        len_UV = ((U.^2+V.^2).^0.5)*arrow_resize;
        U = U./len_UV;
        V = V./len_UV;
        quiver(X,Y,U,V,0,'Color',sel_cmap_list(count,:));
        hold on
    end
    count = count +1;
    
    set(gca,'XLim',[-2.3,2.1])
    set(gca,'YLim',[-2.1,2.3])
    set(gca,'XTick',[])
    set(gca,'YTick',[])
    xlabel('UMAP 1')
    ylabel('UMAP 2')
    disp(p)
    pause(0.1)
end
hold off
% colorbar
h12 = subplot('Position',[0.49,0.93,0.05,0.01]);
imagesc(1:100)
colormap(h12,cmap)
axis off
text(-60,0.5,'min')
text(110,0.5,'max')
title('Distance')
%% 5. Speed space 3D

subplot('Position',[0.66,0.7,0.23,0.23])

speedlist = cellfun(@(x) mean(x(:)),data_sample_cell(:,6));
smospeedlist = medfilt1(speedlist,11);
normspeedlist = round(mat2gray(smospeedlist)*255+1);
cmap = cbrewer2('BuPu',384);%turbo(256);
cmap = cmap(129:end,:);
cmaplist = cmap(normspeedlist,:);
scatter3(zscore_embed(:,1),zscore_embed(:,2),smospeedlist,...
   4*ones(size(zscore_embed,1),1),cmaplist,'filled');
view(131,50)
set(gca,'XTickLabel',[])
set(gca,'YTickLabel',[])
set(gca,'ZTickLabel',[0,20,40])
xlabel('UMAP 1')
ylabel('UMAP 2')
zlabel('Speed cm/s')
% colorbar
h12 = subplot('Position',[0.79,0.93,0.05,0.01]);
imagesc(1:100)
colormap(h12,cmap)
axis off
text(-60,0.5,'min')
text(110,0.5,'max')
title('Speed')
%% 6. Dynamical behaviors
subplot('Position',[0.36,0.55,0.1,0.1])
xlabel('Moving contact','Color',sel_cmap_list(4,:))
subplot('Position',[0.5,0.55,0.1,0.1])
xlabel('Approaching','Color',sel_cmap_list(3,:))
subplot('Position',[0.64,0.55,0.1,0.1])
xlabel('Wandering','Color',sel_cmap_list(2,:))
subplot('Position',[0.78,0.55,0.1,0.1])
xlabel('Running away','Color',sel_cmap_list(1,:))
%% 7. HMM states
subplot('Position',[0.36,0.15,0.5,0.3])























