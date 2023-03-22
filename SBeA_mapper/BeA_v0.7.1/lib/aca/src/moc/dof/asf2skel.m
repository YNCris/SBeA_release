function skel = asf2skel(src)
% Read the asf file, and parse it into the skel struct.
%
% Input
%   src     -  mocap source
%
% Output
%   skel    -  skel struct
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 12-29-2008
%   modify  -  Feng Zhou (zhfe99@gmail.com), 11-23-2009

fprintf('dof -> skel...');

% skel path
[amcpath, matpath, asfpath] = mocPaths(src);

boneCount = 0;
fid = fopen(asfpath, 'r');
lin = strtrim(getline(fid));

skel.length = 1.0; skel.mass = 1.0; skel.angle = 'deg'; skel.type = 'acclaim';
skel.documentation = ''; skel.name = asfpath;

while ~feof(fid)
    if lin(1) ~= ':'
        error('Unrecognised file format');
    end

    switch lin(2 : end)
    case 'name'
        lin = getline(fid);
        lin = strtrim(lin);
        skel.name = lin;
    case 'units'
        lin = getline(fid);
        lin = strtrim(lin);
        while lin(1) ~= ':'
            parts = tokenise(lin, ' ');
            switch parts{1}
            case 'mass'
                skel.mass = str2double(parts{2});
            case 'length'
                skel.length = str2double(parts{2});
            case 'angle'
                skel.angle = strtrim(parts{2});
            end
            lin = getline(fid);
            lin = strtrim(lin);
        end
    case 'documentation'
        skel.documentation = [];
        lin = getline(fid);
        while lin(1) ~=':'
            skel.documentation = [skel.documentation char(13) lin];
            lin = getline(fid);
        end
        lin = strtrim(lin);

    case 'root'
        skel.tree(1) = newTree(1);
        lin = getline(fid);
        lin = strtrim(lin);
        while lin(1) ~= ':'
            parts = tokenise(lin, ' ');
            switch parts{1}
            case 'order'
                order = [];
                for i = 2 : length(parts)            
                    switch lower(parts{i})
                    case 'rx'
                        chan = 'Xrotation';
                        order = [order 'x'];
                    case 'ry'
                        chan = 'Yrotation';
                        order = [order 'y'];
                    case 'rz'
                        chan = 'Zrotation';
                        order = [order 'z'];
                    case 'tx'
                        chan = 'Xposition';
                    case 'ty'
                        chan = 'Yposition';
                    case 'tz'
                        chan = 'Zposition';
                    case 'l'
                        chan = 'length';
                    end
                    skel.tree(boneCount + 1).channels{i - 1} = chan;
                end

                % order is reversed compared to bvh
                skel.tree(boneCount + 1).order = order(end : -1 : 1);

            case 'axis'
                % order is reversed compared to bvh
                skel.tree(1).axisOrder = lower(parts{2}(end : -1 : 1));

            case 'position'
                skel.tree(1).offset = [str2double(parts{2}) ...
                                       str2double(parts{3}) ...
                                       str2double(parts{4})];
            case 'orientation'
                skel.tree(1).orientation = [str2double(parts{2}) ...
                                            str2double(parts{3}) ...
                                            str2double(parts{4})];
            end
            lin = getline(fid);
            lin = strtrim(lin);
        end

    case 'bonedata'
        lin = getline(fid);
        lin = strtrim(lin);
        while lin(1) ~= ':'
            parts = tokenise(lin, ' ');
            switch parts{1}
            case 'begin'
                boneCount = boneCount + 1;
                skel.tree(boneCount + 1) = newTree(0);
                lin = getline(fid);
                lin = strtrim(lin);

            case 'id'
                skel.tree(boneCount+1).id = str2double(parts{2});
                lin = getline(fid);
                lin = strtrim(lin);
                skel.tree(boneCount+1).children = [];

            case 'name'
                skel.tree(boneCount + 1).name = parts{2};
                lin = getline(fid);
                lin = strtrim(lin);

            case 'direction'
                direction = [str2double(parts{2}) str2double(parts{3}) str2double(parts{4})];
                lin = getline(fid);
                lin = strtrim(lin);

            case 'length'
                lgth =  str2double(parts{2});
                lin = getline(fid);
                lin = strtrim(lin);

            case 'axis'
                skel.tree(boneCount+1).axis = [str2double(parts{2}) ...
                                               str2double(parts{3}) ...
                                               str2double(parts{4})];

                % order is reversed compared to bvh
                skel.tree(boneCount+1).axisOrder =  lower(parts{end}(end:-1:1));
                lin = getline(fid);
                lin = strtrim(lin);

            case 'dof'
                order = [];
                for i = 2 : length(parts)            
                    switch parts{i}
                    case 'rx'
                        chan = 'Xrotation';
                        order = [order 'x'];
                    case 'ry'
                        chan = 'Yrotation';
                        order = [order 'y'];
                    case 'rz'
                        chan = 'Zrotation';
                        order = [order 'z'];
                    case 'tx'
                        chan = 'Xposition';
                    case 'ty'
                        chan = 'Yposition';
                    case 'tz'
                        chan = 'Zposition';
                    case 'l'
                        chan = 'length';
                    end
                    skel.tree(boneCount + 1).channels{i - 1} = chan;
                end

                % order is reversed compared to bvh
                skel.tree(boneCount+1).order = order(end: -1: 1);
                
                lin = getline(fid);
                lin = strtrim(lin);
            case 'limits'
                limitsCount = 1;
                skel.tree(boneCount+1).limits(limitsCount, 1:2) = ...
                [str2double(parts{2}(2:end)) str2double(parts{3}(1:end-1))];

                lin = getline(fid);
                lin = strtrim(lin);
                while ~strcmp(lin, 'end')
                    parts = tokenise(lin, ' ');

                    limitsCount = limitsCount + 1;
                    skel.tree(boneCount+1).limits(limitsCount, 1:2) = ...
                    [str2double(parts{1}(2:end)) str2double(parts{2}(1:end-1))];
                    lin = getline(fid);
                    lin = strtrim(lin);
                end

            case 'end'
                skel.tree(boneCount + 1).offset = direction * lgth;
                lin = getline(fid);
                lin = strtrim(lin);
            end
        end

    case 'hierarchy'
        lin = getline(fid);
        lin = strtrim(lin);
        while ~strcmp(lin, 'end')
            parts = tokenise(lin, ' ');
            if ~strcmp(lin, 'begin')
                ind = strloc(parts{1}, skel.tree, 'name');
                for i = 2:length(parts)
                    skel.tree(ind).children = [skel.tree(ind).children ...
                            strloc(parts{i}, skel.tree, 'name');];
                end        
            end
            lin = getline(fid);
            lin = strtrim(lin);
        end
        if feof(fid)
            skel = finaliseStructure(skel);
            fprintf('\n');
            return;
        end

    otherwise
        if feof(fid)
            skel = finaliseStructure(skel);
            fprintf('\n');
            return;
        end
        lin = getline(fid);
        lin = strtrim(lin);
    end
