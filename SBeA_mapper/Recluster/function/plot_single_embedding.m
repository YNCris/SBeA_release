function plot_single_embedding(best_label_embedding,class_num)
%{
    在图谱中绘制单一的类别,class_num为向量
%}
cmaplist3 = best_label_embedding(:,4);
cmapcolor3 = imresize(colormap('jet'),[length(unique(cmaplist3)),3]);
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
scatter3(best_label_embedding(:,1),best_label_embedding(:,2),best_label_embedding(:,3),...
    50*ones(size(best_label_embedding(:,1))),cmap3,'filled');
axis square
