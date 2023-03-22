function [X, featEx] = dof2feat(DOF, paraF)
% Convert the DOF matrix into feature matrix.
%
% Input
%   DOF     -  DOF matrix, (nJ x 3) x nF
%   paraF
%     feat  -  feature name, {'log'} | 'vel' | 'ang'
%               'log'   -  logarithm map of quaternion, dim = 3
%               'vel'   -  angluar velocity, dim = 3
%               'ang'   -  Euler angle, dim = 3
%
% Output
%   X       -  feature matrix, (nJ x dim) x nF
%   featEx  -  detailed explanation of extracted feature
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 12-29-2008
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

prom('m', 'dof -> feat\n');

% function option
feat = ps(paraF, 'feat', 'log');

if strcmp(feat, 'log')
    X = logq(dof2q(DOF));
    featEx = 'logarithm map of quaternion';

elseif strcmp(feat, 'vel')
    Q = logq(dof2q(DOF));
    X = zeros(size(Q, 1), size(Q, 2) + 1);
    X(:, end - 1) = diff(Q, 1, 2);
    X(:, end) = X(:, end - 1);
    featEx = 'angluar velocity';

elseif strcmp(feat, 'ang')
    X = DOF;
    featEx = 'Euler angle';
    
else
    error('unknown feature type');
end
