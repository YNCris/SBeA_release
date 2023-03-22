%{
    compare social behavior in groups
%}
clear all
close all
%% set path
filepath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'zengyuting_diff_color\data_for_analysis\recluster_data'];
filename = {'group_compare.mat','GC_cell.mat','group_GC.mat'};
% set L2 label list
label_list_L2 = {...
    'Walking','Walking','Immobility','Immobility',...
    'Avoidence running','Approach running','Risng','Upstretching',...
    'Avoidence walking','Right turning','Right turning','Right running',...
    'Approach sniffing','Approach sniffing','Upstretching' ,'no idea',...
    'Approach sniffing','Approach sniffing','Noise','Running',...
    'Immobility','Immobility','Right turning','Right rising/hunchinggrooming',...
    'Right grooming','Rearing','Rearing','Rearing',...
    'Sniffing','Sniffing','Sniffing','Left grooming/rising',...
    'Left running','Right sniffing','Left turning','no idea',...
    'Left turning','Trotting','Sniffing','Rising/hunching',...
    'noise'...
};
%% load data
for k = 1:length(filename)
    load([filepath,'\',filename{k}])
end
%% plot canvas
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
%% compare hemi
subplot('Position',[0.1,0.7,0.8,0.2])
sel_data = group_compare(1:12,1:3);
show_data = zeros(size(sel_data,1),41);
for k = 1:size(sel_data,1)
    show_data(k,:) = sel_data{k,3}(:,2)';
end
SK_BL6.raw_data = show_data(1:3,:);
SK_129.raw_data = show_data(4:6,:);
SK_AJ.raw_data = show_data(7:9,:);
SK_W.raw_data = show_data(10:12,:);

SK_BL6.mean = mean(SK_BL6.raw_data);
SK_129.mean = mean(SK_129.raw_data);
SK_AJ.mean = mean(SK_AJ.raw_data);
SK_W.mean = mean(SK_W.raw_data);

SK_BL6.std = std(SK_BL6.raw_data);
SK_129.std = std(SK_129.raw_data);
SK_AJ.std = std(SK_AJ.raw_data);
SK_W.std = std(SK_W.raw_data);

sel_show = [1,2,5,6,18,24,25,26,28,32,33,35,38,40];

x_label = label_list_L2(sel_show);

errorbar(1:length(x_label),SK_BL6.mean(sel_show),SK_BL6.std(sel_show),'or');
hold on
errorbar(1:length(x_label),SK_129.mean(sel_show),SK_129.std(sel_show),'og');
hold on
errorbar(1:length(x_label),SK_AJ.mean(sel_show),SK_AJ.std(sel_show),'ob');
hold on
errorbar(1:length(x_label),SK_W.mean(sel_show),SK_W.std(sel_show),'oy');
hold off

axis([0,length(x_label)+1,0,0.2])
box off
set(gca,'TickDir','out')
legend({'SK-BL6','SK-129','SK-AJ','SK-W'},'Location','northwest');
legend('boxoff')

set(gca,'XTick',1:length(x_label))
set(gca,'XTickLabel',x_label)

ylabel('Fractions')
title('Genotype to behavior')

%% compare hemi
subplot('Position',[0.1,0.3,0.8,0.2])
sel_data = group_compare(13:24,1:3);
show_data = zeros(size(sel_data,1),41);
for k = 1:size(sel_data,1)
    show_data(k,:) = sel_data{k,3}(:,2)';
end
SK_BL6_white.raw_data = show_data(1:3,:);
SK_129_white.raw_data = show_data(4:6,:);
SK_AJ_white.raw_data = show_data(7:9,:);
SK_W_white.raw_data = show_data(10:12,:);

SK_BL6_white.mean = mean(SK_BL6_white.raw_data);
SK_129_white.mean = mean(SK_129_white.raw_data);
SK_AJ_white.mean = mean(SK_AJ_white.raw_data);
SK_W_white.mean = mean(SK_W_white.raw_data);

SK_BL6_white.std = std(SK_BL6_white.raw_data);
SK_129_white.std = std(SK_129_white.raw_data);
SK_AJ_white.std = std(SK_AJ_white.raw_data);
SK_W_white.std = std(SK_W_white.raw_data);

sel_show = [3,4,13,15,22,29,30];

x_label = label_list_L2(sel_show);

errorbar(1:length(x_label),SK_BL6_white.mean(sel_show),SK_BL6_white.std(sel_show),'or');
hold on
errorbar(1:length(x_label),SK_129_white.mean(sel_show),SK_129_white.std(sel_show),'og');
hold on
errorbar(1:length(x_label),SK_AJ_white.mean(sel_show),SK_AJ_white.std(sel_show),'ob');
hold on
errorbar(1:length(x_label),SK_W_white.mean(sel_show),SK_W_white.std(sel_show),'oy');
hold off

axis([0,length(x_label)+1,0,0.35])
box off
set(gca,'TickDir','out')
legend({'SK-BL6-White','SK-129-White','SK-AJ-White','SK-W-White'},'Location','northwest');
legend('boxoff')

set(gca,'XTick',1:length(x_label))
set(gca,'XTickLabel',x_label)

ylabel('Fractions')
title('White')
%% visualize GC
%% plot canvas
h1 = figure(2);
set(h1,'Position',[900,100,800,800])
%% 
subplot('Position',[0.8,0.6,0.015,0.3])
imagesc((256:-1:1)')
colormap(mat2gray(imresize(redbluecmap,[256,3])))
set(gca,'YAxisLocation','right')
set(gca,'XTick',[])
set(gca,'YTick',[1,64,128,192,256])
set(gca,'YTickLabel',[20,10,0,-10,-20])

subplot('Position',[0.08,0.6,0.3,0.3])
[GC_12_1_r,GC_12_1_c] = find(GC_cell{1,2}(1:41,42:end)==1);
[GC_12_2_r,GC_12_2_c] = find(GC_cell{1,2}(1:41,42:end)==-1);
[GC_21_1_r,GC_21_1_c] = find(GC_cell{1,2}(42:end,1:41)==1);
[GC_21_2_r,GC_21_2_c] = find(GC_cell{1,2}(42:end,1:41)==-1);
%% 
imagesc(GC_cell{1,1})
hold on
plot(GC_12_1_c+41,GC_12_1_r,'r*','MarkerSize',6)
hold on
plot(GC_12_2_c+41,GC_12_2_r,'b*','MarkerSize',6)
hold on
plot(GC_21_1_c,GC_21_1_r+41,'r*','MarkerSize',6)
hold on
plot(GC_21_2_c,GC_21_2_r+41,'b*','MarkerSize',6)
hold off
colormap(mat2gray(imresize(redbluecmap,[256,3])))
caxis([-20,20])
% colorbar
axis square
title('SK-BL6')
set(gca,'XTick',[1,41,82])
set(gca,'YTick',[1,41,82])
xlabel('Black                   White')
ylabel('White                   Black')
set(gca,'TickDir','out')
box off

subplot('Position',[0.48,0.6,0.3,0.3])
[GC_12_1_r,GC_12_1_c] = find(GC_cell{2,2}(1:41,42:end)==1);
[GC_12_2_r,GC_12_2_c] = find(GC_cell{2,2}(1:41,42:end)==-1);
[GC_21_1_r,GC_21_1_c] = find(GC_cell{2,2}(42:end,1:41)==1);
[GC_21_2_r,GC_21_2_c] = find(GC_cell{2,2}(42:end,1:41)==-1);
imagesc(GC_cell{2,1})
hold on
plot(GC_12_1_c+41,GC_12_1_r,'r*','MarkerSize',6)
hold on
plot(GC_12_2_c+41,GC_12_2_r,'b*','MarkerSize',6)
hold on
plot(GC_21_1_c,GC_21_1_r+41,'r*','MarkerSize',6)
hold on
plot(GC_21_2_c,GC_21_2_r+41,'b*','MarkerSize',6)
hold off
colormap(mat2gray(imresize(redbluecmap,[256,3])))
caxis([-20,20])
% colorbar
axis square
title('SK-129')
set(gca,'XTick',[1,41,82])
set(gca,'YTick',[1,41,82])
xlabel('Brown                   White')
ylabel('White                   Brown')
set(gca,'TickDir','out')
box off

subplot('Position',[0.08,0.2,0.3,0.3])
[GC_12_1_r,GC_12_1_c] = find(GC_cell{3,2}(1:41,42:end)==1);
[GC_12_2_r,GC_12_2_c] = find(GC_cell{3,2}(1:41,42:end)==-1);
[GC_21_1_r,GC_21_1_c] = find(GC_cell{3,2}(42:end,1:41)==1);
[GC_21_2_r,GC_21_2_c] = find(GC_cell{3,2}(42:end,1:41)==-1);
imagesc(GC_cell{3,1})
hold on
plot(GC_12_1_c+41,GC_12_1_r,'r*','MarkerSize',6)
hold on
plot(GC_12_2_c+41,GC_12_2_r,'b*','MarkerSize',6)
hold on
plot(GC_21_1_c,GC_21_1_r+41,'r*','MarkerSize',6)
hold on
plot(GC_21_2_c,GC_21_2_r+41,'b*','MarkerSize',6)
hold off
colormap(mat2gray(imresize(redbluecmap,[256,3])))
caxis([-20,20])
% colorbar
axis square
title('SK-AJ')
set(gca,'XTick',[1,41,82])
set(gca,'YTick',[1,41,82])
xlabel('Black                   White')
ylabel('White                   Black')
set(gca,'TickDir','out')
box off

subplot('Position',[0.48,0.2,0.3,0.3])
[GC_12_1_r,GC_12_1_c] = find(GC_cell{4,2}(1:41,42:end)==1);
[GC_12_2_r,GC_12_2_c] = find(GC_cell{4,2}(1:41,42:end)==-1);
[GC_21_1_r,GC_21_1_c] = find(GC_cell{4,2}(42:end,1:41)==1);
[GC_21_2_r,GC_21_2_c] = find(GC_cell{4,2}(42:end,1:41)==-1);
imagesc(GC_cell{4,1})
hold on
plot(GC_12_1_c+41,GC_12_1_r,'r*','MarkerSize',6)
hold on
plot(GC_12_2_c+41,GC_12_2_r,'b*','MarkerSize',6)
hold on
plot(GC_21_1_c,GC_21_1_r+41,'r*','MarkerSize',6)
hold on
plot(GC_21_2_c,GC_21_2_r+41,'b*','MarkerSize',6)
hold off
colormap(mat2gray(imresize(redbluecmap,[256,3])))
caxis([-20,20])
% colorbar
axis square
title('SK-W')
set(gca,'XTick',[1,41,82])
set(gca,'YTick',[1,41,82])
xlabel('Black                   White')
ylabel('White                   Black')
set(gca,'TickDir','out')
box off




