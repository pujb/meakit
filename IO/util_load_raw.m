function [ rawif ] = util_load_raw( varargin )
%UTIL_LOAD_RAW Get the raw data stream from a data file.
%   Using Neuroshare, the function reads a data file which can be in any
%   format that is supported by Neuroshare and returns the information
%   structure of raw data.
%   Input:
%       filename:   If this is not given, a file open dialog will popup.
%                   [default]: open a dialog.
%
%       startend:   The desired begin/end time of the data stream (ms.)
%                   [default]: total length will be automatically used.
%
%       rawtype:    'elec' - Electrode Raw Data, 'filt' - Filtered Data
%                   [default]: 'elec';
%
%       stream_sn:  The serial number of the stream, index from 1
%                   [default]: 1.
%
%       channel:    e.g. [12 22 32] or 'all'
%                   [default]: 'all'.
%
%       timemode:   'EXACT' or 'REARRANGED'
%                   This parameter will be useful if the user specifics the
%                   'startend'. For example, if the file 'A' contains the
%                   data from 0 ~ 500 ms, and we set the startend to [250
%                   500].
%
%                   In 'EXACT' mode, all datapoints will be set from 250 to
%                   500 as they were.
%                   In 'REARRANGED' mode, all datapoints will be set from 0
%                   to 250 as the length of 'startend'.
%
%   Output:
%       The raw information structure.
%   
%   Created on Jun/10/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

% Analyze parameters
pvpmod(varargin);

% Get the filename from user input or function call
if ~exist('filename', 'var')
    [filename, pathname, ~] = uigetfile({'*.mcd','MCRACK files (*.mcd)'; ...
                                         '*.raw','RAW files (*.raw)'; ...
                                         '*.spk','SPK files (*.spk)'; ...
                                         '*.*', 'All files (*.*)'}, 'Pick a data file...', 'MultiSelect', 'off');
    % Check user input
    if filename == 0
        error('You must provide the data file.');
    end
    
    % Display filename
    disp(['Running on ' filename '...']);
    
    % Combine the filename and pathname into one.
    filename = fullfile(pathname, filename);
    
    % Get .ext
    [~, ~, filetype, ~] = fileparts(filename);
    % filetype will help the function to select proper dll.
    filetype = filetype(2:end); % ignore '.'
end

% Load Neuroshare DLL
util_load_nsdll(filetype, true);

% Open data file
hfile = util_load_nsfile(filename);

% Determine the reading range 'startend'
if ~exist('startend', 'var')    % please note, unit is ms.
    startime = 0;
    stoptime = util_get_nsfile_info(hfile, 'timespan');  % in ms
else
    startime = startend(1);
    stoptime = startend(2);
    % Check if the user specified parameter is rational
    if startime < 0
        startime = 0;
        warning('IO:INVALID', 'Invalid start time, reset to ZERO.');
    end
    if stoptime > util_get_nsfile_info(hfile, 'timespan')
        stoptime = util_get_nsfile_info(hfile, 'timespan');
        warning('IO:INVALID', 'Invalid stop time, reset to TOTAL_LENGTH.');
    end
end

% Display the startend
disp(['Start at ' datestr(util_get_nsfile_info(hfile, 'StartTime')) ...
      ', Total length: ' num2str(util_get_nsfile_info(hfile, 'timespan')) 'ms.']);
disp(['Read from ' num2str(startime) ' to ' num2str(stoptime) 'ms.']);
disp(' ');

% Next we will loop into all entities to get the data, but we have to check
% if the user-specified channels exist in the raw data (if failed, just
% warns the user and continue)

if ~exist('rawtype', 'var')
    rawtype = 'elec';
end

if ~exist('stream_sn', 'var')
    stream_sn = 1;
end

if ~exist('channel', 'var')
    channel = 'all';
end

disp(['Data to be processed is in ' rawtype ' stream [' num2str(stream_sn) '].']);

% Check if the number of rawtype stream > 1, then notice the user
temp_no = util_get_nsfile_info(hfile, 'MCDStreamNumber', 'name', rawtype);
if temp_no > 1
    disp(['Number of ' rawtype ' streams: ' num2str(temp_no) '.']);
elseif temp_no < 1
    error('The specified stream serial number is not exist.');
end
clear temp_no;

% Get entity info
[~, fileinfo] = ns_GetFileInfo(hfile);
[~, entityinfo] = ns_GetEntityInfo(hfile, (1:1:fileinfo.EntityCount));

% Remove the entities which is not needed to be processed from the entity
% info
index_to_be_removed  = [];
for i = 1:fileinfo.EntityCount
    [temp_name, temp_sn, ~, ~, temp_chid, ~] = util_resolve_nsentity_label( entityinfo(i).EntityLabel, filetype );
    if ischar(channel) && strcmpi(channel, 'all')
        % All channel are selected
        temp_chid_included = true;
    elseif ~ischar(channel)
        % User provides a list
        if isnumeric(temp_chid)
            % The channel is labeled with number.
            temp_chid_included = ~isempty(find(channel == temp_chid, 1));
        else
            % Triggering stream will be presented as 'trig0001'
            % which is not the raw data channel.
            temp_chid_included = false;
        end
        
    end
    
    if entityinfo(i).EntityType ~= util_get_nsentity_typecode('analog') ...
        || ~strcmpi(temp_name, rawtype) ...
        || temp_sn ~= stream_sn ...
        || ~temp_chid_included
        % Current entity is not in our channel list
        index_to_be_removed = [index_to_be_removed i];
    end
end
clear temp_name temp_sn temp_chid;

% Update entity info and fileinfo
entityinfo(index_to_be_removed) = [];
fileinfo.EntityCount = length(entityinfo);

% Loop into these entities and get the data







end

