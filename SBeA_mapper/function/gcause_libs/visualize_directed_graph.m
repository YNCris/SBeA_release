function visualize_directed_graph(weight_matrix, weight_sig, args)

if nargin < 3
    args = struct();
end

if isfield(args, 'annotation')
    annotation = args.annotation;
else
    annotation = {'variable1', 'variable2'};
end

figure_bgcolor = [1 1 1];

% weight_matrix = results_gcause.gcause_mat;
% annotation = var_module_list;
[num_nodes, m] = size(weight_matrix);
if num_nodes ~= m
    error('Weight matrix should have the same number of rows and columns');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
len_unit = 10;
len_side = 6;
len_gap = (len_unit - len_side)/2;
height = len_unit * ceil(num_nodes/2);
width = len_unit * 2 + len_gap;

% if user wants to use this function and save it as an individual figure
h1 = figure;
if isfield(args, 'set_position')
    set(h1, 'Position', args.set_position, 'Color', figure_bgcolor);
else
    screensize = get(0, 'Screensize');
    fig_width = 25*width;
    fig_height = 25*height;
    fig_position = [50 screensize(4)-fig_height-100 fig_width fig_height];
    set(h1, 'Position', fig_position, 'Color', figure_bgcolor);
end
    
hold on;
xlim([0 width]);
ylim([0 height]);
num_rows = ceil(num_nodes / 2);
for nidx = 1:num_nodes
    rowi = ceil(nidx/2.1);
    columni = mod(nidx+1, 2);
    x = columni*len_unit + len_gap*(columni+1);
    y = (num_rows-rowi)*len_unit + len_gap;
    rectangle('Position', [x y len_side len_side], 'Curvature',1, 'LineWidth', 3);
    center_x = x+len_side/2;
    center_y = y+len_side/2;
    text(center_x, center_y, annotation{nidx}, 'HorizontalAlignment', 'center', 'FontSize', 15);

    if nidx == 2
        % to this node
        if num_nodes > 2
            arrow_start = [x-len_side-0.5 center_y+1.8];
            arrow_end = [x+0.5 center_y+1.8];
            text_loc = [x-len_side/2 center_y+1.8];
            draw_weighted_arrow(arrow_start, arrow_end, ...
                weight_matrix(nidx, nidx-1), text_loc, weight_sig(nidx, nidx-1));

            % from this node
            arrow_start = [x-0.2 center_y];
            arrow_end = [x-len_side+0.2 center_y];
            text_loc = [x-len_side/2 center_y];
            draw_weighted_arrow(arrow_start, arrow_end, ...
                weight_matrix(nidx-1, nidx), text_loc, weight_sig(nidx-1, nidx));
        else
            arrow_start = [x-len_side center_y+1];
            arrow_end = [x center_y+1];
            text_loc = [x-len_side/2 center_y+1];
            draw_weighted_arrow(arrow_start, arrow_end, ...
                weight_matrix(nidx, nidx-1), text_loc, weight_sig(nidx, nidx-1));

            % from this node
            arrow_start = [x center_y-1];
            arrow_end = [x-len_side center_y-1];
            text_loc = [x-len_side/2 center_y-1];
            draw_weighted_arrow(arrow_start, arrow_end, ...
                weight_matrix(nidx-1, nidx), text_loc, weight_sig(nidx-1, nidx));
        end
    elseif nidx == 3
        % to this node
        arrow_start = [center_x-1 y+len_side+2*len_gap];
        arrow_end = [center_x-1 y+len_side];
        text_loc = [center_x-1.8 y+len_side+len_gap];
        draw_weighted_arrow(arrow_start, arrow_end, ...
            weight_matrix(nidx, nidx-2), text_loc, weight_sig(nidx, nidx-2));
        
        % from this node
        arrow_start = [center_x+1 y+len_side];
        arrow_end = [center_x+1 y+len_side+2*len_gap];
        text_loc = [center_x+0.2 y+len_side+len_gap];
        draw_weighted_arrow(arrow_start, arrow_end, ...
            weight_matrix(nidx-2, nidx), text_loc, weight_sig(nidx-2, nidx));
        
        % to this node
        arrow_start = [center_x+len_unit-0.5 center_y+len_unit-1.5];
        arrow_end = [center_x+len_gap-0.5 center_y+len_gap+0.5];
        text_loc = [arrow_start(1,1)-2 arrow_start(1,2)-1];
        draw_weighted_arrow(arrow_start, arrow_end, ...
            weight_matrix(nidx, nidx-1), text_loc, weight_sig(nidx, nidx-1));
        
        % from this node
        arrow_start = [center_x+len_gap+0.5 center_y+len_gap-0.5];
        arrow_end = [center_x+len_unit+0.5 center_y+len_unit-2.5];
        text_loc = [arrow_start(1,1)+1 arrow_start(1,2)+1];
        draw_weighted_arrow(arrow_start, arrow_end, ...
            weight_matrix(nidx-1, nidx), text_loc, weight_sig(nidx-1, nidx));
    elseif nidx == 4
        % to this node
        arrow_start = [center_x-len_unit+0.5 center_y+len_unit-1.5];
        arrow_end = [center_x-len_gap center_y+len_gap+0.5];
        text_loc = [arrow_start(1,1)+0.5 arrow_start(1,2)-1.5];
        draw_weighted_arrow(arrow_start, arrow_end, ...
            weight_matrix(nidx, nidx-3), text_loc, weight_sig(nidx, nidx-3));
        
        % from this node
        arrow_start = [center_x-len_gap-1 center_y+len_gap-0.5];
        arrow_end = [center_x-len_unit-0.5 center_y+len_unit-2.5];
        text_loc = [arrow_start(1,1)-2 arrow_start(1,2)+0.5];
        draw_weighted_arrow(arrow_start, arrow_end, ...
            weight_matrix(nidx-3, nidx), text_loc, weight_sig(nidx-3, nidx));
        
        % to this node
        arrow_start = [center_x-1 y+len_side+2*len_gap];
        arrow_end = [center_x-1 y+len_side];
        text_loc = [center_x-0.2 y+len_side+len_gap];
        draw_weighted_arrow(arrow_start, arrow_end, ...
            weight_matrix(nidx, nidx-2), text_loc, weight_sig(nidx, nidx-2));
        
        % from this node
        arrow_start = [center_x+1 y+len_side];
        arrow_end = [center_x+1 y+len_side+2*len_gap];
        text_loc = [center_x+2 y+len_side+len_gap];
        draw_weighted_arrow(arrow_start, arrow_end, ...
            weight_matrix(nidx-2, nidx), text_loc, weight_sig(nidx-2, nidx));
        
        % to this node
        arrow_start = [x-len_side+0.2 center_y];
        arrow_end = [x-0.2 center_y];
        text_loc = [x-len_side/2 center_y-0.8];
        draw_weighted_arrow(arrow_start, arrow_end, ...
            weight_matrix(nidx, nidx-1), text_loc, weight_sig(nidx, nidx-1));
        
        % from this node
        arrow_start = [x+0.6 center_y-2];
        arrow_end = [x-len_side-0.6 center_y-2];
        text_loc = [x-len_side/2 center_y-2.8];
        draw_weighted_arrow(arrow_start, arrow_end, ...
            weight_matrix(nidx-1, nidx), text_loc, weight_sig(nidx-1, nidx));
    end
end

hold off;
set(gca, 'Visible','off');

%% all the plotting is done, start saving
if isfield(args, 'save_name')
    save_name = args.save_name;
    set(h1,'PaperPositionMode','auto');
    saveas(h1, [save_name '.png']);
%     close(h1);
end