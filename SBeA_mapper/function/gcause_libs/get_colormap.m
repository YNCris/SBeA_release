function colormap = get_colormap(n, is_plot_colormap)

NUM_DEFAULT = 150;
multisensory_colors = [
         0         0    1.0000
         0    1.0000         0
    1.0000         0         0
    1.0000         0    1.0000];

is_color_set = false;
num_colors = NUM_DEFAULT;

if nargin >= 1
    if numel(n) == 1
        num_colors = n;
    elseif size(n,2) == 3
        colormap = n;
        is_color_set = true;
        num_colors = size(n,2);
    end
end

if ~is_color_set
    predefined_colors = distinguishable_colors(num_colors+1);
    predefined_colors = [
        multisensory_colors
        predefined_colors(6:end, :)];
    colormap = predefined_colors;
end

if nargin < 2
    is_plot_colormap = false;
end

if is_plot_colormap
    num_colors = size(colormap, 1);
    h_colormap = figure('Position', [20 20 300 1000], 'Visible', 'off'); % 
    size_unit = 20;
    hold on;
    for i = 1:num_colors
        colorone = colormap(i, :);
        plot_x = [3 3 7 7];
        upper_y = (num_colors-i+1) * size_unit;
        lower_y = (num_colors-i) * size_unit+size_unit/10;
        plot_y = [lower_y upper_y upper_y lower_y];
        fill(plot_x, plot_y, colorone, 'EdgeColor', 'k');
        text(mean(plot_x), mean(plot_y), sprintf('%d', i), 'HorizontalAlignment', 'center');
    end
    xlim([2 8]);
    ylim([0 (num_colors+1)*size_unit]);
    % set(gca, 'XTick',[]);
    % set(gca, 'YTick',[]);
    set(gca,'Visible','off');
    hold off;
    title_str = sprintf('colormap %d colormap', num_colors);
    text(mean(plot_x), -size_unit, title_str, 'HorizontalAlignment', 'center');
    set(h_colormap,'PaperPositionMode','auto');
    saveas(h_colormap, [title_str '.png']);
end

end