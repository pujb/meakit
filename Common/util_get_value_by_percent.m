function value = util_get_value_by_percent( input, percent, isAscending )
%UTIL_GET_VALUE_BY_PERCENT Get the value level in the input vector or
%matrix by a percentage of the whole.
%   Input:
%           input:      Vector or matrix.
%           percent:    Thresholding percentage.
%           isAscending:    If true, the program returns the value which is
%                           the lower percent% in the input data.
%                           If false, it returns the value which is the top
%                           percent% in the input data.
%   Output:
%           value:      Output level.
%
%   Created on Apr/06/2011 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics


unique_values = unique(input); % Unique values in the network_connection_matrix
threshold_index = round(length(unique_values) * percent);
if ~isAscending
    unique_values = unique_values(end:-1:1);     % Revert, now from big to small
end

% Check range
if threshold_index < 1
    threshold_index = 1;
end
if threshold_index > length(unique_values)
    threshold_index = length(unique_values);
end

value = unique_values(threshold_index);




end

