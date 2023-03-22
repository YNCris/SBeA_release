function [X, ran] = scaleX(X0, ran0)
% Scale features of the given samples
%
% Input
%   X0      -  original sample matrix, dim x n
%   ran0    -  numeric range of each dimensions, dim x 2
%              If not indicated, the range is based on the input X0
%
% Output
%   X       -  new sample matrix, dim x n
%   ran     -  numeric range of each dimensions, dim x 2
%              If ran0 is not indicated, this value will be filled out
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-23-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

[dim, n] = size(X0);

if ~exist('ran0', 'var')
    ran = [min(X0, [], 2), max(X0, [], 2)];
    
else
    ran = ran0;
end

% invalid ranges: max == min
vis = abs(ran(:, 1) - ran(:, 2)) > 1e-6;

X = X0;
Mi = repmat(ran(vis, 1), 1, n);
Diff = repmat(ran(vis, 2) - ran(vis, 1), 1, n);
X(vis, :) = (X(vis, :) - Mi) ./ Diff;
X(~vis, :) = 0;

% inputs exceed the range: > max or < min
X(X < 0) = 0;
X(X > 1) = 1;
