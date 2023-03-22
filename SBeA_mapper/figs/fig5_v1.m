%{
   SBeA for shank3 and wt compare
%}
clear all
close all
addpath(genpath(pwd))
%% set path
rootpath = 'Z:\hanyaning\multi_mice_test\Social_analysis\data\figs\fig5';
%% plot canvas
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
set(h1,'color','white');
%% load data
dsc = load([rootpath,'\panel_1\SBeA_data_sample_cell_20221209.mat']);
wc = load([rootpath,'\panel_1\SBeA_wc_struct_20221209.mat']);
beh_seg_path = [rootpath,'\panel_last'];
traj_path = [rootpath,'\panel_last_1'];
%% analysis
beh_labels = cell2mat(dsc.data_sample_cell(:,8));
unique_little_labels = unique(beh_labels(:,1));
unique_much_labels = unique(beh_labels(:,2));
unique_data_name = unique(dsc.data_sample_cell(:,3));
tempsplname = cellfun(@(x) split(x,'_'),unique_data_name,...
    'UniformOutput',false);
%
mice_names = {...
    'M1','KO';
    'M2','KO';
    'M3','KO';
    'M4','KO';
    'M5','KO';
    'M6','WT';
    'M7','WT';
    'M8','WT';
    'M9','WT';
    'M10','WT'};
% generate groups
group_names = cell(size(tempsplname,1),5);
for k = 1:size(group_names,1)
    %
    tempname1 = tempsplname{k,1}{1};
    tempname2 = tempsplname{k,1}{2};
    selidx1 = find(strcmp(tempname1,mice_names(:,1)));
    selidx2 = find(strcmp(tempname2,mice_names(:,1)));
    group_names{k,1} = unique_data_name{k,1};
    group_names{k,2} = mice_names{selidx1,2};
    group_names{k,3} = mice_names{selidx2,2};
    group_names{k,4} = [mice_names{selidx1,2},'-',mice_names{selidx2,2}];
    if strcmp(group_names{k,4},'WT-WT')
        group_names{k,5} = 1;
    elseif strcmp(group_names{k,4},'KO-KO')
        group_names{k,5} = 3;
    else
        group_names{k,5} = 2;
    end
end
% 
unique_group_idx = unique(cell2mat(group_names(:,5)));
fractions_little = zeros(length(unique_little_labels),...
    size(group_names,1));
fractions_much = zeros(length(unique_much_labels),...
    size(group_names,1));
sort_group_names = sortrows(group_names,5);
for k = 1:size(sort_group_names,1)
    %
    tempname = sort_group_names{k,1};
    sel_data_sample_cell = dsc.data_sample_cell(...
        strcmp(tempname,dsc.data_sample_cell(:,3)),:);
    all_frame_num = sum(cell2mat(cellfun(@(x) size(x,2),...
        sel_data_sample_cell(:,1),...
        'UniformOutput',false)));
    %
    sel_labels = cell2mat(sel_data_sample_cell(:,8));
    tab_little_label = tabulate(sel_labels(:,1));
    tab_much_label = tabulate(sel_labels(:,2));
    fractions_little(tab_little_label(:,1),k) = tab_little_label(:,3)/100;
    fractions_much(tab_much_label(:,1),k) = tab_much_label(:,3)/100;
end
%% 1. experiment procedure
subplot('Position',[0.05,0.75+0.03,0.2,0.2])
%% 2. Behavior atlas
start_x = 0.41;
start_y = 0.75+0.03;
box_size = 0.2;
hba = subplot('Position',[start_x,start_y,box_size,box_size]);
mk_size = 3;
res_num = 1;
ethogram_list = cell2mat(cellfun(@(x,y) ones(size(x,2),1)*y,...
    dsc.data_sample_cell(:,1),...
    dsc.data_sample_cell(:,8),'UniformOutput',false));
etho_unique_idx = unique(ethogram_list(:,1));
class_list = cell2mat(dsc.data_sample_cell(:,8));
embedding = cell2mat(dsc.data_sample_cell(:,4));
zscore_embed = embedding(1:res_num:end,:);
distlist = medfilt1(cellfun(@(x) min(x(:)),dsc.data_sample_cell(:,7)),3);
distlist = distlist(1:res_num:end,:);
normdistlist = round(mat2gray(distlist)*255+1);
cmap = flipud(cbrewer2('Spectral',256));
cmaplist = cmap(normdistlist,:);
scatter(zscore_embed(:,1),zscore_embed(:,2),...
    mk_size*ones(size(zscore_embed,1),1),cmaplist,'filled');
