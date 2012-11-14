function [ spif triggerif ] = util_load_spike_trigger_mcdstream_from_multiple_files_basefunc( varargin )
%UTIL_LOAD_SPIKE_TRIGGER_MCDSTREAM_FROM_MULTIPLE_FILES Extract SPIF/TRIF
%from multiple MCD (MultiChannel Systems) files.
%   Note: The function depends on util_load_spike_trigger_mcdstream.m
%
%   The function can extract information from multiple MCD files. According
%   to the given timespan, it can automatically detect files which should
%   be used as input. (The timespan is in the terms of all selected files)
%   
%   While selecting files, the user can select the files in any order, the
%   function will sort the selected files by their recording timestamps.
%
%   Please check the timespans in the outputs of the function.
%
%   The procedure can be used separatedly, or, it can be called by
%   util_load_spike_trigger_mcdstream_from_multiple_files for used in 32/64 mixed environment
%
%   Input:
%
%           filenames:  If provided, the selected filenames in a matrix.
%           isCompact:  If true, the SpikeValues table will be compacted.
%                       [default:1]
%           segment_size:   The size of each segment which the function
%                           will use to read the file separately to avoid
%                           out of memory issue. [default=2000 in ms]
%           startend:   The timespan in [start end] ms. If not provided,
%                       the function will read the whole session.
%           continuous: If true, the function will connect two neighbour
%                       files without considering the actual time
%                       difference between them. In this way, two files in
%                       succession will have no time difference between
%                       them.
%                       If false, the function will add the time
%                       differences according to the actual recording time.
%                       [default: true]
%
%   Output:
%           spif:       Spike information structure.
%           trif:       Trigger information structure.
%
%   Created on Jun/24/2009 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2009-06-27  Fixed BUG: startend_segment_startTotal (changed from < to >=) startend(1).
%       PJB#2009-07-03  Fixed BUG: Now using exist() to determine whether
%                       trif.segment exists.
%       PJB#2009-07-19  Added 'continuous' switch.
%       PJB#2010-05-07  Fixed BUG: The timespan unit is incorrect while
%                       reading multiple files.
%                       Changed the way of displaying information.
%                       Added non-continuous method. Now the 'continuous'
%                       is finally working.
%       PJB#2010-05-19  Fixed BUG: The program did not connect trigger
%                       information structure (TRIF) while connecting two
%                       files.
%       PJB#2011-07-01  Changed the way of displaying information.
%       PJB#2012-07-05  Re-styling output to improve compatiblity.
%       PJB#2012-09-15  Fixed BUG: Improved compatiblity with
%                       util_load_spike_trigger_mcdstream.
%       PJB#2012-10-05  Now the program can automatically process single file
%                       without getting into error and quit.
%       PJB#2012-10-11  Changed comments into English and optimized the
%                       comment format.
%       PJB#2012-11-06  Fixed BUG: Compact mode default settings.

pvpmod(varargin);

% Analyze parameters

if ~exist('continuous', 'var')
    % Set continuous switch to default-1
    disp('The CONTINUOUS mode is on by default.');
    continuous = 1;
end

if ~exist('segment_size', 'var')
    segment_size = 2000;
end

if ~exist('isCompact', 'var')
    isCompact = 1;
end

if isCompact
    disp('The COMPACT mode is on by default.');
end

% Process the filename
if exist('filenames', 'var')
    % If the user has provided a file list then we will do nothing.
else
    % Pop-up a file select dialog
    [filenames pathname index] = uigetfile('*.mcd', 'MultiSelect', 'On');
    
    % Detecting if the user didn't select a file.
    if isequal(filenames,0) || isequal(pathname,0)
        error('At least 1 mcd files should be selected.');
    end
    
    % Detecting if the user only pick up one file.
    if ~iscell(filenames)
        % We should call util_load_spike_trigger_mcdstream
        disp('You have only selected one MCD file, we will call the single file processor for you.');
        disp('Note: If you want datastrm object D, please call util_load_spike_trigger_mcdstream by yourself.');
        disp('<<< Leaving UTIL_LOAD_SPIKE_TRIGGER_MCDSTREAM_FROM_MULTIPLE_FILES ... >>>');
        [~, spif, triggerif] = util_load_spike_trigger_mcdstream('filename', [pathname filenames], varargin{:});
        return;
    end
    
    % Connecting the filename and its path
    num_of_files = size( filenames, 2 );
    filenames_tmp = cell( num_of_files, 2 );   % Col1: Filename, Col2: RecDate
    
    for i = 1:num_of_files
        filenames_tmp{i,1} = [pathname filenames{i}];
    end
    
    filenames = filenames_tmp;
    clear filenames_tmp;
