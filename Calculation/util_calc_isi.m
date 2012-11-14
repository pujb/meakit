function [ isi, seq, ts, mean_isi, std_isi, sem_isi, binedge ] = util_calc_isi( spif, varargin )
%UTIL_CALC_ISI Get inter-spike intervals between selected channels and time
%range.
%   Input:
%           spif:       The spike information structure
%           ch:         If not given, it means all channels except gnds, or
%                       you can provide a list like [28, 87];
%           gnds:       Grounding electrodes.
%           startend:   If not given, it means the whole recording length.
%           network_mode:   If true, all channels in ch(if not given = all
%                           channels) except gnds will be rearranged into
%                           one, and calc the isi. [default:false]
%           normed:     If true, the ISI value will be normalized. This
%                       will only affect isi histogram values: isi.
%                       Note: Not functional while isi_mode = 'vsTime'
%                       [default: false]
%           isi_mode:   'histo' [default] / 'vsTime' / 'loghisto'
%                       @ 'vsTime', this program will also return a
%                       timestamp [isi,seq,timestamp] = util...
%           binedge:    @ 'histo', 'binedge' must be given to generate the
%                       histogram. for example: [default: [0:0.1:%max_isi%]].
%                       at 25 kHz Sampling rate, the minium interval is 0.04
%                       @ 'loghisto', default binedge is logspace(0,%max_isi%,%max_isi%*%bin_per_10%)
%           bins_edge_interval:
%                       Used only @ 'histo' defines the width of each bin.
%                       [default: 0.1] ms.
%           bins_per_log10:
%                       Used only @ 'loghisto', defines how many points
%                       between 10^t ~ 10^(t+1). [default: 20]
%   Please note: all time unit are 'ms'.
%   Output:
%           isi:        @ 'vsTime' ROWS: Time, COLS: Electrodes
%                       @ '*histo' Histogram values
%           binedge:    Return the binedge in use.
%           seq:        Channel sequence.
%           ts:         @ 'vsTime', the timestamp of each isi dot.
%           mean_isi/std/sem_isi.
%
%   Created on Aug/24/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2011-03-05  Now it can provide both ISIunit & ISIarray info
%                       & returns mean_isi.
%       PJB#2012-09-19  Added Normalization function.
%                       Changed the auto-gen method of binedge.
%                       Fixed BUG: Forget to return sem_isi
%                       Added LogISI function.


% Analyze parameter
pvpmod(varargin);

if ~exist('ch', 'var')
    ch = [];
end

if ~exist('gnds', 'var')
    gnds = [];
end

if ~exist('startend', 'var')
    startend = spif.startend;
else
    if startend(1) < spif.startend(1) || startend(2) > spif.startend(2) || startend(1) > spif.startend(2) || startend(2) < spif.startend(1)
        error('Incorrect startend.');
    end
end

if ~exist('network_mode', 'var')
    network_mode = false;
end

if ~exist('isi_mode', 'var')
    isi_mode = 'histo';
end

% if ~exist binedge
% We take care of it in the calculation process.

if ~exist('normed', 'var')
    normed = 0;
end

