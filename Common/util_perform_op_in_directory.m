function [ varargout ] = util_perform_op_in_directory( given_dir, op, result_dir, filematch, var_to_save, varargin )
%UTIL_PERFORM_OP_IN_DIRECTORY Perform the same operation on each file in
%the given directory.
%   Input:
%           given_dir:      The root directory from where the processing
%                           will begin.
%           op:             The operation script.
%                           '[a b c] = opertest(%file, d, e, f)'
%                           %file: will be replaced by the current file.
%                           %dir: will be replaced by the current result
%                           output dir.
%                           like: 'c:\data\data.mcd' (auto with quotes.)
%                                 'c:\result_dir\xxx'
%           result_dir:     The root of result directory. The results will
%                           be save into a mat file under the same name of
%                           the data file.
%           filematch:      e.g. '*.mcd' / '*CNQX*.mcd' / *n1271*.mcd
%           var_to_save:    Which varibles you want to save.
%                           'a b c' for example.
%           is_recursive:   If true, scan the directory and its sub-dirs.
%                           [default:true]
%           verbose:        If true, display the working directory. [default]
%                           If false, display percentage.
%           sorttype:       Sort files in each directory(not in the
%                           global).
%                           'no'[default] / 'byDateAsc' / 'byDateDes' /
%                           'byRecAsc' / 'byRecDes'
%           
%   Output:
%           Not decided...
%           Currently, returns 1 if successfully finished.
%
%   Example:
%           util_perform_op_in_directory('G:\MC_Rack Data\','[ a b c ] =
%           util_test_function_for_looping( %file, ''e'',''f'' );','C:\test','*.mcd','a b c','is_recursive',true,'verbose',false);
%
%   Note:
%           This function will save the output to a mat file by each data
%           file. But you can write a looping function that saves values of all
%           processed data file in the same dir to a single file by using
%           %dir.
%           
%
%   Created on Aug/18/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2010-08-19  Adding 'sorttype' switch.
%       PJB#2011-03-22  Adding 'dir' support to op-handle
%       PJB#2011-03-26  Bug fix: when is_recursive = 0, but it still gives
%                       one of its sub-dirs
%       PJB#2011-04-08  Bug fix: now the %dir will be changed with
%                       different data files.

% Analyze parameter
pvpmod(varargin);

if ~exist('is_recursive', 'var')
    is_recursive = true;
end

if ~exist('var_to_link', 'var')
    var_to_link = [];
end

if ~exist('verbose', 'var')
    verbose = true;
end

if ~exist('sorttype', 'var')
    sorttype = 'no';
end

% Check dir format
% Check if exist
if ~exist(given_dir, 'dir')
    error([given_dir ' does not exist.']);
end

if ~exist(result_dir, 'dir')
    disp([result_dir ' is created.']);
end

% Remove the last file system separator
if strcmp(given_dir(end), filesep)
    given_dir(end) = [];
end
if strcmp(result_dir(end), filesep)
    result_dir(end) = [];
end

% Get full path of the given_dir
given_dir = util_get_fullpath(given_dir);

% Get how many directory
disp('Counting workload...');
if is_recursive
    dirs = util_get_subdirs( given_dir, false, is_recursive, [] );
else
    dirs = {};
end
if isempty(dirs)
    % use {} to make it a cell, or it will be a char array
    dirs = {given_dir};
else
    dirs = [given_dir dirs];
end

% Loop all these directories and find out how many files will be proceeded.
filelist = {};
for i = 1:length(dirs)
    filelist = [filelist; util_get_dirfiles( 'given_dir', dirs{i}, 'wildchar', filematch, 'sorttype', sorttype, 'genfull', true )];
end

fprintf(['\tTotal files: ' num2str(length(filelist)) '\n']);
fprintf(['\tTotal dir  : ' num2str(length(dirs)) '\n']);

% Analyze Operation Code
% Code Format:
%      [a b c] = script('DUM',DUM,'DUM2',%file,'DUM3',DUM3,DUM4)
% We will replace %file to the current filename, then eval this string
% %file = current file
% %dir = current directory

% Check semicolon
if ~strcmpi(op(end), ';')
    op = [op ';'];
end
if verbose
    disp('Working...');
else
    fprintf('\nWorking...');
end
for i = 1:length(filelist)
    if verbose
        disp(['... [' num2str(i) '/' num2str(length(filelist)) '] ' filelist{i}]);
    else
        util_show_progress_rounding(100 * i/length(filelist));
    end
    % Get the result output dir based on data root(given_dir) and
    % result_root (result_dir)
    current_result_dir = gen_result_dir(given_dir, result_dir, fileparts(filelist{i}));
    
    % Create the execution string (Replacement %parameter)
    execute_str = strrep(op, '%file', ['''' filelist{i} '''']);
    execute_str = strrep(execute_str, '%dir', ['''' current_result_dir '''']);

    % Eval
    [~] = evalc(execute_str);
    % Check if we want to save result
    if ~isempty(var_to_save)
        % We want to save result
        % Get the MAT filename
        matname = gen_matname(given_dir, result_dir, filelist{i});
        % Save to file
        [~] = evalc(['save ' matname ' ' var_to_save]);
    end
end

% Done
if verbose
    disp('Finished');
else
    util_show_progress_rounding(100);    
end

% Return flag (1 = success)
varargout{1} = 1;


end


function matname = gen_matname(data_root, result_root, filename)
%GEN_MATNAME Generate the mat filename base on data filename
%   Note: All must be in full path.
%   Note: The directory of this matfile is automatically made.
%
%   Created on Aug/18/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

[pathstr, matname, ~] = fileparts(filename);
len_pathstr = length(pathstr);
len_datroot = length(data_root);

if len_pathstr == len_datroot
    dirname = result_root;
    if ~exist(dirname, 'dir')
        mkdir(dirname);
    end
    matname = [dirname filesep matname '.mat'];
else
    dirname = [result_root pathstr(len_datroot+1:end)];
    if ~exist(dirname, 'dir')
        mkdir(dirname);
    end
    matname = [dirname filesep matname '.mat'];
end

matname = ['''' matname ''''];

end

function result_dir = gen_result_dir(data_root, result_root, current_data_path)
%GEN_RESULT_DIR Generate the result_dir base on data filesystem root and
%the result filesystem root.
%   Note: All must be in full path.
%   Note: The directory of this matfile is automatically made.
%
%   Created on Apr/08/2011 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

% result_dir = [result_root] + [filesep] + [current_data_path - data_root]

% Check if data_root/result_root is in right format [...\...\]
if data_root(end) ~= filesep
    data_root = [data_root filesep];
end

if result_root(end) ~= filesep
    result_root = [result_root filesep];
end

% Get the relative path based on data_root
result_dir = [result_root current_data_path(length(data_root)+1:end)];

if ~exist(result_dir, 'dir')
    mkdir(result_dir);
end

end
