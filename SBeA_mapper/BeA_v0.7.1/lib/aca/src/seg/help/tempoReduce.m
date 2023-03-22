function [sR, X, XD, XD0] = tempoReduce(X0, para)
% Remove the temporal redunancy by merging the consecutive frames with similar
% features into single frames.
%
% Input
%   X0      -  original time series, dim x n0
%   para
%     alg   -  reduction algorithm type, {'merge'} | 'ave'
%     redL  -  maximum segment length
%     kF    -  #frame cluster
%
% Output
%   sR      -  starting positions of merged areas, 1 x (m + 1)
%   X       -  reduced time series data, dim x n
%   XD      -  1-D time series after reduction, 1 x n
%   XD0     -  1-D time series before reduction, 1 x n0
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-04-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-23-2009

% function option
alg = ps(para, 'alg', 'merge');

prom('t', 'tempo reduce');
redL = para.redL; kF = para.kF;

% kmeans to discretize
[dim, n0] = size(X0);
if dim > 1
    G0 = kmean(X0, kF);
    XD0 = G2L(G0);
else
    XD0 = X0;
end

if strcmp(alg, 'merge')
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

elseif strcmp(alg, 'ave');
    sR = 1 : redL : n0 + 1;

else
    error('unknown alg');
end

% fetch the part
X = sPick(X0, sR);
XD = sPick(XD0, sR);
fprintf(' %d -> %d\n', n0, size(X, 2));
