function [ spif ] = util_convert_spif_with_amplitude( d, spif )
%UTIL_CONVERT_SPIF_WITH_AMPLITUDE Process the spike amplitude values in the
%spif structure to the actual amplitude values. After convertion, spif will
%be marked with a flag to avoid second time convertion.
%   Input:
%           d:      MCD file object.
%           spif:   Spike information structure.
%   Output:
%           spif:   Spike information with converted actual amplitudes
%
%   Created on Sep/18/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

% Check the spif convertion flag
if isfield(spif, 'amp_converted')
    if spif.amp_converted
        converted = true;
    else
        converted = false;
    end
else
    converted = false;
end

if converted
    disp('This file has been converted to actual amplitude values. Quit...');
else
    for hwid = 1:64
        spif.spikevalues{hwid} = ad2muvolt( d, spif.spikevalues{hwid} );
    end
    spif.amp_converted = true;
    spif.amp_unit = 'uV';
end

end

