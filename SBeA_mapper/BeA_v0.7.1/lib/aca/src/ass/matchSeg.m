function [seg, acc, C, P] = matchSeg(seg0, segT)
% Find the best matching between two given segmentation.
% One of the segmentation will be adjusted in its lables.
%
% Input
%   seg0    -  original segmentation
%   segT    -  ground-truth segmentation
%
% Output
%   seg     -  new segmentation after adjusted the segment's label
%   acc     -  accuracy of the matching
%   C       -  confusion matrix after matching, k x k
%   P       -  Permutation matrix, k x k 
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-22-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-23-2009

% confusion matrix
G0 = seg0.G;
C0 = genConMatrix(segT, seg0);

% optimal assignment
[P, acc] = ass(C0);
C = C0 * P';

% adjust indicator matrix
k = size(P, 1);
idx = zeros(1, k);
for i = 1 : k
    p = P(i, :);
    idx(i) = find(p);
end
G = G0(idx, :);

% segmentation
seg = seg0;
seg.G = G;
seg.acc = acc;
