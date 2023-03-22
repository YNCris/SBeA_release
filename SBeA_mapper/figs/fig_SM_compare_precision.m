%{
    compare sbea, dlc and sleap
%}
clear all
close all
%% set path
datapath = 'G:\multi_mice_test\Social_analysis\methods_compare\data\save_data';
%% load data
sbea_nid = load([datapath,'\sbea_err_nid_cell.mat']);
dlc_nid = load([datapath,'\dlc_err_nid_cell.mat']);
slp_nid = load([datapath,'\slp_err_nid_cell.mat']);
load([datapath,'\dist_cell.mat']);
distlist = cell2mat(dist_cell(:,2));
sbea_nid_mat = cell2mat(sbea_nid.err_nid_cell(:,2));
% sbea_id_mat = cell2mat(sbea_id.err_id_cell(:,2));
dlc_nid_mat = cell2mat(dlc_nid.err_nid_cell(:,2));
% dlc_id_mat = cell2mat(dlc_id.err_id_cell(:,2));
slp_nid_mat = cell2mat(slp_nid.err_nid_cell(:,2));
% slp_id_mat = cell2mat(slp_id.err_id_cell(:,2));
mean_sbea_nid = mean(sbea_nid_mat,1);
std_sbea_nid = std(sbea_nid_mat,1);
mean_dlc_nid = mean(dlc_nid_mat,1);
std_dlc_nid = std(dlc_nid_mat,1);
mean_slp_nid = mean(slp_nid_mat,1);
std_slp_nid = std(slp_nid_mat,1);
%% body parts
body_parts = {...
    'Nose','Left ear','Right ear','Neck',...
    'Left front limb','Right front limb','Left hind limb','Right hind limb',...
    'Left front paw','Right front paw','Left hind paw','Right hind paw',...
    'Back','Root tail','Mid tail','Tip tail'};
%% compare distance to error
bin_width = 50;
distbinlist = (0:bin_width:(500-bin_width))';
dist_all_cell = cell(size(distbinlist,1),5);
dist_all_cell(:,1) = num2cell(distbinlist);
dist_all_cell(:,2) = num2cell(distbinlist+bin_width);
dist_mean_cell = dist_all_cell;
dist_std_cell = dist_all_cell;
dist_sem_cell = dist_all_cell;
for k = 1:size(dist_all_cell,1)
    %%
    distidx = (distlist>=dist_all_cell{k,1})&(distlist<dist_all_cell{k,2});
    dist_all_cell{k,3} = reshape(sbea_nid_mat(distidx,:),[],1);
    dist_all_cell{k,4} = reshape(dlc_nid_mat(distidx,:),[],1);
    dist_all_cell{k,5} = reshape(slp_nid_mat(distidx,:),[],1);
    temp_mean_sbea = mean(sbea_nid_mat(distidx,:),1);
    temp_mean_dlc = mean(dlc_nid_mat(distidx,:),1);
    temp_mean_slp = mean(slp_nid_mat(distidx,:),1);
    dist_mean_cell{k,3} = (temp_mean_sbea(1,1:16)+temp_mean_sbea(1,17:32))/2;
    dist_mean_cell{k,4} = (temp_mean_dlc(1,1:16)+temp_mean_dlc(1,17:32))/2;
    dist_mean_cell{k,5} = (temp_mean_slp(1,1:16)+temp_mean_slp(1,17:32))/2;
    temp_std_sbea = std(sbea_nid_mat(distidx,:),1);
    temp_std_dlc = std(dlc_nid_mat(distidx,:),1);
    temp_std_slp = std(slp_nid_mat(distidx,:),1);
    dist_std_cell{k,3} = (temp_std_sbea(1,1:16)+temp_std_sbea(1,17:32))/2;
    dist_std_cell{k,4} = (temp_std_dlc(1,1:16)+temp_std_dlc(1,17:32))/2;
    dist_std_cell{k,5} = (temp_std_slp(1,1:16)+temp_std_slp(1,17:32))/2;
    dist_sem_cell{k,3} = dist_std_cell{k,3}/sqrt(length(dist_all_cell{k,3}));
    dist_sem_cell{k,4} = dist_std_cell{k,3}/sqrt(length(dist_all_cell{k,4}));
    dist_sem_cell{k,5} = dist_std_cell{k,3}/sqrt(length(dist_all_cell{k,5}));
