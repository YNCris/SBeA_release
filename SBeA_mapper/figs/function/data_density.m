function [image,XX,YY,embed_img] = data_density(embedding, sigma, prec)
%{
    ����embedding���ܶ�
%}
% sigma = 100;
%% embeddingת��Ϊͼ��
% prec = 0.03;%ͼ�񾫶�
new_embedding  = round(embedding/prec);
max_x = max(new_embedding(:,1));
max_y = max(new_embedding(:,2));
min_x = min(new_embedding(:,1));
min_y = min(new_embedding(:,2));
temp_image = zeros(max_x-min_x+1,max_y-min_y+1);
ex = new_embedding(:,1)-min_x+1;
ey = new_embedding(:,2)-min_y+1;
temp_embed_img = cell(size(temp_image));
for k = 1:size(new_embedding,1)
    temp_image(ex(k,1),ey(k,1)) = temp_image(ex(k,1),ey(k,1))+1;
    temp_embed_img{ex(k,1),ey(k,1)} = [temp_embed_img{ex(k,1),ey(k,1)};k];% embedding 2 ͼ��ӳ��ͼ
end
%% �ܶ�ƽ��
W = mat2gray(fspecial('gaussian',[max_x-min_x+1,max_y-min_y+1],sigma)); 
image = flipud(mat2gray(imfilter(temp_image, W, 'replicate','same'))');
%% ����ӳ���
XX = flipud(((min_x:max_x)'*ones(1,size(image,1)).*prec)');
YY = flipud((ones(size(image,2),1)*(min_y:max_y).*prec)');
embed_img = flipud(temp_embed_img');
