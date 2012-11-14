function util_plot_curve(x1,y1,x2,y2,  lwidth,lcolor,lalpha,  min_radian,modified_length,  method)
%UTIL_PLOT_CURVE Plot a curve from (x1,y1) to (x2,y2)
%   Input:
%           x1,x2,y1,y2:    Position of (x1,y1), (x2,y2)
%           lwidth:     Line width
%           lcolor:     Line color, [r g b; r g b] -> [begin color, end color]
%           lalpha:     Line alpha transparency, [0 1] -> [begin alpha, end alpha]
%                       if begin color = end color, lcolor = [r g b],
%                       if begin alpha = end alpha, lalpha = [a].
%           min_radian: Max:pi, Min:0. Smaller means more straight line.
%           modified_length:    The line can be shorter(-value) or longer(+value) than a
%                               predefined value.
%           method:     'plot': default, single color, vector output
%                       'gradient': using patch, gradient color, vector output
%                       'alpha': using patch, supporting gradient color and
%                                alpha blending, bitmap output.
%   Explanation:
%           @alpha, we will generate lines with gradient color and
%           alpha blending. But the result cannot be saved in vector
%           format.
%           @gradient, we can only support gradient colored lines. The
%           result is in vector format, but please note the bold lines will
%           be very ugly (lw > 10).
%           @plot, only single colored lines are supported. but it is the
%           fastest and have a smooth outline.
%
%   Color:
%           @plot / @alpha, the color is givened by true color RGB values.
%           @gradient, the color should be given as the index in colormap.
%
%   The calculation of angle is based on Feng Xian & Chen Wenjuan's work
%
%   Created on Mar/29/2011 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2011-03-30  Adding 'modified_length'

% initial radian of the curve
init_radian = pi/4;

% max radian
if isempty(min_radian)
    min_radian = pi/4/4.5;
end

% distance between (x1,y1) & (x2,y2)
distance = sqrt((x2-x1)^2 + (y2-y1)^2);

if ~isempty(modified_length)
    % x2,y2 need to be modified
    x2 = x2 + ((x2-x1) * modified_length / distance);
    y2 = y2 + ((y2-y1) * modified_length / distance);
    % Recalc
    distance = sqrt((x2-x1)^2 + (y2-y1)^2);
end

% polar angle between (x1,y1) & (x2,y2)
angle = atan2(-(x2-x1), (y2-y1));

% radian
radian = init_radian / distance;
if radian < min_radian
    radian = min_radian;
end
radian_range = linspace(angle - radian, angle + radian);

% radius
radius = distance/2/sin(radian);

% distance between the circle center and the median between (x1,y1) & (x2,y2)
distance_center = sqrt(radius^2 - distance^2/4);

% Convert the polar coordinate of the curve into Cartesian coordinate
% system
m = (x1+x2) / 2 - distance_center * cos(angle) + radius * cos(radian_range);
n = (y1+y2) / 2 - distance_center * sin(angle) + radius * sin(radian_range);

% Determine and remember the hold status, toggle if necessary
if ishold,
	washold = true;
else
	washold = false;
	hold on;
end

if strcmpi(method, 'plot')
    plot(m, n, 'LineWidth', lwidth, 'Color', lcolor);
elseif strcmpi(method, 'gradient')
    % Forming color
    % Check if the line need gradient coloring (Begin Color != End Color)
    % Color is in index format not true color format
    if length(lcolor) > 1
        if lcolor(1) ~= lcolor(end)
            needcoloring = true;
        else
            needcoloring = false;
        end
    else
        needcoloring = false;
    end
    
    num_points = length(m);
    if num_points > 2 && needcoloring
        % Need to form a gradient coloring mapping
        linecolors = linspace(lcolor(1), lcolor(end), num_points);
    else
        % All color points should be the same
        linecolors = ones(num_points, 1) * lcolor(1);
    end
    
    patch([m nan], [n nan], [linecolors' nan], ...
        'EdgeColor', 'interp', 'LineWidth', lwidth);
    
elseif strcmpi(method, 'alpha')
    % Forming color
    % Check if the line need gradient coloring (Begin Color != End Color)
    if size(lcolor, 1) ~= 1
        if lcolor(1,1) ~= lcolor(2,1) && lcolor(1,2) ~= lcolor(2,2) && lcolor(1,3) ~= lcolor(2,3)
            needcoloring = true;
        else
            needcoloring = false;
        end
    else
        needcoloring = false;
    end
    
    num_points = length(m);
    if num_points > 2 && needcoloring
        % Need to form a gradient coloring mapping
        linecolors = zeros(num_points, 3, 'double');
        color_space = [linspace(lcolor(1,1), lcolor(2,1), num_points); linspace(lcolor(1,1), lcolor(2,1), num_points); linspace(lcolor(1,1), lcolor(2,1), num_points)]';
        for i = 1:num_points
            linecolors(i, :) = color_space(i, :);
        end
    else
        % All color points should be the same
        linecolors = repmat(lcolor(1,:), num_points, 1);
    end
    
    % Forming alpha
    % Check if the line need gradient alpha mapping (Begin alpha != End alpha)
    if length(lalpha) > 1
        if lalpha(1) ~= lalpha(end)
            needalpha = true;
        else
            needalpha = false;
        end
    else
        needalpha = false;
    end
    
    if num_points > 2 && needalpha
        % Need to form a gradient alpha mapping
        linealphas = linspace(lalpha(1), lalpha(end), num_points);
    else
        % All points should be the same
        linealphas = ones(num_points, 1) * lalpha(1);
    end

    patch([m nan], [n nan], 0, 'FaceVertexCData', [linecolors; nan nan nan], ...
        'FaceVertexAlphaData', [linealphas 1]', ...
        'EdgeColor', 'interp', 'EdgeAlpha', 'interp', 'LineWidth', lwidth);
else
    error('wrong input - method.');
end

% restore hold status
if ~washold
	hold off
end
end
