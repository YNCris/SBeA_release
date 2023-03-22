function link_matrix = visualize_gcause_matrix_group_development(gcause_mat_groups, gcause_sig_groups, gcause_str_list, kid_list, save_name)

color_emerge = [...
    1	0	0; ...
    1 1 1; ...
    1 1 1];
color_dissolve = [0 0 1];
color_nochange = [1 1 1];

num_kids = size(gcause_mat_groups, 1);
num_gcause = size(gcause_mat_groups, 2);
num_exp = size(gcause_mat_groups, 3);

plot_xlim = [0 num_gcause];
plot_ylim = [0 num_kids];
h = figure('Position', [50 50 1200 1000]);
hold on;
% plot row by row
gcause_mat_prev = gcause_mat_groups(:, :, 1);
gcause_mat_dev = gcause_mat_groups(:, :, 2);
gcause_sig_prev = gcause_sig_groups(:, :, 1);
gcause_sig_dev = gcause_sig_groups(:, :, 2);

link_matrix = zeros(num_kids, num_gcause);

for kidx = 1:num_kids
    plot_y_one = num_kids - kidx;
    block_y = [plot_y_one plot_y_one+1 plot_y_one+1 plot_y_one];
    text_y = mean(block_y);
    % row var text
    text(-0.05, text_y, sprintf('kid%d', kid_list(kidx)), 'HorizontalAlignment', 'right', 'FontSize', 8);
    
    for gtidx = 1:num_gcause
        block_x = [gtidx-1 gtidx-1 gtidx gtidx];

        gcause_sig_one = gcause_sig_dev(kidx, gtidx);
        % if postive link
        if gcause_sig_one > 0
            % emergence of new positive links
            if gcause_sig_prev(kidx, gtidx) < 1
                block_color = color_emerge(1, :);
%                 gcause_one = gcause_mat_dev(kidx, gtidx);
                gcause_one = gcause_mat_dev(kidx, gtidx) - gcause_mat_prev(kidx, gtidx);
                link_matrix(kidx, gtidx) = 1;
            else
                gcause_one = gcause_mat_dev(kidx, gtidx) - gcause_mat_prev(kidx, gtidx);
                % increase
                if gcause_one > 0
                    block_color = color_emerge(2, :);
                % discrease
                elseif gcause_one < 0
                    block_color = color_emerge(3, :);
                else
                    block_color = color_nochange;
                end
            end
        else
%             gcause_one = gcause_mat_dev(kidx, gtidx);
            gcause_one = gcause_mat_dev(kidx, gtidx) - gcause_mat_prev(kidx, gtidx);
            % dissolve of sig positive links
            if gcause_sig_prev(kidx, gtidx) > 0
                block_color = color_dissolve;
                link_matrix(kidx, gtidx) = -1;
            else
                block_color = color_nochange;
            end
        end
        
        if gcause_one > 66 && gcause_sig_one < 1
            kid_list(kidx)
            block_color = color_emerge(1, :);
        end
        
        fill(block_x, block_y, block_color, 'EdgeColor', 'k');
        text_x = mean(block_x);
        text(text_x, text_y, sprintf('%.2f', gcause_one), 'HorizontalAlignment', 'center', 'FontSize', 8);
        
        if kidx < 2
            % column var text
            text(text_x, (num_kids+0.1), {gcause_str_list{gtidx, 1}; gcause_str_list{gtidx, 2}}, ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 6);
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