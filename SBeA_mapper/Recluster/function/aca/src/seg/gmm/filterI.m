function I = filterI(I0, w)
% Obtain the class labels of segments when given lables for frames.
% The consecutive frames with same labels will be grouped into one segment.
%
% Input
%   I0      -  indicator matrix of frames
%   w       -  range (min and max) of length
%
% Output
%   I       -  temporal segmentation result
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-13-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-23-2009

[k, n] = size(I0);
cs = zeros(1, n + 1);
cs(1 : n) = G2L(I0);
cs(n + 1) = -1;

% remove the short segment until satisfy the minimum constraint
while true
    minLen = inf;

    head = 1;
    for i = 2 : n + 1
        if cs(i) ~= cs(head)
            len = i - head;
            if len < minLen
                minLen = len;
                minHead = head;
                minTail = i - 1;
            end

            head = i;
        end
    end

    if minLen >= w(1)
        break;
    end

    % merge the shortest segment
    if minHead == 1 && minTail < n
        cs(minHead : minTail) = cs(minTail + 1);
        
    elseif minHead > 1 && minTail == n
        cs(minHead : minTail) = cs(minHead - 1);
        
    elseif minHead > 1 && minTail < n
        mid = floor((minHead + minTail) / 2);
        cs(minHead : mid) = cs(minHead - 1);
        
        if mid + 1 <= minTail
            cs(mid + 1 : minTail) = cs(minTail + 1);
        end
    end
end

I = zeros(k, n);
for i = 1 : n
    I(cs(i), i) = 1;
end
