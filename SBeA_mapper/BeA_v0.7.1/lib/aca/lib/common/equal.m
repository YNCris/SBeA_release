function flag = equal(M1, M2, s)
% Testify whether the two matrices are equal.
%
% Input
%   M1      -  1st matrix
%   M2      -  2nd matrix
%   s       -  name of matrix
%
% Output
%   flag    -  boolean flag
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 08-03-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 01-12-2010

m1 = M1(:);
m2 = M2(:);

% check the length
if length(m1) ~= length(m2)
    fprintf('%s non equal (diff in length): %d %d\n', s, length(m1), length(m2));
    flag = 0;
    return;
end

% check the infinite value
vis1 = isinf(M1(:));
vis2 = isinf(M2(:));
if any(vis1 ~= vis2)
    disp('%s non equal (diff in inf)\n');
    flag = 0;
    return;
end
m1(vis1) = 0;
m2(vis2) = 0;

dM = abs(m1(:) - m2(:));
d = max(dM);

if d < 1e-6
    fprintf('%s equal\n', s);
    flag = 1;
else
    fprintf('%s non equal: diff %.6f\n', s, d);
    flag = 0;
end
