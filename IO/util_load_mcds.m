function [ spif triggerif d ] = util_load_mcds( opmode, varargin )
%UTIL_LOAD_MCDS Read MCD files.
%   This is a shortcut for
%   util_load_spike_trigger_mcdstream_from_multiple_files
%   and util_load_spike_trigger_mcdstream
%   Please refer to the original function.
%
%   Input:
%           opmode: 'one' / 'mult'
%                   one = open only one file, that will return a D as
%                   mcdata object
%                   mult = open multiple files, D will be empty.
%   Output:
%           spif, triggerif: Information struture for spikes and triggers.
%           D:      MC Data objects, only valid when opmode = 'one'.
%
%   Created on Oct/11/2012 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2012-11-05  Added opmode, so that the function could return
%                       D when opmode = 'one'.

if strcmpi(opmode, 'one')
    [d, spif, triggerif] = util_load_spike_trigger_mcdstream(varargin{:});
elseif strcmpi(opmode, 'mult')
    [spif, triggerif] = util_load_spike_trigger_mcdstream_from_multiple_files(varargin{:});
    d = [];
else
    help util_load_mcds
    disp(' ');
    error('Wrong inputs - opmode, please refer to help documents.');
end

