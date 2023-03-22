function seg = segNewS(seg0, sR, varargin)
% Adjust the segment position according to the compressed configuration.
%
% Input
%   seg0    -  original segmentation
%   sR      -  configuration of the compression
%   varargin
%     type  -  function type, {'shrink'} | 'expand'
%
% Output
%   seg     -  segmentation parameter
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-04-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-23-2009

% function option
type = ps(varargin, 'type', 'shrink');

s0 = seg0.s; G0 = seg0.G;
if strcmp(type, 'shrink')

    s0 = frame2block(s0(1 : end - 1), sR);
    s0 = [s0, length(sR)];

    s = []; G = [];
    for i = 1 : length(s0) - 1
        if s0(i) ~= s0(i + 1)
            s = [s, s0(i)];
            G = [G, G0(:, i)];
        end
    end
    s = [s, length(sR)];

elseif strcmp(type, 'expand')
    s = sR(s0);
    G = G0;

else
    error('unknown type');
end

seg = seg0;
seg.s = s;
seg.G = G;
