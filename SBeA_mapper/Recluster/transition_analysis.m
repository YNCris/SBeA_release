%{
    ת�Ʒ���
%}
clear all
close all
%% ��ȡ����
load('.\data\final_group_compare_30.mat');
load('.\data\final_embedding_30.mat');
%% ����ת�ƾ���
for k = 1:size(group_compare,1)
    subplot(2,6,k)
    imagesc(group_compare{k,5})
    title(group_compare{k,1})
    axis square
end
%% ����״̬ת�ƾ���Ĳ��죬�����ÿһ�����Ӽ���t����
group_num = 2;
p_mat = zeros(size(group_compare{1,5}));
statistic_cell = cell(size(group_compare{1,5}));
sd_statistic_cell = cell(size(group_compare{1,5})); 
G_index = {1:6;7:12};
comb_list = nchoosek(1:group_num,2);
for m = 1:size(statistic_cell,1)
    for n = 1:size(statistic_cell,2)
        %%
        temp_x = [];
        temp_group = [];
        temp_statistic_group = struct;
        for m1 = 1:group_num
            temp_x_cell = [];
            for n1 = G_index{m1,1}
                temp_x_cell = [temp_x_cell,group_compare{n1,5}(m,n)];
            end
            temp_x = [temp_x,temp_x_cell];
            temp_group = [temp_group,m1*ones(1,numel(temp_x_cell))];
        end
        %��̬�Լ���
        [H,temp_statistic_group.lillietest] = lillietest(temp_x(:));
        %�������Լ���
        for k = 1:size(comb_list,1)
            [~,var_plist(k,1),~,~] = vartest2(temp_x(temp_group==comb_list(k,1)),...
                temp_x(temp_group==comb_list(k,2)));
        end
        temp_statistic_group.vartest = var_plist';
        %������̬�Ժͷ���������t���飬�����÷ǲ�������
        if (min(var_plist(:))>0.05)&&(temp_statistic_group.lillietest>0.05)
            [h,p,ci,stats] = ttest2(temp_x(temp_group==comb_list(1,1)),...
                temp_x(temp_group==comb_list(1,2)));
%             [p,table,stats]=anova1(temp_x(:),temp_group(:),'off');
%             [comparison,means,h,gnames] = multcompare(stats,'display','off','estimate','anova1');
        else
            [p, h, stats] = ranksum(temp_x(temp_group==comb_list(1,1)),...
                temp_x(temp_group==comb_list(1,2)));
%             [p,table,stats]=anova1(temp_x(:),temp_group(:),'off');
%             [comparison,means,h,gnames] = multcompare(stats,'display','off','estimate','kruskalwallis');
        end
        temp_statistic_group.comparison = abs(comparison);
        temp_statistic_group.p = p;
        temp_statistic_group.x = temp_x;
        temp_statistic_group.group = temp_group;
        temp_statistic_group.means = [mean(temp_x(temp_group==comb_list(1,1))),...
            mean(temp_x(temp_group==comb_list(1,2)))];
        temp_statistic_group.std = [std(temp_x(temp_group==comb_list(1,1))),...
            std(temp_x(temp_group==comb_list(1,2)))];
%         temp_statistic_group.p_star = comparison(:,end)';
        statistic_cell{m,n} = temp_statistic_group;
        if temp_statistic_group.means(1)>=temp_statistic_group.means(2)
            p_mat(m,n) = p;
        else
            p_mat(m,n) = -p;
        end
%         if min(temp_statistic_group.p_star(:))<0.05
            sd_statistic_cell{m,n} = temp_statistic_group;
%         end
    end
end
%% ���ӻ�p����
p_larger_mat = p_mat;
p_larger_mat(p_mat>0.05) = 0;
p_larger_mat(p_mat<-0.05) = 0;
subplot(121)
imagesc(p_mat)
axis square
colormap('jet')
colorbar
subplot(122)
imagesc(p_larger_mat)
axis square
colormap('jet')
colorbar
%% ����������ֵ����
mean_mat_cell = cell(2,1);
for m = 1:size(mean_mat_cell,1)
    temp_mat = zeros(size(group_compare{1,5}));
    for n = 1:size(group_compare,1)
        if m == group_compare{n,2}
            temp_mat = temp_mat+group_compare{n,5};
            disp(m)
        else 

        end
    end
    mean_mat_cell{m,1} = temp_mat/6;
end
%% ��ֵ����Ƚ���֤
sub_mat = mean_mat_cell{1,1}>mean_mat_cell{2,1};
subplot(121)
imagesc(sub_mat)
sub_mat = mean_mat_cell{1,1}<mean_mat_cell{2,1};
subplot(122)
imagesc(sub_mat)