end

% Sort the files by their recording timestamps.
[filenames(:,1) filenames(:,2) isOverlapped] = util_sort_mcdfile_by_rectime( filenames(:,1), num_of_files );

% If in 'continuous' mode, then the lapping between two adjacent files
% could be ignored. The user can read the warning information from the
% output of util_sort_mcdfile_by_rectime
% If not in 'continuous' mode, then the lapping will cause problems while
% connecting two files. We will ask the user which file will be considered
% as a base. If the previous one is the base, then the lappings in the next
% file will be deleted. However, we didn't finish this in the current
% version because we haven't met such condition.
% Now, if such lapping & ~continuous met, we just send out a error and

if ~continuous && isOverlapped
    error('Overlapped mcd files cannot be processed in the mode other than CONTINUOUS.');
end

% Display the file list.
% Loop in the file list and counting sweepTotalTime
sweepTotalTime = 0;
disp(' ');
fprintf('\t------------------\n');
fprintf('\t  MCD File Lists  \n');
fprintf('\t------------------\n');
disp(' ');
for i = 1:num_of_files
    disp(['[' num2str(i) '] ' filenames{i,1}]);
    [~] = evalc('D = datastrm(filenames{i,1})');
    sweepTotalTime = sweepTotalTime + getfield(D, 'sweepStopTime');
    disp(['    Start: ' datestr(filenames{i,2},0) '. Length:' num2str(getfield(D, 'sweepStopTime')) ' ms.']);
    clear D;
end

disp(' ');
fprintf('\t----------------------------\n');
fprintf('\t Individual File Processing \n');
fprintf('\t----------------------------\n');
disp(' ');

% If not in 'continuous' mode, then
% sweepTotalTime = the recording start time of the last file in the list + sweepStopTime
if ~continuous
    [~] = evalc('D2 = datastrm(filenames{end,1})');
    [~] = evalc('D1 = datastrm(filenames{1,1})');
    % Get time T value
    T2 = datevec( addtodate(getfield(D2, 'recordingdate'), getfield(D2, 'sweepStopTime'),'millisecond'));
    T1 = datevec(getfield(D1, 'recordingdate'));
    sweepTotalTime = etime(T2,T1) * 1000;   % etime returns in seconds
    clear D1 D2 T1 T2;
end

% If user provided [start end], then we should check whether the time range
% is valid.
if ~exist('startend', 'var')
    % Read the timestamps from the first and the last file
    % 1st File
    [~] = evalc('D = datastrm(filenames{1,1})');
    startend = getfield(D, 'sweepStartTime');
    clear D;
    
    % Total time:
    startend = [startend sweepTotalTime];
else
    % Check if the time range specified by [start end] is in the actual
    % range of files in the list.
    [~] = evalc('D = datastrm(filenames{1,1})');
    
    if startend(1) < getfield(D, 'sweepStartTime')
        startend(1) = getfield(D, 'sweepStartTime');
        warning('StartTime should be bigger than the rec-start-time of the first mcd.');
        util_disp_hyperlink('Resetting StartTime to default.');
    end
    clear D;
    
    if startend(2) > sweepTotalTime
        startend(2) = sweepTotalTime;
        warning('StopTime should be smaller than the rec-stop-time of the last mcd.');
        util_disp_hyperlink('Resetting StopTime to default.');
    end
end

% Determine which files should will be read according to [start end]
startend_segment_endTotal = 0;                          % Used for counting accumulated EndTime
mcdfile_needed_to_be_processed = zeros(num_of_files,1); % File IDs that need to be read
% Init
spif = struct('spiketimes', {cell(64,1)}, 'spikevalues', {cell(64,1)}, 'startend', startend);
triggerif = struct('times', [], 'values', [], 'startend', startend);

