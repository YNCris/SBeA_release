clear all
close all
%% 读取数据
load('.\data\group_compare.mat');
load('.\data\embedding.mat');
%% 比较动作类别数量
comp_mot_num = zeros(size(group_compare,1),size(group_compare{1,3},1));
for k = 1:size(comp_mot_num,1)
    comp_mot_num(k,:) = group_compare{k,3}(:,2)';
end
figure
boxplot(comp_mot_num);
%% 显示
for k = 1:size(group_compare,1)
    if group_compare{k,2} == 1
        plot(group_compare{k,3}(:,1),group_compare{k,3}(:,2),'g*-')
        hold on
    elseif group_compare{k,2} == 2
        plot(group_compare{k,3}(:,1),group_compare{k,3}(:,2),'y*-')
        hold on
    elseif group_compare{k,2} == 3
        plot(group_compare{k,3}(:,1),group_compare{k,3}(:,2),'b*-')
        hold on
    elseif group_compare{k,2} == 4
        plot(group_compare{k,3}(:,1),group_compare{k,3}(:,2),'r*-')
        hold on
    else
        error('数据错误！');
    end
end
hold off
set(gca,'xtick',group_compare{1,3}(:,1))
%% 比较动作类别时间
comp_mot_time = zeros(size(group_compare,1),size(group_compare{1,4},1));
for k = 1:size(comp_mot_time,1)
    comp_mot_time(k,:) = group_compare{k,4}(:,2)';
end
figure
boxplot(comp_mot_time);
%% 比较动作类别马氏极限分布
comp_plimit = zeros(size(group_compare,1),size(group_compare{1,6},1));
for k = 1:size(comp_plimit,1)
    comp_plimit(k,:) = group_compare{k,6}(:,1)';
end
figure
boxplot(comp_plimit);
%% 测试
m = 2;
transmat = group_compare{m,5};
p_limit = group_compare{m,6};
S1 = group_compare{m,3}(:,2)';
Sn = S1*transmat;
plot(S1,Sn)
%% 分类别绘制embedding
class_num = [27,41];
figure
plot_single_embedding(best_label_embedding,class_num);
%% UMAP
close all
dimesion_num = 3;
comp_data = zeros(size(group_compare{1,3},1),size(group_compare,1));
for k = 1:size(group_compare,1)
    comp_data(:,k) = group_compare{k,3}(:,2);
end
[reduction, umap, clusterIdentifiers] = run_umap(comp_data','n_neighbors',30,...
    'min_dist',0.3,'metric','euclidean','n_components', dimesion_num);
% reduction = tsne(comp_data','NumDimensions',dimesion_num);
group_label = group_compare(:,2);%{1;2;1;2;1;2;1;2;1;2;1;2};%
group_embedding = [reduction-ones(size(reduction,1),1)*mean(reduction),cell2mat(group_label)];
close all
handle_cell = plot_single_embedding_setc(group_embedding,[1,2]);
grid on
view(-45,45)
% figure
% gscatter(group_embedding(:, 1), group_embedding(:, 2), group_embedding(:,3))
%% svm
obj_lin = fitclinear(group_embedding(...
    :,1:dimesion_num),...
    group_embedding(:,4));
%% 绘图
close all
if dimesion_num == 3
    %% 计算超平面
    syms x y z
    Xm = zeros(dimesion_num,dimesion_num);
    for k = 1:dimesion_num
        Xm(k,k) = -1*(obj_lin.Bias/obj_lin.Beta(k));
    end
    D=[ones(4,1),[[x,y,z];Xm]];%由空bai间解析几du何的内容知道D的行列式等于零就是平面方程。zhi
    detd=det(D);
    disp(strcat('平面方程为：',char(detd),'=0'))
    %下面的图像只bai当能解出显式z时才画的出来：
    z=solve(detd,z);%这是解出来的
    %% svm绘图，3d
    fh = fsurf(z,[-2,2]);
    set(fh,'FaceColor','g')
    set(fh,'edgecolor','none')
    alpha(0.3)
    hold on
    handle_cell = plot_single_embedding_setc(group_embedding,[1,2]);
    hold off
else
%% svm绘图,2d
    gscatter(group_embedding(:, 1), group_embedding(:, 2), group_embedding(:,3))
    hold on
    x1 = [-1*(obj_lin.Bias/obj_lin.Beta(1)),0];
    x2 = [0,-1*(obj_lin.Bias/obj_lin.Beta(2))];
    X=[x1(1),x2(1)];
    Y=[x1(2),x2(2)];
    p=polyfit(X,Y,1);%多项式拟合，后面的1表示一阶多项式，即直线
    x=-10:10;
    y=polyval(p,x);%通过p求对应x的值
    plot(x,y)
    axis([3,12,10,25])
    axis square
    hold off
end
%% 合并类别比较
sel_group = [20,32,33,39];
merge_group_cell = cell(size(group_compare,1),3);
merge_group_cell(:,1:2) = group_compare(:,1:2);
for k = 1:size(merge_group_cell,1)
    temp_sel_group = group_compare{k,3};
    temp_sum = 0;
    for m = 1:size(sel_group,2)
        temp_sum = temp_sum+temp_sel_group(sel_group(1,m),2);
    end
    merge_group_cell{k,3} = temp_sum;
end































