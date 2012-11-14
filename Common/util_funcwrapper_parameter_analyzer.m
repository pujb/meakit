function [ num_para para_list_cell ] = util_funcwrapper_parameter_analyzer( mfunc_exec_string )
%UTIL_FUNCWRAPPER_PARAMETER_ANALYZER A not-very-commonly used common
%function. This function will anaylze "[a b c] = func(xxxx)", and output
%its output parameter into a cell in para_list_cell.
%   Input:
%           mfunc_exec_string: Function calling string.
%   Output:
%           num_para:   Number of output parameters
%           para_list_cell: A Cell array of strings containing output
%                       parameter names.
%
%   Created on Nov/06/2012 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

% Trim spaces
mfunc_exec_string = strtrim(mfunc_exec_string);

if isempty(strfind(mfunc_exec_string, '='))
    num_para = 0;
    para_list_cell = [];
    disp('UTIL:PARA_ANA: The function will not return any parameter.')
    return;
end

% Find '='
equal_loc = strfind(mfunc_exec_string, '=');
% We only look for the first '='
equal_loc = equal_loc(1);

% Trim spaces of the list
para_list_cell = strtrim(mfunc_exec_string(1:equal_loc-1));
% If we have [], then removed it
if para_list_cell(1) == '['
    para_list_cell = para_list_cell(2:end);
end
if para_list_cell(end) == ']'
    para_list_cell = para_list_cell(1:end-1);
end

% Now we have something like that 'xxx xxx ~ xxx, xxx'
para_list_cell = regexp(para_list_cell, '\s,|\s|,', 'split');
% Remove spaces and '~'
labelled = [];
for i = 1:length(para_list_cell)
    if (strcmpi(para_list_cell{i}, '~')) || (strcmpi(para_list_cell{i}, ''))
        labelled = [labelled i];
    end
end
para_list_cell(labelled) = [];
num_para = length(para_list_cell);

end

