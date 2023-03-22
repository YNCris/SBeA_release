function G = L2G_Slow(l)
% Convert class label vector to class indicator matrix.
%
% Sample
%   input   -  l = [2 1 3 0], k = 3
%   call    -  G = L2G(l, k)
%   output  -  G = [0 1 0 0; ...
%                   1 0 0 0; ...
%                   0 0 1 0]
%
% Input
%   l       -  class label vector, 1 x n
%   k       -  #class, use the max(l) if not indicated
%
% Output
%   G       -  class indicator matrix, k x n
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-04-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-20-2009
%   modify  -  Yaning Han  (yn.han@siat.ac.cn), 07-16-2020

k = max(unique(l));
n = length(l);
G = zeros(k, n);

for i = 1:k
    G(i, l == i) = 1;
end
