function wsPart = mocPart(src, paraP, wsFeat, varargin)
% Obtain the part of mocap data.
%
% Input
%   src     -  mocap source
%   paraP   -  partition parameter
%     rang  -  range of used frames, {[]}
%     pick  -  type for picking frames, {'non'} | 'ave' | 'med'
%              'non': just keep the first frame of the part
%              'ave': averaging the frames in the part
%              'med': select the mediean frame in the part
%     algU  -  uniformly partition type, {'non'} | 'rate' | 'gap'
%              'non':  no partition
%              'rate': rate of used part / all
%              'gap':  number of frames between two parts
%     valU  -  uniformly partition value
%     algN  -  non-uniformly partition type
%     valN  -  non-uniformly partition value
%   wsFeat  -  mocap feature
%     X     -  old feature, dim x nF0
%   varargin
%     save option
%
% Output
%   wsPart
%     X     -  new feature matrix, dim x nF
%     pF    -  position of used frames, 1 x nF
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-13-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 01-04-2010

% save option
[savL, path] = psSave(varargin, 'prex', src.name, ...
                                'subx', 'part', ...
                                'fold', 'moc/part');

% load
if savL == 2 && exist(path, 'file')
    prom('t', 'old moc part: src %s\n', src, name);
    wsPart = matFld(path, 'wsPart');
    return;
end
prom('t', 'new moc part: src %s\n', src, name);

% function option
rang = ps(paraP, 'rang', []);
pick = ps(paraP, 'pick', 'non');
algU = ps(paraP, 'algU', 'non');
valU = ps(paraP, 'valU', []);

% range
X = wsFeat.X;
pFR = mocPartR(size(X, 2), rang);
X = X(:, pFR);

% uniformly partition
[X, pFU] = mocPartU(X, algU, valU, pick);

pF = pFR(pFU);
wsPart.X = X;
wsPart.pF = pF;

if savL > 0
    save(path, 'wsPart');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pF = mocPartR(nF0, rang)
% Range partition.
%
% Input
%   nF0     -  original feature number
%   rang    -  range of sequence, 1 x 2
%
% Ouput
%   pF      -  position of used frames, 1 x nF

if ~isempty(rang)
    head = max(1, rang(1));
    tail = min(nF0, rang(2));
    pF = head : tail;

else
    pF = 1 : nF0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [X, pF] = mocPartU(X0, algU, valU, pick)
% Uniformly partition.
%
% Input
%   X0      -  original feature matrix, dim x nF0
%   algU    -  algorithm type
%   valU    -  algorithm value
%   pick    -  pick algorithm
%
% Ouput
%     X     -  new feature matrix, dim x nF
%     pF    -  new frame index, 1 x nF

nF0 = size(X0, 2);

if strcmp(algU, 'non')
    X = X0;
    pF = 1 : nF0;

elseif strcmp(algU, 'rate')
    gap = round(nF0 * valU);
    pF = 1 : gap : nF0;
    X = X0(:, pF);

elseif strcmp(algU, 'gap')
    gap = valU;
    pF = 1 : gap : nF0;
    X = X0(:, pF);    
    
else
    error('unknown type');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [X, pF] = mocPartN(X0, pF0, algU, valU, pick)
% Uniformly partition.
%
% Input
%   X0      -  original feature matrix, dim x nF0
%   pF0     -  original frame index, 1 x nF0
%   algU    -  algorithm type
%   valU    -  algorithm value
%   pick    -  pick algorithm
%
% Ouput
%     X     -  new feature matrix, dim x nF
%     pF    -  new frame index, 1 x nF
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 04-22-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 01-04-2010

% temporal reduction
isR = psY(paraF, 'reduce', 'n');
if isR
    X = X(:, posF);
    
    % temporal reduction
    [X, stR, DX] = tempoReduce(X, paraF);
    X = stPick(X, stR);
    
    wsPart.DX = DX;
    wsPart.stR = stR;
    wsPart.X = X;
end
