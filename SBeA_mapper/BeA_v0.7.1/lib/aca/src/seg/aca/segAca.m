function [seg, segs] = segAca(K, para, seg0)
% Aligned Cluster Analysis (ACA).
% See the following paper for the details:
%   Aligned Cluster Analysis for Temporal Segmentation of Human Motion, FG 2008
%
% Input
%   K       -  frame similarity matrix, n x n
%   para    -  parameter of segmentation
%   seg0    -  inital segmentation
%
% Output
%   seg     -  segmentation result
%   segs    -  segmentation result during the procedure, 1 x nIter (cell)
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-14-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 01-12-2010

% maximum number of iterations
global HBT

nIterMa = 30;

objs = zeros(nIterMa, 1);
segs = cell(1, nIterMa);
tim = 0;
for nIter = 1 : nIterMa
    tic;

    % search
    segs{nIter} = dpSearch(K, para, seg0);
    objs(nIter) = segs{nIter}.obj;

    % time
    tim = tim + toc;

    % stop condition
    if cluEmp(segs{nIter}.G)
        prom('b', 'segAca stops due to an empty cluster\n');
        segs{nIter}.obj = inf;
        break;
    elseif isequal(segs{nIter}.G, seg0.G) && isequal(segs{nIter}.s, seg0.s)
        break;
    end

    seg0 = segs{nIter};
    disp(['nIter: ', num2str(nIter), 'times, Loss: ', num2str(objs(nIter))]);
end
segs(nIter + 1 : end) = [];

segs{nIter}.tim = tim / nIter;
seg = segs{nIter};
prom('b', 'dpSearch : %.2f seconds, %d iterations\n', seg.tim, nIter);

HBT.HBT_DecData.L2.objs = objs;















