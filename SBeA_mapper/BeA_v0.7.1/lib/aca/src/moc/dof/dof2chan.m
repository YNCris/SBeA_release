function [skel, chan] = dof2chan(DOF, joint, skel)
% Parse the structure of DOFs.
%
% Input
%   DOF     -  d x n matrix
%   joint   -  joint
%   skel    -  original skeleton
%
% Output
%   skel    -  new skeleton
%   chan    -  channels
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 04-26-2008
%   modify  -  Feng Zhou (zhfe99@gmail.com), 11-23-2009

fprintf('dof -> chan...');

name = joint.name; nJ = length(name); dim = joint.dim;
loc = zeros(1, nJ); loc(1) = 1;
for i = 2 : nJ
    loc(i) = loc(i - 1) + dim(i - 1);
end

n = size(DOF, 2);

for j = 1 : nJ
    ind = strloc(name{j}, skel.tree, 'name');

    for i = 1 : n
        for k = 1 : dim(j)
            bone{ind}{i}(k) = DOF(loc(j) + k - 1, i);
        end
    end
end

numFrames = n;
numChannels = 0;
for i = 1 : length(skel.tree)
    numChannels = numChannels + length(skel.tree(i).channels);
end
chan = zeros(numFrames, numChannels);

endVal = 0;
for i = 1 : length(skel.tree)
    if ~isempty(skel.tree(i).channels)
        startVal = endVal + 1;
        endVal = endVal + length(skel.tree(i).channels);
        chan(:, startVal:endVal)= reshape([bone{i}{:}], ...
                                          length(skel.tree(i).channels), numFrames)';
    end
    [skel.tree(i).rotInd, skel.tree(i).posInd] = ...
        resolveIndices(skel.tree(i).channels, startVal);
end

chan = smoothAngleChannels(chan, skel);

fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rotInd, posInd] = resolveIndices(channels, startVal)
% Get indices from the channels.

baseChannel = startVal - 1;
rotInd = zeros(1, 3);
posInd = zeros(1, 3);
for i = 1:length(channels)
    switch channels{i}
    case 'Xrotation'
        rotInd(1, 1) = baseChannel + i;
    case 'Yrotation'
        rotInd(1, 2) = baseChannel + i;
    case 'Zrotation'
        rotInd(1, 3) = baseChannel + i;
    case 'Xposition'
        posInd(1, 1) = baseChannel + i;
    case 'Yposition'
        posInd(1, 2) = baseChannel + i;
    case 'Zposition'
        posInd(1, 3) = baseChannel + i;
    end        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function channels = smoothAngleChannels(channels, skel)
% Try and remove artificial discontinuities associated with angles.

for i = 1 : length(skel.tree)
    for j = 1 : length(skel.tree(i).rotInd)    
        col = skel.tree(i).rotInd(j);
        if col
            for k = 2 : size(channels, 1)
                diff = channels(k, col) - channels(k - 1, col);
                if abs(diff + 360) < abs(diff)
                    channels(k : end, col) = channels(k : end, col) + 360;
                elseif abs(diff - 360) < abs(diff)
                    channels(k : end, col) = channels(k : end, col) - 360;
                end        
            end
        end
    end
end
