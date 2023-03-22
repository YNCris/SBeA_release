function wsStat = statSeg(wsSegs, varargin)
% Parse the accuracy and running time of each method.
%
% Input
%   wsSegs    -  segmentation container, m x n (cell)
%   varargin
%     prompt  -  prompting flag, {'y'} | 'n'
%
% Output
%   wsStat
%     acc     -  accuracy of ACA
%     accH    -  accuracy of HACA
%     accS    -  accuracy of GMM
%     ti      -  time cost of ACA
%     ti1     -  time cost of HACA, 1st level
%     ti2     -  time cost of HACA, 2nd level
%
% History
%   create    -  Feng Zhou (zhfe99@gmail.com), 01-03-2009
%   modify    -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

% parameter
isP = psY(varargin, 'prompt', 'y');

[m, n] = size(wsSegs);
nSeg = m * n;

% ACA
if isfield(wsSegs{1}, 'acc')
    accs = cellFields(wsSegs, 'acc', 'type', 'double');
    acc = sum(accs(:)) / nSeg * 100;
    
    tis = cellFields(wsSegs, 'ti', 'type', 'double');
    ti = sum(tis(:)) / nSeg;
    
    if isP
        tmpS = sprintfs(floor(accs * 100), 'type', '%4d');
        fprintf('ACA:%s%4d(ave) ti %4d seconds\n', tmpS, floor(acc), floor(ti));
    end
else
    acc = 0;
    ti = 0;
end
wsStat.acc = acc; wsStat.ti = ti;

% HACA
if isfield(wsSegs{1}, 'accH')
    accHs = cellFields(wsSegs, 'accH', 'type', 'double');
    accH = sum(accHs(:)) / nSeg * 100;
    
    ti1s = cellFields(wsSegs, 'ti1', 'type', 'double');
    ti2s = cellFields(wsSegs, 'ti2', 'type', 'double');
    ti1 = sum(ti1s(:)) / nSeg;
    ti2 = sum(ti2s(:)) / nSeg;
    
    if isP
        tmpS = sprintfs(floor(accHs * 100), 'type', '%4d');
        fprintf('HACA:%s%4d(ave) ti1 %4d ti2 %4d seconds\n', tmpS, floor(accH), floor(ti1), floor(ti2));
    end
else
    accH = 0;
    ti1 = 0; ti2 = 0;
end
wsStat.accH = accH; wsStat.ti1 = ti1; wsStat.ti2 = ti2;

% GMM
if isfield(wsSegs{1}, 'accS')
    accSs = cellFields(wsSegs, 'accS', 'type', 'double');
    accS = sum(accSs(:)) / nSeg * 100;
    
    if isP
        tmpS = sprintfs(floor(accSs * 100), 'type', '%4d');
        fprintf('GMM:%s%4d(ave)\n', tmpS, floor(accS));
    end
else
    accS = 0;
end
wsStat.accS = accS;
