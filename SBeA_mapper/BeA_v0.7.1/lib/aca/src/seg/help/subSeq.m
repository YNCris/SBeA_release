function Xs = subSeq(X, seg, c)
% Obtain the set of sub-sequences corresponding to the specific segmentation.
%
% Input
%   X       -  sequence, dim x n
%   seg     -  segmentation
%   c       -  class
%
% Output
%   Xs      -  set of sequences, 1 x mc (cell)
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 07-21-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

st = seg.st;
H = seg.H;

idx = find(H(c, :));
mc = length(idx);

Xs = cell(1, mc);
for ic = 1 : mc
    i = idx(ic);
    Xs{ic} = X(:, st(i) : st(i + 1) - 1);
end
