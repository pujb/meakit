function [ return_code varargout ] = util_run32bit_matlabfunc( mfunc_exec_string, varargin )
%UTIL_RUN32BIT_MATLABFUNC Calling matlab functions with 32-bit Matlab
%environment without JVM support.
%   The function calls a 32-bit Matlab environment and executes the
%   specific M function. It could be useful when we are dealing with big
%   data that causes OUT OF MEMORY error. You can use this function to call
%   a 32-bit mex and it will automatically transfer the results to the
%   64-bit caller environment by using a temporary mat file.
%
%   Input:
%       mfunc_exec_string: like '[c,~,endian] = computer', the ' must be
%                          replaced by %$, for example, 'rep' = %$rep%$
%       Note: use , for separator, DO NOT USE SPACE.
%             ANY SPACE WILL BE REPLACED BY %SPACE%. If really needed.
%       e.g: [code spif trif] =  util_run32bit_matlabfunc('[D,spif,triggerif]=util_load_spike_trigger_mcdstream(%$filename%$,%$E:\DAT\Data\Develop\n1226-20071109\selected\n1226-1109-0114 Baseline SPIKE.mcd%$);');
%
%       verbose:    Display detailed information. Default: 0
%   Output:
%       return_code:    The return code of Matlab.exe, not very useful at
%                       the current stage.
%       varargout:      The returned varibles of the m-function in the
%                       sequence written in the mfunc_exec_string.
%                       e.g. c endian, in the example.
%
%
%   Created on Nov/06/2012 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2012-11-07  Fixed BUG: Invalid calling to Matlab due to
%                       mal-formatted exec string. Now it supports the %$
%                       and %SPACE%.
%                       Added VERBOSE switch.

pvpmod(varargin);

% Set default value for verbose
if ~exist('verbose', 'var')
    verbose = 0;
end

% Mat file name for temp saving (util_run32bit_matlabfunc/util_run32bit_matlabfunc_wrapper)
mat_filename = 'util_run32bit_matlabfunc_wrapper_mat.mat';
mat_finished_filename = 'util_run32bit_matlabfunc_wrapper_finished.mat';

% Check if we are running in 64bit (only valid for MS-Win currently)
comp = computer;
if strcmpi(comp, 'PCWIN')
    disp('You are under 32-bit environment already.');
end

% Get JAVA Runtime
runtime = java.lang.Runtime.getRuntime();

% Setting up Matlab starting environment
% matlab64_start_line = 'C:\Progra~1\MATLAB\R2012a\bin\matlab.exe -nodesktop -nojvm -nosplash -minimize -r ';
matlab32_start_line = 'C:\Progra~2\MATLAB\R2012a\bin\matlab.exe -nodesktop -nojvm -nosplash -minimize -r util_run32bit_matlabfunc_wrapper(%%';

% Delete any previous result file
current_dir = pwd;
cd(tempdir)
if exist(mat_filename, 'file')
    delete(mat_filename);
end
if exist(mat_finished_filename, 'file')
    delete(mat_finished_filename);
end
cd(current_dir)

% Get the runcode
% Check and Convert the SPACE
mfunc_exec_string = strrep(strtrim(mfunc_exec_string), ' ', '%SPACE%');
% In the calling code, we also have the quotes problem, we replace %% to ',
% Please note that user gives %$ which will be replaced to ' inthe wrapper
% func to avoid invalid call to matlab command line.
runcode = strrep([matlab32_start_line mfunc_exec_string '%%)'], '%%', '''');

% Run and but we cannot block until the matlab process exits
if verbose
    disp(['Calling 32bit Matlab with ' runcode '...'])
    disp('If the program seems to be no response, please check the new Matlab window to see if there is something wrong.')
    disp('Enter Ctrl + C to quit the infinite waiting loop.')
end
process = runtime.exec(runcode);
process.waitFor();
% Get exit code (not very useful now).
return_code = process.exitValue();
%process.destroy();


% Varibles were saved into a mat in the wrapper function(if exist), therefore we can read it now.
% Analyze the output parameter list:
[num_vars, vars_list] = util_funcwrapper_parameter_analyzer(mfunc_exec_string);

if num_vars == 0
    disp('You have not specified returning parameter.')
    return;
else
    current_dir = pwd;
    cd(tempdir)
    % Check and Block if the mat file did not show
    if verbose
        disp('Waiting for external 32-bit Matlab response...')
    end
    % We check for the second file - mat_finished_filename, to make sure
    % the first data file is finished writing.
    while ~exist(mat_finished_filename, 'file')
        pause(3); % pause 3 seconds
    end
    if verbose
        disp('Matlab worker finished.')
    end
    load(mat_filename, vars_list{:});
    cd(current_dir)
    
    if verbose
        fprintf('Return value: ')
    end
    % Return values in the varargout
    for i = 1:num_vars
        evalc(['varargout{i}=' vars_list{i}]);
        if verbose
            fprintf(vars_list{i});
            if i~=num_vars
                fprintf(', ')
            else
                fprintf('.\n')
            end
        end
    end
end

end
