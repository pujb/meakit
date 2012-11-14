function [ handle ] = util_load_nsfile( filename )
%UTIL_LOAD_NSFILE Read a data file in Neuroshare format then returns a handle.
%   Open a data file which is supported in Neuroshare, then returns the
%   file handle.
%
%   Created on Jun/10/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

% Open data file
[nsresult, handle] = ns_OpenFile(filename);

% Check if open successfully
if nsresult ~= 0
    util_disp_ns_errcode(nsresult, true);
    error('Opening data file failed.');
end

end

