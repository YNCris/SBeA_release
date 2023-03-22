function visualize_point_process(data_matrix, vis_args)

if nargin < 2
    vis_args = struct();
end

plot_data = [];

[num_streams, data_length, num_trials] = size(data_matrix);

for tidx = 1:num_trials
    data_one = data_matrix(:, :, tidx);
    data_pp = point_process2interval(data_one', 1);
    
    for ppidx = 1:length(data_pp)
        pp_one = data_pp{ppidx};
        pp_one(:, end) = ppidx;
        data_pp{ppidx} = pp_one;
    end
    plot_data = [plot_data; data_pp];
end

vis_args.color_code = 'category';
vis_args.sample_rate = 1;
vis_args.colormap = [
         0         0    1.0000
    1.0000         0         0
         0    1.0000         0
    1.0000         0    1.0000];

visualize_time_series(plot_data, vis_args);