end
dist_mean_mat_sbea = cell2mat(dist_mean_cell(:,3));
dist_mean_mat_dlc = cell2mat(dist_mean_cell(:,4));
dist_mean_mat_slp = cell2mat(dist_mean_cell(:,5));
dist_std_mat_sbea = cell2mat(dist_std_cell(:,3));
dist_std_mat_dlc = cell2mat(dist_std_cell(:,4));
dist_std_mat_slp = cell2mat(dist_std_cell(:,5));
dist_sem_mat_sbea = cell2mat(dist_sem_cell(:,3));
dist_sem_mat_dlc = cell2mat(dist_sem_cell(:,4));
dist_sem_mat_slp = cell2mat(dist_sem_cell(:,5));
%% plot canvas
h1 = figure(1);
set(h1,'Position',[900,100,800,800])
%% compare nid
subplot('Position',[0.1,0.75,0.8,0.2])
x_list = 1:32;
errorbar(x_list,mean_sbea_nid,std_sbea_nid,'or')
hold on
errorbar(x_list,mean_dlc_nid,std_dlc_nid,'og')
hold on
errorbar(x_list,mean_slp_nid,std_slp_nid,'ob')
hold off
title('Total error')
ylabel('Pixel error')
set(gca,'TickDir','out')
axis([0.5,32.5,-30,90])
box off
set(gca,'XTick',1:32)
set(gca,'XTickLabel',[body_parts,body_parts])
xlabel('Mouse 1                                                                     Mouse 2')
legend({'SBeA','DLC','SLEAP'},'Location','northwest')
legend('boxoff')

subplot('Position',[0.06,0.4,0.17,0.17])
errorbar(1:16,dist_mean_mat_sbea(1,:),dist_sem_mat_sbea(1,:),'-r')
hold on
errorbar(1:16,dist_mean_mat_dlc(1,:),dist_sem_mat_dlc(1,:),'-g')
hold on
errorbar(1:16,dist_mean_mat_slp(1,:),dist_sem_mat_slp(1,:),'-b')
hold off
title('0-50 pixels')
ylabel('Pixel error')
axis([0.5,16.5,0,40])
set(gca,'TickDir','out')
set(gca,'XTick',1:16)
set(gca,'XTickLabel',[])
box off
subplot('Position',[0.24,0.4,0.17,0.17])
errorbar(1:16,dist_mean_mat_sbea(2,:),dist_sem_mat_sbea(2,:),'-r')
hold on
errorbar(1:16,dist_mean_mat_dlc(2,:),dist_sem_mat_dlc(2,:),'-g')
hold on
errorbar(1:16,dist_mean_mat_slp(2,:),dist_sem_mat_slp(2,:),'-b')
hold off
title('50-100 pixels')
set(gca,'YTickLabel',[])
axis([0.5,16.5,0,40])
set(gca,'TickDir','out')
set(gca,'XTick',1:16)
set(gca,'XTickLabel',[])
box off
subplot('Position',[0.42,0.4,0.17,0.17])
errorbar(1:16,dist_mean_mat_sbea(3,:),dist_sem_mat_sbea(3,:),'-r')
hold on
errorbar(1:16,dist_mean_mat_dlc(3,:),dist_sem_mat_dlc(3,:),'-g')
hold on
errorbar(1:16,dist_mean_mat_slp(3,:),dist_sem_mat_slp(3,:),'-b')
hold off
title('100-150 pixels')
set(gca,'YTickLabel',[])
axis([0.5,16.5,0,40])
set(gca,'TickDir','out')
set(gca,'XTick',1:16)
set(gca,'XTickLabel',[])
box off
subplot('Position',[0.6,0.4,0.17,0.17])
errorbar(1:16,dist_mean_mat_sbea(4,:),dist_sem_mat_sbea(4,:),'-r')
hold on
errorbar(1:16,dist_mean_mat_dlc(4,:),dist_sem_mat_dlc(4,:),'-g')
hold on
errorbar(1:16,dist_mean_mat_slp(4,:),dist_sem_mat_slp(4,:),'-b')
hold off
title('100-200 pixels')
set(gca,'YTickLabel',[])
axis([0.5,16.5,0,40])
set(gca,'TickDir','out')
set(gca,'XTick',1:16)
set(gca,'XTickLabel',[])
box off
subplot('Position',[0.78,0.4,0.17,0.17])
errorbar(1:16,dist_mean_mat_sbea(5,:),dist_sem_mat_sbea(5,:),'-r')
hold on
errorbar(1:16,dist_mean_mat_dlc(5,:),dist_sem_mat_dlc(5,:),'-g')
hold on
errorbar(1:16,dist_mean_mat_slp(5,:),dist_sem_mat_slp(5,:),'-b')
hold off
title('200-250 pixels')
set(gca,'YTickLabel',[])
axis([0.5,16.5,0,40])
set(gca,'TickDir','out')
set(gca,'XTick',1:16)
set(gca,'XTickLabel',[])
box off