% CALCULATION
if network_mode
    % Calc network isi
    spiketimes = [];
    isi = [];
    seq = [];
    ts = [];
    for i = 1:64
        chid = util_convert_hw2ch(i);
        if ~isempty(ch)
            % If the user provided a list of selected channels
            % Only selected channels
            if ~util_find_a_in_b(chid, ch)
                continue;
            end
        end
        if ~isempty(gnds)
            % If the user provided a list of not-selected channels
            % Except grouding channels
            if util_find_a_in_b(chid, gnds)
                continue;
            end
        end
        
        % Link into one
        s = spif.spiketimes{i};
        spiketimes = [spiketimes(:); s(:)];
    end
    % Sort
    spiketimes = unique(spiketimes);

    % Calc isi
    diff_spiketimes = diff(spiketimes); % Used commonly
    
    if strcmpi(isi_mode, 'vsTime')
        % ISI vs Time
        isi = diff_spiketimes;
        ts = spiketimes(2:end);   % ts
        binedge = [];
    elseif strcmpi(isi_mode, 'histo')
        % ISI Histogram
        if ~exist('bins_edge_interval', 'var')
            bins_edge_interval = 0.1;
        end
        if ~exist('binedge', 'var')
            binedge = [0:bins_edge_interval:ceil(max(diff_spiketimes))];
        end
        isi = histc(diff_spiketimes, binedge);
        % Normalization
        if normed && sum(isi)
           isi = isi ./ sum(isi); 
        end
        %isi = isi(1:end-1); % The last bin may be not correct
    elseif strcmpi(isi_mode, 'loghisto')
        % Log-ISI Histogram
        if ~exist('bins_per_log10', 'var')
            bins_per_log10 = 20;
        end
        if ~exist('binedge', 'var')
            max_isi = ceil(log10(max(diff_spiketimes)));
            binedge = [0:max_isi:max_isi*bins_per_log10];
        end
        isi = histc(diff_spiketimes, binedge);
        % Normalization
        if normed && sum(isi)
            isi = isi ./ sum(isi);
        end
        %isi = isi(1:end-1); % The last bin may be not correct
    end

    mean_isi = mean(diff_spiketimes);  % mean_isi
    std_isi = std(diff_spiketimes);
    sem_isi = util_calc_sem(diff_spiketimes);
else
    % Calc individual isi
    isi = {};
    mean_isi = [];
    std_isi = [];
    sem_isi = [];
    ts = {};
    seq = [];
    if ~exist('binedge', 'var')
        binedge_not_exist = 1;
        binedge = {};
    end
    % Get the channel list
    for i = 1:64
        chid = util_convert_hw2ch(i);
        if ~isempty(ch)
            % Only selected channels
            if ~util_find_a_in_b(chid, ch)
                continue;
            end
        end
        if ~isempty(gnds)
            % Except grounding channels
            if util_find_a_in_b(chid, gnds)
                continue;
            end
        end
        
        % Add channel sequence
        seq = [seq chid];
        
        % Calc isi
        spiketimes = spif.spiketimes{i};
        spiketimes = spiketimes(spiketimes >= startend(1) & spiketimes <= startend(2));
        diff_spiketimes = diff(spiketimes); % Used commonly
        
        if strcmpi(isi_mode, 'vsTime')
            % ISI vs Time
            isi = [isi; {diff_spiketimes}];
            ts = [ts; {spiketimes(2:end)}];
            binedge = [];
        elseif strcmpi(isi_mode, 'histo')
            % ISI Histogram
            if ~exist('bins_edge_interval', 'var')
                bins_edge_interval = 0.1;
            end
            if binedge_not_exist
                this_binedge = [0:bins_edge_interval:ceil(max(diff_spiketimes))];
                binedge = [binedge; {this_binedge}];    % save it
            else
                this_binedge = binedge;
            end
            this_isi = histc(diff_spiketimes, this_binedge);
            % Normalization
            if normed && sum(this_isi)
                this_isi = this_isi ./ sum(this_isi);
            end
            %this_isi = this_isi(1:end-1);   % The last bin may not correct
            isi = [isi; {this_isi}];
        elseif strcmpi(isi_mode, 'loghisto')
            % Log-ISI Histogram
            if ~exist('bins_per_log10', 'var')
                bins_per_log10 = 20;
            end
            if binedge_not_exist
                max_isi = ceil(log10(max(diff_spiketimes)));
                this_binedge = [0:max_isi:max_isi*bins_per_log10];
                binedge = [binedge; {this_binedge}];    % save it
            else
                this_binedge = binedge;
            end
            this_isi = histc(diff_spiketimes, this_binedge);
            % Normalization
            if normed && sum(this_isi)
                this_isi = this_isi ./ sum(this_isi);
            end
            %this_isi = this_isi(1:end-1);   % The last bin may not correct
            isi = [isi; {this_isi}];
        end
        
        mean_isi = [mean_isi mean(diff_spiketimes)];
        std_isi  = [std_isi std(diff_spiketimes)];
        sem_isi  = [sem_isi util_calc_sem(diff_spiketimes)];
    end
end

end

