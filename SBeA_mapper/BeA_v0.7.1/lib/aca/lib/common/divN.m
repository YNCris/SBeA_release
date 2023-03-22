function ns = divN(n, m, varargin)
% Randomly divide n into m parts, such that sum(ns) == n.
%
% Input
%   n       -  number
%   m       -  parts
%   varargin
%     alg   -  algorithm type, 'rand' | {'eq'}
%
% Output
%   ns      -  numbers, 1 x m
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 05-30-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 11-13-2009

% function option
alg = ps(varargin, 'alg', 'eq');

if strcmp(alg, 'eq')
    ns = zeros(1, m);
    w = floor(n / m);
    for i = 1 : m - 1
        ns(i) = w;
    end
    ns(m) = n - w * (m - 1);

elseif strcmp(alg, 'w')
    w = m;
    m = ceil(n / w);
    ns = zeros(1, m);
    for i = 1 : m - 1
        ns(i) = w;
    end
    ns(m) = n - w * (m - 1);
    
    if ns(m) < w / 2
        ns(m - 1) = ns(m - 1) + ns(m);
        ns(m) = [];
    end
    
elseif strcmp(alg, 'rand')
    while true
        aa = rand(1, m); aa = aa / sum(aa);

        ns = floor(n * aa);
        n2 = n - sum(ns);

        i = 0;
        while n2 > 0
            i = mod(i + 1, m) + 1;
            ns(i) = ns(i) + 1;

            n2 = n2 - 1;
            i = i + 1;
        end

        if isempty(find(ns == 0, 1))
            break;
        end
    end
end
