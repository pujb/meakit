function [ locations sizes lengths vectors network_vectors seq sizes_spk sizes_amp] = util_detect_avalanche( spif, gnds, varargin )
%UTIL_DETECT_AVALANCHE Detecting the neural avalanches
%   For the detailed algorithm, please refer to Begg's paper (2003, JNS)
%   Input:
%           spif:        Spike information structure
%           gnds:        Grounding electrodes
%           binwidth:    [default]: 4 ms, as defined in Begg's papers
%           active_ch_threshold:  [default]: 0, to determine the active
%                        channels when generating the initial bin sequence.
%                        Channels whose mean rate > this (>= this, when it = 0).
%                        will be selected into the sequence, otherwise, they
%                        will be excluded. (like gnds)
%           method_size: 'unique' [default] / 'repetitive' 
%                        'unique': the size of avalanche is the the number of 
%                                electrodes being active at least once
%                                inside an avalanche.
%                        'repetitive': the total number of active electrodes within
%                                an avalanche, taking into account multiple
%                                activations of the same electrodes.
%                        Defined by Neuroscience 153 (2008) 1354¨C1369
%           calc_amp:    'none' [default]: Don't do the sizes of amplitude
%                               because it is very slow. sizes_amp will be
%                               [].
%                        'sum-p2p':  Sum all peak-to-peak values in each
%                                    avalanche.
%                        'mean-p2p': Average all peak-to-peak values in
%                                    each avalanche.
%                        'sum-peak': Sum all abs(lowest peaks) in each
%                                    avalanche.
%                        'mean-peak':Average all abs(lowest peaks) in each
%                                    avalanche.
%                        Note: The lowest peaks are the second row in the
%                        spike values table, which means the spif must be a
%                        compacted spif (first row: the largest value,
%                        second row: the lowest value.)
%   Output:
%           locations:   In bins, the locations of detected avalanches,
%                        acturally, we locate them at the blank frame
%                        before the first frame of an avalanche.
%           sizes:       The sizes of detected avalanches (electrodes - 'unique' or 'repetitive')
%           sizes_spk:   The sizes of detected avalanches (summed number of spikes)
% NOT READY - sizes_amp:   The sizes of detected avalanches (summed amplitude of spikes)  
%           lengths:     The lengths of detected avalanches
%           vectors:     N(number of avalanches) * (64 - 4 - num_gnd), the detailed frames.
%           network_vectors: The time sequence of spike firings used in
%                        detection. (useful for following calculation).
%           seq:         Electrode sequence (hwid), e.g.
%                        seq(network_vectors(:,bin)) = electrodes in 'bin'
%
%   Examples:
%           [ locations sizes lengths vectors ] = util_detect_avalanche(
%           spif, [15] );
%               
%           [ locations sizes lengths vectors network_vectors seq spks
%           amps] = util_detect_avalanche( spif, [28], 'method_size',
%           'repetitive', 'calc_amp', 'none');
%
%   Created on Jul/31/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2010-09-15  Double check the algorithm and do bug fixes.
%                       Add 'method_size' option.
%       PJB#2010-09-17  Add 'sizes_spk' output.
%       PJB#2010-09-18  Add 'sizes_amp' output.
%                       Add 'calc_amp' option to calc different modes of
%                       spike amplitudes into the avalanche statistic.
%       PJB#2011-03-07  Fix the performance issue, now is 880% faster, by
%                       using a different pattern to store "vectors"
%       PJB#2011-03-08  Change the default method to 'unique'
%       PJB#2011-05-16  Fix the hardcoding of electrode numbers (64), now
%                       using num_units (derived from spif).
%       PJB#2011-05-17  Try to speed up by MEX function. But it turns out
%                       that the original M code is the fastest
%                       (MEX/builtin/M).
%       PJB#2012-07-05  Adding outputs of avalanche number


% Analysis parameters
pvpmod(varargin);

if ~exist('binwidth', 'var')
    binwidth = 4;
end

if ~exist('active_ch_threshold', 'var')
    active_ch_threshold = 0;
end

if ~exist('method_size', 'var')
    method_size = 'unique';
end

if ~exist('calc_amp', 'var')
    calc_amp = 'none';
end

% Check spif
if (~isfield(spif, 'amp_converted') || ~spif.amp_converted) && ~strcmp(calc_amp, 'none')
    error('Note: The amplitudes in the spif have not been correctly converted to the actual values.');
