function [ info ] = util_get_nsfile_info( handle, property_name, varargin )
%UTIL_GET_NSFILE_INFO Get file info from a opened handle
%   Using the provided file handle, the user can use this function to
%   retrieve the named property from the data file.
%   Input:
%       handle:         file handle provided by ns_OpenFile
%       property_name:  the name of the property you want to access
%           if property_name = 'MCDStreamNumber'
%           then you have to give the other parameter "name".
%   Output:
%       info:           the value of the property
%
%   Usage:
%   (1)
%   Find out how many types of entities in the data file.
%       entity_types = util_get_nsfile_info(hfile, 'EntityTypes');
%       disp('Entity types:');
%       disp(entity_types);
%   (2)
%   Find out how many types of streams in the data file.
%       stream_types = util_get_nsfile_info(hfile, [upper(filetype) 'StreamTypes']);
%       disp('Stream types and numbers (Index: 1-based):');
%       for i = 1:length(stream_types)
%           stream_numbers(i) = util_get_nsfile_info(hfile, [upper(filetype) 'StreamNumber'], 'name', stream_types{i});
%           disp(['    ' stream_types{i} ': ' num2str(stream_numbers(i))]);
%       end
%
%   Created on Jun/10/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

%   $Revision:
%       PJB#2010-06-11  Adding 'MCDStreamTypes'
%                       Adding 'MCDStreamNumber'

% Get parameter
pvpmod(varargin);

% Get file information
[nsresult, FileInfo] = ns_GetFileInfo(handle);

% Check if success
if (nsresult ~= 0)
    util_disp_ns_errcode(nsresult, true);
    error('Accessing data file failed.');
end

% Retrieve the property by request
switch upper(property_name)
    case upper('FileType')
        info = FileInfo.FileType;
    case upper('EntityCount')
        info = FileInfo.EntityCount;
    case upper('EntityTypes')
        % Get info of all entities
        [~, entity_info] = ns_GetEntityInfo(handle, (1 : 1 : FileInfo.EntityCount));
        entity_types = arrayfun(@(x)(x.EntityType), entity_info);
        % Find different types
        info_code(1) = entity_types(1);
        for i = 2:length(entity_types)
            if ~util_find_a_in_b(entity_types(i), info_code)
                info_code(end+1) = entity_types(i);
            end
        end
        % Translate type codes into type names
        for i = 1:length(info_code)
            info{i} = util_get_nsentity_typename(info_code(i));
        end
    case upper('MCDStreamTypes')
        % Get info of all entities
        [~, entity_info] = ns_GetEntityInfo(handle, (1 : 1 : FileInfo.EntityCount));
        entity_labels = arrayfun(@(x)(x.EntityLabel), entity_info, 'UniformOutput', false);
        % Find different types
        [ firstone, ~, ~, ~, ~, ~ ] = util_resolve_nsentity_label( entity_labels{1}, 'MCD' );
        info{1} = firstone;
        for i = 2:length(entity_labels)
            [ curr, ~, ~, ~, ~, ~ ] = util_resolve_nsentity_label( entity_labels{i}, 'MCD' );
            if ~util_find_a_in_b({curr}, info, 'string_mode', true)
                info{end+1} = curr;
            end
        end
    case upper('MCDStreamNumber')
        % Check input
        if ~exist('name', 'var')
            error('MCDStreamNumber requires the stream name.');
        end
        % Get info of all entities
        [~, entity_info] = ns_GetEntityInfo(handle, (1 : 1 : FileInfo.EntityCount));
        entity_labels = arrayfun(@(x)(x.EntityLabel), entity_info, 'UniformOutput', false);
        info = 0;
        for i = 1:length(entity_labels)
            [ stream_name, stream_number, ~, ~, ~, ~ ] = util_resolve_nsentity_label( entity_labels{i}, 'MCD' );
            if strcmpi(stream_name, name)
                if info < stream_number
                    info = stream_number;
                end
            end
        end
    case upper('TimeRes')   % ms
        info = FileInfo.TimeStampResolution * 1000;
    case upper('SamplFreq') % Hz
        info = 1/FileInfo.TimeStampResolution;
    case upper('TimeSpan')  % ms
        info = FileInfo.TimeSpan * 1000;
    case upper('AppName')
        info = FileInfo.AppName;
    case upper('StartTime')
        info = datenum( FileInfo.Time_Year, ...
                        FileInfo.Time_Month, ...
                        FileInfo.Time_Day, ...
                        FileInfo.Time_Hour, ...
                        FileInfo.Time_Min, ...
                        FileInfo.Time_Sec + (FileInfo.Time_MilliSec / 1000));
    case upper('Comment')
        info = FileInfo.FileComment;
    otherwise
        info = FileInfo;
end

end

