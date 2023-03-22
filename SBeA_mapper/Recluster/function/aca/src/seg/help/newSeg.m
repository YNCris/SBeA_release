function seg = newSeg(varargin)
% Create segmentation structure.
%
% Input
%   nH      -  #levels
%   or
%   varargin
%     s     -  starting position, {1}
%     sH    -  starting position in hierarchy, {1}
%     G     -  class indicator, {[]}
%     acc   -  accuracy, {[]}
%     tim   -  time cost, {[]}
%     obj   -  objective value, {[]}
%
% Output
%   seg     -  seg struct
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-05-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 01-12-2010

if nargin == 1
    nH = varargin{1};
%     [s, sH, G, acc, tim, obj, T, KC, umap, dimRed] = cellss(1, nH);
    [s, sH, G, acc, tim, obj, T] = cellss(1, nH);
  
else
    s = ps(varargin, 's', 1);
    sH = ps(varargin, 'sH', 1);
    G = ps(varargin, 'G', []);
    acc = ps(varargin, 'acc', []);
    tim = ps(varargin, 'tim', []);
    obj = ps(varargin, 'obj', []);
    T = ps(varargin, 'T', []);
    G = ps(varargin, 'T', []);
%     KC = ps(varargin, 'KC', []);
%     umap = ps(varargin, 'umap', []);
%     dimRed = ps(varargin, 'dimRed', []);
end

% seg = struct('s', s, 'sH', sH, 'G', G, 'acc', acc, 'tim', tim, 'obj', obj, 'T', T, 'KC', KC, 'umap', umap, 'dimRed', dimRed);
seg = struct('s', s, 'sH', sH, 'G', G, 'acc', acc, 'tim', tim, 'obj', obj, 'T', T);


