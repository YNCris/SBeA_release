function xyz = chan2xyz(skel, chan, ang)
% Compute XYZ values given skeleton structure and channels.

% Root Rotation
rotVal = skel.tree(1).orientation;
for i = 1 : length(skel.tree(1).rotInd)
    rind = skel.tree(1).rotInd(i);
    if rind
        rotVal(i) = rotVal(i) + chan(rind);
    end
end

% root rotation
xyzStruct(1).rot = ang2matrix(rotVal, skel.tree(1).axisOrder);

% extra rotation
extRot = ang2matrix([0, ang, 0]);
xyzStruct(1).rot = xyzStruct(1).rot * extRot;

% root offset
xyzStruct(1).xyz = skel.tree(1).offset;
for i = 1 : length(skel.tree(1).posInd)
    pind = skel.tree(1).posInd(i);
    if pind
        xyzStruct(1).xyz(i) = xyzStruct(1).xyz(i) + chan(pind);
    end
end

for i = 1:length(skel.tree(1).children)
    ind = skel.tree(1).children(i);
    xyzStruct = getChildXyz(skel, xyzStruct, ind, chan);
end
xyz = reshape([xyzStruct(:).xyz], 3, length(skel.tree))';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xyzStruct = getChildXyz(skel, xyzStruct, ind, channels)
% GETCHILDXYZ

parent = skel.tree(ind).parent;
children = skel.tree(ind).children;
rotVal = zeros(1, 3);
for j = 1:length(skel.tree(ind).rotInd)
  rind = skel.tree(ind).rotInd(j);
  if rind
    rotVal(j) = channels(rind);
  else
    rotVal(j) = 0;
  end
end

option.order = skel.tree(ind).order;
tdof = ang2matrix(rotVal, option.order);

option.order = skel.tree(ind).axisOrder;
torient = ang2matrix(skel.tree(ind).axis, option.order);

option.order = skel.tree(ind).axisOrder(end:-1:1);
torientInv = ang2matrix(-skel.tree(ind).axis, option.order);

xyzStruct(ind).rot = torientInv * tdof * torient * xyzStruct(parent).rot;
xyzStruct(ind).xyz = xyzStruct(parent).xyz + (skel.tree(ind).offset * xyzStruct(ind).rot);

for i = 1:length(children)
  cind = children(i);
  xyzStruct = getChildXyz(skel, xyzStruct, cind, channels);
end
