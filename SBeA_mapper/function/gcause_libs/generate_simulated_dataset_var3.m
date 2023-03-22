function data_matrix = generate_simulated_dataset_var3(frequency_base, response_window, success_rate, args)

if nargin < 4
    args = struct();
end

if isfield(args, 'data_length')
    data_length = args.data_length;
else
    data_length = 3000;
end
    
if isfield(args, 'num_trials')
    num_trials = args.num_trials;
else
    num_trials = 2;
end

num_variables = 3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set parameters here for the leading relationship between stream1 and stream2
step_size = floor(data_length / frequency_base);

data_matrix = nan(num_variables, data_length, num_trials);
% plot_data = [];

index_start = response_window+1;

for tidx = 1:num_trials
    data_one = zeros(num_variables, data_length);

    main_index_list = randi([index_start step_size]):step_size:data_length;
    data_one(1, main_index_list) = 1;
    main_index = find(data_one(1, :));
    main_index = [1 main_index data_length];

    for lidx = 2:(length(main_index)-1)
        is_succ = randi([0 1000]) <= 1000 * success_rate;
        if is_succ
            range_lead_start = max([main_index(lidx-1) main_index(lidx)-response_window]);
            index_lead = randi([range_lead_start main_index(lidx)-1]);
            data_one(2, index_lead) = 1;
        end
            
        is_succ = randi([0 1000]) <= 1000 * success_rate;
        if is_succ
            range_follow_end = min([main_index(lidx+1)-1 main_index(lidx)+response_window]);
            index_follow = randi([main_index(lidx)+1 range_follow_end]);
            data_one(3, index_follow) = 1;
        end
    end
    data_matrix(:, :, tidx) = data_one;
%     plot_data = [plot_data; point_process2interval(data_one', 1)];
end