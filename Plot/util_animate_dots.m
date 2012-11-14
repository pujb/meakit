function [] = util_animate_dots( x, y, steps )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

for i = 1:length(x)/steps
    section_start = (i-1) * steps;
    section_end = i * steps - 1;
    if section_start < 1
        section_start = 1;
    end
    if section_end > length(x)
        section_end = length(x);
    end
    section = (section_start : section_end);
    util_plot_scatter_with_lines(x(section),y(section), 'labels', {'PC 1', 'PC 2'}, 'lineoff', 1, 'holdon', 1)
    drawnow
    pause(0.001)
end

end

