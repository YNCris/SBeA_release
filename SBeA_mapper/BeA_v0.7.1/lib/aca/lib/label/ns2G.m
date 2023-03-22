function G = ns2G(ns)
% Obtain the class indicator matrix from the frame number.
%
% Example
%   input   -  ns = [4 2 3]
%   call    -  G = ns2G(ns)
%   output  -  G  = [1 1 1 1 0 0 0 0 0; ...
%                    0 0 0 0 1 1 0 0 0; ...
%                    0 0 0 0 0 0 1 1 1];
% Input
%   ns      -  frame number vector, 1 x k
%
% Output
%   G       -  class indicator matrix, k x n
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 03-19-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-20-2009

k = length(ns);
n = sum(ns);

G = zeros(k, n);
p = 0;
for c = 1 : k
    nc = ns(c);
    
    G(c, p + 1 : p + nc) = 1;
    p = p + nc;
end
