function [ clu_sub ] = util_calc_div_cluster( x, y, div_section, threshold )
%UTIL_CALC_DIV_CLUSTER Simple clustering based on DIVs
%   The points of each DIV are clustred to one class. Any points within or
%   near the area around this class will be classed into the same class (by
%   a threshold).
%
%   Input:
%           x,y:            The location of points
%           div_section:    The DIV of each point
%           threshold:      The radius, any other points within the circle
%                           whose center is an existing classed point will
%                           be clustred in the same class.
%   Output:
%           clu_sub:        Tells the clustering results (the same format
%                           as util_extract_cluster()).
%                           clu_sub.c?.index = bin_id.
%                           ? is the DIV number.
%   Example:
%           [ clu_sub ] = util_calc_div_cluster( mappedX(:,1),
%           mappedX(:,2), divsection, 0.05 );
%
%   Created on Sep/09/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

% Check parameter
if length(x) ~= length(y)
    error('X and Y must be of the same length.');
end

% Check the div_section and total number of bins
if length(div_section) > length(x)
    warning off backtrace
    warning('UTIL:PARAM','Automatically fixed length(div_section) ~= length(bins)');
    warning on backtrace
    div_section = div_section(1:length(x));
end

fprintf('Working... ');
% Loop in the points to generate the clustering result by DIV
divs = unique(div_section);
for i = 1:length(divs)
    % Current DIV
    div = divs(i);
    
    % Points group
    points_in_this_div_x = x(div_section == div);
    points_in_this_div_y = y(div_section == div);
    points_not_in_this_div_x = x(div_section ~= div);
    points_not_in_this_div_y = y(div_section ~= div);
    points_not_in_this_div_index = find(div_section ~= div);
    
    % Add existing points
    clu_sub.(['c' num2str(i)]).index = find(div_section == div);
    
    % Find if any other points which are not in this DIV near those points
    % in this DIV
    for j = 1:length(points_not_in_this_div_x)
        for k = 1:length(points_in_this_div_x)
            if eu_distance(points_not_in_this_div_x(j), points_not_in_this_div_y(j), points_in_this_div_x(k), points_in_this_div_y(k)) < threshold
                % Add this point into the same cluster
                clu_sub.(['c' num2str(i)]).index = [clu_sub.(['c' num2str(i)]).index points_not_in_this_div_index(j)];
                % Go to check next point
                break;
            end
        end
    end
    
    % Make unique
    clu_sub.(['c' num2str(i)]).index = unique(clu_sub.(['c' num2str(i)]).index);
end

fprintf('done.\n');

end

function dis = eu_distance(x1,y1,x2,y2)
%EU_DISTANCE Return the Euclid distance between (x1,y1) & (x2,y2)
    dis = sqrt( (x1-x2)^2 + (y1-y2)^2 );
end

