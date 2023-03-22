function plot_skeleton_figfun(data, k, symb, sizee, cmap, bodyPart_name, auto_zoom,handles)

% plot skeleton
%
%
% History
%   create  -  Kang Huang  (kang.huang@siat.ac.cn), 03-02-2020

if nargin < 7
    auto_zoom = 0;
end
axes(handles.axes2)
n_bodyParts = length(bodyPart_name);
scatter(data(k, 1:n_bodyParts), data(k, n_bodyParts+(1:n_bodyParts)), sizee,cmap(1:n_bodyParts, :),'filled')
hold off
x_max = max(data(k, 1:end/2))+10;
x_min = min(data(k, 1:end/2))-10;
y_max = max(data(k, 1+(end/2):end))+10;
y_min = min(data(k, 1+(end/2):end))-10;
x_cent = (x_max + x_min)/2;
y_cent = (y_max + y_min)/2;
x_Wid = x_max - x_min;
y_Wid = y_max - y_min;
if x_Wid > y_Wid
    y_min = y_cent - x_Wid/2;
    y_max = y_cent + x_Wid/2;
else
    x_min = x_cent - y_Wid/2;
    x_max = x_cent + y_Wid/2;
end

if auto_zoom
    axis([x_min, x_max, y_min, y_max])
    axis square
else
    axis equal
end

set(gca,'xtick',-inf:inf:inf, 'FontSize', 15);
set(gca,'ytick',-inf:inf:inf);