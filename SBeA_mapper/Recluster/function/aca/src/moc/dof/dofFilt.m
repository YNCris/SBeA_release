function [Dof, join] = dofFilt(Dof0, join0, paraF)
% Remove the DOFs related to unnecessary joints.
%
% Input
%   Dof0    -  original DOF matrix, dim x nF
%   join0   -  original joints
%   paraF  
%     filt  -  filtering method, see function filt2name
%
% Output
%   Dof     -  new Dof matrix, (nJ x 3) x nF
%   join    -  new joints
%     dim   -  number of value of each joint, 1 x nJ
%     name  -  name of each joint, 1 x nJ
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 12-29-2008
%   modify  -  Feng Zhou (zhfe99@gmail.com), 01-03-2010

prom('m', 'dof filt\n');

nF = size(Dof0, 2);

% original joints
name0 = join0.name;
dim0 = join0.dim;
nJ0 = length(dim0);
s = n2s(dim0);

% used joints
name = filt2name(paraF.filt);
nJ = length(name);
% if nJ == 0
%     name = name0;
% end

% index of used joints
idx = zeros(1, nJ);
for i = 1 : nJ
    for j = 1 : nJ0
        if strcmpi(name{i}, name0{j})
            idx(i) = j;
            break;
        end
    end
end

% filtering
Dof = zeros(nJ * 3, nF);
for i = 1 : nJ
    p = idx(i);
    d0 = dim0(p);
    Dof((i - 1) * 3 + 1 : (i - 1) * 3 + d0, :) = Dof0(s(p) : s(p) + d0 - 1, :);
end

join.name = name;
join.dim = ones(1, nJ) * 3;
