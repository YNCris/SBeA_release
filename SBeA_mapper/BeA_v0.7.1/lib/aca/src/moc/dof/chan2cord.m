function [cord, conn, angys] = chan2cord(skel, chan, angV, angP)
% Parse the skeleton and joints to determine the coordinates of each joint and the bones that attach them.
%
% Input
%   skel    -  skeleton components
%   chan    -  joint components, nF x nC
%   angV    -  the angles (optional), 1 x nF
%   angP    -  the angles (optional), 1 x nF
%
% Output
%   cord    -  3-D coordinates of each joints, nF x nJ x 3
%   conn    -  the two joints which is joined by the bone, nB x 2
%   angys   -  1 x nF
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 12-29-2008
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-17-2009

fprintf('dof -> cord...');

nF = size(chan, 1);
nJ = length(skel.tree);
cord = zeros(nF, nJ, 3);

% y angles of root
angys = zeros(1, nF);
for i = 1 : nF
    angys(i) = rootAngY(skel, chan(i, :));
end

for i = 1 : nF
    ang = 0;
    if nargin > 2
        ang = -angys(i) + angys(angP(i)) - angV(i);
    end
    
    cord(i, :, :) = chan2xyz(skel, chan(i, :), ang);
end

% connection matrix
connect = zeros(nJ);
for i = 1 : nJ
    for j = 1 : length(skel.tree(i).children)    
        connect(i, skel.tree(i).children(j)) = 1;
    end
end

indices = find(connect);
nB = size(indices, 1);
conn = zeros(nB, 2);
[conn(:, 1), conn(:, 2)] = ind2sub(size(connect), indices);

fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function angy = rootAngY(skel, chan)
% Parse the angles of root
%
% Input
%   skel  -  skeleton components
%   chan  -  joint components
%
% Output
%   angy  -  root angle

rotVal = skel.tree(1).orientation;
for i = 1 : length(skel.tree(1).rotInd)
    rind = skel.tree(1).rotInd(i);
    if rind
        rotVal(i) = rotVal(i) + chan(rind);
    end
end

% root rotation
xyzStruct(1).rot = ang2matrix(rotVal, skel.tree(1).axisOrder);

% original rotation
ang0 = SpinCalc('DCMtoEA132', xyzStruct(1).rot, eps, 0);
if ang0 > 180
    ang0 = 360 - ang0;
end
angy = ang0(end);
