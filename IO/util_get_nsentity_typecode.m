function [ type_code ] = util_get_nsentity_typecode( type_name )
%UTIL_GET_NSENTITY_TYPECODE Translate the Neuroshare entity type name into
%type code.
%   Please refer to:
%   http://neuroshare.sourceforge.net/Matlab-Import-Filter/NeuroshareMatlab
%   API-2-2.htm
%
%   Created on Jun/11/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

switch lower(type_name)
    case 'unknown'
        type_code = 0;
    case 'event'
        type_code = 1;
    case 'analog'
        type_code = 2;
    case 'segment'
        type_code = 3;
    case 'neural'
        type_code = 4;
    otherwise
        warning('CONVERT:INVALID','Invalid entity type name.');
end


end

