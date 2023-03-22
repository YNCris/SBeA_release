function seg = segIniR(K, para)
% Randomly initialize the segmentation.
%
% Input
%   K       -  frame similarity, n x n
%   para    -  segmentation parameter
%
% Output
%   seg     -  temporal segmentation result
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-26-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-22-2009

n = size(K, 1);
[k, nMi, nMa] = stFld(para, 'k', 'nMi', 'nMa');

% local constarint
lc = ps(para, 'lc', 0);

% frame weights
wFs = ps(para, 'wFs', []);
if isempty(wFs)
    wFs = ones(1, n);
end

% generate segmentation until the constraints have been satisfied
co = 0;
while true
    co = co + 1;
    % randomly generate segment position
    s = ones(1, n + 1);
    head = 1;
    m = 0;
    while head <= n
        m = m + 1;
        s(m) = head;

        len = float2block(rand(1), nMi, nMa);
        head = head + len;
    end
    s(m + 1) = n + 1;
    s(m + 2 : end) = [];
    
    % ensure that each segment has satisfied the length constraint
    ns = diff(s);
    visMi = ns < nMi;
    visMa = ns > nMa;
    if any(visMi | visMa)
        continue;
    end

    % label by clustering
    seg = newSeg('s', s);
    T = dtaksFord(K, seg, lc, wFs);
    seg.G = cluSc(T, k);
    
    % ensure that each cluster has at least one segment
    if ~cluEmp(seg.G)
        break;
    elseif co > 100
        fprintf('empty cluster\n');
    end
end