end

fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function skel = finaliseStructure(skel)

% FINALISESTRUCTURE 
skel.tree = treeFindParents(skel.tree);
ordered = false;
while ordered == false
    for i = 1 : length(skel.tree)
        ordered = true;
        if skel.tree(i).parent > i
            ordered = false;
            skel.tree = swapNode(skel.tree, i, skel.tree(i).parent);
        end
    end
end

for i = 1 : length(skel.tree)
    option.order = skel.tree(i).axisOrder;
    skel.tree(i).C = ang2matrix(skel.tree(i).axis, option.order);
    skel.tree(i).Cinv = inv(skel.tree(i).C);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tree = newTree(isRoot)

if isRoot
    name = 'root';
    id = 0;
    parent = 0;
else
    name = [];
    id = [];
    parent = [];
end

tree = struct('name', name, ...
              'id', id, ...
              'offset', [], ...
              'orientation', [], ...
              'axis', [0 0 0], ...
              'axisOrder', [], ...
              'C', eye(3), ...
              'Cinv', eye(3), ...
              'channels', [], ...
              'bodymass', [], ...
              'confmass', [], ...
              'parent', parent, ...
              'order', [], ...
              'rotInd', [], ...
              'posInd', [], ...
              'children', [], ...
              'limits', []);
          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [chans, order] = newChan(parts)

n = length(parts);
chans = cell(1, n - 1);
order = zeros(1, n - 1);

for i = 2 : n
    switch parts{i}
    case 'rx'
        chans{i - 1} = 'Xrotation';
        order(i - 1) = 'x';
    case 'ry'
        chans{i - 1} = 'Yrotation';
        order(i - 1) = 'y';
    case 'rz'
        chans{i - 1} = 'Zrotation';
        order(i - 1) = 'z';
    case 'tx'
        chans{i - 1} = 'Xposition';
    case 'ty'
        chans{i - 1} = 'Yposition';
    case 'tz'
        chans{i - 1} = 'Zposition';
    case 'l'
        chans{i - 1} = 'length';
    end
end

% remove empty order
order(order == '') = [];

% order is reversed compared to bvh
skel.tree(boneCount+1).order = order(end: -1: 1);
