function toolbox_path = util_get_toolbox_root(varargin)
%UTIL_GET_TOOLBOX_ROOT Get the root directory of this toolbox
%   Input:
%           If no parameter is provided, then this function will return the
%           root path of this toolbox.
%           if ...('the path here') is called, the function will update the
%           root path of this toolbox. (This will be done while installing)
%   Output:
%           The toolbox root path.
%
%   Created on Oct/15/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

current_dir = pwd;

if size(varargin, 2) > 0
    % Save the rootpath
    
    % Chdir to the 'Common' directory
    chdir(varargin{1});
    chdir('Common');
    % Save the current path
    pathroot = varargin{1};
    save('pathdef.mat', 'pathroot');
else
    % Load the rootpath
    
    % Chdir to the 'Common' directory
    [mypath] = fileparts(mfilename('fullpath'));
    chdir(mypath);
    
    % Load the root path
    if ~exist('pathdef.mat', 'file')
        chdir(current_dir);
        error('I cannot find the path definition data file, please reset it using this func or reinstall this toolbox.');
    else
        pathroot = load('pathdef.mat', 'pathroot');
        pathroot = pathroot.pathroot;
        toolbox_path = pathroot;
    end
end

chdir(current_dir);

end

