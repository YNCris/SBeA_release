function seg = mergeI2H(I, para)
% Obtain the class labels of segments when given lables for frames.
% The consecutive frames with same labels will be grouped into one segment.
%
% Input
%   I       -  indicator matrix of frames
%   para    -  segmentation parameter
%
% Output
%   seg     -  temporal segmentation result
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-26-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-23-2009

nMi = para.nMi;
nMa = para.nMa;
w = [nMi, nMa];

[k, n] = size(I);

% empty
G = []; hist = zeros(k, 1); s = 1; m = 0;

for i = 1 : n + 1

    % current segment's length
    len = i - s(m + 1) + 1;

    % stat of frames of current segment
    [tmpHist, tmpInd] = sort(hist);
    cMax = tmpInd(end);

    % current frame
    if i == n + 1
        c = -1;
    else
        c = find(I(:, i));
    end

    % need to place a cut
    if i == n + 1 || (len > w(1) && c ~= cMax) || len > w(2)
        m = m + 1;
        s(m + 1) = i;
        g = zeros(k, 1); g(cMax) = 1; G = [G, g];
        hist = zeros(k, 1);
    else
        hist(c) = hist(c) + 1;
    end
end

% merge the end
% if m > 1 && st(m + 1) - st(m) < w(1)
%     H(:, m) = [];
%     st(m) = st(m + 1);
%     st(m + 1) = [];
% end

seg = newSeg('s', s, 'G', G);
