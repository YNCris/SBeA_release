function idx = density_cluster(embedding, sigma)
%{
    ���ڷ�ˮ����ܶȾ���
%}
[image,XX,YY] = data_density(embedding, sigma);
idx = watershed_cluster(image,XX,YY,embedding);