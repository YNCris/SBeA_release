function [C, W] = dtakBackSlow(P)
% Trace back to seek the optimum path.
%
% Input
%   P       -  path matrix, n1 x n2
%
% Output
%   C       -  frame correspondance matrix, 2 x m
%   W       -  warping matrix, n1 x n2
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-16-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-22-2009

[n1, n2] = size(P);
maM = n1 + n2;
C = zeros(2, maM);

i = n1; j = n2;
m = 1;
C(:, m) = [i; j];
while true
    p = P(i, j);
    
    if p == 0
        break;

    elseif p == 1
        j = j - 1;
       
    elseif p == 2
        i = i - 1;
       
    elseif p == 3
        i = i - 1;
        j = j - 1;

    elseif p == 4
        m = m + 1;
        j = j - 1;
        C(:, m) = [i; j];
        
        i = i - 1;
        j = j - 1;        

    elseif p == 5
        m = m + 1;
        i = i - 1;
        C(:, m) = [i; j];
        
        i = i - 1;
        j = j - 1;
       
    else
        error('unknown path direction p: %d', p);
    end

    m = m + 1;
    C(:, m) = [i; j];
end
C(:, m + 1 : end) = [];
C = C(:, end : -1 : 1);

% warping matrix
W = C2W(C);
for t = 1 : m
    i = C(1, t);
    j = C(2, t);

    if t == 1
        W(i, j) = 2;
    elseif i - C(1, t - 1) == 1 && j - C(2, t - 1) == 1
        W(i, j) = 2;
    end
end
