function XD = knl2x(K, k, varargin)
% Obtain the discrete label for each frame.
%
% Input
%   K       -  similarity matrix, n x n
%   k       -  #class
%   varargin
%     save option
%
% Output
%   XD      -  sample matrix, 1 x n
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 12-29-2008
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-23-2009

% save option
[savL, path] = psSave(varargin, 'subx', 'dx');

% load
if savL == 2 && exist(path, 'file')
    XD = matFld(path, 'XD');
    return;
end

fprintf('similarity matrix -> time series\n');

G = cluSc(K, k);
XD = G2L(G);

if savL > 0
    save(path, 'XD');
end
