%{
    ��ξ����Ͼ���ȥ��
%}
clear all
close all
%% ��ȡ����
load('.\data\data_sample_cell.mat')
% load('.\data\newT.mat');
% load('.\data\embedding3d.mat');
% embedding = embedding3d;
embedding = cell2mat(data_sample_cell(:,6));
%% ��ξ���
tic
W = embedding;
D = pdist(W);
D = squareform(D);
% imagesc(D)
rng('default') % For reproducibility
tree = linkage(D, 'ward','seuclidean');
% leafOrder = optimalleaforder(tree, D);
toc
%% ����ǰ100��ľ�������ͼ���
tree_h_cell = cell(100,2);
for k = 2:100
    T = cluster(tree,'maxclust',k);
    colorThr = mean(tree(end-k+1 : end-k+2,3));
    tree_h_cell{k,1} = T;
    ht = dendrogram(tree,0,'ColorThreshold',colorThr);
    frame = getframe(gcf);
    tree_h_cell{k,2} = frame.cdata;
    disp(k)
end
%% �۲�����ÿһ��ľ�����
every_tree_cell = cell(100,6);
show_text = 0;
for k = 2:100
    %% ���������
    T = tree_h_cell{k,1};
    subplot(231)
    imshow(tree_h_cell{k,2})
    title(['��������',num2str(k)])
