function addMes2log(includetime, newinfo, HBTMesBox, HBTlog, display, showWarnmsgbox, replaceline)
% add message to log or message box
%
% Input
%   includetime         - bool variable, whether to display the current time
%   newinfo             - string variable, message to add
%   HBTMesBox           - bool variable, whether to display message in HBTMesBox
%   HBTlog              - bool variable, whether to add massage to log
%   display             - bool variable, whether to display in Command Window
%   showmsgbox          - bool variable, warn massage show in massage box
%
% History
%   modified from ledalab (http://www.ledalab.de/)  -  Kang Huang  (kang.huang@siat.ac.cn), 03-02-2020
global HBT

if nargin < 7
    replaceline = 0;
end
if nargin < 6
    showWarnmsgbox = 0;
end
if nargin < 5
    display = 0;
end
if nargin < 4
    HBTlog = 1;
end
if nargin < 3
    HBTMesBox = 1;
end

if includetime
    newinfo = [datestr(now,13),': ',newinfo];
end

if HBTMesBox
    if replaceline
        HBT.GUI.Mes_BoxMes = [{newinfo}; HBT.GUI.Mes_BoxMes(2:end)];
    else
        HBT.GUI.Mes_BoxMes = [{newinfo}; HBT.GUI.Mes_BoxMes];
    end
    set(HBT.GUI.Mes_Box, 'String', HBT.GUI.Mes_BoxMes);
    %drawnow;
end

if HBTlog
    fid_ll = fopen(fullfile('./HBTlog.txt'), 'a');
    fprintf(fid_ll,'%s\r\n', newinfo);
    fclose(fid_ll);
end


if display
    disp(newinfo)
end

if showWarnmsgbox 
    msgbox(newinfo,'Info','warn')
end
