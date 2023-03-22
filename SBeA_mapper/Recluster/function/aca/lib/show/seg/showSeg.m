function h = showSeg(X, seg, varargin)
% Show sequence with its segments.
%
% Input
%   X         -  frame matrix, dim x n
%   seg       -  segmentation property
%   varargin
%     show option
%     axis    -  axis flag, {'y'} | 'n'
%     cutWid  -  cut line width, {2}
%     lnWid   -  line width, {1}
%     mkSiz   -  size of markers, {5}
%     mkEg    -  flag of marker edge, {'y'} | 'n'
%     lim0    -  predefined limitation, {[]}
%
% Output
%   h         -  handle for the figure
%     lim     -  limitation of the axis
%
% History
%   create    -  Feng Zhou (zhfe99@gmail.com), 12-31-2008
%   modify    -  Feng Zhou (zhfe99@gmail.com), 01-12-2010

% show option
psShow(varargin);

% function option
isAxis = psY(varargin, 'axis', 'y');
cutWid = ps(varargin, 'cutWid', 2);
lnWid = ps(varargin, 'lnWid', 1);
mkSiz = ps(varargin, 'mkSiz', 5);
lim0 = ps(varargin, 'lim0', []);

% dimensionality of sample
[dim, n] = size(X);
if dim == 1
    X = [1 : n; X];
    
elseif dim > 2
    X = embed(X, [], 2, 'alg', 'pca');
end

% labels
G = ps(seg, 'G', 0);
s = ps(seg, 's', [1, n + 1]);
[k, m] = size(G);

% markers
[markers, colors] = genMarkers;
if k > length(markers)
    error('too much classes');
end

% main display
hold on;
for i = 1 : m
    c = find(G(:, i));
    tmpX = X(:, s(i) : s(i + 1) - 1);
    
    plot(tmpX(1, :), tmpX(2, :), '-', 'LineWidth', lnWid, 'Color', colors{c}, 'Marker', markers{c}, 'MarkerSize', mkSiz, ...
        'MarkerFaceColor', colors{c});
end

% axis boundary
if isAxis
    if dim > 1, axis equal; end
    
    aspect = ps(varargin, 'aspect', []);
    if isempty(aspect)
        aspect = select(dim == 1, [0.01, 0.1], [0.1, 0.1]);
    end
    h.lim = setBound(X, 'mar', aspect, 'box0', lim0);
end

% cutlines, only for 1-D time series
if dim == 1 && cutWid > 0
    xL = [s(2 : m); s(2 : m)] - 0.5;
    yL = repmat(h.lim(2, :)', 1, m - 1);
    
    line(xL, yL, 'LineStyle', '--', 'LineWidth', cutWid, 'Color', 'k');
end

