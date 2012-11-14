function util_setup(varargin)
%UTIL_SETUP The installer/updater of the toolbox
%   If method is 'install', we will add the necessary paths to the
%   system path, if the method is 'remove', we will remove the existing
%   version.
%
%   util_setup(method)
%   
%   method: 'remove'  - Remove paths
%           'install' - Add paths
%           'install-nosavepath' - Add paths but not save it
%
%   Created on Aug/14/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2012-09-10  Now the installer can automatically uninstall the previous version if exists.
%       PJB#2012-09-17  The installer now saves the path by default.
%                       The version information has been moved into the
%                       InstallationMaker folder and been kept as a mat
%                       file.

% Get parameter
if nargin == 1
    method = varargin{1};
else
    help util_setup
    return;
end
   
% Notify the user
if strcmpi(method, 'install') || strcmpi(method, 'install-nosavepath')
    disp('Please make sure you have the latest MCINTFAC from MCS.');
    pause;
end

% Get the path of setup file, which is also the root of UTIL toolbox
try
    mpath = mfilename('fullpath');
catch
    dbs = dbstack;
    mpath = dbs.name;
end

% Remove the filename from the path
temp = strfind( mpath, filesep );
mpath( temp(end) : end ) = [];

% Temporarily add COMMON to path
findtool = which('util_get_subdirs');
if isempty(findtool)
    addpath([mpath filesep 'Common']);
end

% Directory we want to add into the system path
toolbox_paths = util_get_subdirs(mpath, false, true, util_setup_excluded_path(mpath));

% Remove the temporarily added path
if isempty(findtool)
    rmpath([mpath filesep 'Common']);
end

if strcmpi(method, 'remove')
    % Remove all paths
    for i = 1:length(toolbox_paths)
        rmpath(toolbox_paths{i});
    end
    disp('MEAKIT matlab toolbox has been removed');
elseif strcmpi(method, 'install') || strcmpi(method, 'install-nosavepath')
    
    % Check if need to uninstall previous version
    if (util_setup_check_if_installed)
        % Remove all paths
        for i = 1:length(toolbox_paths)
            rmpath(toolbox_paths{i});
        end
        disp('Removing previous installation of UTIL toolbox...');
    end
    
    
    % Add paths
    for i = 1:length(toolbox_paths)
        addpath(toolbox_paths{i});
    end
    util_get_toolbox_root(mpath);
    disp(['MEAKIT matlab toolbox v.' util_get_version() ' has been installed']);
end

if strcmpi(method, 'install-nosavepath')
    disp(' ');
    disp('Note: The paths are not saved. Please use savepath command to make the path changes permanent.');
end

end

function paths = util_setup_excluded_path(root)
%UTIL_SETUP_EXCLUDED_PATH The path you dont want to add to the system path
paths = {[root filesep 'Otherbox' filesep 'FIND'], ...
         [root filesep 'Help'], ...
         [root filesep 'For_Papers']};
end

function result = util_setup_check_if_installed()
paths = path;
indice = strfind(paths, 'util\InstallationMarker');
if isempty(indice)
    result = 0;
else
    result = 1;
end
end