for i = 1:num_of_files
    % Read the file timestamp
    [~] = evalc('D = datastrm(filenames{i,1})');
    
    % Get the [start end] position (sweep) of the current file
    startend_segment_startSelf = getfield(D, 'sweepStartTime');
    startend_segment_endSelf = getfield(D, 'sweepStopTime');
    
    % Calculating the position of the current file in the whole sequence.
    % = The [start end] position + offset
    
    % If this is the First file, then the offset = 0;
    if i ~= 1
        if continuous
            % In 'continuous' mode, the offset = the total length of all previous files.
            time_elapsed = startend_segment_endTotal;
        else
            % Not in 'continuous' mode, the offset = the start time of the current file - the start time of the first file
            % 1st File
            [~] = evalc('D1 = datastrm(filenames{1,1})');
            T1 = datevec(getfield(D1, 'recordingdate'));
            % The current file
            T2 = datevec(getfield(D, 'recordingdate'));
            time_elapsed = etime(T2,T1) * 1000; % etime's unit is second.
            clear D1;
        end
    else
        time_elapsed = 0;
    end
    
    % The position of the start time of the current file in the whole sequence
    % (Usually, startend_segment_startSelf = 0)
    
    startend_segment_startTotal = startend_segment_startSelf + time_elapsed;
    
    % The position of the end time of the current file in the whole
    % sequence
    % P.S. startend_segment_endTotal also = The total length of all
    % previous readed file while in the next loop [continuous mode]
    startend_segment_endTotal = startend_segment_endSelf + time_elapsed;
    clear D;
    
    % Determine whether the time span of the current file is needed to be
    % processed.
    if (startend_segment_startTotal > startend(2)) || (startend_segment_endTotal < startend(1))
        % The required STARTTIME is after the current file
        % -OR-
        % The required STOP is before the current file
        % Then the current file is not needed.
        mcdfile_needed_to_be_processed(i) = 0;
    else
        % The current file is needed to be read
        % mcdfile_needed_to_be_processed is a index of the list, it may be
        % returned in future versions of this function.
        mcdfile_needed_to_be_processed(i) = 1;
        [~, mcdname, mcdext] = fileparts(filenames{i,1});
        util_disp_hyperlink(['[' num2str(i) '/' num2str(num_of_files) '] ' mcdname mcdext ' (click to open).'], 'links', pathname);
        
        % Read data stream by calling util_load_spike_trigger_mcdstream.m
        
        % Calculating how long should we read from the current file
        if startend_segment_startTotal >= startend(1)
            % If the required STARTTIME is before the current file, then we
            % read from the beginning of it.
            % Keep startend_segment_startSelf = 0 (not changed)
        else
            % If the required STARTTIME is after the current file, then the
            % startend_segment_startSelf should be changed according to the
            % offset. (If not changed, it will be 0)
            startend_segment_startSelf = (startend(1) - startend_segment_startTotal) + startend_segment_startSelf;
        end
        
        if startend_segment_endTotal <= startend(2)
            % If the required STOPTIME is after the current file, then we
            % read until the end of if.
            % Keep startend_segment_endTotal not changed.
        else
            % If the required STOPTIME is before the current file, then we
            % need to change startend_segment_endSelf according to the
            % offset.
            startend_segment_endSelf = (startend(2) - startend_segment_endTotal) + startend_segment_endSelf;
        end
        
        [~, spif_segment trif_segment] = util_load_spike_trigger_mcdstream(...
            'filename', filenames{i,1}, ...
            'isCompact', isCompact, ...
            'segment_size', segment_size, ...
            'startend', [startend_segment_startSelf startend_segment_endSelf], ...
            'dispFilename', 0);
        
        % Connect the current data segment to the previous segments (SPIF & TRIF)
        % Check if we have the important SPIF data
        if isempty(spif_segment)
            disp('>>> NOTE: We have an empty spike information structure in this file.');
            continue;
        end
        spif.spiketimes = util_connect_spif_spiketimes(spif.spiketimes, spif_segment.spiketimes, 'auto_extend', startend_segment_startTotal);
        spif.spikevalues = util_connect_spif_spikevalues(spif.spikevalues, spif_segment.spikevalues);
        
        % Check if we have TRIF
        if isfield(trif_segment,'times')
            triggerif.times = [triggerif.times trif_segment.times];
            triggerif.values = [triggerif.values trif_segment.values];
        end
    end
end
end

