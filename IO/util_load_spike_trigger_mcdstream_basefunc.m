function [ D spif triggerif ] = util_load_spike_trigger_mcdstream_basefunc ( varargin )
%UTIL_LOAD_SPIKE_TRIGGER_MCDSTREAM_BASEFUNC Load spike and/or trigger stream from
%MCD data file. Using MCINTFAC
%   The procedure is based on MCINTFAC(datastrm), therefore only works on
%   Win32 Matlab.
%
%   The procedure can be used separatedly, or, it can be called by
%   util_load_spike_trigger_mcdstream for used in 32/64 mixed environment
%
%   Input:
%           filename:   The MCD datafile path. [default: '' pops up a dialog]
%           segment_size:   This parameter changes the segmentation
%                           behavior of this program. The segmentation
%                           process is designed to avoid "OUT OF MEMORY" by
%                           reading the data separately. [default: 60000 in
%                           ms]
%           isCompact:      Set this to true to delete spike values but leave
%                           only the peak values (Max & Min). [default: true]
%           startend:       If you want to read only a part of the file, use
%                           this to set the time period. (in ms.) [default: all timepoints] 
%           dispFilename:   Set this to true to display filename while
%                           processing. [default: true].
%
%   Output:
%           D:          Datastrm Object
%           spif:       Spike information structure
%           triggerif:  Trigger information structure
%
%   Example:
%           [d spif trif] = util_load_spike_trigger_mcdstream('isCompact', 1)
%
%
%   Created on May/31/2009 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2009-06-15  Added the segmentation reading functionality.
%       PJB#2009-06-17  Improved the segmentation function. Partly get rid
%                       of the OUT OF MEMORY error.
%                       Using PVPMOD to accept default settings of the
%                       program.
%                       Added waitbar as progress indicator.
%       PJB#2009-06-23  Added 'startend', so user can specify a time period
%                       region.
%                       Changed the function name, no more "_whole_length"
%       PJB#2009-06-26  Fixed BUG: Errors while don't gives 'isCompact'
%                       parameter.
%       PJB#2009-07-03  Fixed BUG: The program ignores 'isCompact' while
%                       'segment_size' is set to false.
%       PJB#2009-12-26  Fixed BUG: The program mistakenly *1000 twice to
%                       the time region. (already in ms, but mistakenly
%                       thinks they are in us.)
%       PJB#2010-05-07  Fixed BUG: Removed redundance information - caused
%                       by evalc.
%       PJB#2010-05-13  Fixed BUG: The program reads several more
%                       milliseconds of data at the end of the file -
%                       caused by the buggy segementation function.
%                       Added tips when the provided file don't have
%                       trigger datastream.
%       PJB#2010-07-15  Now 'isCompact' is set to 1 by default.
%       PJB#2010-07-23  Improved progress bar. Quicker and use less
%                       resource and don't need windows environment.
%       PJB#2010-09-07  Changed the way of the program to exist while it
%                       cannot find a spike stream. This will do good to
%                       the batch process.
%       PJB#2012-07-05  Removed 'cprintf' to improve compatibility
%       PJB#2012-09-15  Removed 'warn', now use disp.
%                       Added filename and path display while processing.
%       PJB#2012-09-26  Fixed BUG: Some notification message texts.
%       PJB#2012-10-05  Finished comments in English.

pvpmod(varargin);

if exist('filename', 'var')
    [~] = evalc('D = datastrm(filename)');
else
    [~] = evalc('D = datastrm(''open'')');
end

if isempty(D)
    error('A MCD file must be selected.');
end

if ~exist('isCompact', 'var')
    isCompact = 1;
end

if ~exist('dispFilename', 'var')
    dispFilename = 1;
end

% Start End
if exist('startend', 'var')
    start_time = startend(1); % ms
    stop_time = startend(2);  % ms
        
    if start_time < getfield(D, 'sweepStartTime')
        disp('Start time must be bigger than sweepStartTime, is automatically set to sweepStartTime.');
        start_time = getfield(D, 'sweepStartTime');
    end
    if stop_time > getfield(D, 'sweepStopTime');
        disp('Stop time must be smaller than sweepStopTime, is automatically set to sweepStopTime.');
        stop_time = getfield(D, 'sweepStopTime');
    end
else
    start_time = getfield(D, 'sweepStartTime');
    stop_time = getfield(D, 'sweepStopTime');
end

% Display File Info
if dispFilename
    disp(getfield(D, 'filename'))
end
disp(['Start: ' datestr(getfield(D, 'recordingdate')) ', Stop: '  datestr(getfield(D, 'recordingStopDate')) ', Length: ' num2str(getfield(D, 'sweepStopTime')) ' ms.']);

% Read datastream
% Find SPIKE STREAM
[stream_number spike_streamname] = util_find_spikestream(D);
if stream_number < 1
    warning('UTIL:FILEERR','No spike stream is detected. File ignored.');
    % We don't use error here, because that may cause the batch process
    % exit unexpectedly.
    D = []; spif = []; triggerif = [];
    return;
