function showSegBar(seg, varargin)
% Show segmentation of one sequence. The segments would be displayed as rectangulars.
%
% Input
%   seg      -  segmentation
%   varargin
%     show option
%     lnWid  -  line width, {1}
%     lim0   -  predefined limitation, {[]}
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 01-03-2008
%   modify   -  Feng Zhou (zhfe99@gmail.com), 12-23-2009

% show option
psShow(varargin);

% function option
lnWid = ps(varargin, 'lnWid', 1);

% plotted segment
s = seg.s; G = seg.G;
[k, m] = size(G);
cs = ps(varargin, 'cs', 1 : k); visC = idx2vis(cs, k);
ms = ps(varargin, 'ms', 1 : m); visM = idx2vis(ms, m);

hold on;
[markers, colors] = genMarkers;
for i = 1 : m
    c = find(G(:, i));
    
    % skip the segments
    if ~visC(c) || ~visM(i)
        continue;
    end

    x = [s(i), s(i + 1), s(i + 1), s(i)];
    y = [0, 0, 1, 1];

    if lnWid == 0
        fill(x, y, colors{c}, 'EdgeColor', colors{c});
    else
        fill(x, y, colors{c}, 'EdgeColor', 'w', 'LineWidth', lnWid);
    end
end

% set boundary
setBound([1, s(end) - 1; 0, 1], 'mar', [.01, .1], 'flag', 'on');
xLim = ps(varargin, 'xLim', []);
if ~isempty(xLim), xlim(xLim); end
axis off;
