function K = conPropSimSlow(K0, nMa)
% Construct the progagative similarity matrix.
%
% Input
%   K0      -  frame similarity matrix, n x n
%   nMa     -  maximum width of motion
%
% Output
%   K       -  non-time-warping similarity matrix
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-13-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-22-2009

n = size(K0, 1);
K = zeros(n, n);

for i1 = 1 : n
    for j1 = i1 + 1 : n
        for w = 1 : nMa
            i2 = i1 + w;
            j2 = j1 + w;

            if i2 <= n && j2 <= n
                tmp = min(K0(i1, j1), K0(i2, j2));

                ii = i1; jj = j1;
                K(ii, jj) = max(K(ii, jj), tmp);
                ii = i2; jj = j2;
                K(ii, jj) = max(K(ii, jj), tmp);
                ii = i1; jj = j2;
                K(ii, jj) = max(K(ii, jj), tmp);
                ii = i2; jj = j1;
                K(ii, jj) = max(K(ii, jj), tmp);
            end
        end
    end
end

K = triu(K, 1) + eye(n) + triu(K, 1)';
