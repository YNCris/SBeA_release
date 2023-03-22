function varargout = cellFldD(A, varargin)
% Fetch out the field (double) of each cell element.
%
% Input
%   A          -  struct cell array, n1 x n2 x n3 x ... (cell)
%   varargin   -  field name list, 1 x m (cell)
%
% Output
%   varargout  -  field value list, 1 x m (cell)
%
% History
%   create     -  Feng Zhou (zhfe99@gmail.com), 02-01-2009
%   modify     -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

ndim = ndims(A);
dims = cell(1, ndim);
n = numel(A);
for i = 1 : ndim
    dims{i} = size(A, i);
end

m = length(varargin);

if nargout ~= m
    error('The number of outputs must be same as the names given in the parameters.');
end

for i = 1 : m
    B = zeros(dims{:});
    name = varargin{i};

    for j = 1 : n
        B(j) = A{j}.(name);
    end
    
    varargout{i} = B;
end
