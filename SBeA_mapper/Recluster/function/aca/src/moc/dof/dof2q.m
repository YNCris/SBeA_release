function Q = dof2q(DOF)
% Convert degree of freedom (DOF) into quaternion.
%
% Input
%   DOF     -  DOF matrix, (k x 3) x n
%
% Output
%   Q       -  quaternion matrix, (k x 4) x n
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 12-29-2008
%   modify  -  Feng Zhou (zhfe99@gmail.com), 11-23-2009

[k, n] = size(DOF);
k = round(k / 3);

% rotation matrix
R = zeros(3, 3, n, k);
for c = 1 : k
    for i = 1 : n
        dof = DOF((c - 1) * 3 + 1 : c * 3, i);
        R(:, :, i, c) = ang2matrix(dof);
    end
end

% quaternion
Q = zeros(k * 4, n);
for c = 1 : k
    Q((c - 1) * 4 + 1 : c * 4, :) = dcm2q(R(:, :, :, c))';
end
