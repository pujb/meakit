function [ distance, distance_sd ] = util_calc_distance_from_DIV_cluster( mapping, bin_table )
%UTIL_CALC_DISTANCE_FROM_DIV_CLUSTER Evaluate the "Tightness" of each
%cluster by calculating the distance among dots
%   This function is not generally purposed.
%   [mappedX mapping] = compute_mapping(matrix, 'PCA');
%   bin_table = util_print_bins_with_files('binwidth', binwidth, 'culdate', '2008-12-09');
%   mappedX => mapping
%   bin_table => bin_table
%   
%   Created on Jul/05/2012 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

% Get length
n_mapping = length(mapping);
n_bin = bin_table{end, 3};
n_cluster = length(bin_table);
if n_mapping ~= n_bin
    warn('Bin number and the number of mapped dots is not equal.');
end

% init var
distance = zeros(n_cluster, 1);
distance_sd = zeros(n_cluster, 1);

% Loop in every cluster
for i = 1:n_cluster
    % bin number in this cluster
    n_bin_cluster_start = bin_table{i, 2};
    n_bin_cluster_end = bin_table{i, 3};
    tmp = [];
    % Calc the distance of each dot recurrently
    for j = n_bin_cluster_start:n_bin_cluster_end
        for k = n_bin_cluster_start:n_bin_cluster_end
            if j == k
                continue;
            end
            tmp = [tmp sqrt((mapping(j,1)-mapping(k,1))^2 + (mapping(j,2)-mapping(k,2))^2)];
        end
    end
    distance(i) = mean(tmp);
    distance_sd(i) = std(tmp);
end


end

