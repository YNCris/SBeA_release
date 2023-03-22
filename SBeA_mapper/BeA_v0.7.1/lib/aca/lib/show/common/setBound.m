function box = setBound(X, varargin)
% Set the boundary of the figure.
%
% Input
%   X       -  sample matrix, dim x n
%   varargin
%     mar   -  marginal aspect, {.1}
%     siz   -  box siz, {[]}
%     box0  -  initial bounding box, dim x 2
%     set   -  setting flag, {'y'} | 'n'
%
% Output
%   box     -  bounding box, dim x 2
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-29-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

% parse option
mar = ps(varargin, 'mar', .1);
siz = ps(varargin, 'siz', []);
box0 = ps(varargin, 'box0', []);
isSet = psY(varargin, 'set', 'y');

% bounding box
dim = size(X, 1);
if ~isempty(siz)
    center = mean(X, 2);
    if length(siz) == 1
        siz = ones(dim, 1) * siz;
    else
        siz = siz(:);
    end
    box = [center - siz / 2, center + siz / 2];
    
elseif ~isempty(box0)
    box = box0;

else
    mi = min(X, [], 2);
    ma = max(X, [], 2);
    siz = ma - mi;
    
    if length(mar) == 1
        mar = ones(dim, 1) * mar;
    else
        mar = mar(:);
    end
    
    box = [mi - siz .* mar, ma + siz .* mar];
end

% adjust
if isSet
    if abs(box(1, 1) - box(1, 2)) > eps
        xlim([box(1, 1), box(1, 2)]);
    end
    
    if abs(box(2, 1) - box(2, 2)) > eps
        ylim([box(2, 1), box(2, 2)]);
    end
    
    if size(box, 1) > 2
        zlim([box(3, 1), box(3, 2)]);
    end
end
