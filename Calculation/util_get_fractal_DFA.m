function [DFA_mean DFA_std DFA_sem DFA_list] = util_get_fractal_DFA( spif, gnds, varargin )
%UTIL_GET_FRACTAL_DIM Get the fractal hurst exponent of the array.
%   For details, see also estimate_hurst_exponent
%   Input:
%           spif:       Spike information structure
%           gnds:       Grouding electrodes
%           threshold:
%                       default = 0 spikes/second of each channel, you can set
%                       a value bigger than 0 to exclude some in-activated
%                       channel.
%           binwidth:   binwidth, default = 1 ms.
%           startend:   Start/End time, default = whole length. (unit:ms)
%           method:     'fastdfa'[default]
%                       'fastdfa': using fastDFA
%
%   Note: Those electrodes in [gnds] and didn't pass the threshold will
%         appear in the DFA_list (1*64), but will not be counted while
%         averaging the DFA_mean.
%
%   Output:
%           DFA_mean:    Mean hurst exponent
%           DFA_std/sem.
%           DFA_list:    1*64 vector containing DF for each electrode.
%                      0 means grounding / < threshold
%
%   Created on Apr/07/2011 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

pvpmod(varargin);

if ~exist('threshold', 'var')
    threshold = 0;
end

if ~exist('method', 'var')
    method = 'fastdfa';
end

if ~exist('binwidth', 'var')
    binwidth = 1;
end

if ~exist('startend', 'var')
    startend = [];
end

if isempty(startend)
    start_time = spif.startend(1);
    stop_time = spif.startend(2);
else
    start_time = startend(1);
    stop_time = startend(2);
    if start_time < stop_time || ...
       start_time < spif.startend(1) || ...
       start_time > spif.startend(2) || ...
       stop_time < spif.startend(1) || ...
       stop_time > spif.startend(2)
        error('wrong input - startend');
    end
end

% Thresholding to exclude electrodes
[~, ~, ~, ~, ~, avg] = util_calc_rate(spif, 'gnd', gnds, 'bin', 1000, 'mode', 'electrode');
if threshold == 0
    chlist = util_convert_hw2ch(find( avg>threshold ));
elseif threshold > 0
    chlist = util_convert_hw2ch(find( avg>=threshold ));
else
    error('threshold must >= 0');
end
num_chlist = length(chlist);
% Converting 11-88 to 1-64
chlist_hwid = util_convert_ch2hw(chlist);
disp(['Available active channels: ' num2str(num_chlist)]);

% Init
DFA_mean = [];
DFA_list = zeros(1, 64, 'double');
binedge = start_time:binwidth:stop_time;
% Available counting
available_num = 0;

if strcmpi(method, 'fastdfa')
    % Main loop
    for i = 1:num_chlist
        hwid = chlist_hwid(i);
        
        % Get the data
        channel_data = histc(spif.spiketimes{hwid}, binedge);
        
        DFA_list(hwid) = fastdfa(channel_data);
        DFA_mean = [DFA_mean DFA_list(hwid)];
        available_num = available_num + 1;
    end
else
    error('wrong input - method.')
end

disp(['Counted channels: ' num2str(available_num)])

DFA_std = std(DFA_mean);
DFA_sem = DFA_std / sqrt(available_num);
DFA_mean = mean(DFA_mean);

end

