function [ number spk_stream ] = util_find_spikestream( D )
%UTIL_FIND_SPIKESTREAM Find SPIKE STREAM in the MCS datafile
%   Return the number and corresponding names of SPIKE STREAMs
%   Input:
%           D:  Datastrm object
%   Output:
%           number: Number of Spike streams
%           spk_stream: Cell array of Spike stream info.
%
%   Created on May/22/2009 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2012-09-15  Added logic to check if the file is broken.

streamCount = getfield(D, 'StreamCount');
streamInfo = getfield(D, 'StreamInfo');

% Check if the file was broken
if isempty(streamInfo)
    error('The given file was broken. No stream info.');
end

% init
number = 0;
spk_stream = {};


for i = 1:streamCount
    if strcmp( streamInfo{i}.DataType, 'spikes' )
        number = number + 1;
        spk_stream{number} = streamInfo{i}.StreamName;
    end
end


end

