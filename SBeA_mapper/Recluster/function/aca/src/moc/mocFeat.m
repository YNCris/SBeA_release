function wsFeat = mocFeat(src, paraF, wsDof)
% Obtain the mocap features.
%
% Input
%   src       -  mocap source
%   paraF     -  feature parameter
%   wsDOF     -  DOF source
%
% Output
%   wsFeat
%     X       -  feature matrix by converting the DOF, dim x nF
%     Dof     -  DOF matrix of used joints, (nJ x 3) x nF 
%     join    -  used joint, 1 x nJ (cell)
%     featEx  -  feature explanation
%
% History
%   create    -  Feng Zhou (zhfe99@gmail.com), 02-13-2009
%   modify    -  Feng Zhou (zhfe99@gmail.com), 01-04-2010

prom('t', 'new moc feat: src %s\n', src.name);

Dof0 = wsDof.Dof;
join0 = wsDof.join;

% filter joints
[Dof, join] = dofFilt(Dof0, join0, paraF);

% dof -> feat
[X, featEx] = dof2feat(Dof, paraF);

wsFeat.X = X;
wsFeat.Dof = Dof;
wsFeat.join = join;
wsFeat.featEx = featEx;
