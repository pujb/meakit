function util_rename_datafile_based_on_div(MEANO, culdate)
%UTIL_RENAME_DATAFILE_BASED_ON_DIV Rename the data file by DIV
%   Change the name of datafile by the given MEA number and the culture
%   date. Recordings in the same day will be sorted by each recording start
%   time (0001, 0002, etc.)
%
%   Input:
%           MEANO:      MEA No., 'N1272'
%           culdate:    Culture date, '2010-04-01'
%
%   Created on Sep/09/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

disp('This operation cannot be undone, please be careful');
pause;

% Get file list
% Popup a dialog
[filenames, pathname, ~] = uigetfile('*.mcd', 'MultiSelect', 'On');

if ~iscell(filenames) || size(filenames,2) < 2
    % Only one files been selected
    num_of_files = 1;
    % Create a cell array to put together filename and its timestamp
    filenames_tmp = cell( num_of_files, 2 );   % col1: Filename, col2: Timestamp
    filenames_tmp{1,1} = [pathname filenames];
else
    % Multiple files
    num_of_files = size( filenames, 2 );
    % Create a cell array to put together filename and its timestamp
    filenames_tmp = cell( num_of_files, 2 );   % col1: Filename, col2: Timestamp
    for i = 1:num_of_files
        filenames_tmp{i,1} = [pathname filenames{i}];
    end
end

filenames = filenames_tmp;
clear filenames_tmp;

% Sort
[filenames(:,1) filenames(:,2) isOverlapped] = util_sort_mcdfile_by_rectime( filenames(:,1), num_of_files );

if isOverlapped
    error('File overlapped, please double check the recording start/end time');
end

% Generate the prefix of filenames
prefix = [MEANO '-' culdate(1:4) culdate(6:7) culdate(9:10) '-'];

% Change pwd
current_pwd = pwd();
cd(pathname);

% Loop and rename
for i = 1:num_of_files
    
    % Get old filename
    [~, filename, ext] = fileparts(filenames{i,1});
    quote = '"';
    old_name = [quote filename ext quote];
    
    % Read mcd
    [~] = evalc('D = datastrm(filenames{i,1})');
    
    % Get DIV and generate the new name
    div = fix(getfield(D, 'recordingdate') - datenum(culdate));
    new_name = [prefix num2str(div) 'D' ext];
    
    % Close old file
    clear D;
    clear mex;
    
    disp(['[' num2str(i) '/' num2str(num_of_files) '] ' old_name ' --> ' quote new_name quote]);
    
    % Check if already renamed
    if strcmpi(old_name, [quote new_name quote])
        continue;
    end
    
    % Check if the same name exist
    fileid = 0;
    while exist(new_name, 'file')
        % Exist! Create a new name
        fileid = fileid + 1;
        new_name = [prefix num2str(div) 'D ' num2str(fileid, '%.4d') ext];
    end
    
    % Rename
    new_name = [quote new_name quote];
    [status osresult] = system(['ren ' old_name ' ' new_name]);
    if ~status
        error(osresult);
    end
end

% Restore pwd
cd(current_pwd);

end

