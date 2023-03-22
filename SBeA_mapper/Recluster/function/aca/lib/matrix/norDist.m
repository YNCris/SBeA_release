function [DSqs, Ds] = norDist(DSq0s, nei)
% Normalize the distance matrix.
%
% Input
%   DSq0s   -  original square of distance matrix, 1 x dim (cell), n x n
%   nei     -  width of neighborhood, dim x 1
%
% Output
%   DSqs    -  new square of distance matrix, 1 x dim (cell), n x n
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 10-24-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 11-14-2009

dim = length(DSq0s);
if length(nei) == 1
    nei = repmat(nei, dim, 1);
end

[DSqs, Ds] = cellss(1, dim);
for d = 1 : dim
    D0 = real(sqrt(DSq0s{d}));
    n = size(D0, 1);

    % Estimate the variance of distance
    m = min(n - 1, floor(n * nei(d)));
    v = 1;
    if m > 0
        D1 = sort(D0);
        D2 = D1(2 : (1 + m), :);

        v = sum(sum(D2, 1)) / (n * m);
    end
    
    DSqs{d} = DSq0s{d} / (2 * v ^ 2);
    Ds{d} = real(sqrt(DSqs{d}));
end
