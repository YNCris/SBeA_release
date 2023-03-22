function [sR, X, XD, XD0, G] = decompose_poses(X0, para)
% Decompose poses layer and remove the temporal redunancy by merging the
% consecutive frames with similar features into single frames.
%
% Input
%   X0      -  original time series of postural data, dim x n0
%   para
%     calg   -  clustering algorithm type, {'kmeans'} | 'density'
%     ralg   -  reduction algorithm type, {'merge'} | 'ave'
%     redL  -  maximum segment length
%     kF    -  #frame cluster, needed if the calg is 'kmeans'
%
% Output
%   sR      -  starting positions of merged areas, 1 x (m + 1)
%   X       -  decomposed time series representation of postural data, dim x n
%   XD      -  1-D time series after decomposition, 1 x n
%   XD0     -  1-D time series before decomposition, 1 x n0
%   G0      -  1-D numerical lables
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-04-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-23-2009
%   modify  -  Kang Huang (kang.huang@siat.ac.cn), 02-29-2020

% function option
ralg = para.ralg;
calg = para.calg;

prom('t', 'tempo reduce');
redL = para.redL; kF = para.kF;

% clustering poses
[dim, n0] = size(X0);
if dim > 1
    if strcmp(calg, 'kmeans')
        G0 = kmean(X0, kF);
        XD0 = G2L_Slow(G0);
    elseif strcmp(calg, 'density')
%         [reduction, ~, L0] = run_umap(X0', 'verbose', 'text', 'n_neighbors', 100);
        [reduction, ~, ~] = run_umap(X0', 'sgd_tasks',1,...
            'verbose', 'text','n_neighbors', 80, 'min_dist', 0.3);
        G0 = kmean(reduction', kF);
        XD0 = G2L_Slow(G0);
%         reduction = phate(X0', 'ndim', 3, 't', 20);
%         L0 = reshape(L0, 1, length(L0));
%         G0 = L2G_Slow(L0+1);
%         XD0 = L0;
    end
else
    XD0 = X0;
end

if strcmp(ralg, 'merge')
    % insert a useless sample at the end
    XD0(n0 + 1) = -1;
    
    sR = ones(1, 10000);
    m = 0;
    for i = 2 : n0 + 1
        if i - sR(m + 1) >= redL || XD0(i) ~= XD0(i - 1)
            m = m + 1;
            sR(m + 1) = i;
        end
    end
    sR(m + 2 : end) = [];
    XD0(n0 + 1) = [];
    
elseif strcmp(ralg, 'ave')
    sR = 1 : redL : n0 + 1;
    
else
    error('unknown alg');
end

% fetch the part
if strcmp(calg, 'kmeans')
    X = sPick(X0, sR);
elseif strcmp(calg, 'density')
    X = sPick(reduction', sR);
end
G = sPick(G0, sR);
XD = sPick(XD0, sR);
fprintf(' %d -> %d\n', n0, size(X, 2));
