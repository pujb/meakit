function [] = util_plot_raster_simple( spif, gnd, bin, draw_command, quickmode )
%UTIL_PLOT_RASTER_SIMPLE Plot the RASTER PLOT using simple plotting methods
%   This function draws the raster plot using 'plot' or 'scatter' method.
%   Compared to UTIL_PLOT_RASTER_IMAGE, this function is suitable for
%   drawing data sets with sparse firing patterns.
%
%   Input:
%       spif:   Spike information structure.
%       gnd:    Grounding electrodes.
%       draw_command:   'plot' or 'scatter'. If you are drawing an
%                       extremely large data set, please use 'plot'.
%       quickmode:  true/false, if true, the raster will be based on spike
%                   rate (ASDR/SPB) instead of precisely timing.
%
%   Jiangbo Pu / May-27-2010
%   Jiangbo Pu / Jun-01-2010
%       Add 'plot' method.
%   Jiangbo Pu / May-16-2011
%       Fix plot SPSA method;
%       Add automatically X tick.

% First plot, SPSA
subplot(2,1,1);
[spb] = util_plot_spsa( spif, 'bin', bin, 'mode', 'mean');

% Second plot, RASTER

% Get Spikes Per Bin of Each electrode
index = 1;
bin_size = 1000; % 1s
bin_range = 1:1:fix( spif.startend(2)/bin_size );

for hwid = 1:length(spif.spiketimes)
    if ~util_find_a_in_b(util_convert_hw2ch(hwid), [11 18 81 88 gnd])
        if quickmode
            locationX = find(histc(spif.spiketimes{hwid}/bin_size, bin_range) > 1);
            locationY = ones(length(locationX),1) * index;
        else
            locationX = spif.spiketimes{hwid} / bin_size;
            locationY = ones(length(locationX),1) * index;
        end
        
        % PLOT METHOD
        if strcmp(draw_command, 'plot')
            % PLOT (Recommended)
            subplot(2,1,2),plot([locationX,locationX]', [locationY-0.3,locationY+0.3]', 'k');
        elseif strcmp(draw_command, 'scatter')
            % SCATTER METHOD (Fatter markers)
            subplot(2,1,2),scatter(...
                locationX, locationY, 10, ...
                'Marker','.','MarkerEdgeColor','black','MarkerFaceColor','black','EraseMode','none');
        else
            error('Not supported drawing command.');
        end
        hold on;
        index = index + 1;
    end
end

box off
set(gca,'TickDir','Out')
set(gca,'TickLength',[0.005 0.01])

set(gca,'YTick',[0 index])
set(gca,'YTickLabel',[1 index-1])

set(gca,'XMinorTick','on')
ylabel('Electrodes')

% Set X Axis
util_set_xtick( spb, bin );
