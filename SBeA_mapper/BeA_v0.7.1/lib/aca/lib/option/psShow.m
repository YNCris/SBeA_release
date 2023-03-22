function h0 = psShow(option)
% Parse the common option for show* functions.
%
% Input
%   name    -  option name, 'fig' | 'ax' | 'cla' | 'h0'
%   value   -  option value
% 
% Output
%   h0      -  initial handle
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-21-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

% fig
fig = ps(option, 'fig', []);
if length(fig) == 1
    figure(fig); clf('reset');

elseif length(fig) == 4
    figure(fig(1));
    subplot(fig(2), fig(3), fig(4), 'replace');
end

% h0
h0 = ps(option, 'h0', []);