subplot('Position',[0.06,0.2,0.17,0.17])
errorbar(1:16,dist_mean_mat_sbea(6,:),dist_sem_mat_sbea(6,:),'-r')
hold on
errorbar(1:16,dist_mean_mat_dlc(6,:),dist_sem_mat_dlc(6,:),'-g')
hold on
errorbar(1:16,dist_mean_mat_slp(6,:),dist_sem_mat_slp(6,:),'-b')
hold off
title('250-300 pixels')
ylabel('Pixel error')
axis([0.5,16.5,0,40])
set(gca,'TickDir','out')
set(gca,'XTick',1:16)
set(gca,'XTickLabel',body_parts)
box off
subplot('Position',[0.24,0.2,0.17,0.17])
errorbar(1:16,dist_mean_mat_sbea(7,:),dist_sem_mat_sbea(7,:),'-r')
hold on
errorbar(1:16,dist_mean_mat_dlc(7,:),dist_sem_mat_dlc(7,:),'-g')
hold on
errorbar(1:16,dist_mean_mat_slp(7,:),dist_sem_mat_slp(7,:),'-b')
hold off
title('300-350 pixels')
axis([0.5,16.5,0,40])
set(gca,'YTickLabel',[])
set(gca,'TickDir','out')
set(gca,'XTick',1:16)
set(gca,'XTickLabel',body_parts)
box off
subplot('Position',[0.42,0.2,0.17,0.17])
errorbar(1:16,dist_mean_mat_sbea(8,:),dist_sem_mat_sbea(8,:),'-r')
hold on
errorbar(1:16,dist_mean_mat_dlc(8,:),dist_sem_mat_dlc(8,:),'-g')
hold on
errorbar(1:16,dist_mean_mat_slp(8,:),dist_sem_mat_slp(8,:),'-b')
hold off
title('350-400 pixels')
axis([0.5,16.5,0,40])
set(gca,'YTickLabel',[])
set(gca,'TickDir','out')
set(gca,'XTick',1:16)
set(gca,'XTickLabel',body_parts)
box off
subplot('Position',[0.6,0.2,0.17,0.17])
errorbar(1:16,dist_mean_mat_sbea(9,:),dist_sem_mat_sbea(9,:),'-r')
hold on
errorbar(1:16,dist_mean_mat_dlc(9,:),dist_sem_mat_dlc(9,:),'-g')
hold on
errorbar(1:16,dist_mean_mat_slp(9,:),dist_sem_mat_slp(9,:),'-b')
hold off
title('400-450 pixels')
axis([0.5,16.5,0,40])
set(gca,'YTickLabel',[])
set(gca,'TickDir','out')
set(gca,'XTick',1:16)
set(gca,'XTickLabel',body_parts)
box off
subplot('Position',[0.78,0.2,0.17,0.17])
errorbar(1:16,dist_mean_mat_sbea(10,:),dist_sem_mat_sbea(10,:),'-r')
hold on
errorbar(1:16,dist_mean_mat_dlc(10,:),dist_sem_mat_dlc(10,:),'-g')
hold on
errorbar(1:16,dist_mean_mat_slp(10,:),dist_sem_mat_slp(10,:),'-b')
hold off
title('450-500 pixels')
axis([0.5,16.5,50,350])
set(gca,'YTick',[50,350])
set(gca,'TickDir','out')
set(gca,'XTick',1:16)
set(gca,'XTickLabel',body_parts)
box off
























