function XY = pixel2cam(E, point)
xy1 = [point;ones(1,size(point,2))];
E_xy1 = E'\xy1;
XY = E_xy1(1:2,:);