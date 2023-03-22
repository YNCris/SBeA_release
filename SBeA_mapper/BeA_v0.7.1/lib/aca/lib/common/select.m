function value = select(flag, v1, v2)
% Implementation of : operation in c++.
%
% Input
%   flag    -  boolean flag
%   v1      -  the first value
%   v2      -  the second value
%
% Output
%   value   -  c++: value = flag ? v1 : v2
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-13-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

if flag
    value = v1;
else
    value = v2;
end
