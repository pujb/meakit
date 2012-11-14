function [ subdirs ] = util_get_subdirs( given_dir, is_sort_by_date, is_recursive, excluded_dir )
%UTIL_GET_SUBDIRS Get sub directories of the given dir.
%   Please note, the method dir (whose name starts with a '@') and private
%   directory (whose name is 'private') will be ignored.
%   This function is called during setup, therefore, many other toolbox
%   functions cannot be used in this file. (e.g. pvpmod.m)
%
%   Input:
%           given_dir: The dir you want to explore its sub directories.
%           is_sort_by_date: If true, the returned list is sorted by date
%                            (ascending, old to new).
%           is_recursive:    If true, we will find all sub directories
%                            recursively.
%           excluded_dir:    A cell array, providing the dir(s) which will
%                            be ignored.
%   Output:
%           subdirs:   The names of sub directories, if none, return []
%
%   Example:
%           util_get_subdirs('.', 1, 1, {'Otherbox\FIND'})'
%
%   Created on Aug/14/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2010-08-15  Adding the ability to exclude dir/sub-dirs.

% Check if it is ignored
for i = 1:length(excluded_dir)
    if strcmpi(excluded_dir{i}, given_dir)
        subdirs = [];
        return;
    end
end

% Save current path
pwd_push = pwd;

% CD to the given_dir
if ~exist(given_dir, 'dir')
    error('The given dir not exists.');
    % Change back to the current path.
    cd(pwd_push);
end
cd(given_dir);

% List all subdirs
listings = dir; 
listings = listings(~cellfun(@isempty,{listings(:).date})); 

% Get all sub directories
subdirs = [];
for i = 1:length(listings)
    if ~(strcmp(listings(i).name, '.') || strcmp(listings(i).name, '..') || strcmp(listings(i).name(1), '@') || strcmp(listings(i).name, 'private')) && listings(i).isdir
        % Setup Flag (indicating this sub will be ignored)
        ignored = false;
        % Check if this sub directory should be ignored
        for j = 1:length(excluded_dir)
            if strcmpi(excluded_dir{j}, [given_dir filesep listings(i).name])
                ignored = true;
            end
        end
        % Add to list
        if ~ignored
            temp.name = listings(i).name;
            temp.datenum = listings(i).datenum;
            subdirs = [subdirs; temp];
        end
    end
end

% Sort
if is_sort_by_date && length(subdirs) > 1
	[~, order] = sort([subdirs(:).datenum]);
    subdirs = subdirs(order);
end

% Change back to the current path.
cd(pwd_push);

% Return

% Generate the relative path (to given_dir)
if isempty(subdirs)
    subdirs = [];
else
    subdirs = {subdirs(:).name};
    for i = 1:length(subdirs)
        subdirs{i} = [given_dir filesep subdirs{i}];
    end
end

% Process all sub directories if necessary
if is_recursive
    if ~isempty(subdirs)
        % Go to each sub directory
        for i = 1:length(subdirs)
            recursive_result = util_get_subdirs(subdirs{i}, is_sort_by_date, true, excluded_dir);
            if ~isempty(recursive_result)
                subdirs = [subdirs {recursive_result{:}}];
            end
        end
    end
end

end

