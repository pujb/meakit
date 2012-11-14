function [ elecs, nonelecs ] = util_get_active_electrodes( spif, threshold )
%UTIL_GET_ACTIVE_ELECTRODES Get active electrodes by mean firing rate
%   Input:
%           spif:   Spike information structure
%           threshold:  Firing rate per second. (spikes/sec)
%   Output:
%           Elecs:  A list of active electrodes.
%           Nonelecs:  A list of non-active electrodes
%
%   Created on Nov/05/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2012-09-26  Adding non-active electrode list output

elecs = [];
nonelecs = [];
for i = 1:64
    histc_result = histc( spif.spiketimes{i}/1000, 1:1:fix(spif.startend(2)/1000)-1 );
    if mean(histc_result) >= threshold
        elecs = [ elecs util_convert_hw2ch(i)];
    else
        nonelecs = [ nonelecs util_convert_hw2ch(i)];
    end
end


end

