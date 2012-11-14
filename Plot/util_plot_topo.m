function [ degree ] = util_plot_topo( w_elec, w_link, gnds, varargin )
%UTIL_PLOT_TOPO Plot a topology graph based on electrode mapping
%   Input:
%           w_elec:     Vector containning the sizes of each electrode.
%           w_link:     The correlation matrix of the array.
%                       w_link(i,j) is the weight from electrode i to j (hwid).
%           gnds:       Grounding electrodes.
%
%           maxmin:     [max min], if provided, only plot links within this range.
%                       This may be useful when comparing among different
%                       DIVs.
%                       default: [1 0]
%
%           unit:       'direct' / 'scaled'
%                       @direct[default]: Only plot data in [max min],
%                                         values > max or < min will not
%                                         plotted.
%                       @scaled: in percentage. Plot data from max% to
%                                         min%.
%
%           drawline:   'strong' links first, or 'weak' links first
%           selected_ch:
%                       if not provided, the program will plot all channels
%                       topology.
%                       if provided, the program will only plot connections
%                       related to selected channels.
%           issymmetric:
%                       When you are using 'selected_ch', if true, only draw lines from
%                       'selected_ch', but not lines to 'selected_ch'.
%                       When not using 'selected_ch', if true, only draw
%                       lines from a to b, but not b to a.
%                       default = false. 
%
%           method:     Drawing method. default = 'plot'
%                       plot: Solid single colored lines
%                       alpha: With alpha blending.
%
%   Please note: 
%           If one of w_elec and w_link is [], the program be still running. 
%
%   Explain:
%           Asymmetric, means the values between a & b is different from b & a.
%           Symmetric, we will only calculate once, then copy the value to
%           its symmetric pair.
%
%           show_axis:  Decides whether the axis will be shown, default = 0.
%
%           colormap_link:  The colormap of links.
%           color_empty_elec_face:
%           color_empty_elec_edge:
%           color_full_elec_face:
%           color_full_elec_edge:
%           width_empty_elec:
%           width_max_link:
%           width_min_link:
%           width_granularity:
%           size_empty_elec:
%           size_full_elec:
%           size_granularity:
%
%                       Please refer to the program, these values have
%                       their default value.
%   Output:
%           degree:     If provided w_link, and ~w_elec, this is the degree mapping
%                       which is w_elec actually.
%                       If w_elec is provided, then degree = w_elec.
%   Example:
%           util_plot_topo( [], matrix, [28],'drawline', 'weak', 'maxmin',
%           [1 0.1], 'unit', 'direct', 'selected_ch', [35], 'issymmetric', 1, 'show_axis', 1);
%
%
%   Created on Apr/01/2011 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2011-04-03  Bug fix. Now @direct mode, the data range among
%                       different trials can be fixed by [max min]




% Check parameters
pvpmod(varargin);

if isempty(w_elec) && isempty(w_link)
    error('w_elec and w_link is all empty, you should provide one at least.')
end

if ~exist('color_empty_elec_face', 'var')
    % The face color of empty electrode outline
    color_empty_elec_face = [0.75 0.75 0.75];
end

if ~exist('color_empty_elec_edge', 'var')
    % The line color of empty electrode outline
    color_empty_elec_edge = [0 0 0];
end

if ~exist('color_full_elec_face', 'var')
    % The face color of empty electrode outline
    color_full_elec_face = [0 0 0];
end

if ~exist('color_full_elec_edge', 'var')
    % The line color of empty electrode outline
    color_full_elec_edge = [0 0 0];
end

if ~exist('width_empty_elec', 'var')
    % The line width of empty electrode outline
    width_empty_elec = 0.75;
end

if ~exist('width_max_link', 'var')
    % The minimum line width of a link
    width_max_link = 10;
end

if ~exist('width_min_link', 'var')
    % The minimum line width of a link
    width_min_link = 1;
end

if ~exist('width_granularity', 'var')
    % The granularity between max/min width link
    width_granularity = 50;
end

if ~exist('size_empty_elec', 'var')
    % The size of empty electrodes
    size_empty_elec = 2;
end

if ~exist('size_full_elec', 'var')
    % The size of full electrodes
    size_full_elec = 17;
end

if ~exist('size_granularity', 'var')
    % The granularity between max/min electrode size
    size_granularity = 50;
end

if ~exist('drawline', 'var')
    drawline = 'strong';
end

if ~exist('show_axis', 'var')
    % Show the axis
    show_axis = false;
end

