function [ type_name ] = util_get_nsentity_typename( type_code )
%UTIL_GET_NSENTITY_TYPENAME Translate the Neuroshare entity type code into
%friendly type name.
%   Please refer to:
%   http://neuroshare.sourceforge.net/Matlab-Import-Filter/NeuroshareMatlab
%   API-2-2.htm
%
%   Created on Jun/10/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

switch type_code
    case 0
        type_name = 'unknown';
    case 1
        type_name = 'event';
    case 2
        type_name = 'analog';
    case 3
        type_name = 'segment';
    case 4
        type_name = 'neural';
    otherwise
        warning('CONVERT:INVALID','Invalid entity code.');
end


end

