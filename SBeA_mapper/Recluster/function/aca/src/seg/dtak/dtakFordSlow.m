function [v, P, KC] = dtakFordSlow(K, lc, wF1s, wF2s)
% Move forward to construct the path matrix.
%
% Input
%   K       -  frame similarity matrix, n1 x n2
%   lc      -  local constraint (Sakoe and Chiba)
%              0 : not used
%              1 : used
%   wF1s    -  frame weight of 1st sequence, 1 x n1
%   wF2s    -  frame weight of 2nd sequence, 1 x n2
%
% Output
%   v       -  dtak value
%   P       -  path matrix, n1 x n2
%   KC      -  cummulative similarity matrix, n1 x n2
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 03-20-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 01-13-2010

[n1, n2] = size(K);

% local constraint
if nargin < 2
    lc = 0;
end

% frame weight
if nargin < 3
    wF1s = ones(1, n1);
    wF2s = ones(1, n2);
end

if lc == 0
    [v, P, KC] = dtakDP(K, wF1s, wF2s);
elseif lc == 1
    [v, P, KC] = dtakDPLc(K, wF1s, wF2s);
else
    error('unknown local constraint');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [v, P, KC] = dtakDP(K, wF1s, wF2s)
% Move forward to construct the path matrix without local constraint.
%
% Input
%   K       -  frame similarity matrix, n1 x n2
%   wF1s    -  frame weight of 1st sequence, 1 x n1
%   wF2s    -  frame weight of 2nd sequence, 1 x n2
%
% Output
%   v       -  dtak value
%   P       -  path matrix, n1 x n2
%   KC      -  cummulative similarity matrix, n1 x n2

[n1, n2] = size(K);
[P, KC] = zeross(n1, n2);

for i = 1 : n1
    for j = 1 : n2
        kij = K(i, j);
        wFi = wF1s(i);
        wFj = wF2s(j);

        if i == 1 && j == 1
            KC(i, j) = (wFi + wFj) * kij;
            P(i, j) = 0;

        elseif i == 1
            KC(i, j) = KC(i, j - 1) + wFj * kij;
            P(i, j) = 1;

        elseif j == 1
            KC(i, j) = KC(i - 1, j) + wFi * kij;
            P(i, j) = 2;

        else
            [KC(i, j), P(i, j)] = max([KC(i, j - 1) + wFj * kij, ...
                                       KC(i - 1, j) + wFi * kij, ...
                                       KC(i - 1, j - 1) + (wFi + wFj) * kij]);
        end
    end
end
v = KC(n1, n2) / (sum(wF1s) + sum(wF2s));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [v, P, KC] = dtakDPLc(K, wF1s, wF2s)
% Move forward to construct the path matrix with local constraint.
%
% Input
%   K       -  frame similarity matrix, n1 x n2
%   wF1s    -  frame weight of 1st sequence, 1 x n1
%   wF2s    -  frame weight of 2nd sequence, 1 x n2
%
% Output
%   v       -  dtak value
%   P       -  path matrix, n1 x n2
%   KC      -  cummulative similarity matrix, n1 x n2

[n1, n2] = size(K);
[P, KC] = oness(n1, n2);
P = -P; KC = -KC;

for i = 1 : n1
    for j = 1 : n2
        kij = K(i, j);
        wFi = wF1s(i);
        wFj = wF2s(j);

        if i == 1 && j == 1
            KC(i, j) = (wFi + wFj) * kij;
            P(i, j) = 0;

        elseif i == 1

        elseif j == 1

        elseif i == 2 || j == 2
            if P(i - 1, j - 1) >= 0
                KC(i, j) = KC(i - 1, j - 1) + (wFi + wFj) * kij;
                P(i, j) = 3;
            end
        else
            wFii = wF1s(i - 1);
            wFjj = wF2s(j - 1);

            if P(i - 1, j - 1) >= 0
                KC(i, j) = KC(i - 1, j - 1) + (wFi + wFj) * kij;
                P(i, j) = 3;
            end

            tmp = KC(i - 1, j - 2) + (wFi + wFjj) * K(i, j - 1) + wFj * kij;
            if P(i - 1, j - 2) >= 0 && tmp > KC(i, j);
                KC(i, j) = tmp;
                P(i, j) = 4;
            end

            tmp = KC(i - 2, j - 1) + (wFii + wFj) * K(i - 1, j) + wFi * kij;
            if P(i - 2, j - 1) >= 0 && tmp > KC(i, j);
                KC(i, j) = tmp;
                P(i, j) = 5;
            end
        end
    end
end
v = KC(n1, n2) / (sum(wF1s) + sum(wF2s));
