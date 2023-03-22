function [heading, attitude, bank] = matrix2ang(rot, varargin)
% Convert euler angles into a rotation matrix.
% Input
%   ange      -  angle vector that contains x y z components
%   varargin
%     unit    -  {'deg'} | 'rad'
%                'deg' - degree, 'rad' - radian
%     order   -  rotating order {'zyx'};
% Output
%   rot       -  rotation matrix

m.m00 = rot(1, 1); m.m01 = rot(1, 2); m.m02 = rot(1, 3);
m.m10 = rot(2, 1); m.m11 = rot(2, 2); m.m12 = rot(2, 3);
m.m20 = rot(3, 1); m.m21 = rot(3, 2); m.m22 = rot(3, 3);

if m.m10 > 0.998  % singularity at north pole
    heading = atan2(m.m02, m.m22);
    attitude = pi / 2;
    bank = 0;
    return;
end

if m.m10 < -0.998 % singularity at south pole
    heading = atan2(m.m02, m.m22);
    attitude = -pi / 2;
    bank = 0;
    return;
end

heading = atan2(-m.m20, m.m00);
bank = atan2(-m.m12, m.m11);
attitude = asin(m.m10);


