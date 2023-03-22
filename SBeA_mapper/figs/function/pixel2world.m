function XYZ = pixel2world(E, R, T, point)
xy1 = [point;ones(1,size(point,2))];
E_xy1 = E'\xy1;
E_xy1_T = E_xy1-T'*ones(1,size(E_xy1,2));
XYZ = (R'\E_xy1_T)*-1;

% plot3(XYZ(1,:),XYZ(2,:),XYZ(3,:),'o')