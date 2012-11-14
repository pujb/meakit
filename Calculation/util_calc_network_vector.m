function [ network_vectors seq ] = util_calc_network_vector( spif, excluded_ch, varargin )
%UTIL_CALC_NETWORK_VECTOR Get the network activity vectors
%   Input:
%       spif: Spike information structure.
%       only_activ_ch: If true, only the spike rate > threshold is counted.
%                      [default]: False
%       threshold: Used with only_active_ch, spike rate per second.
%                  [default]: 1(Hz)
%       excluded_ch: Manually exclude electrodes you dont want to count.
%                    e.g. [15 33], 15 is GND;
%       bin: Bin width in milliseconds. [default]: 1000
%   Output:
%       network_vector: The network activity vector.
%       seq:            The channel sequence indexer. This is very
%                       important when you are using only_active_ch.
%                       Because the original channel sequence will BREAKUP.
%                       Therefor, util_convert_ch/hw will not properly
%                       functioned when facing that.
%   
%   Created on Jul/22/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2010-07-27  Adding the ability to output channel sequence
%                       indexer.
%       PJB#2010-07-30  Bugfix: When selecting active channels by the
%                       threshold, when threshold = 0, all channels that
%                       fired will be selected as active channels. If
%                       threshold != 0, all channels whose rate >=
%                       threshold will be selected as active channels.
%       PJB#2011-03-05  Bugfix: Using sparse matrix to support small bin
%                       sizes.
%       PJB#2011-05-16  Bugfix: Remove the hardcoding of total electrode
%                       numbers, and fix the edge problem with histc.
%       PJB#2012-09-14  Bugfix: IMPORTANT!!! Before this fix, only_activ_ch
%                       does not working properly.


% Analyze parameters
pvpmod(varargin);

if ~exist('only_activ_ch', 'var')
    only_activ_ch = false;
end

if only_activ_ch
    if ~exist('threshold', 'var')
        threshold = 1;
    end
end

if ~exist('bin', 'var')
    bin = 1000;
end

% Get the number of electrode / units
num_units = length(spif.spiketimes);

if ~isempty(excluded_ch)
    % If user provides GND electrodes, then we automatically add four
    % corner electrodes to the GND electrode list
    excluded_ch = unique([excluded_ch 11 88 81 18]);
end

% Judge activ_channel
% Why not just use this function to get network vectors?
% Because util_calc_spb_avg_elec() always get a 64*N matrix, the channels
% not activ and channels excluded are set to 0 only. But here we want to
% completely set them to no visible([])
[~, ~, ~, ~, ~, avg] = util_calc_rate(spif, 'gnd', excluded_ch, 'bin', 1000, 'mode', 'electrode');

if only_activ_ch
    % Get how many electrodes matched the critiria
    % Note: Those excluded_ch = 0
    if threshold == 0
        num_electrodes = length(find(avg>threshold));
    else
        num_electrodes = length(find(avg>=threshold));
    end
    
    % Change the excluded_ch to include those not-matched electrodes
    excluded_ch = unique( [excluded_ch util_convert_hw2ch(find(avg<threshold))] );
else
    num_electrodes = num_units - length(excluded_ch);
end

% Init
bin_number = floor(spif.startend(2)/bin);   % Fix histc edge problem
network_vectors = sparse(zeros(num_electrodes, bin_number));
elec = 1;
seq = (1:num_units);   % Sequence Indexer
seq_tobe_removed = [];

% Main loop
for i = 1:num_units
    % Jump the excluded channels
    if util_find_a_in_b( i, util_convert_ch2hw(excluded_ch) );
        seq_tobe_removed = [seq_tobe_removed i];
        continue;
    end
    
    % Count each bin of current electrodes
    histc_result = histc( spif.spiketimes{i}/bin, 0:1:bin_number );
    histc_result = histc_result(1:end-1);   % Fix histc edge problem
    if ~isempty(histc_result)
        network_vectors(elec, :) = histc_result;
    else
        network_vectors(elec, :) = 0;
    end
    
    % increament
    elec = elec + 1;
end

seq(seq_tobe_removed) = []; 

end

