function [h, Ys] = showSeq(Xs, varargin)
% Show multiple sequence.
%
% Input
%   Xs       -  sequence set, 1 x m (cell), dim x ni
%   varargin
%     show option
%     axis   -  axis flag, {'y'} | 'n'
%     lnWid  -  line width, {1}
%     mkSiz  -  size of markers, {0}
%     mkEg   -  flag of marker edge, {'y'} | 'n'
%     lim0   -  predefined limitation, {[]} 
%
% Output
%   h        -  handle for the figure
%     lim    -  limitation of the axis
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 03-31-2009
%   modify   -  Feng Zhou (zhfe99@gmail.com), 01-11-2010

% function option
psShow(varargin);
isAxis = psY(varargin, 'axis', 'y');
lnWid = ps(varargin, 'lnWid', 1);
mkSiz = ps(varargin, 'mkSiz', 0);
isMkEg = psY(varargin, 'mkEg', 'y');
lim0 = ps(varargin, 'lim0', []);
keyFs = ps(varargin, 'keyFs', {});

if ~iscell(Xs)
    Xs = {Xs};
end

% dimensionality of sample
m = length(Xs);
dim = size(Xs{1}, 1);
ns = cellDim(Xs, 2);
if dim == 1
    for i = 1 : m
        X0 = Xs{i};
        Xs{i} = [1 : ns(i); X0];
    end
    
elseif dim > 2
    X0 = cat(2, Xs{:});
    s = n2s(ns);
    X = embed(X0, [], 2, 'alg', 'pca');
    for i = 1 : m
        Xs{i} = X(:, s(i) : s(i + 1) - 1);
    end
end

% markers
[markers, colors] = genMarkers;
if m > length(markers)
    error('too much classes');
end

% main display
hold on;
for i = 1 : m
    X = Xs{i};
    c = i;
    
    hTmp = plot(X(1, :), X(2, :));
    
    % line
    if lnWid > 0
        set(hTmp, 'LineStyle', '-', 'LineWidth', lnWid, 'Color', colors{c});
    else
        set(hTmp, 'LineStyle', 'none');
    end
end

% axis boundary
if isAxis
    if dim > 1, axis equal; end
    
    aspect = ps(varargin, 'aspect', []);
    if isempty(aspect)
        aspect = select(dim == 1, [0.01, 0.1], [0.1, 0.1]);
    end
    X = cat(2, Xs{:});
    lim = setBound(X, 'mar', aspect, 'lim0', lim0);
    
    if nargout > 0
        h.lim = lim;
    end
end

Ys = Xs;
