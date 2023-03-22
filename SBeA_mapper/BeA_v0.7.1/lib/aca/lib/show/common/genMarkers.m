function [markers, colors] = genMarkers
% Generate the markers for show* functions.
% Notice that the maximum number of classes is 12.
%
% Output
%   markers  -  1 x 12 (cell)
%   colors   -  1 x 12 (cell)
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 01-03-2009
%   modify   -  Feng Zhou (zhfe99@gmail.com), 12-17-2009

colors = {[1 0 0], [0 0 1], [0 1 0], [1 0 1], [0 0 0], [0 1 1], [.3 .3 .3], [.5 .5 .5], [.7 .7 .7], [.1 .1 .1], [1 .8 0], [1, .4, .6]};
%             'r',     'b',     'g',     'm',     'k',     'c',  

markers = {'o', 's', '^', 'd', '+', '*', 'x', 'p', '.', 'v', 'o', 's'};
