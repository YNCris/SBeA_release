function l = G2L_Slow(G)
% Convert class indicator matrix to class label vector.
%
% Example
%   input   -  G = [0 1 0 0; ...      
%                   1 0 0 0; ...  
%                   0 0 1 0]
%   usage   -  l = G2L(G)
%   output  -  l = [2 1 3 0]
%
% Input
%   G       -  class indicator matrix, k x n
%
% Output
%   l       -  class label vector, 1 x n
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-04-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-22-2009

k = size(G, 1);
n = size(G, 2);
l = zeros(1, n);

for i = 1:k
    l(G(i, :) == 1) = i;
end




