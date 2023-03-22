clear all
close all
%% ��ȡ����
load('./data/final_group_compare_30.mat');
load('./data/final_embedding_30.mat');
%% �Ƚ϶����������
comp_mot_num = zeros(size(group_compare,1),size(group_compare{1,3},1));
for k = 1:size(comp_mot_num,1)
    comp_mot_num(k,:) = group_compare{k,3}(:,2)';
end
figure
boxplot(comp_mot_num);
%% ��ʾ
for k = 1:size(group_compare,1)
    if group_compare{k,2} == 1
        plot(group_compare{k,3}(:,1),group_compare{k,3}(:,2),'g*-')
        hold on
    elseif group_compare{k,2} == 2
        plot(group_compare{k,3}(:,1),group_compare{k,3}(:,2),'r*-')
        hold on
    elseif group_compare{k,2} == 3
%         plot(group_compare{k,3}(:,1),group_compare{k,3}(:,2),'b*-')
%         hold on
    else
        error('���ݴ���');
    end
end
hold off
set(gca,'xtick',group_compare{1,3}(:,1))
%% �Ƚ϶������ʱ��
comp_mot_time = zeros(size(group_compare,1),size(group_compare{1,4},1));
for k = 1:size(comp_mot_time,1)
    comp_mot_time(k,:) = group_compare{k,4}(:,2)';
end
figure
boxplot(comp_mot_time);
%% �Ƚ϶���������ϼ��޷ֲ�
comp_plimit = zeros(size(group_compare,1),size(group_compare{1,6},1));
for k = 1:size(comp_plimit,1)
    comp_plimit(k,:) = group_compare{k,6}(:,1)';
end
figure
boxplot(comp_plimit);
%% ����
m = 5;
transmat = group_compare{m,5};
p_limit = group_compare{m,6};
S1 = group_compare{m,3}(:,2)';
Sn = S1*transmat;
plot(S1,Sn)
%% ��������embedding
class_num = 35;
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
    'min_dist',0.1,'metric','euclidean','n_components', dimesion_num);
% reduction = tsne(comp_data','NumDimensions',2);
group_label = group_compare(:,2);%{1;2;1;2;1;2;1;2;1;2;1;2};%
group_embedding = [reduction-ones(size(reduction,1),1)*mean(reduction),cell2mat(group_label)];
% figure
% gscatter(group_embedding(:, 1), group_embedding(:, 2), group_embedding(:,3))
%% svm
obj_lin = fitclinear(group_embedding(:,1:dimesion_num),group_embedding(:,dimesion_num+1));
%% ��ͼ
close all
if dimesion_num == 3
    %% ���㳬ƽ��
    syms x y z
    Xm = zeros(dimesion_num,dimesion_num);
    for k = 1:dimesion_num
        Xm(k,k) = -1*(obj_lin.Bias/obj_lin.Beta(k));
    end
    D=[ones(4,1),[[x,y,z];Xm]];%�ɿ�bai�������du�ε�����֪��D������ʽ���������ƽ�淽�̡�zhi
    detd=det(D);
    disp(strcat('ƽ�淽��Ϊ��',char(detd),'=0'))
    %�����ͼ��ֻbai���ܽ����ʽzʱ�Ż��ĳ�����
    z=solve(detd,z);%���ǽ������
    %% svm��ͼ��3d
    fh = fsurf(z,[-2,2]);
    set(fh,'FaceColor','g')
    set(fh,'edgecolor','none')
    alpha(0.3)
    hold on
    handle_cell = plot_single_embedding_setc(group_embedding,1:2);
    legend('','KO','WT');
    hold off
else
%% svm��ͼ,2d
    gscatter(group_embedding(:, 1), group_embedding(:, 2), group_embedding(:,3))
    hold on
    x1 = [-1*(obj_lin.Bias/obj_lin.Beta(1)),0];
    x2 = [0,-1*(obj_lin.Bias/obj_lin.Beta(2))];
    X=[x1(1),x2(1)];
    Y=[x1(2),x2(2)];
    p=polyfit(X,Y,1);%����ʽ��ϣ������1��ʾһ�׶���ʽ����ֱ��
    x=-10:10;
    y=polyval(p,x);%ͨ��p���Ӧx��ֵ
    plot(x,y)
    axis([3,12,10,25])
    axis square
    hold off
end


































