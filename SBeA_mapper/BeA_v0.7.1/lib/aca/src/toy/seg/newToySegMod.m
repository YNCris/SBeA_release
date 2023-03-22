function mod = newToySegMod(varargin)
% Create mod structure.
%
% Input
%   varargin
%     mes     -  {[]}
%     Vars    -  {[]}
%     units   -  {[]}
%     unitHs  -  {[]}
%
% Output
%   mod       -   mod struct
%
% History
%   create    -  Feng Zhou (zhfe99@gmail.com), 02-13-2009
%   modify    -  Feng Zhou (zhfe99@gmail.com), 01-14-2010

if nargin == 1
    nH = varargin{1};
    mes = [];
    Vars = [];
    [units, unitHs] = cellss(1, nH);

else
    mes = ps(varargin, 'mes', []);
    Vars = ps(varargin, 'Vars', []);
    units = ps(varargin, 'units', []); units = {units};
    unitHs = ps(varargin, 'unitHs', []); unitHs = {unitHs};
end

mod = struct('mes', mes, 'Vars', Vars, 'units', units, 'unitHs', unitHs);
