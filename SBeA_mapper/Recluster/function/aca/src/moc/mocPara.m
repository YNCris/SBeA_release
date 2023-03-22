function [paraF, paraP, para, paraH] = mocPara(src)
% Get parameter for moc (mocap or kitchen) data.
%
% Input
%   src     -  moc source
%
% Output
%   paraF   -  feature parameter    (used in mocFeat)
%   paraP   -  partition parameter  (used in mocPart)
%   para    -  ACA parameter        (used in mocSeg)
%   paraH   -  HACA parameter       (used in mocSeg)
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 04-22-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 01-03-2010

paraF = getMocParaF(src);
paraP = getMocParaP;

if nargout > 2
    [para, paraH] = getMocParaS(src);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function paraF = getMocParaF(src)
% Get feature parameter.
%
% Input 
%   source    -  moc source
%
% Output
%   paraF
%     filt    -  filtering method (used in dofFilt)
%     feat    -  feature name     (used in dof2feat)

dbe = src.dbe;
if strcmp(dbe, 'moc')
    paraF.filt = 'barbic';
    paraF.feat = 'log';

elseif strcmp(dbe, 'kit')
    paraF.filt = 'all2';
    paraF.feat = 'log';

else
    error(['unknown mocap type: ' dbe]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function paraP = getMocParaP
% Get partition parameter.
%
% Output
%   paraP
%     rang  -  range of used frames      
%     pick  -  type for keeping frames
%     algU  -  uniformly partition type
%     valU  -  uniformly partition value
%     algN  -  non-uniformly partition type
%     valN  -  non-uniformly partition value

paraP.rang = [];
paraP.pick = 'non';
paraP.algU = 'non';
paraF.valU = [];
paraP.algN = 'non';
paraF.valN = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [para, paraH] = getMocParaS(src)
% Get segmentation parameter for mocap data.
%
% Input
%   src     -  mocap source
%
% Output
%   para    -  ACA parameter
%   paraH   -  HACA parameter, 1 x 2 (struct)

Hs = cell(1, 3);

% 86
Hs{1} = struct( ...
  'kF',   {  20,  12,  20,  12,  20,  12,  20,  12,  20,  12,  20,  12,  20,  12,  20,  12,  20,  12,  20,  12,  15,  12,  20,  12,  20,  12,  20,  12}, ...
  'k',    {  12,   4,  12,   8,  12,   7,  12,   7,  12,   7,  12,  10,  12,   6,  12,   9,  12,   4,  12,   4,  12,   4,  12,   7,  12,   6,  12,   4}, ...
  'nMi',  {   8,   4,   8,   4,   8,   4,   8,   4,   8,   4,   8,   4,   8,   4,   8,   4,   8,   4,   8,   4,   7,   3,   8,   4,   8,   4,   8,   4}, ...
  'nMa',  {  10,   6,  10,   6,  10,   6,  10,   6,  10,   6,  10,   6,  10,   6,  10,   6,  10,   6,  10,   6,   9,   4,  10,   6,  10,   6,  10,   6}, ...
  'ini',  { 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p'}, ...
  'nIni', {   5,  10,   5,  10,   5,  10,   5,  10,   5,  10,   5,  10,   5,  10,   5,  10,   5,  10,   5,  10,   5,  10,   5,  10,   5,  10,   5,  10}, ...
  'redL', {   5,   1,   5,   1,   5,   1,   5,   1,   5,   1,   5,   1,   5,   1,   5,   1,   5,   1,   5,   1,   5,   1,   5,   1,   5,   1,   5,   1});
% #trial      1         2         3         4         5         6         7         8         9        10        11        12        13        14

dbe = src.dbe; pno = src.pno; trl = src.trl;
if strcmp(dbe, 'moc') && strcmp(pno, '86')
    paraH = Hs{1};

    iT = atoi(trl);
    paraH = paraH(iT * 2 - 1 : iT * 2);
    para = paraH2para(paraH);

else
    error('unknown database');
end
