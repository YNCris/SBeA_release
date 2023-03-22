function seg = filterSeg(seg0, w)
% Filter the short segments while adjust the labels.
%
% Input
%   seg0    -  original segmentation
%   w       -  range (min and max) of length
%
% Output
%   seg     -  segmentation after filtering
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 03-03-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-23-2009

G0 = seg0.G;
s0 = seg0.s;

G = G0; s = s0;
m = length(s) - 1;

% remove the short segment until satisfy the minimum constraint
while m > 1

    lens = diff(s);
    [minLen, i] = min(lens);
    
    if minLen >= w(1)
        break;
    end

    % merge the shortest segment
    if i == 1
        s(i + 1) = [];
        G(:, i) = [];
        
    elseif i == m
        s(i) = [];
        G(:, i) = [];
        
    else
        j = floor((s(i) + s(i + 1)) / 2);
        s(i) = j;
        s(i + 1) = [];
        G(:, i) = [];
    end
end

seg = newSeg('s', s, 'G', G);
