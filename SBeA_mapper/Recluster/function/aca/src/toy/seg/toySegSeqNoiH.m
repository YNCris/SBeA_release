function [X, XD, segH] = toySegSeqNoiH(X0, XD0, segH0, modH, noi)
% Insert random lower-level segs into the given sequence.
%
% Input
%   X0      -  original continuous frame matrix, 2 x n0
%   XD0     -  original discrete frame matrix, 1 x n0
%   segH0   -  original temporal segmentation result
%   modH    -  module, 1 x nH (struct)
%   noi     -  noise level
%
% Output
%   X       -  new continuous frame matrix, 2 x n
%   XD      -  new discrete frame matrix, 1 x n
%   segH    -  new temporal segmentation result
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-13-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-20-2009

nH = length(modH);
fk = length(modH(end - 1).units);
seg1 = segH0(1); seg2 = segH0(2);
m = length(seg1.s) - 1;

% init
X = []; XD = []; [ss, sHs, Gs] = cellss(1, nH);
for iH = 1 : nH
    ss{iH} = 1; sHs{iH} = 1;
end
blockP = 0;

% forward
for i = 1 : m
    % keep the old info
    head = seg1.s(i); tail = seg1.s(i + 1) - 1;
    X = [X, X0(:, head : tail)]; XD = [XD, XD0(:, head : tail)];
    
    % 1st level
    ss{1} = [ss{1} ss{1}(end) + tail - head + 1];
    sHs{1} = [sHs{1} sHs{1}(end) + tail - head + 1];
    Gs{1} = [Gs{1} seg1.G(:, i)];
    
    % 2nd level
    if i == seg2.sH(blockP + 1)
        ss{2} = [ss{2} ss{2}(end) + tail - head + 1];
        sHs{2} = [sHs{2} sHs{2}(end) + 1];
        Gs{2} = [Gs{2} seg2.G(:, blockP + 1)];
        blockP = blockP + 1;
        
    else
        ss{2}(end) = ss{2}(end) + tail - head + 1;
        sHs{2}(end) = sHs{2}(end) + 1;
    end
    
    % insert
    if rand(1) < noi
        c = float2block(rand(1), fk);
        unit = modH(1).units{c}; g = L2G(c, fk);
        
        x = genGausses(modH(1).mes(:, unit), modH(1).Vars(:, :, unit), 1);
        X = [X, x]; XD = [XD, unit];
        
        % 1st level
        ss{1} = [ss{1} ss{1}(end) + length(unit)];
        sHs{1} = [sHs{1} sHs{1}(end) + length(unit)];
        Gs{1} = [Gs{1} g];
        
        % 2nd level
        ss{2}(end) = ss{2}(end) + length(unit);
        sHs{2}(end) = sHs{2}(end) + 1;
    end
end

segH = newSeg('s', ss, 'sH', sHs, 'G', Gs);
