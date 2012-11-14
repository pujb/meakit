function [ matrix ] = util_calc_corr_matrix( spif, gnds, varargin)
%UTIL_CALC_CORR_MATRIX Calculate peak correlation values between channel pairs in the
%array.
%   Input:
%           spif:   Spike information structure.
%           gnds:   Grounding electrodes. [15 28]
%           threshold:
%                   default = 0 spikes/second of each channel, you can set
%                   a value bigger than 0 to exclude some in-activated
%                   channel.
%           method: default = cc-xcorr
%                   'cc-hist', using cross-correlation histogram. it's asymmetric.
%                   'cc-xcorr', using cross-correlation function. it's symmetric. 
%                   'migram',   using mutual information(migram). it's symmetric.
%                   'nmi',   using mutual information(nmi). it's symmetric and quick, but less accurate. 
%                   'sync',  using synchrony. it's symmetric, and very slow.
%           bin:    binwidth, default = 1 ms;
%           window: i.e. nlag, [-window +window], default = 100 ms;
%   Explain:
%           Asymmetric, means the values between a & b is different from b & a.
%           Symmetric, we will only calculate once, then copy the value to its symmetric pair.
%   Output:
%           matrix: The correlation matrix of the array. (in chen's program, this is called CCPeak)
%           
%
%   Created on Mar/27/2011 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2011-03-28  Adding 'cc-hist'/'cc-xcorr'/'migram'/'nmi' switch.
%       PJB#2011-04-03  Adding 'sync' switch.
%       PJB#2011-04-12  Bug fix: Don't reset matlabpool every time.
%       PJB#2011-05-16  Bug fix: Remove the hardcoding of electrode numbers

pvpmod(varargin);

if ~exist('threshold', 'var')
    threshold = 0;
end

if ~exist('method', 'var')
    method = 'cc-xcorr';
end

if ~exist('bin', 'var')
    bin = 1;
end

if ~exist('window', 'var')
    window = 100;
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
num_unit = length(spif.spiketimes);
matrix = zeros(num_unit, num_unit, 'double');

% Matlabpool
% If we didn't start multiple workers, start them now
if matlabpool('size') == 0
    matlabpool;
end
    
progress = 0; total_progress = num_chlist;
fprintf('Calculating correlations... '); tic;

if strcmpi(method, 'cc-hist')
    % Main loop
    for i = 1:num_chlist
        hwid_i = chlist_hwid(i);
        chid_i = chlist(i);
        % Asymmetric

        % To use parfor: we need to use special grammar.
        % First get the results, then arrange them.
        % Note: Matlab will not disturb []'s sequence in parfor
        mytemp = [];
        parfor j = 1:num_chlist
            % hwid_j = chlist_hwid(j);
            if i == j
                % auto
                % matrix(hwid_i,hwid_j) = 1;
                mytemp = [mytemp 1];
                continue;
            end
            [~, cch] = util_calc_raw_spont_cch('spif',spif,'ref',chid_i,'obs',chlist(j),'bin',bin,'nlag',window,'normalization','prob','findpeakw',0,'verbose',0,'method','histc');
            % matrix(hwid_i,hwid_j) = max(cch);
            mytemp = [mytemp max(cch)];
        end
        % Rearrange
        for j = 1:num_chlist
            hwid_j = chlist_hwid(j);
            matrix(hwid_i,hwid_j) = mytemp(j);
        end
        % Show progress
        progress = progress + 1;
        util_show_progress_rounding(100 * progress / total_progress);
    end
elseif strcmpi(method, 'cc-xcorr')
    % Main loop
    for i = 1:num_chlist
        hwid_i = chlist_hwid(i);
        chid_i = chlist(i);
        % Symmetric, like this:
        % 1 1 1
        % 0 1 1
        % 0 0 1

        % To use parfor: we need to use special grammar.
        % First get the results, then arrange them.
        % Note: Matlab will not disturb []'s sequence in parfor
        mytemp = [];
        parfor j = i:num_chlist
            % hwid_j = chlist_hwid(j);
            if i == j
                % auto
                % matrix(hwid_i,hwid_j) = 1;
                % mytemp(hwid_j) = 1;
                mytemp = [mytemp 1];
                continue;
            end
            [~, cch] = util_calc_raw_spont_cch('spif',spif,'ref',chid_i,'obs',chlist(j),'bin',bin,'nlag',window,'findpeakw',0,'verbose',0,'method','xcorr');
            % matrix(hwid_i,hwid_j) = max(cch);
            mytemp = [mytemp max(cch)];
        end
        % Rearrange
        for j = i:num_chlist
            hwid_j = chlist_hwid(j);
            matrix(hwid_i,hwid_j) = mytemp(j-i+1);
            matrix(hwid_j,hwid_i) = mytemp(j-i+1);
        end
        % Show progress
        progress = progress + 1;
        util_show_progress_rounding(100 * progress / total_progress);
    end
elseif strcmpi(method, 'migram')
    % Main loop
    for i = 1:num_chlist
        hwid_i = chlist_hwid(i);
        chid_i = chlist(i);
        % Symmetric, like this:
        % 1 1 1
        % 0 1 1
        % 0 0 1
        
        % To use parfor: we need to use special grammar.
        % First get the results, then arrange them.
        % Note: Matlab will not disturb []'s sequence in parfor
        mytemp = [];
        parfor j = i:num_chlist
            % hwid_j = chlist_hwid(j);
            if i == j
                % auto
                % matrix(hwid_i,hwid_j) = 1;
                % mytemp(hwid_j) = 1;
                mytemp = [mytemp 1];
                continue;
            end
            [~, cch] = util_calc_raw_spont_cch('spif',spif,'ref',chid_i,'obs',chlist(j),'bin',bin,'nlag',window,'findpeakw',0,'verbose',0,'method','migram');
            % matrix(hwid_i,hwid_j) = max(cch);
            mytemp = [mytemp max(cch)];
        end
        % Rearrange
        for j = i:num_chlist
            hwid_j = chlist_hwid(j);
            matrix(hwid_i,hwid_j) = mytemp(j-i+1);
            matrix(hwid_j,hwid_i) = mytemp(j-i+1);
        end
        % Show progress
        progress = progress + 1;
        util_show_progress_rounding(100 * progress / total_progress);
    end
elseif strcmpi(method, 'nmi')
    % Main loop
    for i = 1:num_chlist
        hwid_i = chlist_hwid(i);
        chid_i = chlist(i);
        % Symmetric, like this:
        % 1 1 1
        % 0 1 1
        % 0 0 1
        
        % To use parfor: we need to use special grammar.
        % First get the results, then arrange them.
        % Note: Matlab will not disturb []'s sequence in parfor
        mytemp = [];
        parfor j = i:num_chlist
            % hwid_j = chlist_hwid(j);
            if i == j
                % auto
                % matrix(hwid_i,hwid_j) = 1;
                % mytemp(hwid_j) = 1;
                mytemp = [mytemp 1];
                continue;
            end
            [~, cch] = util_calc_raw_spont_cch('spif',spif,'ref',chid_i,'obs',chlist(j),'bin',bin,'findpeakw',0,'verbose',0,'method','mi');
            % matrix(hwid_i,hwid_j) = max(cch);
            mytemp = [mytemp cch];
        end
        % Rearrange
        for j = i:num_chlist
            hwid_j = chlist_hwid(j);
            matrix(hwid_i,hwid_j) = mytemp(j-i+1);
            matrix(hwid_j,hwid_i) = mytemp(j-i+1);
        end
        % Show progress
        progress = progress + 1;
        util_show_progress_rounding(100 * progress / total_progress);
    end
elseif strcmpi(method, 'sync')
    % Main loop
    for i = 1:num_chlist
        hwid_i = chlist_hwid(i);
        chid_i = chlist(i);
        % Symmetric, like this:
        % 1 1 1
        % 0 1 1
        % 0 0 1
        
        % To use parfor: we need to use special grammar.
        % First get the results, then arrange them.
        % Note: Matlab will not disturb []'s sequence in parfor
        mytemp = [];
        parfor j = i:num_chlist
            % hwid_j = chlist_hwid(j);
            if i == j
                % auto
                % matrix(hwid_i,hwid_j) = 1;
                % mytemp(hwid_j) = 1;
                mytemp = [mytemp 1];
                continue;
            end
            Q = util_calc_synchrony( spif, [chid_i chlist(j)], 'method', 'single' );
            % matrix(hwid_i,hwid_j) = max(cch);
            mytemp = [mytemp Q];
        end
        % Rearrange
        for j = i:num_chlist
            hwid_j = chlist_hwid(j);
            matrix(hwid_i,hwid_j) = mytemp(j-i+1);
            matrix(hwid_j,hwid_i) = mytemp(j-i+1);
        end
        % Show progress
        progress = progress + 1;
        util_show_progress_rounding(100 * progress / total_progress);
    end
else
    error('wrong input - method');
end

% disp 'done'
t = fix(toc);
util_show_progress_rounding(100);
fprintf('Calculation used ~ %d seconds.\n', t);
    
% Close pool
% matlabpool close;

end

