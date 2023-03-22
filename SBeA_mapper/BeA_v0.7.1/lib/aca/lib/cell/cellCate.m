function a = cellCate(varargin)
% Concatenate a set of cell array into a single cell array.
%
% Example
%   input     -  a1 = {'feng', 28}; a2 = {'age'}; a3 = 33;
%   call      -  a = cellCate(a1, a2, a3)
%   output    -  a = {'feng', 28, 'age', 33}
%
% Input
%   varargin  -  set of cell array, 1 x m (cell)
%
% Output
%   a         -  single cell array, 1 x n (cell)
%
% History
%   create    -  Feng Zhou (zhfe99@gmail.com), 02-16-2009
%   modify    -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

nargin = length(varargin);
maxN = 10000;

a = cell(1, maxN); n = 0;
for i = 1 : nargin
    a0 = varargin{i};
    if ~iscell(a0)
        a0 = {a0};
    end
    
    m = length(a0);
    for j = 1 : m
        n = n + 1;
        a{n} = a0{j};
    end
end
a(n + 1 : end) = [];
