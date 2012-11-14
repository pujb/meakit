function [ stream_name stream_number hwid chidx chid sub_digi_ch ] = util_resolve_nsentity_label( entity_label, label_type )
%UTIL_RESOLVE_NSENTITY_LABEL Resolve the Neuroshare entity label
%   The entity label contains all information of the entity, e.g. the
%   channel name and the stream type. 
%   Please refer to the MCS API PDF.
%
%   Input:
%       entity_label:   usually, you can get this label from entity info
%                       structure.
%       label_type:     'MCD' or 'RAW' or 'SPK'
%   Output:
%       stream_name:    Stream name, e.g. elec/digi
%       stream_number:  Stream Number, e.g. 0/1/2
%       hwid:           Hardware ID, this is different from hwid in
%                       util_convert_hwid2chid, because, in the later, the
%                       hwid is actually the serial index in the spif
%                       structure but not the hardware index.
%       chidx:          Index of channel, e.g. 0/1/2
%       chid:           Channel ID, the name of the channel
%       sub_digi_ch:    Only in event entities of digital data, the sub
%                       channel of events of digital data.
%
%   Created on Jun/11/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

if strcmpi(label_type, 'MCD')
    stream_name = entity_label(1:4);
    stream_number = str2double(entity_label(5:8));
    hwid = str2double(entity_label(10:13));
    chidx = str2double(entity_label(15:18));
    
    % Determine if the channel name is a number
    chid = str2double(strtrim(entity_label(20:27)));
    if ~strcmpi(num2str(chid), strtrim(entity_label(20:27)))
        % If the channel name contains string, then return as a string.
        chid = strtrim(entity_label(20:27));
    end
    
    % If in event entities of digital data (not all digital data contains
    % these 2 digis.
    if strcmpi(stream_name, 'digi') && (length(entity_label) > 27)
        sub_digi_ch = str2double(entity_label(29:30));
    else
        sub_digi_ch = 0;
    end
elseif strcmpi(label_type, 'RAW')
    disp('Not yet implemented.');
elseif strcmpi(label_type, 'SPK')
    disp('Not yet implemented.');
end


end

