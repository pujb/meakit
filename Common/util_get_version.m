function result = util_get_version()
%UTIL_GET_VERSION Get the current version the installed UTIL toolbox
%   The version format is in MAJOR_VERSION.MINOR_VERSION.CHANGESTEPS
%
%
%   Created on Sep/17/2012 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

% Save current path
bak = pwd;

% Change path to version info
util_root = util_get_toolbox_root();
cd ([util_root filesep 'InstallationMarker']);

% Load version info
load('version.mat', 'version');

% Return to bak path
cd (bak);

result = version;

end