end

% Calculate the network vector
fprintf('Parsing bins... '); tic;
[ network_vectors seq ] = util_calc_network_vector( spif, gnds, 'only_activ_ch', true, 'threshold', active_ch_threshold, 'bin', binwidth); t = fix(toc);
fprintf(' Done ~ %d seconds\n', t);

% Find active frames
num_units = length(spif.spiketimes);
num_bins = size(network_vectors, 2);
summed_activity = sum(network_vectors, 1);
% For speed concern, active bins is much fewer than blanked bins
active_framebins = find(summed_activity > 0);

% Check if there is no active frames
if isempty(active_framebins)
    error('No active frames.');
end

locations = [];
sizes = [0];    % size(1) is reserved for the following calculation of sizes
sizes_spk = [0];
sizes_amp = [0];
lengths = [];
vectors = {};

% Check if there is only 1 avalanche
% We check here to simplify the logic of the following codes
if isempty(sub_find_not_continued_point(active_framebins, 1))
    % All active_framebins are continous
    % Check if there are blank frames befroe and after this sequence
    if active_framebins(1) == 1 || active_framebins(end) == num_bins
        error('There is 1 candidate, but it is not surrounded by blank frames.');
    else
        disp('Only 1 avalanche');
        locations = active_framebins(1);
        lengths = active_framebins(end) - active_framebins(1) + 1;
        
        electrodes_list = [];   % Store all active electrodes in the current avalanche
        amplitude_list = [];    % Store all amplitudes in the current avalanche
        current_vector = cell(1, length(active_framebins));    % Prealloc the vector for performance issue
        for i = 1:length(active_framebins)
            % Recording the participation of electrodes in the current bin
            % The following line is the old slow version, but they work the same
            % vectors{1, i} = util_convert_hw2ch((seq(network_vectors(:, active_framebins(i)) > 0)));
            current_vector{i} = util_convert_hw2ch((seq(network_vectors(:, active_framebins(i)) > 0)));
            % Calculating electrodes involved in the current bin
            electrodes_list = [electrodes_list vectors{1, i}];
            % Calculating summed spike counts in the current bin
            sizes_spk(1) = sizes_spk(1) + sum(network_vectors(:, active_framebins(i)));
            
            % Amplitudes
            if strcmpi(calc_amp, 'none')
                % Do nothing
            elseif strcmpi(calc_amp, 'sum-p2p') || strcmpi(calc_amp, 'mean-p2p')
                % Calculating peak-to-peak spike amplitudes in the current bin
                for hwid = 1:num_units
                    % Get the max peaks and min peaks in the current bin and
                    % current electrode, calc Peak to peak amplitudes
                    channel_amp = spif.spikevalues{hwid};
                    channel_spk = spif.spiketimes{hwid} / binwidth;
                    channel_amp = channel_amp(:, channel_spk >= active_framebins(i) & channel_spk < (active_framebins(i) + 1));
                    if ~isempty(channel_amp)
                        amplitude_list = [amplitude_list abs(channel_amp(1,:) - channel_amp(2,:))];
                    else
                        amplitude_list = [amplitude_list 0];
                    end
                end
            elseif strcmpi(calc_amp, 'sum-peak') || strcmpi(calc_amp, 'mean-peak')
                % Calculating absolute spike peak amplitudes in the current bin
                for hwid = 1:num_units
                    % Get the max peaks and min peaks in the current bin and
                    % current electrode, calc Peak to peak amplitudes
                    channel_amp = spif.spikevalues{hwid};
                    channel_spk = spif.spiketimes{hwid} / binwidth;
                    channel_amp = channel_amp(:, channel_spk >= active_framebins(i) & channel_spk < (active_framebins(i) + 1));
                    if ~isempty(channel_amp)
                        amplitude_list = [amplitude_list abs(channel_amp(2,:))];
                    else
                        amplitude_list = [amplitude_list 0];
                    end
                end
            end
        end
        % Setup vector
        vectors{1} = current_vector; 
        % Calculating sizes (of electrodes)
        if strcmpi(method_size, 'repetitive')
            sizes(1) = length(electrode_list);
        elseif strcmpi(method_size, 'unique')
            sizes(1) = length(unique(electrode_list));
        end
        % Calculating amplitudes
        if strcmpi(calc_amp, 'none')
            sizes_amp = [];
        elseif strcmpi(calc_amp, 'sum-p2p') || strcmpi(calc_amp, 'sum-peak')
            sizes_amp(1) = sizes_amp(1) + sum(amplitude_list);
        elseif strcmpi(calc_amp, 'mean-p2p') || strcmpi(calc_amp, 'mean-peak')
            sizes_amp(1) = sizes_amp(1) + mean(amplitude_list);
        end
    end
    
    % Quit
    return;
