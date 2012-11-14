function [ dllpath dllname ] = util_load_nsdll( filetype, dodisp )
%UTIL_LOAD_NSDLL Load the corresponding Neuroshare dll according to the filetype
%   Because Neuroshare requires the path to a specific dll while reading,
%   this function simply returns the dll path according to the file type.
%   Input:
%       filetype:   MCD or RAW or SPK.
%           MCD is for Multichannel Systems' data type.
%           RAW/SPK is reserved for MEAKIT's data type.
%       dodisp:     True then the function will display the information.
%
%   Returns:
%       dllpath:    The absolute path of the dll.
%       dllname:    The name of the dll.
%
%   Created on Jun/10/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

% Get path

if strcmpi(filetype, 'MCD')
    dllpath = 'D:\';
    dllname = 'nsMCDLibrary.dll';
elseif strcmpi(filetype, 'RAW')
    disp('Not yet implemented.');
elseif strcmpi(filetype, 'SPK')
    disp('Not yet implemented.');
end

% Load Neuroshare DLL

% Because ns_SetLibrary cannot receive a path with a space like this:
%   D:\Software Profiles\matlab\util\IO\mcd\neuroshare\nsMCDLibrary\nsMCDLibrary.dll
% So we have to change the current directory to the dll path, then do the
% loading.

current_directory = pwd;
cd(dllpath);
[nsresult] = ns_SetLibrary(dllname);
cd(current_directory);

% Check the library
if nsresult ~= 0
    util_disp_ns_errcode(nsresult, true);
    error('Loading DLL failed.');
end

% Display Library Version (depends on dodisp)
if dodisp
    [nsresult nsLibraryInfo] = ns_GetLibraryInfo();
    if nsresult ~= 0
        util_disp_ns_errcode(nsresult, true);
        error('Reading DLL failed.');
    end

    disp(['Successfully loaded library: ' dllname]);
    disp(['v.' num2str(nsLibraryInfo.LibVersionMaj) '.' num2str(nsLibraryInfo.LibVersionMin) ...
          ' for API v.' num2str(nsLibraryInfo.APIVersionMaj) '.' num2str(nsLibraryInfo.APIVersionMin) ...
          ' on ' num2str(nsLibraryInfo.Time_Year) '/' num2str(nsLibraryInfo.Time_Month) '/' num2str(nsLibraryInfo.Time_Day)]);
    disp(' ');
end
end

