function [ sum_e mean_e sem_e ] = util_calc_energy( spif, chlist, active_thres )
%UTIL_CALC_ENERGY Calculate the neural energy from spike trains
%   Input:
%           spif:   Spike information structure (must be converted)
%           chlist: 'all' / [11 22 ... 88]
%                   if = 'all', all electrodes will be calc.
%           active_thres: Active channel threshold (if you dont want a
%                         threshold, set to 0), unit: spikes/sec
%   Output:
%           if chlist = 'all',
%               sum/mean/sem of all electrodes
%           else
%               sum/mean/sem of selected electrode(s)
%
%   Created on Nov/05/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

% Check spif (if the amplitude is converted)
if (~isfield(spif, 'amp_converted') || ~spif.amp_converted)
    error('Note: The amplitudes in the spif have not been correctly converted to the actual values.');
end

% Check chlist then convert it into hw format
if ischar(chlist)
    if strcmpi(chlist, 'all')
        chlist = (1:64);
    else
        error('Wrong format of CHLIST.');
    end
else
    chlist = util_convert_ch2hw(chlist);
end

e = [];
for i = 1:length(chlist)
    curr_ch = spif.spikevalues{chlist(i)};
    % Check if empty channel
    if size(curr_ch, 2) < 1
        continue;
    end
    % Check active channel thresholding
    if active_thres ~= 0
        histc_result = histc( spif.spiketimes{chlist(i)}/1000, 1:1:fix(spif.startend(2)/1000)-1);
        if mean(histc_result) < active_thres
            continue;
        end
    end
    
    curr_amp = curr_ch(1, :) - curr_ch(2, :);
    curr_e = curr_amp.^2;
    e = [e curr_e];
end

sum_e = sum(e);
mean_e = mean(e);
sem_e = util_calc_sem(e);

end

