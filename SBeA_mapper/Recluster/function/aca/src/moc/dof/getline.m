function line = getline(fid)
% Get a line from a file, , but ignore it if it starts with a comment character.
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 12-29-2008
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

line = fgetl(fid);

while ~isempty(line) && line(1) == '#'
    line = fgetl(fid);
end
