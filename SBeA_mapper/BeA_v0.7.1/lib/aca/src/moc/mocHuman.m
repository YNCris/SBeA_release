function MOC = mocHuman
% Load human label file for segmentation.
% Obtain the list of all the motion capture file.
%
% Output
%   MOC  
%     name  
%       seg
%       cnames
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 12-29-2008
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-23-2009

% path
global footpath; % specified in addPath.m
matpath = [footpath '/data/moc/moc.mat'];
txtpath = [footpath '/data/moc/mocap.txt'];

% if mat existed, just load
if exist(matpath, 'file')
    MOC = matFld(matpath, 'MOC');
    return;
end
fprintf('parsing file %s...\n', txtpath);

MOC = getAllNames;

% open text file
fid = fopen(txtpath, 'rt');

% line-by-line
while ~feof(fid)
    line = fgetl(fid);
    parts = tokenise(line, ' ');

    % skip empty line
    if isempty(parts), continue; end

    % parse one mocap
    if length(parts) == 2
        pno = parts{1};
        trl = parts{2};
        name = ['moc_' pno '_' trl];

        [seg, cnames] = mocapOne(fid);
        MOC.(name).seg = seg;
        MOC.(name).cnames = cnames;

    else
        error('grammar error');
    end
end

save(matpath, 'MOC');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [seg, cnames] = mocapOne(fid)
% Parse one mocap's label.
%
% Input
%   fid     -  file handler
%
% Output
%   seg     -  segmentation parameter
%   cnames  -  class names, 1 x k (cell)
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 12-29-2008
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-23-2009

% initialize
maxk = 20; maxm = 100;
k = 0; m = 0;
cnames = cell(1, maxk);
L = zeros(1, maxm);
s = ones(1, maxm + 1);

while ~feof(fid)
    line = fgetl(fid);
    parts = tokenise(line, ' ');

    % finish one mocap
    if isempty(parts), break; end
    
    m = m + 1;
    
    % label
    cname = parts{1};
    c = strloc(cname, cnames);
    if c == 0 % new class?
        k = k + 1;
        cnames{k} = cname;
        c = k;
    end
    L(m) = c;
    
    % boundary
    p2 = floor(str2double(parts{3}));
    s(m + 1) = p2 + 1;
end

% remove no-used fields
cnames(k + 1 : end) = [];
s(m + 2 : end) = [];
L(m + 1 : end) = [];

seg = newSeg('s', s, 'G', L2G(L, k));

%%%%%%%%%%%%%%%%%%%%%%%%%%
function MOC = getAllNames
% Obtain all names under the folder data/mocap and data/kitchen
%
% Output
%   MOC  
%     name  
%       seg
%       cnames
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 04-08-2008
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-23-2009

% path
global footpath; % specified in addPath.m

foldpath = sprintf('%s/data/moc', footpath);

% person numbers
pnos = dir(foldpath);
for i = 1 : length(pnos)
    pno = pnos(i).name;
    pos = regexp(pno, '^\d', 'once');
    if ~isempty(pos)
        pnopath = sprintf('%s/%s', foldpath, pno);

        % motion trials
        trials = dir(pnopath);
        for j = 1 : length(trials)
            trial = trials(j).name;
            trialL = lower(trial);
            pos = regexp(trialL, '^[\w\d_]+\.amc$', 'once');
            if ~isempty(pos)
                name = sprintf('moc_%s', trialL(1 : end - 4));
                MOC.(name).seg = [];
                MOC.(name).cnames = [];
            end
        end
    end
end
