function plot_single_embedding_dbscan(best_label_embedding,class_num,textflg)
%{
    在图谱中绘制单一的类别,class_num为向量
%}
class_num(class_num==-1) = [];
cmaplist3 = best_label_embedding(:,4);
cmapcolor3 = imresize(colormap('jet'),[max(class_num),3]);
cmap3 = zeros(size(cmaplist3,1),3);
for k = 1:size(cmap3,1)
%     text(best_label_embedding(k,1),best_label_embedding(k,2),best_label_embedding(k,3),...
%             num2str(cmaplist3(k,1)),'FontSize',14);
    for m = 1:size(class_num,1)
        if cmaplist3(k,1) == -1
            cmap3(k,:) = 0.7.*ones(1,3);
            break;
        elseif cmaplist3(k,1) == class_num(m)
            cmap3(k,:) = cmapcolor3(cmaplist3(k,1),:);
            break;
        else
%             cmap3(k,:) = 0.7.*ones(1,3);
        end
    end
end
scatter3(best_label_embedding(:,1),best_label_embedding(:,2),best_label_embedding(:,3),...
    50*ones(size(best_label_embedding(:,1))),cmap3,'filled');
%% 贴字
unique_cmaplist = unique(cmaplist3);
if textflg == 1 
    for k = 1:size(unique_cmaplist,1)
        ext_embedding = best_label_embedding(best_label_embedding(:,4)==unique_cmaplist(k,1),1:3);
        cent_embedding = mean(ext_embedding,1);
        text(cent_embedding(1,1),cent_embedding(1,2),cent_embedding(1,3),...
                num2str(unique_cmaplist(k,1)),'FontSize',10);
    end
end
axis square