elseif stream_number > 1
    % More than one SPIKE STREAM
    % Listing the names of all spike streams, Let the user decide.
    for i = 1:stream_number
        disp(spike_streamname{i});
    end
    user_entry = input('Please select a spike stream by number: ');
    
    spike_streamname_selected = spike_streamname{user_entry};
else
    spike_streamname_selected = spike_streamname{1};
end

% Find Trigger stream
[stream_number trigger_streamname] = util_find_triggerstream(D);
if stream_number < 1
    disp('No trigger stream is detected.');
elseif stream_number > 1
    % More than one TRIG STREAM
    % Listing the names of all trigger streams, Let the user decide.
    for i = 1:stream_number
        disp(trigger_streamname{i});
    end
    user_entry = input('Please select a trigger stream by number: ');
    
    trigger_streamname_selected = trigger_streamname{user_entry};
else
    trigger_streamname_selected = trigger_streamname{1};
end    

% If we arrived here, we have got the names of spike and trigger stream,
% and they are stored in
% spike_streamname_selected & trigger_streamname_selected

% Now we try to get SPIF & TRIGGERIF

% Determine how long the stream is
if exist('segment_size', 'var')
    limited_size = segment_size;
else
    limited_size = 60000; % 1min
end

if (stop_time - start_time) > limited_size;
    % The data segment is too long to get it all for one time, we read it
    % separately and connect into one.
    
    % Process SPIKE stream
    fprintf('Processing spike data...');
    
    % Init the SPIF structure, please note, the {} around cell() is
    % important.
    spif = struct('spiketimes', {cell(64,1)}, 'spikevalues', {cell(64,1)}, 'startend', [start_time stop_time]);
    
    % First we loop into the segments which have complete length (divided
    % by limited_size)
    for i = start_time:limited_size:stop_time
        spif_segment = nextdata(D, 'streamname', spike_streamname_selected, 'startend', [i i+limited_size]);
        spif.spiketimes = util_connect_spif_spiketimes(spif.spiketimes, spif_segment.spiketimes);
        % If isCompact, the spikevalue table will be compressed (currently,
        % we will only leave the MAX/MIN values in the table)
        if (isCompact)
            spif_segment.spikevalues = util_compact_spif_spikevalues(spif_segment.spikevalues);
        end
        spif.spikevalues = util_connect_spif_spikevalues(spif.spikevalues, spif_segment.spikevalues);
        
        if ~mod(i, 50000)
            util_show_progress_rounding(100 * i/(stop_time - start_time));
        end
        clear spif_segment;
    end
    % close(h);
    util_show_progress_rounding(100);
    fprintf('\n');
    
    % Process TRIGGER stream
    % The stream_number is used in counting the number of spif/trif
    % streams, but the last time we used it is to count the number of
    % trigger streams. Therefore, it stores the number of trigger streams.
    if stream_number < 1
        triggerif = NaN;
    else
        fprintf('Processing trigger data...');

        % Init the TRIF structure
        triggerif = struct('times', [], 'values', [], 'startend', [start_time stop_time]);
        
        % First we loop into the segments which have complete length (divided
        % by limited_size)
        for i = start_time:limited_size:stop_time
            trif_segment = nextdata(D, 'streamname', trigger_streamname_selected, 'startend', [i i+limited_size]);
            triggerif.times = [triggerif.times trif_segment.times];
            triggerif.values = [triggerif.values trif_segment.values];
            
            if ~mod(i, 50000)
                util_show_progress_rounding(100 * i/(stop_time - start_time));
            end
            clear trif_segment;
        end
        % close(h);
        util_show_progress_rounding(100);
        fprintf('\n');
    end
else
    % Read it normally
    spif = nextdata(D,'streamname', spike_streamname_selected,'startend',[start_time stop_time]);   
    
    % If isCompact, the spikevalue table will be compressed (currently,
    % we will only leave the MAX/MIN values in the table)
    if isCompact
       spif.spikevalues = util_compact_spif_spikevalues(spif.spikevalues);
    end
    
    % To check whether there is a TRIGGER STREAM
    
    % The stream_number is used in counting the number of spif/trif
    % streams, but the last time we used it is to count the number of
    % trigger streams. Therefore, it stores the number of trigger streams.
    if stream_number < 1
        triggerif = NaN;
    else
        triggerif = nextdata(D,'streamname', trigger_streamname_selected,'startend',[start_time stop_time]);        
    end
end

% Display the number of triggers

% The stream_number is used in counting the number of spif/trif
% streams, but the last time we used it is to count the number of
% trigger streams. Therefore, it stores the number of trigger streams.
if stream_number >= 1
    disp(['Triggers: ' num2str(length(triggerif.times))]);
    if (isempty(triggerif.times))
        disp('The file has a trigger stream, but no trigger is detected. \n Maybe you had made a mistake while recording.');
    end
end

end

