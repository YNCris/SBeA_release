function seg = segPart(seg0, c)
% Extract the part of segmentation for the specific class
%
% Input
%   seg0    -  original segmentation
%   c       -  class
%
% Output
%   seg     -  new segmentation with only two classes, c or not c
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-20-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

H0 = seg0.H;
st0 = seg0.st;

[k0, m0] = size(H0);
h0 = H0(c, :);

st = zeros(1, m0 + 1);
H = zeros(2, m0);
m = 0; lastc = 1;
for i = 1 : m0
    if h0(i) == 1
        m = m + 1;
        H(1, m) = 1;
        st(m) = st0(i);
        lastc = 1;

    elseif h0(i) == 0 && lastc == 1
        m = m + 1;
        H(2, m) = 1;
        st(m) = st0(i);
        lastc = 0;

    end
end

st(m + 1) = st0(end);
st(m + 2 : end) = [];
H(:, m + 1 : end) = [];

seg.st = st;
seg.H = H;
