function visualize_time_series(data, args)
% This is a plotting function for visualizing temperol events data
% For input format, please see the function get_test_data() below

LENGTH_CEVENT = 3;

% if isfield(args, 'text_offset')
%     text_offset = args.text_offset;
% else
%     text_offset = 20;
% end

if nargin < 2
    args = struct();
end

figure_bgcolor = [1 1 1];
text_bgcolor = figure_bgcolor;

if isempty(data)
    error('Input data matrix is empty!');
end

if isfield(args, 'trial_times')
%     max_trial_due = max(args.trial_times(:,2)-args.trial_times(:,1));
%     text_offset = text_offset * (max_trial_due/100);
    text_offset = args.trial_times(1,1) - 0.1;
    
    % reverse visualization order
    if size(data, 1) > 2 % there are multiple trials
        data = flip(data);
        args.trial_times = flip(args.trial_times);
%         args.row_text = flip(args.row_text);
        args.time_ref = flip(args.time_ref);
    end
end

if ~exist('args', 'var')
    args.info = 'No user input information here';
end

% How many instances on each figure
if isfield(args, 'MAX_ROWS')
	MAX_ROWS = args.MAX_ROWS;
else
    MAX_ROWS = 20;
end

if isfield(args, 'colormap')
    colormap = args.colormap;
else
    colormap = get_colormap();
end

if isfield(args, 'is_closeplot')
    is_closeplot = args.is_closeplot;
% elseif isfield(args, 'save_name')
%     is_closeplot = true;
else
    is_closeplot = false;
end

% preprocess cell data, transfer it into a matrix
if iscell(data)
    num_data_stream = size(data, 2);
    data_new = {};
    max_num_cvent_data_column = nan(1,num_data_stream);
    
    % go through each stream (each column in the cell data)
    for dsidx = 1:num_data_stream
        data_column = data(:,dsidx);
        
        data_column_length = cellfun(@(data_one) ...
            size(data_one, 1), ...
            data_column, ...
            'UniformOutput', false);
        data_column_length = vertcat(data_column_length{:});
        list_cevent_length = unique(data_column_length(:,1));
        max_data_column_length = max(list_cevent_length);
        
        % if data is a cell and needs to be processed
        if sum(~ismember(list_cevent_length, 1)) > 0
            data_column_new = nan(length(data_column), max_data_column_length*LENGTH_CEVENT);
            for didx = 1:length(data_column)
                data_column_one = data_column{didx};
                for doidx = 1:max_data_column_length
                    if doidx <= size(data_column_one,1)
                        data_column_new(didx,(doidx-1)*3+1:doidx*3) = ...
                            data_column_one(doidx,1:3);
                    end
                end
            end
        else
            data_column_new = vertcat(data_column{:});
            max_data_column_length = list_cevent_length(1);
        end
        if max_data_column_length < 1
            tmp_len = length(data_column_length);
            data_column_new = nan(tmp_len, 3);
        end
        data_new{dsidx} = data_column_new;
        max_num_cvent_data_column(dsidx) = max(max_data_column_length, 1);
    end
    data = horzcat(data_new{:});
    tmp_count = 0;
    for tmpi = 1:length(max_num_cvent_data_column)
        prev_tmp_count = tmp_count + 1;
        tmp_count = tmp_count + max_num_cvent_data_column(tmpi);
        stream_position_new(prev_tmp_count:tmp_count) = ...
            tmpi;
    end
    if ~isfield(args, 'stream_position')
        args.stream_position = stream_position_new;
    end
end

% end
[rows, cols] = size(data);
if ~iscell(data)
    cols = cols / LENGTH_CEVENT;
end

if ~isfield(args, 'stream_position')
    args.stream_position = ones(1,cols);
end

if isfield(args, 'legend')
    if ~isfield(args, 'legend_location')
        if ~exist('cont_args', 'var')
            args.legend_location = 'NorthEastOutside';
        else
            args.legend_location = 'NorthWestOutside';
        end
    end
end

