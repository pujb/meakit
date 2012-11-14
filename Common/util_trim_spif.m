function spif = util_trim_spif( spif, starttime, stoptime, varargin )
%UTIL_TRIM_SPIF Trim Spif into a small segment.
%   Input:
%       spif:       Spike Information Structure
%       starttime:  Spif START time (ms).
%       stoptime:   Spif STOP time (ms).
%       startzero:  1: if start zero
%                   0: if start from START time [default]
%       nospv:      1: Delete spikevalues from spif
%                   0: Default
%
%   Created on May/16/2011 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2011-05-17  Adding 'startzero' / 'nospv'
%                       'nospv' is useful while dealing with MODEL results.
%                       'startzero' is useful while plotting.


% Check parameter
pvpmod(varargin);

if ~exist('startzero', 'var')
    startzero = 0;
end

if ~exist('nospv', 'var')
    nospv = 0;
end

if starttime < spif.startend(1)
    starttime = spif.startend(1);
    disp('START time is not correct, automatically fixed.');
end
if stoptime > spif.startend(2)
    stoptime = spif.startend(2);
    disp('STOP time is not correct, automatically fixed.');
end

if startzero
    % The new SPIF will start from 0
    for i = 1:length(spif.spiketimes)
        tmp_spt = spif.spiketimes{i};
        if ~nospv
            % Delete the spike values whose spike timing is not exist
            tmp_spv = spif.spikevalues{i};
            tmp_spv(:, tmp_spt < starttime | tmp_spt > stoptime) = [];
            spif.spikevalues{i} = tmp_spv;
        end
        % Delete spike timings
        tmp_spt(tmp_spt < starttime | tmp_spt > stoptime) = [];
        % Change spike timings according to 0
        spif.spiketimes{i} = tmp_spt - starttime;
    end
    % Mark new startend
    spif.startend = [0 stoptime - starttime];
else
    % The new SPIF will start from START time
    for i = 1:length(spif.spiketimes)
        tmp_spt = spif.spiketimes{i};
        if ~nospv
            % Delete the spike values whose spike timing is not exist
            tmp_spv = spif.spikevalues{i};
            tmp_spv(:, tmp_spt < starttime | tmp_spt > stoptime) = [];
            spif.spikevalues{i} = tmp_spv;
        end
        % Delete spike timings
        tmp_spt(tmp_spt < starttime | tmp_spt > stoptime) = [];
        spif.spiketimes{i} = tmp_spt;
    end
    % Mark new startend
    spif.startend = [starttime stoptime];
end

end

