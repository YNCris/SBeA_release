function [G, cost, acc] = kmean(X, k, varargin)
% K-means. A wrapper of matlab function, kmeans.
% After initalized serveral times, the one with the minimum cost is selected.
%
% Input
%   X       -  sample matrix, dim x n
%   k       -  cluster number
%   varargin
%     nRep  -  number of repetition to select the minimum cost, {50}
%     G0    -  ground truth label, k x n, {[]}
%              if indicated, adjust the output label
%
% Output
%   G       -  indicator matrix, k x n
%   cost    -  error cost
%   acc     -  accuracy if H0 is indicated
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-22-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-22-2009

% function option
nRep = ps(varargin, 'nRep', 50);
G0 = ps(varargin, 'G0', []);

XTran = X';
Gs = cell(1, nRep); 
costs = zeros(1, nRep);
warning off;
for i = 1 : nRep
    try
        L = kmeans(XTran, k, 'emptyaction', 'singleton', 'display', 'off');
    catch
        err = lasterror;
        sprintf('%s\n', err.message);
        
        costs(i) = inf;
        continue;
    end

    G = L2G(L, k);
    
    costs(i) = evalClu(X, G, 'type', 'in');
    Gs{i} = G;
end
warning on;

[cost, ind] = min(costs);
G = Gs{ind};
acc = 0;

if ~isempty(G0)
    [G, acc] = match(G, 'HT', G0);
end
