function [] = util_script_print_channel_firing_rate_sd( spif, output_folder )
%UTIL_SCRIPT_PRINT_CHANNEL_FIRING__RATE_SD A Script that prints out PNGs.
%Each of them contains Rate/SD of one individual channel.
%   Input:
%           spif:   Spike information structure
%           output_folder:  Output folder which will contains result PNGs
%
%   Created on Jun/11/2012 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

% Parameters
binwidth = 1000;    % Bin width for calculating SD window / Rate window
bin_int = 150;      % Bin width for calculating rate for SD (we should have smaller bin size to get the SD in binwidth)
gnd = [];           % Grounding
threshold = 0;      % Leave it to 0 to include all electrodes

% Get firing rate
[ ~,~,~,~, rate, ~,~,~ ] = util_calc_rate( spif, 'bin', binwidth, 'gnd', gnd, 'threshold', threshold, 'mode', 'electrode' );

% Get SD from Rate
[ elec_sd ] = util_calc_sd_from_rate( spif, 'bin', binwidth, 'bin_int', bin_int, 'gnd', gnd, 'threshold', threshold );

% PLOT
k = 1;
fig_filename = '';
if output_folder(end) ~= '\'
    output_folder = [output_folder '\'];
end

figure

for i = 1:8
    for j = 1:8
        subplot(2,1,1); plot(rate(:,k)); title('Firing Rate (spikes/s)'); xlabel('Bin'); ylabel('Spikes / s'); set(gca, 'xlim', [0 length(rate(:,k))])
        subplot(2,1,2); plot(elec_sd(:,k)); title('SD of Rate'); xlabel('Bin'); ylabel('SD'); set(gca, 'xlim', [0 length(rate(:,k))])
        fig_filename = [output_folder 'ch' num2str(util_convert_hw2ch(k)) '.png'];
        export_fig(fig_filename, '-png');
        k = k + 1;
    end
end

end

