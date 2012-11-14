function [] = util_plot_raster_image( spif, gnd, bin, def_colormap, varargin)
%UTIL_PLOT_RASTER_IMAGE Plot the RASTER PLOT using imagesc method
%   Compared to UTIL_PLOT_RASTER_SIMPLE, this function may get a cleaner
%   look when you give it a large data set.
%   
%   Input:
%       spif:   Spike information structure
%       gnd:    Grounding electrodes.
%       bin:    Bin number.
%       def_colormap:       Colormap (You can use UTIL_MAKE_RASTER_COLORMAP.)
%       smooth_win:         Window width to smooth SPSA.
%       active_threshold:   Threshold for active channel selecting, default
%                           = 0 spikes/sec, which plots all channels. 
%
%   Example:
%       util_plot_raster_image(spif, 15, util_make_raster_colormap('hot'));
%
%   Jiangbo Pu / Dec-27-2009
%   Jiangbo Pu / Jun-01-2010
%       Add smoothing method.
%       Change the arguments of this function, removing spb,bin_number, we
%           will generate them inside the function.
%   Jiangbo Pu / May-16-2011
%       Support auto X range.
%   Jiangbo Pu / Sep-21-2012
%       Support customized smooth window
%   Jiangbo Pu / Sep-26-2012
%       Support rastermap of only active channels.

pvpmod(varargin);

if ~exist('smooth_win', 'var')
    smooth_win = 3;
end

if ~exist('active_threshold', 'var')
    active_threshold = 0;
end

% First plot, SPSA
subplot(2,1,1), util_plot_spsa( spif, 'bin', bin, 'mode', 'mean', 'smooth_win', smooth_win);  % you can change 'mean' into 'sum'

% Second plot, RASTER
% Get Spikes Per Bin of Each electrode
[~, ~, ~, ~, spb] = util_calc_rate(spif, 'gnd', gnd, 'bin', bin, 'mode', 'electrode');
% Remove non-active channels
[~, non_active] = util_get_active_electrodes(spif, active_threshold);
gnd = unique([gnd non_active]);

num_units = size(spb,2);
num_bin = size(spb,1);

% Smooth
for i=1:num_units
    spb(:,i) = smooth(spb(:,i), 3, 'moving');
end

% Remove GND
if ~isempty(gnd)
    gnd = unique([gnd 11 88 81 18]);
    spb(:, util_convert_ch2hw(gnd)) = [];
    num_units = num_units - length(gnd);
end

% Plot the figure.
subplot(2,1,2),imagesc(spb', [0 max(max(spb))]);
colormap(def_colormap);

box off
set(gca,'TickDir','Out')
set(gca,'TickLength',[0.005 0.01])

ylabel('Electrodes')
set(gca,'YTick',[0.5 num_units + 0.5])
set(gca,'YTickLabel',[1 num_units])
axis xy

set(gca,'XMinorTick','on')

% Set X Axis
util_set_xtick( zeros(size(spb, 1), 1), bin );

end

