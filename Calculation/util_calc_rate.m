function [ array_spike_count_per_bin ...
           array_mean_spike_count_per_bin ...
           array_mean_spike_count_per_bin_std ...
           array_mean_spike_count_per_bin_sem ...
           elec_spike_counts_per_bin ...
           elec_spike_counts_per_bin_mean ...
           elec_spike_counts_per_bin_mean_std ...
           elec_spike_counts_per_bin_mean_sem ] = util_calc_rate( spif, varargin )
%UTIL_CALC_RATE Get firing rate from spif
%   Input:
%           spif:   Spike information structure.
%           bin:    Bin width, default = 1000 ms.
%           gnd:    Grounding electrode. default = [].
%                   If you provide [15], it will automatically add four
%                   corner electrodes.
%           threshold: 
%                   if spike per bin of any channel < threshold, the
%                   channel will be removed (not an active channel).
%                   THIS WILL NOT AFFECT THE OUTPUT OF per electrode***
%                   results.
%           mode:
%                   'array' [default] / 'electrode'
%
%   Output:
%           array_spike_count_per_bin:
%                   The total number of spikes per bin of the whole array vs Time.
%           array_mean_spike_count_per_bin:
%                   The mean number of spikes per bin of the whole array vs Time.
%           array_mean_spike_count_per_bin_std/sem.
%                   ...
%           elec_spike_counts_per_bin:
%                   The number of spikes per bin of each electrode vs Time.
%           elec_spike_counts_per_bin_mean:
%                   The mean number of spikes per bin of each electrode
%                   during the whole period.
%           elec_spike_counts_per_bin_mean_std/sem:
%                   STD/SEM of the mean number of spikes per bin of each
%                   electrode during the whole period.
%                
%
%   Created on Jun/17/2009 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2009-07-13  Adding the ability to process four-well MEAs
%       PJB#2010-05-07  FIX: Crashes when the file length < bin width.
%       PJB#2010-08-28  FIX: Crashes when network fires no spikes in one
%                       bin.
%                       CHG: Change name from UTIL_CALC_SPB_AVG to
%                       UTIL_CALC_RATE
%       PJB#2011-05-13  FIX: GND now can be a [].
%                       REMOVE: Fourwell
%                       FIX: Assuming 64 channel, now we can accept any
%                       number of channels.
%                       REWRITE & INTEGRATE: UTIL_CALC_SPB_AVG_ELEC.
%                       FIX: Histc EDGE problem.
%      PJB#2012-06-08   CHG: Renamed internal variable names. 


% Analyzing parameters
pvpmod(varargin);

if ~exist('bin', 'var')
    bin = 1000;
end

if ~exist('mode', 'var')
    mode = 'array';
end

if ~exist('gnd', 'var')
    gnd = [];
end

% Get time range
stop_time = spif.startend(2);
bin_number = floor(stop_time/bin);
if (bin_number < 1)
    error('The bin length is bigger than file length!');
end

% Convert GND to hwid
gnd = util_convert_ch2hw(gnd);

if ~isempty(gnd)
    % Adding default grounding electrodes (corner electrodes)
    % if isempty, then we don't add those electrodes.
    gnd = unique([gnd 1 8 57 64]);
end

% How many units (electrode / neuron)?
num_units = length(spif.spiketimes);
spikes_per_bin_in_each_channel = zeros(bin_number, num_units, 'double');

% Main loop
hwID = 1;
while hwID <= num_units
    % Ignore the excluded channels
    if util_find_a_in_b( hwID, gnd );
        hwID = hwID + 1;
        continue;
    end

    % Count spike number in each bin
    if isempty(spif.spiketimes{hwID})
        spikes_per_bin_in_each_channel(:,hwID) = zeros(bin_number, 1);
    else
        temp = histc( spif.spiketimes{hwID}/bin, 0:1:bin_number );
        spikes_per_bin_in_each_channel(:,hwID) = temp(1:end-1);
    end
    
    hwID = hwID + 1;
end

if strcmpi(mode, 'array')
    % Thresholding
    if exist('threshold', 'var')
        spikes_per_bin_in_each_channel = util_remove_colrow_based_on_mean(spikes_per_bin_in_each_channel, threshold, 'method', 'col');
    end
    
    array_spike_count_per_bin =  sum( spikes_per_bin_in_each_channel, 2 );
    array_mean_spike_count_per_bin = mean( spikes_per_bin_in_each_channel, 2 );
    array_mean_spike_count_per_bin_std = std( spikes_per_bin_in_each_channel, 0, 2 );
    array_mean_spike_count_per_bin_sem = array_mean_spike_count_per_bin_std / sqrt( num_units );
    
    elec_spike_counts_per_bin = [];
    elec_spike_counts_per_bin_mean = [];
    elec_spike_counts_per_bin_mean_std = [];
    elec_spike_counts_per_bin_mean_sem = [];
elseif strcmpi(mode, 'electrode')
    elec_spike_counts_per_bin = spikes_per_bin_in_each_channel;
    elec_spike_counts_per_bin_mean = mean( spikes_per_bin_in_each_channel, 1 );
    elec_spike_counts_per_bin_mean_std = std( spikes_per_bin_in_each_channel, 0, 1 );
    elec_spike_counts_per_bin_mean_sem = elec_spike_counts_per_bin_mean_std / sqrt( bin_number );
    
    array_spike_count_per_bin = [];
    array_mean_spike_count_per_bin = [];
    array_mean_spike_count_per_bin_std = [];
    array_mean_spike_count_per_bin_sem = [];
end

end

