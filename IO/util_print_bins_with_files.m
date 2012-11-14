function bin_table = util_print_bins_with_files( varargin )
%UTIL_PRINT_BINS_WITH_FILES Print out how many bins in each data file.
%   This function is helpful when you are counting bins from multiple
%   files. It is also very helpful to count DIVs (days in vitro) from
%   multiple recordings.
%
%   Input:
%           filenames:  You can provide a list of filename, or the program
%                       will popup a dialog.
%           binwidth:   (ms), default: 1 ms
%           culdate:    Culture date, in such format '2007-11-1'.
%                       If not provided, the program will not calc DIV for
%                       you, therefore COL4 in the bin_table will not
%                       exist.
%                       If = 'ASK', then the program will ask you for a
%                       date.
%   Output:
%           bin_table:  e.g.
%                       COL 1      COL 2       COL 3       COL 4 (if any)
%               ROW 1   filename   start_bin   end_bin     DIV
%   Example:
%           bin_table = util_print_bins_with_files('binwidth', 10000,
%           'culdate', '2007-07-10');
% 
%   Created on Sep/07/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2010-09-08  Adding a new function to calc DIV
%                       Enabling couting only one file, as well as multiple
%                       files
%       PJB#2012-11-14  Now if culdate == 'ASK', the program will ask you.

pvpmod(varargin);

% filenames
if ~exist('filenames', 'var')
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
end

% Sort
fprintf('Sorting... ');
[filenames(:,1) filenames(:,2) isOverlapped] = util_sort_mcdfile_by_rectime( filenames(:,1), num_of_files );
fprintf('Done. \n')

if isOverlapped
    error('File overlapped, please double check the recording start/end time');
end

% binwidth
if ~exist('binwidth', 'var')
    binwidth = 1;
end


if exist('culdate', 'var')
    if strcmpi(culdate, 'ask')
        culdate = input('Please enter the date of seeding in xxxx-xx-xx format:', 's');
    else
        bin_table = cell(num_of_files, 4);
    end
else
    bin_table = cell(num_of_files, 3);
end

% main loop
disp('_____________________________________________________________________');
disp(['FILENAME:                             START/END BIN_WIDTH = ' num2str(binwidth) ' ms']);

sweepTotalTime = 0;
% Make output more elegant by couting spaces
maxlength = 0;
for i = 1:num_of_files
    [~, filename, ~] = fileparts(filenames{i,1});
    if maxlength < length(filename)
        maxlength = length(filename);
    end
end
    
for i = 1:num_of_files
    % filename
    bin_table{i, 1} = filenames{i,1};
    [~, filename, ~] = fileparts(filenames{i,1});
    fprintf(['[' num2str(i) '] ' filename]);
    
    % read mcd
    [~] = evalc('D = datastrm(filenames{i,1})');
    
    % Start
    bin_table{i, 2} = fix(sweepTotalTime / binwidth) + 1;
    sweepTotalTime = sweepTotalTime + getfield(D, 'sweepStopTime');
    
    % End
    bin_table{i, 3} = fix(sweepTotalTime / binwidth);

    % Output spaces
    spaces = repmat(' ', 1, maxlength - length(filename) + 2);    
    fprintf(spaces);
    
    fprintf(['[' num2str(bin_table{i, 2}) ':' num2str(bin_table{i, 3}) ']']);
    
    % DIV
    if exist('culdate', 'var')
        bin_table{i, 4} = fix(getfield(D, 'recordingdate') - datenum(culdate));
        fprintf(['\t\t' num2str( bin_table{i, 4} ) ' DIV\n']);
    else
        fprintf('\n');
    end
    
    clear D;
end

end

