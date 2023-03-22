function plot_skeleton(data, k, symb, size, cmap, bodyPart_name, auto_zoom)

% plot skeleton
%
%
% History
%   create  -  Kang Huang  (kang.huang@siat.ac.cn), 03-02-2020

if nargin < 7
    auto_zoom = 0;
end

n_bodyParts = length(bodyPart_name);
for ib = 1:n_bodyParts
    plot(data(k, ib), data(k, n_bodyParts+ib), symb, 'MarkerSize', size, 'Color', cmap(ib, :))
    hold on
end
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
% legend(bodyPart_name, 'Location', 'bestoutside', 'Box', 'off')
% title('Mouse Skeleton', 'Color', 'white')
% title('Estimated Mouse Posture ', 'Color', 'k')