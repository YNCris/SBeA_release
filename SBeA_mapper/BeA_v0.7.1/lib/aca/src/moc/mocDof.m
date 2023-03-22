function wsDof = mocDof(src)
% Load Degree of Freedom (Dof) of the specified mocap source.
%
% Input
%   src     -  mocap source
%
% Output
%   wsDof
%     Dof   -  Dof Matrix, dim x n
%     join  -  joints related to DOFs
%     skel  -  skel struct for animation
%     cord  -  cordinates for animation
%     conn  -  connection of joints
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 12-29-2008
%   modify  -  Feng Zhou (zhfe99@gmail.com), 01-04-2010

prom('t', 'new moc dof: src %s\n', src.name);

% data path
[amcpath, matpath] = mocPaths(src);

% test whether mat file is valid
isEx = exist(matpath, 'file');
if isEx
    tmpMat = load(matpath);
    isEx = isfield(tmpMat, 'Dof') && isfield(tmpMat, 'join') && isfield(tmpMat, 'skel') && isfield(tmpMat, 'cord') && isfield(tmpMat, 'conn');
end

% load the data from mat file or parse the amc file
if isEx
    [Dof, join, skel, cord, conn] = stFld(tmpMat, 'Dof', 'join', 'skel', 'cord', 'conn');

else
    [Dof, join] = amc2dof(amcpath);
    skel0 = asf2skel(src);
    [skel, channels] = dof2chan(Dof, join, skel0);
    [cord, conn] = chan2cord(skel, channels);

    save(matpath, 'Dof', 'join', 'skel', 'cord', 'conn');
end

% store
wsDof = struct('Dof', Dof, ...
               'join', join, ...
               'skel', skel, ...
               'cord', cord, ...
               'conn', conn);
