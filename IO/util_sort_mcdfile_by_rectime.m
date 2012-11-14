function [ sorted_filename_list sorted_timestamp_list isOverlapped ] = util_sort_mcdfile_by_rectime( input_list, number_of_files, varargin )
%UTIL_SORT_MCDFILE_BY_RECTIME Sort the MCS datafile by their recording time
%   Input:
%           input_list:     A cell array which contains the full path of
%                           all files.
%                           e.g. {'E:\DATA\xxxx.mcd','F:\2.mcd'}
%           number_of_files:    Number of processing files
%           method:         'RecAsc'[default] / 'RecDes'
%   Output:
%           sorted_filename_list:   A cell array which contains filename.
%           sorted_timestamp_list:  A cell array which contains recording
%                                   StartTime.
%           isOverlapped:           True if one of the given files started
%                                   when the previous one has not stopped.
%
%   Example:
%           [filelist, ~, ~] = util_sort_mcdfile_by_rectime( filelist,
%           length(listings), 'method', 'RecAsc' );
%
%   Created on Jun/26/2009 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2009-06-27  Debugging, adding following lines:
%                       [sorted_filename_list{1:end}] = sort_struct(:).filename;
%                       sorted_timestamp_list = cellstr(datestr([sort_struct(:).start]));
%       PJB#2010-08-17  Adding 'method', to get descending sort.
%                       Adding escping funtion to make sure the displaying
%                       is correct.
%       PJB#2010-09-07  Before reporting 'Overlapped', now we first check
%                       if these two files are recorded continously, for
%                       example, 'xxxxx.mcd' and 'xxxxx0001.mcd'. Because
%                       in such situation, these two have the same start
%                       time.

echo off all

% Analyze parameter
pvpmod(varargin);

if ~exist('method', 'var')
    method = 'RecAsc';
end

% Reading
unsort_struct = struct('filename', {cell(number_of_files,1)}, ...
                     'start', zeros(number_of_files,1), ...
                     'end', zeros(number_of_files,1));

for i = 1:number_of_files
    unsort_struct(i).filename = input_list{i};
    [~] = evalc('D = datastrm(unsort_struct(i).filename)');
    unsort_struct(i).start = getfield(D, 'recordingdate');
    unsort_struct(i).end = getfield(D, 'recordingStopDate');
    clear D;
end

% Sort
if strcmpi(method, 'RecAsc')
    [~, order] = sort([unsort_struct(:).start]);
elseif strcmpi(method, 'RecDes')
    [~, order] = sort([unsort_struct(:).start], 'descend');
else
    error('Not supported yet.');
end
sort_struct = unsort_struct(order);


% Construct the final results
% sorted_filename_list = sort_struct(:).filename only returns the first
% one.
sorted_filename_list = cell(number_of_files,1);

[sorted_filename_list{1:end}] = sort_struct(:).filename;
sorted_timestamp_list = cellstr(datestr([sort_struct(:).start]));

% Check overlapped
isOverlapped = 0;
for i = 1:(number_of_files-1)
    if strcmpi(method, 'RecAsc')
        if sort_struct(i).end > sort_struct(i+1).start
            if util_check_two_files_are_continuous_recording({sort_struct(i).filename;sort_struct(i+1).filename}, [sort_struct(i).start;sort_struct(i+1).start])
                fprintf([util_escape_string(sort_struct(i+1).filename) '\n\tis continued with\n\t' util_escape_string(sort_struct(i).filename) '.\n']);
            else
                isOverlapped = 1;
                fprintf([util_escape_string(sort_struct(i+1).filename) '\n\tis overlapped with\n\t' util_escape_string(sort_struct(i).filename) '.\n']);
            end
        end
    elseif strcmpi(method, 'RecDes')
        if sort_struct(i).start < sort_struct(i+1).end
            if util_check_two_files_are_continuous_recording({sort_struct(i).filename;sort_struct(i+1).filename}, [sort_struct(i).start;sort_struct(i+1).start])
                fprintf([util_escape_string(sort_struct(i+1).filename) '\n\tis continued with\n\t' util_escape_string(sort_struct(i).filename) '.\n']);
            else
                isOverlapped = 1;
                fprintf([util_escape_string(sort_struct(i+1).filename) '\n\tis overlapped with\n\t' util_escape_string(sort_struct(i).filename) '.\n']);
            end
        end
    end
end


end
