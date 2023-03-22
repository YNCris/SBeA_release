function saveConKnlPara(nei, sigma)

current_path = fileparts(which('getConKnlPara'));
data_path = [current_path(1:end-18), 'data/'];

config.conKnl_nei = nei;
config.conKnl_sigma = sigma;

save([data_path, 'config.mat'], 'config')
