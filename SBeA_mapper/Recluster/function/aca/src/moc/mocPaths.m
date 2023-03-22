function [amcpath, matpath, asfpath, avipath, txtpath] = mocPaths(src)
% Obtain the file paths for the given mocap source (mainly used in mocDof).
%
% Input
%   src      -  mocap source
%
% Output
%   amcpath  -  the path of amc file
%   matpath  -  the path of mat file
%   asfpath  -  the path of asf file
%   avipath  -  the path of avi file
%   txtpath  -  the path of txt file
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 12-29-2008
%   modify   -  Feng Zhou (zhfe99@gmail.com), 11-23-2009

dbe = src.dbe;
pno = src.pno;
trl = src.trl;

global footpath; % specified in addPath.m

path = sprintf('%s/data/%s/%s/%s', footpath, dbe, pno, pno);
amcpath = [path '_' trl '.amc'];
matpath = [path '_' trl '.mat'];
asfpath = [path '.asf'];
avipath = [path '_' trl '.avi'];
txtpath = [path '_' trl '.txt'];

if exist(avipath, 'file') ~= 2
    avipath = [path '_' trl '.mpg'];
end