if isfield(args, 'ForceZero')
    if isfield(args, 'ref_index')
        ref_index = args.ref_index;
    elseif isfield(args, 'ref_column')
        ref_column = args.ref_column;
    else
        ref_column = 2;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~iscell(data)
        if isfield(args, 'time_ref')
            time_ref = args.time_ref;
        elseif exist('ref_column', 'var')
            time_ref = data(:,ref_column);
        else
            time_ref = data(ref_index(1), ref_index(2));
            time_ref = repmat(time_ref, size(data,1), 1);
        end
        
        tmp_ref_nan = sum(isnan(time_ref));
        if tmp_ref_nan > 0
            error('Error! There is nan data in the reference time column!');
        end
        data_mat = data;
    else
        data_mat = cell2mat(data);
        if isfield(args, 'time_ref')
            time_ref = args.time_ref;
        elseif exist('ref_column', 'var')
            time_ref = data(:,ref_column);
        else
            time_ref = data(ref_index(1), ref_index(2));
            time_ref = repmat(time_ref, size(data,1), 1);
        end
        if sum(isnan(time_ref)) > 0
%             time_idx_list = sort([1:3:size(data_mat,2) 2:3:size(data_mat,2)]);
            nan_count_data = sum(isnan(data_mat));
            [I, J] = find(nan_count_data);
            ref_column = min(setdiff(1:size(data_mat,2), J));
            if isfield(args, 'ref_column')
                warning(['The reference column for ForceZero time has NaN ' ...
                    'values and thus is changd to column ' int2str(ref_column) '.']);
            end
            time_ref = data_mat(:,ref_column);
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for j = cols:-1:1
        data_mat(:,j*LENGTH_CEVENT-1) = data_mat(:,j*LENGTH_CEVENT-1) - time_ref;
        data_mat(:,j*LENGTH_CEVENT-2) = data_mat(:,j*LENGTH_CEVENT-2) - time_ref;
    end
else
    data_mat = data;
end

if isfield(args, 'color_code') && strcmp(args.color_code, 'category')    
    value_idx_list = 3:LENGTH_CEVENT:size(data_mat,2);
    max_cevent_value = max(max(data_mat(:,value_idx_list)));
end

% to calculate how many figure will be needed in total
num_figures = floor(rows/MAX_ROWS)+ceil(mod(rows/MAX_ROWS, 1));

for fidx = 1:num_figures
    if isfield(args, 'figure_visible') && ~args.figure_visible
        h = figure('Visible','Off');
    else
        h = figure;
    end
    %% The first half of the figure
    hold on;
    
    % to get how many rows/instances will be in this figure
    if fidx == num_figures
        if mod(rows, MAX_ROWS) == 0
            rows_one = MAX_ROWS;
        else
            rows_one = mod(rows, MAX_ROWS);
        end
    else
        rows_one = MAX_ROWS;
    end
    
    if isfield(args, 'position_row_width')
        position_row_width = args.position_row_width;
    else
        position_row_width = 80;
    end
    
    if isfield(args, 'set_position')
        set(h, 'Position', args.set_position, 'Color', figure_bgcolor);
    else
        screensize = get(0, 'Screensize');
        fig_position = [50 50 screensize(3)-60 (100+position_row_width*rows_one)];
        set(h, 'Position', fig_position, 'Color', figure_bgcolor);
    end
    
    % to get the sub chunk of data for this figure
    if fidx == num_figures
        sub_data_mat = data_mat((fidx-1)*MAX_ROWS+1:end,:);
    else
        sub_data_mat = data_mat((fidx-1)*MAX_ROWS+1:(fidx)*MAX_ROWS,:);
    end
    
    start_time_idx = 1:LENGTH_CEVENT:size(sub_data_mat,2);
    end_time_idx = 2:LENGTH_CEVENT:size(sub_data_mat,2);
    
    if isfield(args, 'xlim_list')
        xlim_list = args.xlim_list;
        min_x = xlim_list(1);
        max_x = xlim_list(2);
    else
        min_x = nanmin(nanmin(sub_data_mat(:,start_time_idx))) - 0.1;
        max_x = nanmax(nanmax(sub_data_mat(:,end_time_idx))) + 0.1;
        xlim_list = [min_x max_x];
    end
    
    text_offset = min_x - (max_x-min_x)/100;
    length_of_streams = length(unique(args.stream_position));
    each_stream_space = 1/length_of_streams;
    
    % draw legend cubics
    if isfield(args, 'legend') && isfield(args, 'colormap')
        for lidx = 1:length(args.legend)
            x = [min_x, min_x, min_x, min_x];
            y = [0.1, 1, 1, 0.1];
            if iscell(args.colormap)
                color = args.colormap{lidx};
            else
                color = args.colormap(lidx, :);
            end
            fill(x, y, color);
        end
    end

    if isfield(args, 'row_text')
        row_text_pos_y = nan(MAX_ROWS, 1);
    end
    
    % Draw the background bars - white / grey
    for rowidx = 1:MAX_ROWS
        % Draw left to right in each row
        x = [min_x, max_x, max_x, min_x];
        y = [(rowidx-1)*(1+each_stream_space), (rowidx-1)*(1+each_stream_space), ...
            rowidx*(1+each_stream_space), rowidx*(1+each_stream_space)];
        color = [1 1 1];
        fill(x, y, color);
    end
    
    max_y = 0;
    % Draw actual instances row by row
    for rowidx = 1:rows_one
        % Draw left to right in each row
        pos_num_old = -1;
        for columnidx = 1:cols
            cevent_one = data_mat(rowidx+(fidx-1)*MAX_ROWS,(columnidx-1)*3+1:(columnidx-1)*3+3);
            pos_num_new = args.stream_position(columnidx);
            if isfield(args, 'annotation')
                if iscell(args.annotation)
                    var_text_one =  args.annotation{pos_num_new};
                elseif ischar(args.annotation)
                    var_text_one = sprintf('%s%d', args.annotation, pos_num_new);
                end
            end
            
            if ~(isempty(cevent_one) || sum(isnan(cevent_one)) > 0)
                start_time = cevent_one(1);
                end_time = cevent_one(2);