if ~exist('colormap_link', 'var')
    h = figure();
    colormap_link = util_make_raster_colormap('esa');
    close(h);
end

if ~exist('maxmin', 'var')
    maxmin = [1 0];
end

if ~exist('unit', 'var')
    unit = 'direct';
end

if ~exist('issymmetric', 'var')
    issymmetric = false;
end

if ~exist('selected_ch', 'var')
    selected_ch = [];
end

if ~exist('method', 'var')
    method = 'plot';
end

% Draw the 8*8 positions of all electrodes
figure, hold on
for i = 1:8
    for j = 1:8
        curr_chid = i*10 + j;
        if util_find_a_in_b(curr_chid, [11 88 18 81 gnds])
            continue;
        end
        plot(i, j, 'o', 'LineWidth', width_empty_elec, 'MarkerEdgeColor', color_empty_elec_edge, 'MarkerFaceColor', color_empty_elec_face, ...
             'MarkerSize', size_empty_elec);
    end
end
axis([0 9 0 9]); axis ij
if ~show_axis
    axis off;
end
hold off;

% Rendering sequence (can be changed with switch 'drawline')
% Draw the strong links first, then the weak links to emphasize the weak
% links. Afterwards, the dots (electrodes)

% Draw the links first, if we have w_link
% In w_link, w_link(i,j) is the weight from i to j.
if ~isempty(w_link)
    % Clean up the auto-correlation
    for i = 1:64
        w_link(i,i) = 0;
    end
    
    % Get how many value level in the link matrix
    unique_values = unique(w_link(w_link > 0)); % Unique values in the w_link
    unique_values = unique_values(end:-1:1);     % Revert, now from big to small
    
    % The real max/min
    real_max = unique_values(1);
    real_min = unique_values(end);
    
    if issymmetric || ~isempty(selected_ch)
        % Preserve old link
        original_w_link = w_link;
    end
    
    % Process if provided selected_ch
    if ~isempty(selected_ch)
        hwid_list = util_convert_ch2hw(selected_ch);
        w_link = zeros(size(original_w_link), 'double');
        w_link(hwid_list, :) = original_w_link(hwid_list, :);
        if ~issymmetric
            w_link(:, hwid_list) = original_w_link(:, hwid_list);
        end
    else
        % Remove symmetrical information
        if issymmetric
            for i = 1:64
                for j = i:64
                    w_link(i,j) = 0;
                end
            end
        end
    end
    
    % The range max/min
    if strcmpi(unit, 'direct')
        range_max = maxmin(1);
        range_min = maxmin(2);

        % Check range
        if range_max < range_min
            error('wrong input - maxmin.');
        end
        
        % Check range with real max/min values
        % Fix the range with user provided max/min
        disp(['User Max: ' num2str(range_max)])
        disp(['Real Max: ' num2str(real_max)])
        if range_max > real_max
            % The real_max is set to user-defined max(range_max)
            real_max = range_max;
            disp('Max value has been set to user-defined value.');
        end
        
        disp(['User Min: ' num2str(range_min)])
        disp(['Real Min: ' num2str(real_min)])
        if range_min < real_min
            % The real_min is set to user-defined min(range_min)
            real_min = range_min;
            disp('Min value has been set to user-defined value.');
        end
    else
        % the max/min is given in percentage
        % convert it into direct value
        if maxmin(1) > 1 || maxmin(2) < 0 || maxmin(1) < maxmin(2)
            error('wrong input - maxmin.');
        end
        range_max_index = round(length(unique_values) * (1-maxmin(1)));
        range_min_index = round(length(unique_values) * (1-maxmin(2)));
        if range_max_index < 1
            range_max_index = 1;
        end
        if range_min_index < 1
            range_min_index = 1;
        end        
        if range_max_index > length(unique_values)
            range_max_index = length(unique_values);
        end
        if range_min_index > length(unique_values)
            range_min_index = length(unique_values);
        end
        range_max = unique_values(range_max_index);
        range_min = unique_values(range_min_index);
    end
    % Filtering the values 
    % Data>Max or <Min will not shown
    % ===================> Note: unique_values have changed its length
    unique_values(unique_values > range_max | unique_values < range_min) = [];
    % Define the drawing sequence
    if strcmpi(drawline ,'strong')
        % Draw strong links first
        slicing = (1:length(unique_values));
    elseif strcmpi(drawline, 'weak')
        % Draw weak links first
        slicing = (length(unique_values):-1:1);
    else
        error('wrong input - drawline.');
    end
    
    % Determine the width space
    lwidth_space = linspace(width_min_link, width_max_link, width_granularity);
    
    % Draw loop
    for i = slicing
        % Get current value in the unique value list
        % Note: Big to small
        current_value = unique_values(i);
        % Get the pairs with current weight
        % w_link(i,j) is weight from i to j, i is ref_ch, j is obs_ch
        [ref_ch obs_ch] = find(w_link == current_value);
        ref_ch = util_convert_hw2ch(ref_ch);
        obs_ch = util_convert_hw2ch(obs_ch);
        num_pairs = length(ref_ch); % Number of pairs
        for j = 1:num_pairs
            [x1 y1] = sub_get_electrode_position(ref_ch(j));
            [x2 y2] = sub_get_electrode_position(obs_ch(j));
            width_color_indexer = fix(current_value/real_max * width_granularity);
            if width_color_indexer < 1
                width_color_indexer = 1;
            end
            if width_color_indexer > width_granularity
                width_color_indexer = width_granularity;
            end
            lwidth = lwidth_space(width_color_indexer);
            lcolor = colormap_link(width_color_indexer, :);
            if strcmpi(method, 'plot')
                util_plot_curve(x1,y1,x2,y2,lwidth,lcolor,[],[],[],'plot');
            else
                util_plot_curve(x1,y1,x2,y2,lwidth,lcolor,[0.3 1],[],[],'alpha');
                % ==========================
                % Other method could be used
                %util_plot_curve(x1,y1,x2,y2,lwidth,width_color_indexer*width_granularity/size(colormap_link, 1),[],[],[],'gradient');   % 64 is the length of colormap
            end

        end
    end
    
    % Setup the colorbar
    cbar = util_set_colorbar(colormap_link);
    % Label selected range
    if range_min ~= real_min
        yticks = [1 fix(range_min/(real_max) * width_granularity)];
        ytickl = {real_min, range_min};
    else 
        yticks = 1;
        ytickl = {real_min};
    end
    if range_max ~= real_max
        yticks = [yticks fix(range_max/real_max * width_granularity) size(colormap_link, 1)];
        ytickl = [ytickl, {range_max, real_max}];
    else
        yticks = [yticks size(colormap_link, 1)];
        ytickl = [ytickl, {real_max}];
    end
    % Check if overlapped
    [yticks overlapped_sorted_index] = unique(yticks);
    ytickl = ytickl(overlapped_sorted_index);
    set(cbar, 'YTick', yticks);
    set(cbar, 'YTickLabel', ytickl);
