function varargout = matFld(path, varargin)
% Load the mat file from the specified path.
%
% Input
%   path      -  mat path
%   varargin  -  name list, 1 x n (cell)
%
% Output
%   mat       -  mat file
%
% History
%   create    -  Feng Zhou (zhfe99@gmail.com), 01-06-2009
%   modify    -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

a = load(path);
m = length(varargin);

if nargout ~= m
    error('The number of outputs must be same as the names given in the parameters.');
end

for i = 1 : m
    varargout{i} = a.(varargin{i});
end

