function modH = toySegModH(paraMH, varargin)
% Generate hierachical models for k temporal sequences.
%
% Input
%   paraMH   -  segmentation parameter, 1 x nH (struct array)
%     kF     -  #classes of frames or number of classes of units (segments) in the last level
%     k      -  #classes of segments in the current level
%     nMi    -  min segment length in the current level respect to the last units
%     nMa    -  max segment length in the current level respect to the last units
%   varargin
%     rep    -  repetition flag in one segment, {'y'} | 'n'
%
% Output
%   modH     -  temporal model, 1 x nH cell array
%     unit   -  component for each unit respect to frames
%     unitH  -  component for each unit respect to last level
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 02-13-2009
%   modify   -  Feng Zhou (zhfe99@gmail.com), 12-20-2009

% function option
isRep = psY(varargin, 'rep', 'y');

nH = length(paraMH);
modH = newToySegMod(nH);

% bottom level
modH(1) = toySegMod(paraMH(1));
unit0s = modH(1).units;

for iH = 2 : nH
    [kF, k, nMi, nMa] = stFld(paraMH(iH), 'kF', 'k', 'nMi', 'nMa');
    [units, unitHs] = cellss(1, k);
    for c = 1 : k
        len = float2block(rand(1), nMi, nMa);
        units{c} = [];

        unitHs{c} = float2block(rand(1, len), kF);
        f = unitRep(unitHs{c});
        
        while ~isRep && f
            unitHs{c} = float2block(rand(1, len), kF);
            f = unitRep(unitHs{c});
        end
        
        for j = 1 : len
            c0 = unitHs{c}(j);
            units{c} = [units{c} unit0s{c0}];
        end
    end
    
    unit0s = units;
    modH(iH) = modH(1);
    modH(iH).units = units;
    modH(iH).unitHs = unitHs;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = unitRep(units)
% Test whether the units has the repetitive components.

n = length(units);
f = 0;
for i = 1 : n
    for j = i + 1 : n
        if units(i) == units(j)
            f = 1;
            return;
        end
    end
end
