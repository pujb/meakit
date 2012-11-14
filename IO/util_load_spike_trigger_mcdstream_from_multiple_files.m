function [ spif triggerif ] = util_load_spike_trigger_mcdstream_from_multiple_files( varargin )
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
%   This function is a 32/64-bit mixed delegate of
%   util_load_spike_trigger_mcdstream_from_multiple_files_basefunc, please refer to it.
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
%           calling_in_64bit:
%                       The switch is used when the function is called
%                       under 64-bit Matlab environment. If true, the
%                       reading process will be done in a separate
%                       32-bit Matlab process, and return the value to
%                       the function caller. So less information will
%                       be shown. [default: 0 when at 32bit mode, 1 when
%                       at 64bit mode];
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
%       PJB#2012-11-07  Added CALLING_IN_64BIT switch to support 32/64-bit
%                       mixed programming.

% Analyze parameters
pvpmod(varargin);

% Determine the caller environment
if ~exist('calling_in_64bit', 'var')
    if strcmpi(computer, 'PCWIN')
        calling_in_64bit = 0;
    else
        calling_in_64bit = 1;
    end
end

if calling_in_64bit
    % Rebuild the parameter list
    % DO NOT replace SPACE to %SPACE% <== this is done in
    % util_run32bit_matlabfunc.m
    exec_line = '[spif,triggerif]=util_load_spike_trigger_mcdstream_from_multiple_files_basefunc(';
    if exist('filenames', 'var') % is a cell array
        error('We could not support filenames list in 32/64-bit mixed environment, sorry.');
    end
    if exist('segment_size', 'var')
        exec_line = [exec_line, '%$segment_size%$,' num2str(segment_size) ','];
    end
    if exist('isCompact', 'var')
        exec_line = [exec_line, '%$isCompact%$,' num2str(isCompact) ','];
    end
    if exist('startend', 'var')
        exec_line = [exec_line, '%$startend%$,[' num2str(startend(1)) ',' num2str(startend(2)) '],'];
    end
    if exist('continuous', 'var')
        exec_line = [exec_line, '%$continuous%$,' num2str(continuous), ','];
    end
    % Remove last ,
    if exec_line(end)==','
        exec_line = exec_line(1:end-1);
    end
    exec_line = [exec_line ');'];
    [~,spif,triggerif]=util_run32bit_matlabfunc(exec_line);
else
    % Just give the control to util_load_spike_trigger_mcdstream_basefunc
    [spif,triggerif]=util_load_spike_trigger_mcdstream_from_multiple_files_basefunc(varargin{:});
end

end