end

% Draw the electrode mapping
% Checking if we have w_elec
if isempty(w_elec)
    % The user didn't provide w_elec, which means w_elec is the degree of
    % each electrode
    
    % Restore the oringial w_link if issymmetric or selected_ch have taken
    % effect
    % Note: the auto-correlation have been cleaned up already.
    if issymmetric || ~isempty(selected_ch)
        w_link = original_w_link;
    end
    
    % Filtering w_link by range_min
    w_link(w_link < range_min) = 0;
    
    % init
    w_elec = zeros(1, 64);
    
    % Calc connectivity degrees
    for i = 1:64
        w_elec(i) = length(find(w_link(i, :) ~= 0)) + length(find(w_link(:, i) ~= 0));
    end
    
    % Get the max value for normalization
    % (max degree will changed from trials to trials)
    max_w_elec = 60 - length(gnds);
else
    % Get the max value for normalization
    max_w_elec = max(w_elec);
end

% Do drawing (electrodes)
% Convert to axis position
size_space = linspace(size_empty_elec, size_full_elec, size_granularity);

hold on
for i = 1:length(w_elec)
    if w_elec(i) ~= 0
        [w_elec_pos_x w_elec_pos_y] = sub_get_electrode_position(util_convert_hw2ch(i));
        size_indexer = fix(w_elec(i) / max_w_elec * size_granularity);
        if size_indexer < 1
            size_indexer = 1;
        end
        if size_indexer > size_granularity
            size_indexer = size_granularity;
        end
        plot(w_elec_pos_x, w_elec_pos_y, 'o', 'MarkerSize', size_space(size_indexer), ...
            'LineWidth', 1, 'MarkerEdgeColor', color_full_elec_edge, 'MarkerFaceColor', color_full_elec_face);
    end
end
hold off

degree = w_elec;

end


function [x y] = sub_get_electrode_position(chid)
%SUB_GET_ELECTRODE_POSITION Get electrode position from chid
%   For example:    12 = [1, 2]
%                   87 = [8, 7]
x = fix(chid / 10);
y = rem(chid, 10);
end


