function [ subscript ] = util_extract_cluster( data, clu_result, threshold, varargin )
%UTIL_EXTRACT_CLUSTER Get the specified cluster from the whole set.
%   The program cannot run alone. It should be called after
%   UTIL_EVALUATE_CLUSTER.
%   Note: Only 2D is supported currently.
%
%   Input:
%           data:       The original data points.
%           clu_result: The analysis result from UTIL_EVALUATE_CLUSTER
%           threshold:  The threshold of partition matrix, [0~1].
%                       When method is 'Hard', usually the threshold
%                       should be set to 1. Because each data point should
%                       only belong to one cluster.
%                       When 'Fuzzy', may be you should try a few more
%                       times.
%           dot_size:   The size of scatter dots, [default]: 60
%           labels:     x,y,z lables. e.g. {'PCA 1' 'PCA 2'}
%   Output:
%           subscript:  A structure, sub.c1.index = [. . . .].
%
%   Example:
%           [ subscript ] = util_extract_cluster( mappedX, result, 0.8,
%           'labels', {'PCA 1', 'PCA 2'});
%
%   Created on Jul/26/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

% Analyze parameter
pvpmod(varargin);

c = size(clu_result.data.f, 2);

for cln = 1:c
    if threshold < 1
        subscript.(['c' num2str(cln)]).index = find(clu_result.data.f(:, cln) > threshold);
    else
        subscript.(['c' num2str(cln)]).index = find(clu_result.data.f(:, cln) >= threshold);
    end
end

if ~exist('dot_size', 'var')
    dot_size = 60;
end

% Visualization
colors = {'ro' 'go' 'bo' 'yo' 'mo' 'co' 'ko' 'r.' 'g.' 'b.' 'y.' 'm.' 'c.' 'k.' };
figure
for cln = 1:c
    scatter(data(subscript.(['c' num2str(cln)]).index, 1), data(subscript.(['c' num2str(cln)]).index, 2), dot_size, colors{cln}, 'filled', 'MarkerEdgeColor', [0.5 0.5 0.5])
    hold on
end
hold off

if exist('labels', 'var')
    xlabel(labels{1});
    ylabel(labels{2});
end

for i = 1:c
    legend_label{i} = ['State ' num2str(i) ' (' num2str(length( subscript.(['c' num2str(i)]).index )) ')'];
end
legend(legend_label)
legend('Location','SouthOutside','Orientation','horizontal')
legend('boxoff')

end

