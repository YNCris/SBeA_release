function idx = density_cluster(embedding, sigma)
%{
    基于分水岭的密度聚类
%}
[image,XX,YY] = data_density(embedding, sigma);
idx = watershed_cluster(image,XX,YY,embedding);