%                 if isfield(args, 'is_cont2cevent') && args.is_cont2cevent()
                if cevent_one(3) > 100
%                     cevent_one
                    cevent_one(3) = cevent_one(3) - args.cont_value_offset;
                    cont_colormap = get_colormap(args.cont_color_str{pos_num_new}, args.convert_max_int);
                    color = get_color(cevent_one(3), args.convert_max_int, cont_colormap);
                else
                    if ~isfield(args, 'color_code') || strcmp(args.color_code, 'variable')
                        color = get_color(columnidx, cols, colormap); %get_color(cevent_one(3));
                    elseif isfield(args, 'color_code') && strcmp(args.color_code, 'category')
                        color = get_color(cevent_one(3), max_cevent_value, colormap);
    %                     args.edge_color = get_color(mod(cevent_one(3), 10), max_cevent_value, colormap);
                    end
                end
                [~, y] = create_square(start_time, end_time, rowidx, columnidx, color, args);
                text_color = [0 0 0];
            elseif (cevent_one(3) == 0)
                text_color = [1 0 0];
                [~, y] = create_square(0, 0, rowidx, columnidx, [1 1 1], args);
            else % if there is variable, but no data inside
                text_color = [1 1 1] * 0.8;
                [~, y] = create_square(0, 0, rowidx, columnidx, [1 1 1], args);
            end
            
            y_new = mean(y);
            if pos_num_old ~= pos_num_new && isfield(args, 'annotation')
                text(text_offset, y_new, var_text_one, 'FontSize', 8, 'Color', text_color, ...
                    'BackgroundColor', text_bgcolor, 'Interpreter', 'none', 'HorizontalAlignment', 'right');
            end
            pos_num_old = pos_num_new;
        end
        if isfield(args, 'row_text')
            row_text_pos_y(rowidx) = y(1);
        end
        max_y = rowidx*(1+each_stream_space);
    end
    
    if isfield(args, 'ylim_list')
        ylim_list = args.ylim_list;
        max_y = ylim_list(2);
    else
        ylim_list = [0 max_y];
    end
    
    % draw verticle lines according to the user
    if isfield(args, 'vert_line')
        for vidx = 1:length(args.vert_line)
            x = [args.vert_line(vidx), args.vert_line(vidx), args.vert_line(vidx)+0.01, args.vert_line(vidx)+0.01];
            y = [0, max_y, max_y, 0];
            color = [1 0 0];
            fill(x, y, 'r', 'EdgeColor', color);
        end
    end

    % set transpenrency, so the overlaps between cevents can be shown    
    if isfield(args, 'transparency')
        alpha(args.transparency);
    end
    
    if isfield(args, 'legend')
        new_legend = cell(size(args.legend));
        for i = 1:length(args.legend)
            new_legend{i} = plot_no_underline(args.legend{i});
        end
        
        legend(new_legend, 'Location', args.legend_location);
    end
    
    if isfield(args, 'row_text')
        for rowidx = 1:rows_one
            txrowidx = rowidx+(fidx-1)*MAX_ROWS;
            if isfield(args, 'row_text_type') && strcmp(args.row_text_type, 'time')
                row_text_one = sprintf('%s: %.1f-%.1f', args.row_text{txrowidx}, args.trial_times(rowidx, 1), args.trial_times(rowidx, 2));
            elseif iscell(args.row_text)
                row_text_one = args.row_text{txrowidx};
            else
                row_text_one = args.row_text;
            end
            text(max_x+0.1, row_text_pos_y(rowidx), row_text_one, 'FontWeight', 'bold', 'Interpreter', 'none');%, 'FontSize', 12, 'BackgroundColor', [1 1 1]); -1*length(row_text_one)
        end
    end
    
    xlim(xlim_list);
    ylim(ylim_list);
    
    if isfield(args, 'title')
        title(no_underline(args.title), 'FontWeight', 'bold'); %, 'FontSize', 12, 'BackgroundColor', [1 1 1]
    end
    
    if isfield(args, 'xlabel')
        xlabel(args.xlabel);
    end
    
    set(gca, 'ytick', []);
    hold off;
    %% all the plotting is done, start saving    
    if isfield(args, 'save_name')
        save_name = args.save_name;
        
        if isfield(args, 'save_multiwork_exp_dir')
            save_name = fullfile(args.save_multiwork_exp_dir, save_name);
        end
        if ~isfield(args, 'save_format')
            save_format = 'png';
        else
            save_format = args.save_format;
        end
    
        set(h,'PaperPositionMode','auto');
