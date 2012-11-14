function [] = util_plot_scatter_with_lines( x, y, varargin )
%UTIL_PLOT_SCATTER_WITH_LINES Plot scatter graphs with lines between them.
%   Input:
%           x,y:    data points
%           z:      if axis z is exist, the program will call scatter3 and
%                   plot3 to get a 3d view
%           labels:  x,y,z lables. e.g. {'PCA 1' 'PCA 2'}
%           dot_size:   The size of scatter dots, [default]: 60
%           dot_color:  e.g. [0.5 0.5 0.5], if not provided, the dots will
%                       be colored by the indice of colormap.
%           lineoff:    If true, dont draw lines, [default]: false
%           texton:     If true, label each data point with its subscript,
%                       [default]: off
%           holdon:     If true, we will not create new figure on each
%                       calling.
%                       [default]: off
%   Example:
%           util_plot_scatter_with_lines(mappedX(:,1),mappedX(:,2), 'z',
%           mappedX(:,3),'labels', {'PC 1', 'PC 2', 'PC 3'}, 'lineoff', 1)
%
%   Created on Jul/24/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2011-07-14  Adding 'holdon' switch.
%       PJB#2011-07-15  Adding 'dot_color' switch.

pvpmod(varargin);

% dot-size
if ~exist('dot_size', 'var')
    dot_size = 60;
end

if ~exist('dot_color', 'var')
    dot_color = [];
end

if ~exist('lineoff', 'var')
    lineoff = false;
end

if ~exist('texton', 'var')
    texton = false;
end

if ~exist('holdon', 'var')
    holdon = false;
end


if ~holdon
    figure
else
    hold on
end

% determine the z-axis
if ~exist('z', 'var')
    if ~lineoff
        plot(x, y, 'Color', [0.5 0.5 0.5]); hold on 
    end
    if length(x) == 3
        if isempty(dot_color)
            scatter(x, y, dot_size, [1:length(x)]', 'filled', 'MarkerEdgeColor', [0.5 0.5 0.5]); cbar_axes = colorbar();
        else
            scatter(x, y, dot_size, [1:length(x)]', 'filled', 'MarkerEdgeColor', [0.5 0.5 0.5], 'MarkerFaceColor', dot_color); cbar_axes = colorbar();
        end
    else
        if isempty(dot_color)
            scatter(x, y, dot_size, [1:length(x)], 'filled', 'MarkerEdgeColor', [0.5 0.5 0.5]); cbar_axes = colorbar();
        else
            scatter(x, y, dot_size, [1:length(x)], 'filled', 'MarkerEdgeColor', [0.5 0.5 0.5], 'MarkerFaceColor', dot_color); cbar_axes = colorbar();
        end
    end
    if texton
        textlabel = cell(1,length(x));
        for i = 1:length(x)
            textlabel{i} = num2str(i);
        end
        text(x, y, textlabel);
    end
    hold off
else
    if ~lineoff
        plot3(x, y, z, 'Color', [0.5 0.5 0.5]); hold on
    end
    if isempty(dot_color)
        scatter3(x, y, z, dot_size, [1:length(x)], 'filled', 'MarkerEdgeColor', [0.5 0.5 0.5]); cbar_axes = colorbar('location', 'EastOutside');
    else
        scatter3(x, y, z, dot_size, [1:length(x)], 'filled', 'MarkerEdgeColor', [0.5 0.5 0.5], 'MarkerFaceColor', dot_color); cbar_axes = colorbar('location', 'EastOutside');
    end
    hold off
end

if exist('labels', 'var')
    xlabel(labels{1});
    ylabel(labels{2});
    if exist('z', 'var')
        zlabel(labels{3});
    end
end

box off;
set(gca, 'TickDir', 'out');
set(cbar_axes, 'box', 'off');
set(cbar_axes, 'TickDir', 'out');



end

