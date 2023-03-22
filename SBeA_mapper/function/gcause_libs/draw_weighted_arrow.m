function draw_weighted_arrow(arrow_start, arrow_end, weight, text_loc, weight_sig)

color_max = 20;
color_pos = get_gradient_colors('red', color_max);
color_neg = get_gradient_colors('blue', color_max);

color_index = min(ceil(abs(weight))+1, color_max);
if weight > 0
    arrow_color = color_pos(color_index, :);
else
    arrow_color = color_neg(color_index, :);
end

if weight_sig > 0
    text_color = [1 0 0];
elseif weight_sig < 0
    text_color = [0 0 1];
else
    text_color = [0.8 0.8 0.8];
    arrow_color = [0.8 0.8 0.8];
end

arrow('Start', arrow_start, 'Stop', arrow_end, 'Length', 20, ...
    'Width', 3, 'Ends', 'stop', 'TipAngle', 30, 'BaseAngle', 60, 'Color', arrow_color);
text(text_loc(1), text_loc(2), sprintf('%.2f', weight), 'Color', text_color, ...
    'FontSize', 14, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');