end

% If arrive here, we should have more than 1 avalanche

% Check if the first active_framebin has 1 blank frame before start
if active_framebins(1) == 1
    % The first active_framebin doesnt have 1 blank frame before start
    % Find the next start point by
    % Finding the first active_framebin after the nearest breakpoint
    breakpoint = sub_find_not_continued_point(active_framebins(1:end), 1);
    
    if isempty(breakpoint)
        % The next avalanche is the only 1 candidate left
        if active_framebins(end) == num_bins
            % The next avalanche doesnt have blank frame after end
            error('There is 1 candidate, but it is not surrounded by blank frames.');
        else
            % The next avalanche is qualified
            % Give the job to the usual routine.
            indexer = breakpoint;
        end
    else
        % The next avalanche is not the only 1 candidate left
        % Give the job to the usual routine.
        indexer = breakpoint;
    end
else
    % The first active_framebin has 1 blank frame before start
    % We will calculate the first avalanche from the first active_framebin
    indexer = 1;
end

% Init
num_ava = 0;    %   We know there must have at least 1 avalanche
sizes = [];
sizes_spk = [];
sizes_amp = [];
fprintf('Locating avalanches... '); tic;
qualified = 0;  %   This flag is used to indicate if the current candidate in the loop is qualified

while indexer <= length(active_framebins)
    % Check if this candidate has blank frames before start
    if (indexer ~= 1 && (active_framebins(indexer) - 1) == active_framebins(indexer - 1)) || (indexer == 1 && active_framebins(indexer) ~= 1)
        % There is no blank frames before this candidate
        qualified = 0;
    else
        % Check if this candidate has blank frames after end
        % Find the start of next avalanche
        breakpoint = sub_find_not_continued_point(active_framebins(indexer:end), 1) + indexer - 1;
        
        if isempty(breakpoint)
            % This candidate is the last candidate
            % Check if it has the blank frame after
            if active_framebins(end) == num_bins
                % No, the last active_framebin is actually the last bin
                qualified = 0;
            else
                qualified = 1;
            end
        else
            % Because we can find the breakpoint (the start of next avalanche)
            % It means this candidate will end by a blank framebin
            qualified = 1;
        end
    end
    
    % Check if this candidate is qualified
    if qualified
        % Increase count
        num_ava = num_ava + 1;
        sizes = [sizes 0];
        sizes_spk = [sizes_spk 0];
        sizes_amp = [sizes_amp 0];
    else
        % Prepare the next loop
        % Check if this candidate is the last candidate
        breakpoint = sub_find_not_continued_point(active_framebins(indexer:end), 1) + indexer - 1;
        
        if isempty(breakpoint)
            % This candidate is the last candidate
            % Quit loop
            break;
        else
            % This candidate is not the last candidate, locate indexer to
            % the next candidate
            indexer = breakpoint;
            % Go to the next round of loop directly
            continue;
        end
    end
    
    % If arrive here, we have to add this candidate to the avalanche list
    
    % Mark the start of this avalanche
    locations(num_ava) = active_framebins(indexer);
    
    % FIXED: We dont need to find, because the previous lines have done the
    %        job
    % Find the start of next avalanche
    % breakpoint = util_find_not_continued_point(active_framebins(indexer:end), 1, 1, '>') + indexer - 1;
    % FIXED END-->
    
    % Check the breakpoint (if this is the last avalanche)
    if isempty(breakpoint)
        % The current avalanche is the last avalanche, because it last to
        % the end of rest active framebins
        lengths(num_ava) = active_framebins(end) - active_framebins(indexer) + 1;
    else
        % The length of current one =
        % the last active_frame before next candidate - the first active frame + 1;
        lengths(num_ava) = active_framebins(breakpoint - 1) - active_framebins(indexer) + 1;
    end
    
    % Calculating the size, the vector (electrodes in each active framebin)
    
    % Locating the start/end bins
    start_bin = active_framebins(indexer);
    end_bin = active_framebins(indexer) + lengths(num_ava) - 1;

    % Loop to count the size (of electrodes / of spikes / of amplitudes)
    if strcmpi(method_size, 'repetitive')
        % One electrode may be counted multiple times
        amplitude_list = [];    % Store all amplitudes in the current avalanche
        current_vector = cell(1, lengths(num_ava));    % Prealloc the vector for performance issue
        for i = 1:lengths(num_ava)
            current_bin = start_bin + i - 1;
            current_network_vector = network_vectors(:, current_bin);  % Temp use for speeding up
            % Recording the participation of electrodes in the current bin
            % The following line is the old slow version, but they work the same
            % vectors{num_ava, i} = util_convert_hw2ch((seq(network_vectors(:, current_bin) > 0)));
            % vectors{num_ava, i} = util_convert_hw2ch(seq(current_network_vector > 0));
            current_vector{i} = util_convert_hw2ch(seq(current_network_vector > 0));
            
            % Calculating number of electrodes involved in the current bin
            sizes(num_ava) = sizes(num_ava) + length(current_vector{i});
            % Calculating summed spike counts in the current bin
            % The following line is the old slow version, but they work the same
            % sizes_spk(num_ava) = sizes_spk(num_ava) + sum(network_vectors(:, current_bin));
            sizes_spk(num_ava) = sizes_spk(num_ava) + sum(current_network_vector);
            % Amplitudes
            if strcmpi(calc_amp, 'none')
                % Do nothing
            elseif strcmpi(calc_amp, 'sum-p2p') || strcmpi(calc_amp, 'mean-p2p')
                % Calculating peak-to-peak spike amplitudes in the current bin
                for hwid = 1:num_units
                    % Get the max peaks and min peaks in the current bin and
                    % current electrode, calc Peak to peak amplitudes
                    channel_amp = spif.spikevalues{hwid};
                    channel_spk = spif.spiketimes{hwid} / binwidth;
                    channel_amp = channel_amp(:, channel_spk >= current_bin & channel_spk < (current_bin + 1));
                    if ~isempty(channel_amp)
                        amplitude_list = [amplitude_list abs(channel_amp(1,:) - channel_amp(2,:))];
                    else
                        amplitude_list = [amplitude_list 0];
                    end
                end
            elseif strcmpi(calc_amp, 'sum-peak') || strcmpi(calc_amp, 'mean-peak')
                % Calculating absolute spike peak amplitudes in the current bin
                for hwid = 1:num_units
                    % Get the max peaks and min peaks in the current bin and
                    % current electrode, calc Peak to peak amplitudes
                    channel_amp = spif.spikevalues{hwid};
                    channel_spk = spif.spiketimes{hwid} / binwidth;
                    channel_amp = channel_amp(:, channel_spk >= current_bin & channel_spk < (current_bin + 1));
                    if ~isempty(channel_amp)
                        amplitude_list = [amplitude_list abs(channel_amp(2,:))];
                    else
                        amplitude_list = [amplitude_list 0];
                    end
                end
            end
        end
        % Setup vector
        vectors{num_ava} = current_vector;
        % Calculating amplitudes
        if strcmpi(calc_amp, 'none')
            sizes_amp = [];
        elseif strcmpi(calc_amp, 'sum-p2p') || strcmpi(calc_amp, 'sum-peak')
            sizes_amp(num_ava) = sizes_amp(num_ava) + sum(amplitude_list);
        elseif strcmpi(calc_amp, 'mean-p2p') || strcmpi(calc_amp, 'mean-peak')
            sizes_amp(num_ava) = sizes_amp(num_ava) + mean(amplitude_list);
        end
    elseif strcmpi(method_size, 'unique')
        % One electrode will be counted only once (this only affects the sizes (electrodes))
        electrodes_list = [];   % Store all active electrodes in the current avalanche
        amplitude_list = [];    % Store all amplitudes in the current avalanche
        current_vector = cell(1, lengths(num_ava));    % Prealloc the vector for performance issue
        for i = 1:lengths(num_ava)
            current_bin = start_bin + i - 1;
            current_network_vector = network_vectors(:, current_bin);  % Temp use for speeding up
            % Recording the participation of electrodes in the current bin
            % The following line is the old slow version, but they work the same
            % vectors{num_ava, i} = util_convert_hw2ch((seq(network_vectors(:, current_bin) > 0)));
            % vectors{num_ava, i} = util_convert_hw2ch((seq(current_network_vector)));
            current_vector{i} = util_convert_hw2ch(seq(current_network_vector > 0));
            % Temporarily store the list of all the electrodes appear in
            % the this avalanche
            electrodes_list = [electrodes_list current_vector{i}];
            % Calculating summed spike counts in the current bin
            % The following line is the old slow version, but they work the same
            % sizes_spk(num_ava) = sizes_spk(num_ava) + sum(network_vectors(:, current_bin));
            sizes_spk(num_ava) = sizes_spk(num_ava) + sum(current_network_vector);
            % Amplitudes
            if strcmpi(calc_amp, 'none')
                % Do nothing
            elseif strcmpi(calc_amp, 'sum-p2p') || strcmpi(calc_amp, 'mean-p2p')
                % Calculating peak-to-peak spike amplitudes in the current bin
                for hwid = 1:num_units
                    % Get the max peaks and min peaks in the current bin and
                    % current electrode, calc Peak to peak amplitudes
                    channel_amp = spif.spikevalues{hwid};
                    channel_spk = spif.spiketimes{hwid} / binwidth;
                    channel_amp = channel_amp(:, channel_spk >= current_bin & channel_spk < (current_bin + 1));
                    if ~isempty(channel_amp)
                        amplitude_list = [amplitude_list abs(channel_amp(1,:) - channel_amp(2,:))];
                    else
                        amplitude_list = [amplitude_list 0];
                    end
                end
            elseif strcmpi(calc_amp, 'sum-peak') || strcmpi(calc_amp, 'mean-peak')
                % Calculating absolute spike peak amplitudes in the current bin
                for hwid = 1:num_units
                    % Get the max peaks and min peaks in the current bin and
                    % current electrode, calc Peak to peak amplitudes
                    channel_amp = spif.spikevalues{hwid};
                    channel_spk = spif.spiketimes{hwid} / binwidth;
                    channel_amp = channel_amp(:, channel_spk >= current_bin & channel_spk < (current_bin + 1));
                    if ~isempty(channel_amp)
                        amplitude_list = [amplitude_list abs(channel_amp(2,:))];
                    else
                        amplitude_list = [amplitude_list 0];
                    end
                end
            end
        end
        % Setup vector
        vectors{num_ava} = current_vector;
        % Calculating number of electrodes involved in the current bin
        % Each electrode can only counted once (by using unique)
        sizes(num_ava) = sizes(num_ava) + length(unique(electrodes_list));
        % Calculating amplitudes
        if strcmpi(calc_amp, 'none')
            sizes_amp = [];
        elseif strcmpi(calc_amp, 'sum-p2p') || strcmpi(calc_amp, 'sum-peak')
            sizes_amp(num_ava) = sizes_amp(num_ava) + sum(amplitude_list);
        elseif strcmpi(calc_amp, 'mean-p2p') || strcmpi(calc_amp, 'mean-peak')
            sizes_amp(num_ava) = sizes_amp(num_ava) + mean(amplitude_list);
        end
    else
        error(['Not supported method for counting avalanche sizes - ' method_size]);
    end
   
    % Deciding next step
    % Check if this is the last avalanche
    if isempty(breakpoint)
        % Quit loop
        break;
    else
        % Change indexer to the new position
        indexer = breakpoint;
    end
    
    % Progress
    if ~mod(num_ava, 100)
        util_show_progress_rounding(100 * indexer / length(active_framebins));
    end
end

% disp 'done'
t = fix(toc);
util_show_progress_rounding(100);
fprintf('Detecting used ~ %d seconds.\n', t);
disp([num2str(num_ava) ' avalanches detected using ' num2str(binwidth) 'ms window.']);

end


function endp = sub_find_not_continued_point( in_vector, startp )
%SUB_FIND_NOT_CONTINUED_POINT Short version of util_find_not_continued_point
%   Please refer to the full version.
for i = startp:(length(in_vector) - 1)
    if (in_vector(i + 1) - in_vector(i)) > 1
        endp = i + startp;
        return;
    end
end
endp = [];
end
