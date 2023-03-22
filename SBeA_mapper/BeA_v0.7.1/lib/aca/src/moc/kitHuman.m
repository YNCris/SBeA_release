function KIT = kitHuman
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
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

% path
global footpath; % specified in addPath.m
matpath = [footpath '/data/kit/kit.mat'];

% if mat existed, just load
if exist(matpath, 'file')
    KIT = matFld(matpath, 'KIT');
    return;
end

KIT = getAllNames;

save(matpath, 'KIT');

%%%%%%%%%%%%%%%%%%%%%%%%%%
function KIT = getAllNames
% Obtain all names under the folder data/kit
%
% Output
%   MOC  
%     name  
%       seg
%       cnames
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 04-08-2008
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

% path
global footpath; % specified in addPath.m

foldpath = sprintf('%s/data/kit', footpath);

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
                name = sprintf('kit_%s', trialL(1 : end - 4));
                KIT.(name).seg = [];
                KIT.(name).cnames = [];
            end
        end
    end
end
