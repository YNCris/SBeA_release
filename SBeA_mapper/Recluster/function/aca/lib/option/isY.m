function flag = isY(c)
% Same to strcmpi(c, 'y').
%
% Input
%   c     -  character
%
% Output
%   flag  -  boolean flag
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-13-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

if strcmpi(c, 'y')
    flag = true;

elseif strcmpi(c, 'n')
    flag = false;

else
    error('unknown value');
end
