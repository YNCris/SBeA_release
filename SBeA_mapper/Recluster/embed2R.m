%{
    best_label_embedding转换为R数据
%}
embedding = best_label_embedding;
savename = 'embedding_M20201013.mat';
save(savename,'.\data\embedding.mat','-v6');