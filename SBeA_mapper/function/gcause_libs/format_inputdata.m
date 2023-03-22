function [len, dimension, data_list] = format_inputdata(data_list, default_value)
% This function formats data into desired structure
% Each row is one collection of variable categories at one time stamp
%   - number of observations sampled
% Each column is one type of variable input
%   - the dimension of variables

if nargin < 2
    default_value = -99;
end

mask_nan = isnan(data_list);
data_list(mask_nan) = default_value;

[n, m] = size(data_list);

if m > n
    data_list = data_list';
    len = m;
    dimension = n;
else
    len = n;
    dimension = m;
end