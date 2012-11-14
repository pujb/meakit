function [ overlapped std_distance ] = util_calc_pca_overlap( pca_mapped, bintable, varargin )
%UTIL_CALC_PCA_OVERLAP Calculating PCA dots dispersion.
%   Input:
%       radius: 'std' / 'max' / 'fixedtest'
%               'std': the radius of each circle is the std of the data of
%                      the corresponding div section.
%               'max': the radius is the max distance of the data from the
%                      center point of the circle.
%               'fixedtest': 0.1
%       pca_mapped: The mapping from PCA.
%       bintable:   The bin-div table.
%
%   Output:
%       overlapped: The overlapped ratio of the current one to the next
%                   one in a vector.
%       std_distance: STD of distances of points in each DIV section, also
%                   in a vector.
%       Maybe you should check for the texted output. It's better
%       self-explained.
%
%
%   Created on Nov/13/2012 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

pvpmod(varargin);

if ~exist('radius', 'var')
    radius = 'std';
end

% Normalize
x = util_map_minmax(pca_mapped(:,1));
y = util_map_minmax(pca_mapped(:,2));

% How many DIVS we got
divnumber = length(bintable);
disp(['Total DIV Number = ' num2str(divnumber) ', [' num2str(cell2mat(bintable(1,4))) ',' num2str(cell2mat(bintable(end,4))) '].']);

% Init
mean_center_x = ones(divnumber, 1);
mean_center_y = ones(divnumber, 1);
mean_distance = ones(divnumber, 1);
std_distance = ones(divnumber, 1);
distance_all = [];
mean_overlapped = ones(divnumber, 1);
std_overlapped = ones(divnumber, 1);
circle_x = cell(divnumber, 1);
circle_y = cell(divnumber, 1);

% Circle precision
circle_precision = 100;
% Generate the theta value list.
theta = linspace(0, 2*pi, circle_precision);
r = 0;

% Get Center point and std distance for each DIV section
for i = 1:divnumber
    % Get BINRANGE of the current DIV
    binrange = util_analyze_bintable(bintable, 'method', 'queryBINRANGEfromDIV', 'div', cell2mat(bintable(i,4)));
    % Get center point the current div section
    mean_center_x(i) = mean(x(binrange));
    mean_center_y(i) = mean(y(binrange));
    % Get distance between each dot and the center point
    distance = ones(length(binrange), 1);
    for j = 1:length(binrange)
        distance(j) = sqrt((x(binrange(j)) - mean_center_x(i))^2 + (y(binrange(j)) - mean_center_y(i))^2);
    end
    mean_distance(i) = mean(distance);
    std_distance(i) = std(distance);
    distance_all = [distance_all distance'];
    % Create circles
    if strcmpi(radius, 'std')
        r = std_distance(i);
    elseif strcmpi(radius, 'max')
        r = max(distance);
    elseif strcmpi(radius, 'fixedtest')
        r = 0.1;
    else
        error('Wrong input - RADIUS');
    end
    % Get the circle vectors
    circle_x{i} = cos(theta) * r + mean_center_x(i);
    circle_y{i} = -sin(theta) * r + mean_center_y(i);   % -sin for clockwise and avoids warning from polybool
end

% Get overlapped information
intersect_x = cell(divnumber-1, 1);
intersect_y = cell(divnumber-1, 1);
overlapped = ones(divnumber-1, 1);
figure, hold on;
for i = 1:divnumber-1
    % Plot Circle
    plot(circle_x{i}, circle_y{i}, 'Color', 'k');
    % Calc Intersect
    [intersect_x, intersect_y] = polybool('intersection', circle_x{i}, circle_y{i}, circle_x{i+1}, circle_y{i+1});
    % Fill Intersect
    patch(intersect_x, intersect_y, 1, 'FaceColor', 'r', 'FaceAlpha', 0.25)
    % Calc the % of intersection between next DIV and the current.
    % (Intersect) / Current
    overlapped(i) = polyarea(intersect_x, intersect_y) / polyarea(circle_x{i}, circle_y{i});
    % Labelling
    text(mean_center_x(i), mean_center_y(i), num2str(cell2mat(bintable(i,4))));
end
% Plot the last one.
plot(circle_x{divnumber}, circle_y{divnumber}, 'Color', 'k');
text(mean_center_x(divnumber), mean_center_y(divnumber), num2str(cell2mat(bintable(divnumber,4))));
% Plot circle centers
plot(mean_center_x, mean_center_y, 'k.');

% Remove any possible NaN from overlapped
overlapped(isnan(overlapped)) = [];

% Print results briefly
disp(['Overlapping ratio:' num2str(mean(overlapped)) ' +/- ' num2str(std(overlapped))]);
disp(['Standard deviation:' num2str(std(distance_all))]);
disp(['Coefficient of variation:' num2str(std(distance_all)/mean(distance_all))])

end