L_img = wc.wc_struct.L_much==0;
XX = wc.wc_struct.XX_much;
YY = wc.wc_struct.YY_much;
hold on
im = imagesc([min(XX(:)),max(XX(:))],[min(YY(:)),max(YY(:))],L_img);
im.AlphaData = L_img;
hold off
colormap(hba,0.7*[1,1,1])
min_x = min(zscore_embed(:,1));
max_x = max(zscore_embed(:,1));
min_y = min(zscore_embed(:,2));
max_y = max(zscore_embed(:,2));
axis([min_x,max_x,min_y,max_y])
axis square
set(gca,'XTick',[])
set(gca,'YTick',[])
title('Distance map')
xlabel('Dimension 1')
ylabel('Dimension 2')
temph = subplot('Position',...
    [start_x+box_size+0.002,start_y+box_size-0.05,0.005,0.05]);
imagesc((1:size(cmap,1))')
box on
set(gca,'XTick',[],'YTick',[])
colormap(temph,cmap)
title('min max')
%% 3. Density distribution of three groups
group_embed = cell(size(unique_group_idx,1),1);
density_cell = cell(size(group_embed));
sigma = 2;
prec = 0.07;
for k = 1:size(unique_group_idx,1)
    % select group name
    group_idx = unique_group_idx(k,1);
    sel_name = group_names(cell2mat(group_names(:,5))==group_idx,:);
    % select embedding
    sel_data_idx = zeros(size(dsc.data_sample_cell,1),1);
    for m = 1:size(sel_name,1)
        temp_sel_name = sel_name(m,1);
        tempselidx = strcmp(dsc.data_sample_cell(:,3),temp_sel_name);
        sel_data_idx = sel_data_idx+double(tempselidx);
    end
    group_embed{k,1} = embedding(sel_data_idx==1,:);
    [image,XX,YY,embed_img] = data_density(group_embed{k,1}, sigma, prec);
    density_cell{k,1} = {image,XX,YY,embed_img};
end
cmap_num = 256;
group_cmap_str = {...
    'Greens',...
    'Purples',...
    'Oranges'};
group_name = {...
    'WT-WT',...
    'WT-KO',...
    'KO-KO'};
%
start_x = 0.71;
start_y = 0.75+0.03;
box_size = 0.2;
subplot('Position',[start_x,start_y,box_size,box_size])
for k = 1:size(group_cmap_str,2)
    temp_dens = density_cell{k,1}{1,1};
    unique_dens = unique(temp_dens(:));
    new_dens = zeros(size(temp_dens,1),size(temp_dens,2),3);
    seg_len = round(length(unique_dens)/cmap_num);
    cmap_unique_dens = zeros(size(unique_dens,1),3);
    start_pos = (1:seg_len:length(unique_dens))';
    end_pos = [start_pos(2:end)+1;length(unique_dens)];
    group_cmap = cbrewer2(group_cmap_str{k},length(start_pos));
    for m = 1:size(group_cmap,1)
        cmap_unique_dens(start_pos(m):end_pos(m),:) = ...
            ones(end_pos(m)-start_pos(m)+1,1)*group_cmap(m,:);
    end
    for m = 1:length(unique_dens)
        for n = 1:3
            temptempdens = zeros(size(temp_dens));
            temptempdens(temp_dens==unique_dens(m)) = ...
                cmap_unique_dens(m,n);
            new_dens(:,:,n) = new_dens(:,:,n)+temptempdens;
        end
    end
%     figure
    temph = mesh(density_cell{k,1}{1,2},...
        density_cell{k,1}{1,3},...
        density_cell{k,1}{1,1},new_dens,'EdgeAlpha',0.3,...
        'LineWidth',1,'FaceColor','w','FaceAlpha',1);  
    hold on
end
hold off
view(-67,47)
% view(2)
% axis([min_x,max_x,min_y,max_y])
title('Density map')
set(gca,'XTickLabel',[],'YTickLabel',[])
zlabel('Normalized density')
xlabel('Dimension 1')
ylabel('Dimension 2')
%%
plot_edge = 0.005;
plot_x = 0.03;
plot_y = 0.01;
plot_start_x = start_x+box_size;
plot_start_y = 0.9;
for k = 1:size(group_cmap_str,2)
    temph = subplot('Position',[plot_start_x,...
        plot_start_y+(k-1)*(plot_edge+plot_y),plot_x,plot_y]);
    imagesc(1:cmap_num)
    colormap(temph,cbrewer2(group_cmap_str{k},cmap_num))
    set(gca,'XTick',[],'YTick',[])
    ylabel(group_name{k},'Rotation',0)
    set(gca,'YAxisLocation','right')
end
%% 5. compare of much classes (clustergram, need cluster tree)
% using behavior with significant difference
% create colormap
sel_much = 1:260;%[1,2,3,4,5,7,9,48,70,75,78,92,93,175,182,195,196,...
    %201,205,227,239,243,244,258];
% normalize sel_fractions_much
temp_fractions_much = fractions_much(sel_much,:);
norm_fractions_much = zeros(size(temp_fractions_much));
for k = 1:size(norm_fractions_much,1)
    norm_fractions_much(k,:) = mat2gray(temp_fractions_much(k,:));
end
sel_fractions_much = norm_fractions_much;


group_idx = [(1:20)',ones(20,1);...
             (21:40)',2*ones(20,1);...
             (41:60)',3*ones(20,1)];
cmap_list = zeros(size(group_idx,1),3);
for k = 1:size(group_idx,1)
     tempcmap = cbrewer2(group_cmap_str{group_idx(k,2)},128);
     cmap_list(k,:) = tempcmap(64,:);
end
D_beh = pdist(sel_fractions_much,'seuclidean');
Z_beh = squareform(D_beh);
tree_beh = linkage(Z_beh, 'ward','euclidean');
leafOrder_beh = optimalleaforder(tree_beh,D_beh);
D_animal = pdist(sel_fractions_much','seuclidean');
Z_animal = squareform(D_animal);
tree_animal = linkage(Z_animal, 'ward','euclidean');
leafOrder_animal = optimalleaforder(tree_animal,D_animal);
leafOrder_animal = 1:60;
sort_fractions_much = sel_fractions_much(leafOrder_beh,:);
sort_fractions_much = sort_fractions_much(:,leafOrder_animal);
% sort groups
for k = 1:size(group_name,2)
    selfrac = sort_fractions_much(:,((k-1)*20+1):(k*20));
    % find most change
    tempselfrac = sum(abs(diff(selfrac)));
    init_frac = selfrac(:,tempselfrac==min(tempselfrac));
    % sort
    newselfrac = selfrac;
    newselfrac(:,1) = init_frac;
    selfrac(:,tempselfrac==max(tempselfrac)) = [];
    for m = 2:size(newselfrac,2)
        tempfrac = newselfrac(:,m-1);
        mind = sqrt(sum((tempfrac*ones(1,size(selfrac,2))...
        -selfrac).^2,1));
        newselfrac(:,m) = selfrac(:,mind==min(mind));
        selfrac(:,mind==min(mind)) = [];
    end
    sort_fractions_much(:,((k-1)*20+1):(k*20)) = newselfrac;
end
%
tree_beh(:,3) = 1:size(tree_beh,1);
tree_animal(:,3) = 1:size(tree_animal,1);
%
start_x = 0.03;
start_y = 0.53+0.04;
tree_width = 0.02;
box_size_x = 0.43;
box_size_y = 0.15;
edge_dist = 0.005;
% heatmap
temph = subplot('Position',[start_x,start_y,box_size_x,box_size_y]);
imagesc(sort_fractions_much')
colormap(temph,flipud(cbrewer2('RdBu',256)))
xlabel('Social behavior module IDs')
% colormap(temph,mat2gray(imresize(redbluecmap(11),[256,3])))
set(gca,'XTick',[1,130,260])
set(gca,'TickDir','out')
set(gca,'YTick',[])
% top tree
subplot('Position',[start_x,...
    start_y+box_size_y,box_size_x,tree_width])
dendrogram(tree_beh,0,'Orientation','top','Reorder',leafOrder_beh)
axis off
axis([0.5,size(tree_beh,1)+1.5,0,max(tree_beh(:,3))])
% set(gca,'YDir','reverse')
% animal group
temph = subplot('Position',[start_x-edge_dist-0.002,start_y,...
    edge_dist,box_size_y]);
imagesc(leafOrder_animal')
colormap(temph,cmap_list)
set(gca,'XTick',[],'YTick',[])
axis off
temph = subplot('Position',...
    [start_x+box_size_x+0.002,start_y+box_size_y-0.05,0.005,0.05]);
imagesc((1:size(cmap,1))')
box on
set(gca,'XTick',[],'YTick',[])
colormap(temph,flipud(cbrewer2('RdBu',256)))
%% 6. pca show analysis components, 
%using significant difference behavior for analysis
rand('seed',1234)
sel_much = [1,2,3,4,5,7,9,48,70,75,78,92,93,175,182,195,196,...
    201,205,227,239,243,244,258];
sel_much_label = {...
    1,'Immobility';
    2,'Immobility';
    3,'Immobility';
    4,'Immobility';
    5,'Immobility';
    7,'Immobility';
    9,'Sniffing(nose micromovement, immobility)';
    48,'Close grooming';
    70,'Synchronous behavior (hunching, rearing, grooming, sniffing together)';
    75,'Synchronous behavior (hunching, rearing, grooming, sniffing together)';
    78,'independent rearing explorering';
    92,'peer sniffing (some grooming)';
    93,'Synchronous behavior (hunching, rearing, grooming, sniffing together)';
    175,'locomotion rearing explorering';
    182,'locomotion rearing explorering';
    195,'locomotion rearing explorering';
    196,'leaving back to back';
    201,'allogrooming';
    205,'leaving back to back';
    227,'approaching';
    239,'peer sniffing(little allogrooming)';
    243,'peer sniffing(little allogrooming)';
    244,'peer rearing sniffing';
    258,'peer sniffing'};
[coeff,score,latent,tsquared,explained,mu] = pca(fractions_much(sel_much,:)');
subplot('Position',[start_x+box_size_x+0.07,start_y,...
    box_size_y-0.05,box_size_y])
cumsum_e = cumsum(explained);
plot(cumsum_e,'k')
x_90 = 3;
y_90 = cumsum_e(x_90);
x_99 = 11;
y_99 = cumsum_e(x_99);
hold on
plot([0,x_90],[y_90,y_90],'r-')
hold on
plot([x_90,x_90],[min(cumsum_e),y_90],'r-')
hold on
plot([0,x_99],[y_99,y_99],'r-')
hold on
plot([x_99,x_99],[min(cumsum_e),y_99],'r-')
hold off
ylabel('Explained (%)')
axis([1,length(cumsum_e),min(cumsum_e),100])
box off
set(gca,'TickDir','out')
set(gca,'XTick',[3,11,length(cumsum_e)])
xlabel('Components')
%% 6. low dimensional embeddings (animal identities)
rand('seed',1234)
Y = run_umap(fractions_much(sel_much,:)','sgd_tasks',1,'verbose','text',...
    'min_dist',0.051,'n_neighbors',11,'randomize',false,...
    'n_components',3);
%%
edge_xy = 0.1;
min_x = min(Y(:,1));
max_x = max(Y(:,1));
min_y = min(Y(:,2));
max_y = max(Y(:,2));
min_z = min(Y(:,3));
max_z = max(Y(:,3));
subplot('Position',[0.67,start_y,0.15,0.15])
scatter3(Y(:,1),Y(:,2),Y(:,3),10*ones(size(Y,1),1),cmap_list,'filled');
xlabel('UMAP 1')
ylabel('UMAP 2')
zlabel('UMAP 3')
axis([min_x-edge_xy,max_x+edge_xy,...
      min_y-edge_xy,max_y+edge_xy,...
      min_z-edge_xy,max_z+edge_xy])
view(-170,9)
set(gca,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[])
set(gca,'TickLength',[0,0])
title('Phenotype space')
%% 7. show feature vector and cluster for behavior dimension redunction
% figure
angle_mat = zeros(size(coeff,1),size(coeff,1));
for m = 1:size(coeff,1)
    for n = 1:size(coeff,1)
        angle_mat(m,n) = abs(vec_angle(coeff(m,1:3),coeff(n,1:3)));
    end
end
D = pdist(angle_mat,'seuclidean');
Z = squareform(D);
tree = linkage(Z, 'ward','euclidean');
leafOrder = optimalleaforder(tree,D);
show_angle_mat = angle_mat(leafOrder,:);
show_angle_mat = show_angle_mat(:,leafOrder);
T = cluster(tree,'maxclust',11);
tree(:,3) = 1:size(tree,1);

% figure
% imagesc(show_angle_mat)
% colormap(cbrewer2('RdBu',256))
% tempangle = vec_angle(A,B);
start_x = 0.9;
start_y = 0.34;
tree_width = 0.02;
box_size_x = 0.05;
box_size_y = 0.38;
edge_dist = 0.005;

temph = subplot('Position',[start_x,start_y,box_size_x,box_size_y]);
imagesc(show_angle_mat)
colormap(temph,flipud(cbrewer2('RdBu',256)))
set(gca,'XTick',[])
set(gca,'TickDir','out')
set(gca,'YTick',1:length(T))
set(gca,'YTickLabel',sel_much(leafOrder))
box off
ylabel('Social behavior module IDs')
title('Angle spectrum')

subplot('Position',[start_x+box_size_x+edge_dist+0.003,...
    start_y,tree_width,box_size_y])
dendrogram(tree,0,'Orientation','right','Reorder',leafOrder)
axis off
axis([0,max(tree(:,3)),0.5,size(tree,1)+1.5])
set(gca,'YDir','reverse')

temph = subplot('Position',[start_x+box_size_x+0.002,...
    start_y,edge_dist,box_size_y]);
imagesc(T(leafOrder))
axis off
colormap(temph,cbrewer2('Set3',11))

temph = subplot('Position',[start_x,...
    start_y-0.03,box_size_x,0.005]);
imagesc(1:256)
colormap(temph,flipud(cbrewer2('RdBu',256)))
set(gca,'XTick',[1,256],'YTick',[])
set(gca,'XTickLabel',[min(angle_mat(:)),round(max(angle_mat(:)))])
set(gca,'XTickLabelRotation',0)
title('Angular separation')
box on

temph = subplot('Position',[start_x,...
    start_y-0.07,box_size_x,0.005]);
imagesc(1:11)
colormap(temph,flipud(cbrewer2('Set3',11)))
set(gca,'XTick',[1,11],'YTick',[])
set(gca,'XTickLabel',[1,11])
set(gca,'XTickLabelRotation',0)
title('Cluster IDs')
box on
%% 8. significant differences
sel_fractions_much = fractions_much(sel_much,:);
sort_fractions_much = sel_fractions_much(leafOrder,:)';
group_idx = [(1:20)',ones(20,1);...
             (21:40)',2*ones(20,1);...
             (41:60)',3*ones(20,1)];
unique_idx = unique(group_idx(:,2));

group_sort_frac = cell(length(unique(group_idx(:,2))),...
    size(sort_fractions_much,2));
group_cmap_list = group_sort_frac;
for m = 1:size(group_idx,1)
    for n = 1:size(group_sort_frac,2)
        group_sort_frac{group_idx(m,2),n} = ...
            [group_sort_frac{group_idx(m,2),n};sort_fractions_much(m,n)];
        group_cmap_list{group_idx(m,2),n} = cmap_list(m,:);
    end
end
mean_group_sort_frac = group_sort_frac;
std_group_sort_frac = group_sort_frac;
sem_group_sort_frac = group_sort_frac;
for m = 1:size(group_sort_frac,1)
    for n = 1:size(group_sort_frac,2)
        mean_group_sort_frac{m,n} = mean(group_sort_frac{m,n});
        std_group_sort_frac{m,n} = std(group_sort_frac{m,n});
        sem_group_sort_frac{m,n} = std_group_sort_frac{m,n}/sqrt(20);
    end
end

start_x = 0.06;
start_y = 0.34;
box_size_x = 0.77;
box_size_y = 0.15;
inter_y = 0.005;
box_raw_size_y = 0.11;
break_y = 0.06;

axis_start_x = -0.1;
axis_end_x = 11.7;

% bar
subplot('Position',[start_x,start_y,box_size_x,box_raw_size_y])
bar_start_x = 0.0;
group_inter_x = 0.1;
bar_inter_x = 0.03;
bar_w = 0.1;
dot_bias = 0.05;
xtick_list = zeros(size(group_sort_frac,2),1);
for k = 1:size(group_sort_frac,2)
    for m = 1:size(group_sort_frac,1)
        bar_x = bar_start_x+((k-1)*size(group_sort_frac,1)+(m-1))...
            *(bar_inter_x+bar_w)+...
            (k-1)*group_inter_x;
        bar(bar_x,mean_group_sort_frac{m,k},bar_w,...
            'FaceColor',group_cmap_list{m,k})
        hold on
        errorbar(bar_x,mean_group_sort_frac{m,k},...
            sem_group_sort_frac{m,k},'YNegativeDelta',0,...
            'CapSize',2,'Color','k')
        hold on
        plot((bar_x+dot_bias)*ones(size(group_sort_frac{m,k})),...
            group_sort_frac{m,k},'ko','MarkerSize',2,...
            'MarkerFaceColor','w')
        hold on
        if m == 2
            xtick_list(k,1) = bar_x;
        end
    end
end
hold off
ylabel('       Fractions')
box off
set(gca,'TickDir','out')
set(gca,'XTick',xtick_list)
set(gca,'XTickLabel',[])
axis([axis_start_x,axis_end_x,0,break_y])

% use subplot to create break axis
% start_x = 0.05;
% start_y = 0.15;
subplot('Position',[start_x,start_y+box_raw_size_y+inter_y,...
    box_size_x,box_size_y-box_raw_size_y-inter_y])
bar_start_x = 0.0;
group_inter_x = 0.1;
bar_inter_x = 0.03;
bar_w = 0.1;
dot_bias = 0.05;
for k = 1:size(group_sort_frac,2)
    for m = 1:size(group_sort_frac,1)
        bar_x = bar_start_x+((k-1)*size(group_sort_frac,1)+(m-1))...
            *(bar_inter_x+bar_w)+...
            (k-1)*group_inter_x;
        bar(bar_x,mean_group_sort_frac{m,k},bar_w,...
            'FaceColor',group_cmap_list{m,k})
        hold on
        errorbar(bar_x,mean_group_sort_frac{m,k},...
            sem_group_sort_frac{m,k},'YNegativeDelta',0,...
            'CapSize',2,'Color','k')
        hold on
        plot((bar_x+dot_bias)*ones(size(group_sort_frac{m,k})),...
            group_sort_frac{m,k},'ko','MarkerSize',2,...
            'MarkerFaceColor','w')
        hold on
    end
end
hold off
box off
set(gca,'TickDir','out')
axis([axis_start_x,axis_end_x,break_y,0.36])
set(gca,'XTick',[])
set(gca,'YTick',[break_y,0.2,0.36])
set(gca,'YTickLabel',{[],0.2,0.36})
set(gca,'XColor','w')

plot_raw_label = {
    'Micromovement';
    'Immobility';
    'Immobility';
    'Immobility';
    'Immobility';
    'Synchronous grooming, hunching, rearing & sniffing';
    'Synchronous hunching, grooming, micromovement';
    'Synchronous hunching, grooming, micromovement';
    'Peer locomotion sniffing';
    'Immobility';
    'Immobility';
    'Peer grooming sniffing';
    'Peer grooming sniffing';
    'Allogrooming';
    'Peer sniffing';
    'Peer locomotion sniffing';
    'Locomotion rearing explorering';
    'Approaching';
    'Leaving back to back';
    'Locomotion rearing explorering';
    'Locomotion rearing explorering';
    'Leaving back to back';
    'Independent rearing explorering';
    'Independent close grooming'};

% label behavior idx
beh_plot_y = 0.008;
line_l = 0.2;
idx_cmap  = cbrewer2('Set3',11);
sort_T = T(leafOrder);
subplot('Position',[start_x,start_y-beh_plot_y-0.01,...
    box_size_x,beh_plot_y])
for k = 1:size(xtick_list,1)
    tempx = xtick_list(k,1);
    plot([tempx-line_l,tempx+line_l],[1,1],'-','Color',idx_cmap(sort_T(k),:),...
        'LineWidth',6)
    hold on
    text(tempx,-20,plot_raw_label{k},'FontSize',6,'Rotation',90)
end
hold off
box on
set(gca,'XTick',xtick_list)
axis([axis_start_x,axis_end_x,-1,1])
axis off
%% 9. behavior identification

sort_sel_much_label = [sel_much_label(leafOrder,:),num2cell(sort_T)];

setcolor = cbrewer2('Spectral',11);
mouse1_c = setcolor(3,:);
mouse2_c = setcolor(9,:);

re_much_label = {...
    'Immobility';
    'Immobility';
    'Immobility';
    'Immobility';
    'Immobility';
    'Synchronous behavior (Grooming, hunching, rearing, and sniffing)';
    'Synchronous behavior (Hunching, grooming, micromovement)';
    'Synchronous behavior (Hunching, grooming, micromovement)';
    'Peer locomotion sniffing';
    'Immobility';
    'Immobility';
    'Peer sniffing';
    'Peer sniffing';
    'Allogrooming';
    'Peer sniffing';
    'Peer locomotion sniffing';
    'Explorering';
    'Explorering';
    'Explorering';
    'Explorering';
    'Explorering';
    'Explorering';
    'Independent rearing explorering';
    'Independent close grooming'};

new_much_label = [sort_sel_much_label,re_much_label];

plot_cluster_label = {
    'Immobility',[1,2,3,4,5];
    'Synchronous behaviors',[6,7,8,9];
    'Immobility',[10,11];
    'Peer grooming sniffing',[12,13];
    'Allogrooming',[14];
    'Peer sniffing',[15];
    'Peer locomotion sniffing',[16];
    'Explorering',[17,18,19,20,21,22,23];
    'Independent grooming',[24]};

beh_cell = cell(size(plot_cluster_label,1),1);
for k = 1:size(beh_cell,1)
    selbehidx = plot_cluster_label{k,2};
    tempbehnamecell = {};
    for m = selbehidx
        folderidx = sort_sel_much_label{m,1};
        folderpath = [beh_seg_path,'\',num2str(folderidx)];
        fileFolder = fullfile(folderpath);
        dirOutput = dir(fullfile(fileFolder,'*.avi'));
        videonames = {dirOutput.name}';
        tempbehnamecell = [tempbehnamecell;videonames];
    end
    % select max fraction names
    sel_mean_frac = sum(cell2mat(mean_group_sort_frac(:,selbehidx)),2);
    sel_max_idx = find(sel_mean_frac==max(sel_mean_frac));
    
    sel_list = zeros(size(tempbehnamecell,1),1);

    for m = 1:size(tempbehnamecell,1)
        tempname = tempbehnamecell{m};
        tempname = split(tempname,'.a');
        tempname = split(tempname{1},'_');

        class_idx_1 = find(strcmp(tempname{2},mice_names(:,1)));
        class_idx_2 = find(strcmp(tempname{3},mice_names(:,1)));
    
        if sel_max_idx==1
            if class_idx_1 >= 6 && class_idx_2 >= 6
                sel_list(m,1) = 1;
            end
        elseif sel_max_idx==2
            if (class_idx_1 <= 5 && class_idx_2 >= 6) || ...
                   (class_idx_2 <= 5 && class_idx_1 >= 6) 
                sel_list(m,1) = 1;
            end
        else
            if class_idx_1 <= 5 && class_idx_2 <= 5
                sel_list(m,1) = 1;
            end
        end

    end

    beh_cell{k,1} = tempbehnamecell(sel_list==1,:);
end

%% select behavior cases to plot
rand_sel_list = zeros(size(beh_cell,1),1);
rand_sel_names = cell(length(rand_sel_list),1);

rng('default')
rng(1234)%good
k = 1;
rand_sel_list(k,1) = randi(length(beh_cell{k}),1,1);
rand_sel_names{k,1} = beh_cell{k}{rand_sel_list(k,1)};

rng('default')
rng(1234)%good
k = 2;
rand_sel_list(k,1) = randi(length(beh_cell{k}),1,1);
rand_sel_names{k,1} = beh_cell{k}{rand_sel_list(k,1)};

rng('default')
rng(1235)%good
k = 3;
rand_sel_list(k,1) = randi(length(beh_cell{k}),1,1);
rand_sel_names{k,1} = beh_cell{k}{rand_sel_list(k,1)};

rng('default')
rng(1269)
k = 4;
rand_sel_list(k,1) = randi(length(beh_cell{k}),1,1);
rand_sel_names{k,1} = beh_cell{k}{rand_sel_list(k,1)};

rng('default')
rng(1246)%good
k = 5;
rand_sel_list(k,1) = randi(length(beh_cell{k}),1,1);
rand_sel_names{k,1} = beh_cell{k}{rand_sel_list(k,1)};

rng('default')
rng(1244)%good
k = 6;
rand_sel_list(k,1) = randi(length(beh_cell{k}),1,1);
rand_sel_names{k,1} = beh_cell{k}{rand_sel_list(k,1)};

rng('default')
rng(1244)%good
k = 7;
rand_sel_list(k,1) = randi(length(beh_cell{k}),1,1);
rand_sel_names{k,1} = beh_cell{k}{rand_sel_list(k,1)};

rng('default')
rng(1240)%good
k = 8;
rand_sel_list(k,1) = randi(length(beh_cell{k}),1,1);
rand_sel_names{k,1} = beh_cell{k}{rand_sel_list(k,1)};

rng('default')
rng(1240)%good
k = 9;
rand_sel_list(k,1) = randi(length(beh_cell{k}),1,1);
rand_sel_names{k,1} = beh_cell{k}{rand_sel_list(k,1)};

smo_win = 30;
show_sel_beh = cell(size(rand_sel_names,1),4);
for k = 1:size(rand_sel_names,1)
    %%
    tempname = rand_sel_names{k};
    tempname = split(tempname,'.a');
    tempname = split(tempname{1},'_');

    selframe = str2double(tempname{8});

    traj_name_1 = [tempname{2},'-',tempname{4},'.mat'];
    traj_name_2 = [tempname{3},'-',tempname{4},'.mat'];

    class_idx_1 = find(strcmp(tempname{2},mice_names(:,1)));
    class_idx_2 = find(strcmp(tempname{3},mice_names(:,1)));
    
    if class_idx_1 <=5
        show_sel_beh{k,3} = mouse1_c;
    else
        show_sel_beh{k,3} = mouse2_c;
    end

    if class_idx_2 <=5
        show_sel_beh{k,4} = mouse1_c;
    else
        show_sel_beh{k,4} = mouse2_c;
    end

    traj1 = load([traj_path,'\',traj_name_1]);
    traj2 = load([traj_path,'\',traj_name_2]);
    
    raw_traj1 = traj1.coords3d;
    raw_traj2 = traj2.coords3d;
    
    smo_traj1 = zeros(size(raw_traj1));
    smo_traj2 = zeros(size(raw_traj2));

    for m = 1:size(raw_traj1,2)
        smo_traj1(:,m) = smooth(raw_traj1(:,m),smo_win);
        smo_traj2(:,m) = smooth(raw_traj2(:,m),smo_win);
    end

    traj1_frame = smo_traj1(selframe,:);
    traj2_frame = smo_traj2(selframe,:);

    show_sel_beh{k,1} = traj1_frame;
    show_sel_beh{k,2} = traj2_frame;
end
% plot social behaviors
start_x = 0.05;
start_y = 0.02;
box_size_x = 0.1;
box_size_y = 0.1;
inter_x = 0.002;
inter_y = 0.002;


alpha_c = 0.05;
drawline = [ 1 2; 1 3;2 3; 4 5;4 6;5 7;6 8;7 14;8 14;...
    5 9;7 11;6 10; 8 12;14 15; 15 16;5,13;6,13;7,13;8,13;...
    2 4;3 4;5,6;7,8];

edge_x = 10;
edge_y = 10;
edge_z = 10;

x_num = length(plot_cluster_label);
y_num = 2;

for m = 1:x_num
    for n = 1:y_num
        subplot('Position',[...
            start_x+(m-1)*(box_size_x+inter_x),...
            start_y+(n-1)*(box_size_y+inter_y),...
            box_size_x,box_size_y])
        
        tempx1 = show_sel_beh{m,1}(1:3:end)';
        tempy1 = show_sel_beh{m,1}(2:3:end)';
        tempz1 = show_sel_beh{m,1}(3:3:end)';

        tempx2 = show_sel_beh{m,2}(1:3:end)';
        tempy2 = show_sel_beh{m,2}(2:3:end)';
        tempz2 = show_sel_beh{m,2}(3:3:end)';

        min_axis_x = min([tempx1;tempx2]);
        min_axis_y = min([tempy1;tempy2]);
        min_axis_z = min([tempz1;tempz2]);
        max_axis_x = max([tempx1;tempx2]);
        max_axis_y = max([tempy1;tempy2]);
        max_axis_z = max([tempz1;tempz2]);

        new_mesh_mouse(show_sel_beh{m,1},alpha_c,show_sel_beh{m,3})
        hold on
        plot_skl_dl(tempx1(:,1),tempy1(:,1),tempz1(:,1),...
            'k','k',drawline)
        hold on
        new_mesh_mouse(show_sel_beh{m,2},alpha_c,show_sel_beh{m,4})
        hold on
        plot_skl_dl(tempx2(:,1),tempy2(:,1),tempz2(:,1),...
            'k','k',drawline)
        hold off

        box on
        set(gca,'XTick',[],'YTick',[],'ZTick',[])
        if n == 2
            title(plot_cluster_label{m,1})
            view(0,90)
%             xlabel('x')
%             ylabel('y')
%             zlabel('z')
        end
        if n == 1
            xlabel('x')
            view(0,0)
        end
        if m == 1 && n==1
            zlabel({'Side view','z'})
        end
        if m == 1 && n==2
            ylabel({'Top view','y'})
        end

        axis square
        axis([min_axis_x-edge_x,max_axis_x+edge_x,...
              min_axis_y-edge_y,max_axis_y+edge_y,...
              min_axis_z-edge_z+5,max_axis_z+edge_z])
    end 
end