%         if isfield(args, 'figure_visible') && ~args.figure_visible
        if num_figures < 2
            saveas(h, [save_name '.' save_format]);
        else
            saveas(h, [save_name '_' int2str(fidx) '.' save_format]);
        end
        
        if isfield(args, 'pause_before_save') && args.pause_before_save
            pause
        end
%         print(h, '-dpsc', [save_name '_' int2str(fidx) '.' save_format]);
        if is_closeplot
            close(h);
        end
    end
end

end

% Get color according to rainbow color cue pallet
function color = get_color(k, k_base, colormap)
    if ~isempty(colormap)
        if iscell(colormap)
            color = colormap{k};
        else
            color = colormap(k, :);
        end
    else
        color = hsv2rgb([k/k_base,1,0.85]);
    end
end

% Draw one rectangle
% x1: start time
% x2: end time
% y1: y axe coordinate (center)
% color: color of the shape
% height: the height of each rectangle, default value is 0.25
function [x, y] = create_square(x1, x2, y1, cidx, color, args)          
    length_of_streams = length(unique(args.stream_position));
    each_stream_space = 1/length_of_streams;
    position_value = args.stream_position(cidx);
%         color = color*(each_stream_space*position_value)+...
%             (1-each_stream_space*position_value);
    y1 = (y1-1)*(1+each_stream_space);
    y1 = y1 + (length_of_streams-position_value+1)*each_stream_space;    
    
    if ~isfield(args, 'height')
        height = each_stream_space*0.5; %0.2;
    else
        height = args.height;
    end
    if isfield(args, 'edge_color')
        edge_color = args.edge_color; %0.2;
    else
        edge_color = 'none';
    end
    
    x = [x1, x2, x2, x1];
    y = [y1-height, y1-height, y1+height, y1+height];
    rect = fill(x, y, color, 'EdgeColor', color);
end
