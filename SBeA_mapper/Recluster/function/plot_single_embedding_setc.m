function handle_cell = plot_single_embedding_setc(best_label_embedding,class_num)
%{
    ��ͼ���л��Ƶ�һ�����?,class_numΪ����
%}
cmaplist3 = best_label_embedding(:,4);
cmapcolor3 = [0.38,0,0.32;0.33,0.63,0.98;0.75,0.38,0;0,0.75,0;1,0,0];
cmap3 = zeros(size(cmaplist3,1),3);
for k = 1:size(cmap3,1)
    for m = 1:length(class_num)
        if cmaplist3(k,1) == class_num(m)
            cmap3(k,:) = cmapcolor3(cmaplist3(k,1),:);
            break;
        else
            cmap3(k,:) = 0.7.*ones(1,3);
        end
    end
end
handle_cell = cell(length(class_num),1);
for k = 1:length(class_num)
    hold on
    handle_cell{k,1} = scatter3(best_label_embedding(cmaplist3==class_num(k),1),...
        best_label_embedding(cmaplist3==class_num(k),2),...
        best_label_embedding(cmaplist3==class_num(k),3),...
        100*ones(size(best_label_embedding(cmaplist3==class_num(k),1))),...
        cmap3(cmaplist3==class_num(k),:),'filled', 'MarkerEdgeColor', 'k');
    hold on
end
%% annote number
for k = 1:size(best_label_embedding,1)
    text(best_label_embedding(k,1)+0.1,...
        best_label_embedding(k,2)+0.1,...
        best_label_embedding(k,3)+0.1,num2str(k));
end
hold off
axis square
