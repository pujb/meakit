function [ filelist ] = util_get_dirfiles( varargin )
%UTIL_GET_DIRFILES Get the files in the given dir.
%   Input:
%           given_dir:  The given directory, if not exist, the current
%                       directory is used. [default: pwd]
%           wildchar:   The file extensions.
%                       [default: '*.*']
%           sorttype:   Sorting method.
%                       'byDateAsc':    By date, ascending. [default]
%                       'byDateDes':    By date, descending.
%                       'byRecAsc':     By recording start, ascending.
%                       'byRecDes':     By recording start, ascending.
%                       'no':           No sorting.
%           genfull:    If true, return full path. [default]
%   Output:
%           filelist:   File listing.
%
%   Example:
%           [ filelist ] = util_get_dirfiles( 'sorttype', 'byDateDes',
%           'genfull', false )
%
%   Created on Aug/17/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

% Analyze parameter
pvpmod(varargin);

if ~exist('given_dir', 'var')
    given_dir = pwd;
end

if ~exist('wildchar', 'var')
    wildchar = '*.*';
end

if ~exist('sorttype', 'var')
    sorttype = 'byDateAsc';
end

if ~exist('genfull', 'var')
    genfull = true;
end


% CD to the given_dir
pwd_push = pwd;
cd(given_dir);

% dir (excluding those files that dir cannot query)
listings = dir(wildchar);
listings = listings(~cellfun(@isempty,{listings(:).date}));

% Remove directories if any
listings([listings.isdir] == 1) = [];

if isempty(listings)
    filelist = [];
    cd(pwd_push);
    return
end

if length(listings) == 1 || strcmpi(sorttype, 'no')
    filelist = {listings(:).name}';
    % Full path
    if genfull
        filelist = make_full_path(given_dir, filelist);
    end
    cd(pwd_push);
    return
end

% Sort
if strcmpi(sorttype, 'byDateAsc')
    [~, order] = sort([listings(:).datenum]);
    filelist = {listings(order).name}';
    % Full path
    if genfull
        filelist = make_full_path(given_dir, filelist);
    end
elseif strcmpi(sorttype, 'byDateDes')
    [~, order] = sort([listings(:).datenum], 'descend');
    filelist = {listings(order).name}';
    % Full path
    if genfull
        filelist = make_full_path(given_dir, filelist);
    end
elseif strcmpi(sorttype, 'byRecAsc')
    filelist = make_full_path(given_dir, {listings.name});
    [filelist, ~, ~] = util_sort_mcdfile_by_rectime( filelist, length(listings), 'method', 'RecAsc' );
    % Full path
    if ~genfull
        filelist = make_rel_path(filelist);
    end
elseif strcmpi(sorttype, 'byRecDes')
    filelist = make_full_path(given_dir, {listings.name});
    [filelist, ~, ~] = util_sort_mcdfile_by_rectime( filelist, length(listings), 'method', 'RecDes' );
    % Full path
    if ~genfull
        filelist = make_rel_path(filelist);
    end
else
    cd(pwd_push);
    error('Not supported yet.');
end

cd(pwd_push);

end


function fullpaths = make_full_path(given_dir, filename_cell)
%MAKE_FULL_PATH Generate full path from the cell array.
%
%   Created on Aug/17/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

fullpaths = cell(length(filename_cell), 1);

for i = 1:length(filename_cell)
    fullpaths{i} = fullfile(given_dir, filename_cell{i});
end

end

function relpaths = make_rel_path(filename_cell)
%MAKE_REL_PATH Get the filename from full path
%
%   Created on Aug/17/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

relpaths = cell(length(filename_cell), 1);

for i = 1:length(filename_cell)
    [~, name, ext] = fileparts(filename_cell{i});
    relpaths{i} = [name ext];
end

end