%     T = cluster(tree,'maxclust',k);
%     subplot(221)
%     colorThr = mean(tree(end-k+1 : end-k+2,3));
%     dendrogram(tree,0,'ColorThreshold',colorThr)
    %% ����ԭʼembedding
    subplot(232)
    plot_single_embedding_dbscan([embedding,T],unique(T),show_text);
    tabulate(T)
    %% ����ȥ��
    %% ����������ĺ�ÿһ��ľ��뷽��
    unique_label = unique(T);
    center_embedding = zeros(size(unique_label,1),3);
    std_embedding = zeros(size(unique_label));
    for m = 1:size(center_embedding,1)
        temp_embed = embedding(T(:,1)==unique_label(m,1),1:3);
        center_embedding(m,:) = mean(temp_embed);
    %     center_embedding(k,:) = [median(temp_embed(:,1)),median(temp_embed(:,2)),median(temp_embed(:,3))];
        dist_embed = conDist(temp_embed',temp_embed');
        std_embedding(m,1) = std(dist_embed(:));
    end
    %% �������е㵽�������ĵľ���
    dist_mat = conDist(embedding',center_embedding');
    %% ���������ľ���
    diff_dist_mat = dist_mat-(ones(size(dist_mat,1),1)*std_embedding');
    %% ��������
    sort_dist = sort(diff_dist_mat,2,'descend');
    %% ȥ��
    %% ��һ����⣬��С���벻�ڵ�ǰ���ڣ��ִ��������
    class_num = unique_label;
    detc_embedding1 = [embedding,T];
    for m = 1:size(detc_embedding1,1)
        if T(m,1)~=(find(diff_dist_mat(m,:)==min(diff_dist_mat(m,:))))
            detc_embedding1(m,4) = -1;
        end
    end
    subplot(233)
    plot_single_embedding_dbscan(detc_embedding1,class_num,show_text)
    if k>3
    %% �ڶ�����⣬��͹����Ϊ������
        detc_embedding2 = detc_embedding1;
        for m = 1:size(detc_embedding2,1)
            %% ���㰼͹��
            tempsort = sort_dist(m,(end-3):end);
            diff2sort = sum(diff(diff(tempsort)));
            %% �������
            if diff2sort>0
                detc_embedding2(m,4) = -1;
            end
        end
        class_num = unique(detc_embedding2(:,4));
        class_num(class_num==-1) = [];
        subplot(234)
        plot_single_embedding_dbscan(detc_embedding2,class_num,show_text)
        %% ��ʾ�ڶ����������ռ��
        detc_noise2 = sum(detc_embedding2(:,4)==-1)/size(detc_embedding2(:,4),1);
        subplot(236)
        plot(k,detc_noise2,'ro')
        axis([0,100,0,1])
        hold on
        every_tree_cell{k,5} = detc_embedding2;
        every_tree_cell{k,6} = detc_noise2;
    end
    %% ��ʾ��һ���������ռ��
    detc_noise1 = sum(detc_embedding1(:,4)==-1)/size(detc_embedding1(:,4),1);
    subplot(235)
    plot(k,detc_noise1,'ro')
    axis([0,100,0,1])
    hold on
    %% ����ͼ��
    j=get(gcf,'javaframe');
    set(j,'maximized',true);
    frame = print('-RGBImage','-r300');
    every_tree_cell{k,1} = frame;
%     pause
    %% ��ֵ
    every_tree_cell{k,2} = [embedding,T];
    every_tree_cell{k,3} = detc_embedding1;
    every_tree_cell{k,4} = detc_noise1;
end
hold off
%% ��ʾ�����ͼ��
for k = 1:100
    imshow(every_tree_cell{k,1})
    pause
end
%% ��ͼ�����Ϊ��Ƶ
videoname = 'tree_cell_20200930';
writeobj = VideoWriter(['.\data\',videoname]);
writeobj.FrameRate = 30;
open(writeobj)
for k = 2:size(every_tree_cell,1)
    for m = 1:10
        frame = every_tree_cell{k,1};
        writeVideo(writeobj,frame)
    end
end
close(writeobj)
%% ��Ѿ�����ȷ��
others1 = [1;cell2mat(every_tree_cell(:,4))];
others2 = [1;1;1;cell2mat(every_tree_cell(:,6))];
dist12 = ((others1.^2)+(others2.^2)).^0.5;
best_clus = find(dist12 == min(dist12));
% best_clus = 13;
subplot(121)
plot(others1,others2)
hold on
plot(others1(best_clus),others2(best_clus),'*r')
hold off
subplot(122)
plot(dist12)
hold on
plot(best_clus,dist12(best_clus),'*r')
hold off
%% �����µ�CQI
% load('.\data\newT.mat');
%%
CQI1 = calClus_qulity_fast(embedding, every_tree_cell{best_clus,2}(:,4));
%%
CQI2 = calClus_qulity_fast(embedding, every_tree_cell{best_clus,5}(:,4));
%% ���¸�ֵ���
all_data_sample_cell = [data_sample_cell,...
    num2cell(every_tree_cell{best_clus,2}(:,4)),num2cell(CQI1'),...
    num2cell(every_tree_cell{best_clus,5}(:,4)),num2cell(CQI2')];
%% ͳ��CQI�ı仯
before_others_clus = unique(cell2mat(all_data_sample_cell(:,7)));
after_others_clus = unique(cell2mat(all_data_sample_cell(:,9)));
stat_before_clus = zeros(size(before_others_clus,1),3);
stat_after_clus = zeros(size(after_others_clus,1),3);
for m = 1:size(all_data_sample_cell,1)
    tempCQI1 = all_data_sample_cell{m,8};
    tempCQI2 = all_data_sample_cell{m,10};
    for n = 1:size(before_others_clus,1)
        if before_others_clus(n,1) == all_data_sample_cell{m,7}
            stat_before_clus(n,1) = stat_before_clus(n,1)+tempCQI1;
            stat_before_clus(n,2) = stat_before_clus(n,2)+1;
        end
    end
    for n = 1:size(after_others_clus,1)
        if after_others_clus(n,1) == all_data_sample_cell{m,9}
            stat_after_clus(n,1) = stat_after_clus(n,1)+tempCQI2;
            stat_after_clus(n,2) = stat_after_clus(n,2)+1;
        end
    end
end
fboc = [before_others_clus,stat_before_clus(:,1)./stat_before_clus(:,2)];
faoc = [after_others_clus,stat_after_clus(:,1)./stat_after_clus(:,2)];
figure(1)
subplot(311)
plot(fboc(:,1),fboc(:,2),'b*-')
hold on
plot(faoc(:,1),faoc(:,2),'ro-')
hold off
title('CQI')
legend('before denoise','after denoise')
% ͳ������
subplot(312)
[bno,bxo] = hist(every_tree_cell{best_clus,2}(:,4),unique(every_tree_cell{best_clus,2}(:,4)));
plot(bxo,bno,'b*-')
hold on
[ano,axo] = hist(every_tree_cell{best_clus,5}(:,4),unique(every_tree_cell{best_clus,5}(:,4)));
plot(axo,ano,'r*-')
hold off
title('number of movements')
legend('before denoise','after denoise')
subplot(313)
plot(bxo,(bno-ano(2:end))./bno,'g*-')
axis([-1,max(bxo),0,max((bno-ano(2:end))./bno)])
title('different number of movements')
%% ��ʾembedding
figure(2)
subplot(121)
plot_single_embedding_dbscan([every_tree_cell{best_clus,2}],...
    unique(every_tree_cell{best_clus,2}(:,4)),1);
title('before denoise embedding')
view(-170,45)
subplot(122)
plot_single_embedding_dbscan([every_tree_cell{best_clus,5}],...
    unique(every_tree_cell{best_clus,5}(:,4)),0);
title('after denoise embedding')
view(-170,45)
%% ����·��
savepath = '.\data\singlepath_20200930_after_denoise';
mkdir(savepath);
%% ��������·��
video_sample_cell = all_data_sample_cell(:,[1:3,9:10]);
for k = 1:size(video_sample_cell,1)
    temp1 = num2str(video_sample_cell{k,4});
    mkdir([savepath,'\',temp1])
end
%%
videopath = 'Z:\hanyaning\mulldling_data_analysis\zhangna_behanalysis\single_20200925';
fileFolder = fullfile(videopath);
dirOutput = dir(fullfile(fileFolder,'*.avi'));
videonames = {dirOutput.name}';
for n = 1:size(videonames,1)
    vidobj = VideoReader([videopath,'\',videonames{n,1}]);
    for k = 1:size(video_sample_cell,1)
        if strcmp(videonames{n,1}(1,1:(end-4)),video_sample_cell{k,3}(1,1:(end-4)))
            tempstartframe = video_sample_cell{k,2}(1,1);
            tempendframe = video_sample_cell{k,2}(1,2);
            clus1 = num2str(video_sample_cell{k,4});
            videoname2 = video_sample_cell{k,3}(1,1:(end-4));
            clus3 = num2str(video_sample_cell{k,4});
            CQI4 = num2str(video_sample_cell{k,5},'%4.2f');
            writeobj = VideoWriter([savepath,'\',clus1,'\',CQI4,'_',videoname2,'_',clus3,'_',...
                num2str(tempstartframe),'_',num2str(tempendframe),'.avi']);
            writeobj.FrameRate = vidobj.FrameRate;
            open(writeobj);
            for m = tempstartframe:tempendframe
                frame = read(vidobj,m);
                writeVideo(writeobj,frame);
            end
            close(writeobj);
        end
    end
    disp(n);
end
%% ����·��
savepath = '.\data\singlepath_20200820_before_denoise';
mkdir(savepath);
%% ��������·��
video_sample_cell = all_data_sample_cell(:,[1:3,7:8]);
for k = 1:size(video_sample_cell,1)
    temp1 = num2str(video_sample_cell{k,4});
    mkdir([savepath,'\',temp1])
end
%%
videopath = 'Z:\hanyaning\mulldling_data_analysis\BeA_jiajia_social\VideoPath';
fileFolder = fullfile(videopath);
dirOutput = dir(fullfile(fileFolder,'*.avi'));
videonames = {dirOutput.name}';
for n = 1:size(videonames,1)
    vidobj = VideoReader([videopath,'\',videonames{n,1}]);
    for k = 1:size(video_sample_cell,1)
        if strcmp(videonames{n,1}(1,1:(end-4)),video_sample_cell{k,3}(1,1:(end-4)))
            tempstartframe = video_sample_cell{k,1}(1,1);
            tempendframe = video_sample_cell{k,1}(1,2);
            clus1 = num2str(video_sample_cell{k,4});
            videoname2 = video_sample_cell{k,3}(1,1:(end-4));
            clus3 = num2str(video_sample_cell{k,4});
            CQI4 = num2str(video_sample_cell{k,5},'%4.2f');
            writeobj = VideoWriter([savepath,'\',clus1,'\',CQI4,'_',videoname2,'_',clus3,'_',...
                num2str(tempstartframe),'_',num2str(tempendframe),'.avi']);
            writeobj.FrameRate = vidobj.FrameRate;
            open(writeobj);
            for m = tempstartframe:tempendframe
                frame = read(vidobj,m);
                writeVideo(writeobj,frame);
            end
            close(writeobj);
        end
    end
    disp(n);
end
%% �鿴CQI�ֲ�
unique_class = unique(cell2mat(all_data_sample_cell(:,9)));
cmapcolor3 = mat2gray(imresize(colormap('jet'),[size(unique_class,1),3]));
for k = 1:size(unique_class,1)
    others_sample_cell = all_data_sample_cell(cell2mat(all_data_sample_cell(:,9))==unique_class(k,1),:);
    others_CQI = cell2mat(others_sample_cell(:,10));
    [tempn,tempx] = hist(others_CQI,20);
    plot(tempx,cumsum(tempn),'-*','Color',cmapcolor3(k,:))
    hold on
end
legend((num2str(unique_class)))
hold off
%% �ָ��ǵ���Ƶ
%% ����·��
savepath = '.\data\singlepath_20200824_after_denoise_labeled';
mkdir(savepath);
%% ��������·��
video_sample_cell = all_data_sample_cell(:,[1:3,9:10]);
for k = 1:size(video_sample_cell,1)
    temp1 = num2str(video_sample_cell{k,4});
    mkdir([savepath,'\',temp1])
end
%%
videopath = 'Z:\hanyaning\motion_sequence_semantic_recognition\cutCsvPath';
fileFolder = fullfile(videopath);
dirOutput = dir(fullfile(fileFolder,'*.avi'));
videonames = {dirOutput.name}';
for n = 1:size(videonames,1)
    vidobj = VideoReader([videopath,'\',videonames{n,1}]);
    for k = 1:size(video_sample_cell,1)
        if strcmp(videonames{n,1}(1,1:(end-60)),video_sample_cell{k,3}(1,1:(end-4)))
            tempstartframe = video_sample_cell{k,1}(1,1);
            tempendframe = video_sample_cell{k,1}(1,2);
            clus1 = num2str(video_sample_cell{k,4});
            videoname2 = video_sample_cell{k,3}(1,1:(end-4));
            clus3 = num2str(video_sample_cell{k,4});
            CQI4 = num2str(video_sample_cell{k,5},'%4.2f');
            writeobj = VideoWriter([savepath,'\',clus1,'\',CQI4,'_',videoname2,'_',clus3,'_',...
                num2str(tempstartframe),'_',num2str(tempendframe),'.avi']);
            writeobj.FrameRate = vidobj.FrameRate;
            open(writeobj);
            for m = tempstartframe:tempendframe
                frame = read(vidobj,m);
                writeVideo(writeobj,frame);
            end
            close(writeobj);
        end
    end
    disp(n);
end
%% ����all_data_sample_cell��range
for k = 1:size(all_data_sample_cell,1)
    temp_range = all_data_sample_cell{k,1};
    temp_range(1,3) = all_data_sample_cell{k,9};
    all_data_sample_cell{k,1} = temp_range;
end
%% ��������
save('.\data\all_data_sample_cell.mat','all_data_sample_cell');
save('.\data\every_tree_cell.mat','every_tree_cell');
disp('������ɣ�')














































