function pos = keyPosH(seg, iH, iS)
% Obtain the keyframe of the segment.
%
% Input
%   seg     -  temporal segmentation
%   iH      -  level position
%   iS      -  segment position
%
% Output
%   pos     -  key frames' position
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-13-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

nH = length(seg);

if iH == nH + 1
    pos = seg(nH).st(1 : end - 1);
    
elseif iH > 1
    posH = seg(iH).stH(iS) : seg(iH).stH(iS + 1) - 1;
    pos = seg(iH - 1).st(posH);
    
else
    pos = seg(iH).st(iS) : seg(iH).st(iS + 1) - 1;
end
