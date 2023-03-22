%{
    本能行为转移模式量化分析代码
%}
clear all
close all
%% 读取数据
load('.\data\H3_TVTdata.mat','imdsTest');
load('.\data\test_pxdsResults.mat');
load('.\data\classes.mat');
load('.\data\labelIDs.mat');
load('.\data\embedding.mat');
%% 转换为一行标签
RowResults = img2row(pxdsResults);
%% 构建模式转移存储cell
IBTP_cell = {};%{文件名，行为标签，行为位置起点终点，动作标签序列}
count = 1;
maxlabel = (max(best_label_embedding(:,4))+1);%加1是窝内
tic
for m = 1:size(imdsTest.Files,1)
    %% 读图像和标签
    temptemp_img = readimage(imdsTest,m);
    img_label = label2num(RowResults{m,1},classes,labelIDs);
    %% 标签还原
    [filename,index] = imgn2fn_index(imdsTest.Files{m,1});
    temp_img = round(double(temptemp_img(1,:,1))/255*max(index(:)));
    img = index_exchange(temp_img',index,(1:max(index(:))))';
    unique_label = unique(RowResults{m,1});
    %% 搜索行为分段
    diff_img_label = imbinarize(abs(diff(img_label)),0);
    diff_img_label(1) = 1;diff_img_label = [diff_img_label,1];
    pos_list = find(diff_img_label==1);
    end_pos = 0;
    for n = 1:(sum(diff_img_label(:))-1)
        %% 整理数据，文件名
        temp_filename = filename;
        %% 整理数据，行为位置起点终点
        start_pos = end_pos+1;
        end_pos = pos_list(1,n+1);
        %% 整理数据，行为标签
        temp_behlabel = char(RowResults{m,1}(1,start_pos));
        %% 整理数据，动作标签序列
        temp_indexlist = img(1,start_pos:end_pos);
        temp_indexlist(temp_indexlist==0) = [];
        %% 整理数据，赋值
        IBTP_cell = [IBTP_cell;...
            {temp_filename,temp_behlabel,[start_pos,end_pos],temp_indexlist,[]}];
    end
    disp(m)
end
IBTP_cell(cellfun(@isempty,IBTP_cell(:,4)),:) = [];
toc
%% 行为模式分析，动作标签热力图
heatmap_cell = cell(size(classes,1),2);
heatmap_height = max(index(:));
for k = 1:size(classes,1)
    %% 抽取需要分析的行为
    heatmap_cell{k,1} = classes(k,1);
    temp_cell = IBTP_cell(IBTP_cell(:,2)==classes(k,1),:);
    heatmap_width = 0;
    for m = 1:size(temp_cell,1)
        heatmap_width = max([heatmap_width,size(temp_cell{m,4},2)]);
    end
    BP_heatmap = zeros(heatmap_height,heatmap_width);
    for m = 1:size(temp_cell,1)
        for n = 1:size(temp_cell{m,4},2)
%             if temp_cell{m,4}(1,n)~=0%排除补零的部分
                BP_heatmap(temp_cell{m,4}(1,n),n) = BP_heatmap(temp_cell{m,4}(1,n),n)+1;
%             end
        end
    end
    %% 按列归一化
%     min_BP = ones(heatmap_height,1)*min(BP_heatmap);
%     max_BP = ones(heatmap_height,1)*max(BP_heatmap);
%     norm_BP_heatmap = (BP_heatmap-min_BP)./(max_BP-min_BP+eps);
    sum_BP = ones(heatmap_height,1)*sum(BP_heatmap,1);
    norm_BP_heatmap = BP_heatmap./(sum_BP+eps);
    heatmap_cell{k,2} = norm_BP_heatmap;
    %% 显示
    figure
    imagesc(norm_BP_heatmap)
    title(classes(k,1))
    colorbar
end
%% 绘制所有数据和标签
figure
% 制作类别中心点
center_size = 30;
node_num = max(index(:));
center_cell = cell(node_num,4);%{[位置x,位置y,位置z],节点类别,[颜色图],[节点大小]}
for m = 1:(node_num-1)
    temp_embedding = best_label_embedding(best_label_embedding(:,4)==m,:);
    center_cell{m,1} = [mean(temp_embedding(:,1)),...
        mean(temp_embedding(:,2)),...
        mean(temp_embedding(:,3))];
    center_cell{m,2} = num2str(m);
end
center_cell{node_num,1} = [0,0,0];
center_cell{node_num,2} = num2str(node_num);
cmapcolor = mat2gray(imresize(colormap('jet'),[node_num,3]));
for m = 1:node_num
    center_cell{m,3} = cmapcolor(m,:);
    center_cell{m,4} = center_size;
end
% 提取数据
center_mat = zeros(node_num,size(center_cell{1,1},2));
for m = 1:node_num
    center_mat(m,:) = center_cell{m,1};
end
% 提取颜色
cmaplist = zeros(node_num,size(center_cell{1,3},2));
for m = 1:node_num
    cmaplist(m,:) = center_cell{m,3};
end
% 提取节点大小
center_node_size = zeros(node_num,1);
for m = 1:node_num
    center_node_size(m,1) = center_cell{m,4};
end
% 绘制所有数据
point_size = 1;
cmap_best_label_embedding = zeros(size(best_label_embedding,1),3);
for k = 1:size(cmap_best_label_embedding,1)
    cmap_best_label_embedding(k,:) = cmaplist(best_label_embedding(k,4),:);
end
scatter3(best_label_embedding(:,1),best_label_embedding(:,2),best_label_embedding(:,3),...
    best_label_embedding(:,4),...
    cmap_best_label_embedding,[],point_size,cmap_best_label_embedding);
legend off
title('all')
axis square
%     scatter3(center_mat(:,1),center_mat(:,2),center_mat(:,3),...
%         center_node_size,cmaplist,'filled');
hold off
% 放置类别标签
text(center_mat(:,1),center_mat(:,2),center_mat(:,3),center_cell(:,2))
view(2)
%% 行为的转移模式分析，动作状态转移矩阵，总
trans_cell = cell(size(classes,1),2);
for k = 1:size(classes,1)
    %% 抽取需要分析的行为
    trans_cell{k,1} = classes(k,1);
    temp_cell = IBTP_cell(IBTP_cell(:,2)==classes(k,1),:);
    %% 构建状态转移矩阵
    temp_transmat = zeros(max(index(:)),max(index(:)));
    for m = 1:size(temp_cell,1)
        pre_state = temp_cell{m,4}(1,1:(end-1));
        cur_state = temp_cell{m,4}(1,2:end);
        for n = 1:size(pre_state,2)
            temp_transmat(pre_state(1,n),cur_state(1,n)) = ...
                temp_transmat(pre_state(1,n),cur_state(1,n))+1;
        end
    end
    %% 计算状态转移概率，按行归一化
%     min_TS = min(temp_transmat,[],2)*ones(1,max(index(:)));
%     max_TS = max(temp_transmat,[],2)*ones(1,max(index(:)));
%     transmat = (temp_transmat-min_TS)./(max_TS-min_TS+eps);
    sum_TS = sum(temp_transmat,2)*ones(1,max(index(:)));
    transmat = temp_transmat./(sum_TS+eps);
    trans_cell{k,2} = transmat;
    %% 显示
    figure
    imagesc(transmat)
    title(classes(k,1))
    colorbar
end
%% 计算每一段行为的状态转移矩阵
for m = 1:size(IBTP_cell,1)
    temp_transmat = zeros(max(index(:)),max(index(:)));
    pre_state = IBTP_cell{m,4}(1,1:(end-1));
    cur_state = IBTP_cell{m,4}(1,2:end);
    for n = 1:size(pre_state,2)
        temp_transmat(pre_state(1,n),cur_state(1,n)) = ...
            temp_transmat(pre_state(1,n),cur_state(1,n))+1;
    end
    IBTP_cell{m,5} = temp_transmat;
end
%% 绘制状态转移
trans_thres = 0.1;
for k = 1:size(trans_cell,1)
    temp_transmat = trans_cell{k,2};
    temp_transmat(temp_transmat<trans_thres) = 0;
    [sL,tL,weightL,GN,GA] = PGM_GraphPre(temp_transmat);
    subplot(3,4,k)
    imagesc(temp_transmat)
    colorbar
    axis square
    title(trans_cell{k,1})
    subplot(3,4,(k+4))
    plot(GA,'Layout','circle')
    axis square
    subplot(3,4,(k+8))
    hist(temp_transmat)
    axis square
end
%% 每一类单独观察状态
for k = 1:size(classes,1)
    %% 抽取需要分析的行为
    temp_cell = IBTP_cell(IBTP_cell(:,2)==classes(k,1),:);
    for m = 1:size(temp_cell,1)
        temp_transmat = temp_cell{m,5};
%         temp_transmat(temp_transmat<trans_thres) = 0;
        [sL,tL,weightL,GN,GA] = PGM_GraphPre(temp_transmat);
%         figure
        subplot(121)
        imagesc(temp_transmat)
        colorbar
        axis square
        title(classes{k,1})
        subplot(122)
        plot(GA,'Layout','circle')
        axis square
        pause
    end
end
%% 4类状态转移的可视化 
for k = 1:size(classes,1)
    figure
    %% 抽取需要分析的行为
    temp_cell = IBTP_cell(IBTP_cell(:,2)==classes(k,1),:);
    %% 绘制背景
    embedding = best_label_embedding(:,1:3);
    bk_color = 0.7*ones(size(embedding(:,1),1),3);
    bk_size = 1;
    bk_g = cell(size(embedding,1),1);
    for m = 1:size(bk_g,1)
        bk_g{m,1} = 'background';
    end
    gscatter3(embedding(:,1),embedding(:,2),(embedding(:,3)-min(embedding(:,3)))/(max(embedding(:,3))-min(embedding(:,3))),bk_g,...
        bk_color,[],bk_size,bk_color);
    legend off
%     scatter3(embedding(:,1),embedding(:,2),embedding(:,3),...
%         2*ones(size(embedding(:,1))),0.7*ones(size(embedding(:,1),1),3),'filled');%[大小，颜色]
	hold on
    %% 绘制状态转移
    node_num = max(index(:));
    center_cell = cell(node_num,4);%{[位置x,位置y,位置z],节点类别,[颜色图],[节点大小]}
    for m = 1:(node_num-1)
        temp_embedding = best_label_embedding(best_label_embedding(:,4)==m,:);
        center_cell{m,1} = [mean(temp_embedding(:,1)),...
            mean(temp_embedding(:,2)),...
            mean(temp_embedding(:,3))];
        center_cell{m,2} = num2str(m);
    end
    center_cell{node_num,1} = [0,0,-10];%窝内坐标
    center_cell{node_num,2} = num2str(node_num);
    % 提取数据
    center_mat = zeros(node_num,size(center_cell{1,1},2));
    for m = 1:node_num
        center_mat(m,:) = center_cell{m,1};
    end
    for m = 1:size(temp_cell,1)
        temp_transmat = temp_cell{m,5};
        sum_TS = sum(temp_transmat,2)*ones(1,max(index(:)));
        transmat = temp_transmat./(sum_TS+eps);
        [sL,tL,weightL,GN,GA] = PGM_GraphPre(transmat);
        cluster_center = center_mat;
        plot(GA,'b','Xdata',cluster_center(:,1),...
            'Ydata',cluster_center(:,2),...
            'Zdata',cluster_center(:,3));
        hold on
    end
    %% 绘制类别中心节点
    center_size = 30;
    node_num = max(index(:));
    center_cell = cell(node_num,4);%{[位置x,位置y,位置z],节点类别,[颜色图],[节点大小]}
    for m = 1:(node_num-1)
        temp_embedding = best_label_embedding(best_label_embedding(:,4)==m,:);
        center_cell{m,1} = [mean(temp_embedding(:,1)),...
            mean(temp_embedding(:,2)),...
            mean(temp_embedding(:,3))];
        center_cell{m,2} = num2str(m);
    end
    center_cell{node_num,1} = [0,0,0];
    center_cell{node_num,2} = num2str(node_num);
    cmapcolor = mat2gray(imresize(colormap('jet'),[node_num,3]));
    for m = 1:node_num
        center_cell{m,3} = cmapcolor(m,:);
        center_cell{m,4} = center_size;
    end
    % 提取数据
    center_mat = zeros(node_num,size(center_cell{1,1},2));
    for m = 1:node_num
        center_mat(m,:) = center_cell{m,1};
    end
    % 提取颜色
    cmaplist = zeros(node_num,size(center_cell{1,3},2));
    for m = 1:node_num
        cmaplist(m,:) = center_cell{m,3};
    end
    % 提取节点大小
    center_node_size = zeros(node_num,1);
    for m = 1:node_num
        center_node_size(m,1) = center_cell{m,4};
    end
    gscatter3(center_mat(:,1),center_mat(:,2),center_mat(:,3),{center_cell{:,2}},...
        cmaplist,[],center_size,cmaplist);
    legend off
    title(classes{k,1})
    axis square
%     scatter3(center_mat(:,1),center_mat(:,2),center_mat(:,3),...
%         center_node_size,cmaplist,'filled');
	hold off
    disp(k)
end








