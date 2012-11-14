function [ total_number_of_electrodes total_number_of_used electrode_list] = util_find_number_of_used_electrodes( spif )
%UTIL_FIND_USED_ELECTRODES Get the number and list of used electrodes.
%Electrodes at the four corners are not used, for example.
%   Input:
%           spif:   Spike information structure.
%   Output:
%           total_number_of_electrodes:     As title.
%           total_number_of_used:           As title.
%                                           If there is no spike in one
%                                           channel, then the channel will
%                                           be marked as not-used(0).
%           electrode_list (HWID):          The list of all elelctrodes in
%                                           HWID. If used, the
%                                           corresponding position will be
%                                           marked as 1, else : 0.
%
%   Created on Oct/21/2009 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

% Get the total number of all electrodes
spif_size = size( spif.spiketimes );
total_number_of_electrodes = spif_size(1);

% Init
total_number_of_used = 0;
electrode_list = zeros(total_number_of_electrodes, 1);

% Loop
for i = 1:total_number_of_electrodes
    if isempty(spif.spiketimes{i})
        % There is no spike in this channel.
        electrode_list(i) = 0;
    else
        electrode_list(i) = 1;
        total_number_of_used = total_number_of_used + 1;
    end
end

end