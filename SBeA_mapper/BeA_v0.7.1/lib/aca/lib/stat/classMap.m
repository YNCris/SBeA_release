function CMap = classMap(cs)
% Build the class dictionary. 
% Given a dataset, we usually only use one part instead of the whole class set. 
% To faciliate it, CMap maps the used class to real underlying class.
% E.g., the whole class set has three different classes, 'c1', 'c2', 'c3'.
% We only use two of them, 'c1' and 'c3'. The input cs will be like [1 3],
% and CMap will be constructed like
%   | 1 0 0 |
%   | 0 0 1 |
%
% Input
%   cs      -  used class labels, 1 x m (integer)
%
% Output
%   CMap    -  dictionary, k x maxc
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-03-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

k = 0;
m = length(cs);
maxc = max(cs);

% old dictionary, original -> new
dict = zeros(1, maxc);
for i = 1 : m
    c = cs(i);
    if dict(c) == 0
        k = k + 1;
        dict(c) = k;
    end
end

% new dictionary, new -> original
CMap = zeros(k, maxc);
for i = 1 : m
    c = cs(i);
    CMap(dict(c), c) = 1;
end
