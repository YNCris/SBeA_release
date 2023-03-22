function data_matrix = generate_simulated_dataset_random(frequency_base, args)
% By default, ror each dataset, the total length of each trial will be 3000: 
%   3000 data points collected per trial;
% There are four trials in total.
% 
% You can modify these two parameters by setting these two fields in args:
%   args.data_length = 6000;
%   args.num_trials = 2;

if nargin < 2
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

num_variables = 2;

data_matrix = nan(num_variables, data_length, num_trials);

for tidx = 1:num_trials
    data_one = zeros(num_variables, data_length);
    for vidx = 1:num_variables
        index_random = randi(data_length, frequency_base, 1);
        data_one(vidx, index_random) = 1;
    end
    data_matrix(:, :, tidx) = data_one;
%     plot_data = [plot_data; point_process2interval(data_one', 1)];
end