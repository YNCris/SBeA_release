function ind = strloc(str, arr, field)
% Locate the position of the first same string in a string cell array or a struct array.
% with the known field name.
%
% Input
%   str     -  string need to be located, single string | string cell array
%   arr     -  string cell array or struct array that will be searched
%   field   -  field name. If indicated, arr is a struct array.
%
% Output
%   ind     -  position, 0 if not found
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-13-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

% string must be a cell array
if ~iscell(str)
    str = {str};
end

nS = length(str);
nA = length(arr);
ind = zeros(1, nS);

for i = 1 : nS
    for j = 1 : nA
        if exist('field', 'var')
            % arr is a struct array
            tmp = arr(j).(field);
        else
            % arr is a string cell array
            tmp = arr{j};
        end
        
        if strcmp(str{i}, tmp)
            ind(i) = j;
            break;
        end
    end
end
