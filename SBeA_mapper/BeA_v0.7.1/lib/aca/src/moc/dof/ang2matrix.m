function rot = ang2matrix(ang, order)
% Convert euler angles into a rotation matrix.
%
% Input
%   ang     -  angle vector that contains x y z components (in degree)
%   order   -  the rotating order {'zyx'};
%
% Output
%   rot     -  rotation matrix, 3 x 3
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 03-17-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

% function option
if nargin == 1
    order = 'zyx';
end

ang = ang / 180 * pi;

c1 = cos(ang(1)); % The x angle
c2 = cos(ang(2)); % The y angle
c3 = cos(ang(3)); % the z angle
s1 = sin(ang(1));
s2 = sin(ang(2));
s3 = sin(ang(3));

rot = eye(3);
for i = 1 : length(order)
    if order(i) == 'x'
        tmp = [1   0   0; ...
               0  c1  s1; ...
               0 -s1  c1];
         
    elseif order(i) == 'y'
        tmp = [c2  0 -s2; ...
                0  1   0; ...
               s2  0  c2];
           
    elseif order(i) == 'z'
        tmp = [c3  s3  0; ...
              -s3  c3  0; ...
                0   0  1];
    else
        error('unknown order');
    end
    
    rot = tmp * rot;
end
