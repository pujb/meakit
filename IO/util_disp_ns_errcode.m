function [errmsg] = util_disp_ns_errcode( errcode, dodisp )
%UTIL_DISP_NS_ERRCODE Display the meaning of Neuroshare error code
%   According to
%   http://neuroshare.sourceforge.net/Matlab-Import-Filter/NeuroshareMatlabAPI-2-2.htm#Installation
%   
%   if 'dodisp' is true, the function will display the error message, or you
%   can display for yourself using the returned 'errmsg'.
%   
%   Created on Jun/10/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

switch errcode
    case 0
        errmsg = 'Function successful.';
    case -1
        errmsg = 'Generic linked library error.';
    case -2
        errmsg = 'Library unable to open file type.';
    case -3
        errmsg = 'File access or read error.';
    case -4
        errmsg = 'Invalid file handle passed to function';
    case -5
        errmsg = 'Invalid or inappropriate entity identifier specified';
    case -6
        errmsg = 'Invalid source identifier specified';
    case -7
        errmsg = 'Invalid entity index specified';
    otherwise
        errmsg = 'Unexpected error.';
end

if dodisp == true
    disp(errmsg);
end
end

