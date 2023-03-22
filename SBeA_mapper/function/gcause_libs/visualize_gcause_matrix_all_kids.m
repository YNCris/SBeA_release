function visualize_gcause_matrix_all_kids(gcause_mat, var_module_list, save_name)

color_max = 40;
color_pos = get_colormap('red', color_max);
color_neg = get_colormap('blue', color_max);
num_vars = length(var_module_list);

plot_xlim = [0 num_vars];
plot_ylim = [0 num_vars];
h = figure();
hold on;
% plot row by row
for rowidx = 1:num_vars
    plot_y_one = num_vars - rowidx;
    block_y = [plot_y_one plot_y_one+1 plot_y_one+1 plot_y_one];
    text_y = mean(block_y);
    % row var text
    text(-0.05, text_y, ['\rightarrow' var_module_list{rowidx}], 'HorizontalAlignment', 'right');
    
    for colidx = 1:num_vars
        block_x = [colidx-1 colidx-1 colidx colidx];

        gcause_one = gcause_mat(rowidx, colidx);
        color_index = min(round(abs(gcause_one))+1, color_max);
        if gcause_one > 0
            block_color = color_pos(color_index, :);
        else
            block_color = color_neg(color_index, :);
        end
        fill(block_x, block_y, block_color, 'EdgeColor', 'k');
        text_x = mean(block_x);
        text(text_x, text_y, sprintf('%.2f', gcause_one), 'HorizontalAlignment', 'center');
        
        if rowidx < 2
            % column var text
            text(text_x, (num_vars+0.1), ['\leftarrow' var_module_list{colidx}], 'HorizontalAlignment', 'center');
        end
    end
end
hold off;
xlim(plot_xlim);
ylim(plot_ylim);
set(gca,'xticklabel',{[]});
set(gca,'yticklabel',{[]});

if nargin > 2
    saveas(h, save_name);
    close(h);
end