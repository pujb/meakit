function [ D spif triggerif ] = util_load_spike_trigger_mcdstream ( varargin )
%UTIL_LOAD_SPIKE_TRIGGER_MCDSTREAM Load spike and/or trigger stream from
%MCD data file. Using MCINTFAC
%   The procedure is based on MCINTFAC(datastrm), therefore only works on
%   Win32 Matlab.
%
%   This function is a 32/64-bit mixed delegate of
%   util_load_spike_trigger_mcdstream_basefunc, please refer to it.
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
%           calling_in_64bit:
%                           The switch is used when the function is called
%                           under 64-bit Matlab environment. If true, the
%                           reading process will be done in a separate
%                           32-bit Matlab process, and return the value to
%                           the function caller. So less information will
%                           be shown. [default: 0 when at 32bit mode, 1
%                           when at 64bit mode];
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
%       PJB#2012-11-07  Added CALLING_IN_64BIT switch to support 32/64-bit
%                       mixed programming.

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
    exec_line = '[d,spif,triggerif]=util_load_spike_trigger_mcdstream_basefunc(';
    if exist('filename', 'var')
        exec_line = [exec_line '%$filename%$,%$' strtrim(filename) '%$,']; 
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
    if exist('dispFilename', 'var')
        exec_line = [exec_line, '%$dispFilename%$,' num2str(dispFilename), ','];
    end
    % Remove last ,
    if exec_line(end)==','
        exec_line = exec_line(1:end-1);
    end
    exec_line = [exec_line ');'];
    [~,D,spif,triggerif]=util_run32bit_matlabfunc(exec_line);
else
    % Just give the control to util_load_spike_trigger_mcdstream_basefunc
    [D,spif,triggerif]=util_load_spike_trigger_mcdstream_basefunc(varargin{:});
end

end

