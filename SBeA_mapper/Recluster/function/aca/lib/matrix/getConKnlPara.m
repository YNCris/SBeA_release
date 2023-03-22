function [nei, sigma] = getConKnlPara()

current_path = fileparts(which('getConKnlPara'));
data_path = [current_path(1:end-18), 'data/'];

load([data_path, 'config.mat']);
nei = config.conKnl_nei;
sigma = config.conKnl_sigma;
