function [rate] = util_plot_spsa( spif, varargin )
%UTIL_PLOT_SPSA Generate the SPSA (Rate) graph
%   Input£º
%           spif:       Spike information structure
%           gnd:        Grounding electrode (default:15)
%           mode:       'sum'[default] / 'mean'
%           smooth_win: Smoothed using moving window, default = 0;
%
%   Created on May/27/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2010-09-01  Now can return the figure handle.
%       PJB#2010-11-08  Support grounding channels.
%       PJB#2011-05-16  Support auto X range.
%       PJB#2012-09-21  Support smoothed spsa line.
%       PJB#2012-09-26  Now the error range also supports smooth_win.

pvpmod(varargin);

if ~exist('gnd', 'var')
    gnd = [];
end

if ~exist('bin', 'var')
    bin = 1000;
end

if ~exist('mode', 'var')
    mode = 'sum';
end

if ~exist('smooth_win', 'var')
    smooth_win = 0;
end


% Get rate and plot
if strcmpi(mode, 'sum')
    rate = util_calc_rate(spif,'gnd',gnd,'bin',bin);
    if smooth_win
        rate = smooth(rate, smooth_win, 'moving');
    end
    plot(rate, '-k' );
elseif strcmpi(mode, 'mean')
    [~, rate, err] = util_calc_rate(spif,'gnd',gnd,'bin',bin);
    if smooth_win
        rate = smooth(rate, smooth_win, 'moving');
        err = smooth(err, smooth_win, 'moving');
    end
    if length(rate) < 50
        confplot([1:length(rate)], rate, err, err, '-k.');
    else
        confplot([1:length(rate)], rate, err, err, '-k');
    end
end

% Modify
box off
set(gca,'TickDir','Out')
set(gca,'TickLength',[0.005 0.01])
set(gca,'XMinorTick','on')

ylabel(['AWSR (bin = ' num2str(bin) ' ms)'])

% Set X Axis
util_set_xtick( rate, bin );

end