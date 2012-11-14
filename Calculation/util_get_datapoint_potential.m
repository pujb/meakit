function [ pot ] = util_get_datapoint_potential( datax, datay, bin_table)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% datax,y from mappedX
% bin_table from util_print_bins_with_files with binwidth


% Number of States
num_states = size(bin_table, 1);

% Number of datapoints in each state, and their centroids (z), SD (sigma), normalized location (r)
num_points = zeros(num_states, 1);
z = zeros(num_states, 2);
sigma = zeros(num_states, 1);
for i = 1:num_states
    % Count how many points in each state
    start_bin = bin_table{i,2};
    end_bin = bin_table{i,3};
    num_points(i) = end_bin - start_bin + 1;
    
    % Store the Centroid (z) of points in each state
    z(i, 1) = mean(datax(start_bin:end_bin));
    z(i, 2) = mean(datay(start_bin:end_bin));
    
    % Calc the SD (sigma) of the distance between each point and z
    tot = 0;
    for j = 1:num_points(i)
        current_index = start_bin + j - 1;
        tot = tot + (datax(current_index) - z(i, 1)) ^ 2 + (datay(current_index) - z(i, 2)) ^ 2;
    end
    sigma(i) = sqrt(tot / num_points(i));

    % Normalize location (r)
    r = zeros(num_points(i), 2);
    for j = 1:num_points(i)
        current_index = start_bin + j - 1;
        % Normalize the location of each point by z and sigma
        r(j, 1) = (datax(current_index) - z(i, 1)) / sigma(i);
        r(j ,2) = (datay(current_index) - z(i, 2)) / sigma(i);
    end
    
    % Generate the distribution of r
    r_d = zeros(num_points(i), 1);
    for j = 1:num_points(i)
        r_d(j) = sqrt(r(j, 1) ^ 2 + r(j, 2) ^ 2);
    end
    
    % Scatter
    util_plot_scatter_with_lines(r(:,1),r(:,2), 'labels', {'PC 1', 'PC 2'}, 'lineoff', 1)
    set(gca, 'XLim', [-2 4])
    set(gca, 'YLim', [-3.5 1.5])
    
    contour(histcn(r,10,10));
end

pot=1;




end


