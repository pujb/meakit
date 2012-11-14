function util_run32bit_matlabfunc_wrapper( mfunc_exec_string )
%UTIL_RUN32BIT_MATLABFUNC_WRAPPER The function wrapper for calling a matlab
%function in external matlab process especially when used in mixed 32/64
%bit environment. Basically, the function will be called in the other
%matlab environment, and it will handle the m-function
% 
%   Input:
%       mfunc_exec_string: like '[c,~,endian] = computer'
%                          ' should be replaced by %$
%                          SPACE should be replaced by %SPACE%
% 
%   See also UTIL_RUN32BIT_MATLABFUNC
%
%
%   Created on Nov/06/2012 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2012-11-07  Fixed BUG: Invalid calling to Matlab due to
%                       mal-formatted exec string. Now it supports the %$
%                       and %SPACE%.

% Convert quotes
mfunc_exec_string = strrep(mfunc_exec_string, '%$', '''');
% Trim spaces
mfunc_exec_string = strtrim(mfunc_exec_string);
% Convert spaces
mfunc_exec_string = strrep(mfunc_exec_string, '%SPACE%', ' ');

disp(['The calling string is: ' mfunc_exec_string '.'])

% Mat file name for temp saving (util_run32bit_matlabfunc/util_run32bit_matlabfunc_wrapper)
mat_filename = 'util_run32bit_matlabfunc_wrapper_mat.mat';
mat_finished_filename = 'util_run32bit_matlabfunc_wrapper_finished.mat';

% Check semicolon
if ~strcmpi(mfunc_exec_string(end), ';')
    mfunc_exec_string = [mfunc_exec_string ';'];
end

% Eval
[~] = evalc(mfunc_exec_string);

% Determine if the m function have outputs
if isempty(strfind(mfunc_exec_string, '='))
    % The function have no return vars.
    disp('UTIL:WRAPPER: The function will not return any parameter.')
    return;
else
    % Analyze the exec string
    [num_vars, vars_to_be_saved] = util_funcwrapper_parameter_analyzer(mfunc_exec_string);
    for i = 1:num_vars
        eval(vars_to_be_saved{i});
    end
    % Change to temp dir and create a mat file for saving vars
    current_dir = pwd;
    cd(tempdir)
    if exist(mat_filename, 'file')
        disp(['The mat file: ' mat_filename ' exists!']);
        delete(mat_filename);
    end
    if exist(mat_finished_filename, 'file')
        delete(mat_finished_filename);
    end
    save(mat_filename, vars_to_be_saved{:});
    finished = 1;
    save(mat_finished_filename, 'finished');
    cd(current_dir)
end

% Exit MATLAB
exit
end