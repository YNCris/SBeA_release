function showM(M, varargin)
% Show matrix.
%
% Input
%   M        -  matrix, n1 x n2
%   varargin
%     show option
%     bar    -  bar flag, 'y' | {'n'}
%     tick   -  flag of showing x and y ticks, {'y'} | 'n'
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 12-29-2008
%   modify   -  Feng Zhou (zhfe99@gmail.com), 01-12-2010

% function option
psShow(varargin);
isBar = psY(varargin, 'bar', 'n');
isTick = psY(varargin, 'tick', 'y');

% matrix
[n1, n2] = size(M);
imagesc(M);
colormap(gray);

% axis
axis equal;
axis([1 - .5, n2 + .5, 1 - .5, n1 + .5]);
axis ij;
hold on;

% color bar
if isBar
    colorbar;
end

% x and y ticks
if ~isTick
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);    
end
