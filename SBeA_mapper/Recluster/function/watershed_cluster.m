function [idx,L] = watershed_cluster(image,embedding,embed_img)
%{
    ���ڷ�ˮ����ܶȾ���
%}
%% ��ˮ��
new_embed_pdf = 1-mat2gray(image);
L = watershed(new_embed_pdf);
% disp(max(L(:)))
%% ӳ�䵽ԭʼ���ݿռ�
tempidx = zeros(size(embedding,1),1);
for k = 1:max(L(:))
    mask_embed_img = embed_img(L==k);
%     mask_embed_img(cellfun(@isempty,mask_embed_img)) = [];
    maskidx = cell2mat(mask_embed_img);
    tempidx(maskidx,1) = k;
end
zero_embed = embedding(tempidx==0,:);
zero_embed_idx = find(tempidx==0);
distembed = pdist2(embedding,zero_embed);
distembed(zero_embed_idx,:) = inf;
for k = 1:size(zero_embed_idx,1)
    distidx = find(distembed(:,k)==min(distembed(:,k)),1,'first');
    tempidx(zero_embed_idx(k,1),1) = tempidx(distidx,1);
end
idx = tempidx;
%% idxУ��
unique_idx = unique(tempidx);
newidxlist = 1:length(unique_idx);
for k = 1:size(unique_idx,1)
    idx(tempidx==unique_idx(k,1),1) = newidxlist(1,k);
end
%%
% toc
% %% ��ʾ��ˮ��ָ�
% figure
% show_embed_pdf = mat2gray(image);
% show_embed_pdf(L==0) = 1;
% imagesc(show_embed_pdf)
% colormap('hot')
% axis square
% colorbar
% %% ��ʾӳ��
% figure
% s1 = surfc(XX,YY,double(~bw_L));
% colormap('gray')
% shading interp % ȥ��ͼ���ϵ����񣬼�ʹ֮�⻬
% grid off
% alpha(s1,0);
% view(2)
% hold on 
% gscatter(label_embedding(:,1), label_embedding(:,2),label_embedding(:,3));
% legend off
% axis square