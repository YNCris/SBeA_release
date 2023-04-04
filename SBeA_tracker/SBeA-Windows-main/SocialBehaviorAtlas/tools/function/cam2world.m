function XYZ = cam2world(R, T, campos)
XYZ = R'\(campos-T'*ones(1,size(campos,2)));
% XYZ = XYZ*(-1);
% XYZ(2:3,:) = XYZ(2:3,:)*(-1);
