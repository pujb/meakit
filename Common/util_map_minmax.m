function [ result ] = util_map_minmax( input, varargin )
%UTIL_MAP_MINMAX Normalize the input matrix by max/min
%   Input:
%           input:  Input data, can be a vector or m-by-n matrix.
%           maxvalue:   Default:1
%           minvalue:   Default:0
%           method:     Default: 'linear'
%
%   Output:
%           result: Normalized output.
%
%
%   Created on Nov/09/2012 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

% Analyze parameter
pvpmod(varargin);

% Set default values
if ~exist('method', 'var')
    method = 'linear';
end

if ~exist('maxvalue', 'var')
    maxvalue = 1;
end

if ~exist('minvalue', 'var')
    minvalue = 0;
end

% Init MaxMin Var
original_maxvalue = 0;
original_minvalue = 0;

% Check inputs
if isscalar(input)
    error('Wrong input - Should be a vector or matrix.');
elseif isvector(input) 
    original_maxvalue = max(input);
    original_minvalue = min(input);
elseif ismatrix(input)
    original_maxvalue = max(max(input));
    original_minvalue = min(min(input));
end

% Check MIN/MAX range
if original_maxvalue-original_minvalue == 0
    error('The input array has the same value for MAX and MIN.');
end

if maxvalue-minvalue == 0
    error('MAXVALUE cannot equals MINVALUE.');
end

% Init Result
result = zeros(size(input));

if strcmpi(method, 'linear')
    % Mapping min/max linearly
    original_maxminvalue = original_maxvalue - original_minvalue;
    maxminvalue = maxvalue - minvalue;
    
    if maxvalue~=1 || minvalue~=0
        adding_value = minvalue;
    else
        adding_value = 0;
    end
    result = arrayfun(@(x) adding_value+((x-original_minvalue)/original_maxminvalue)*maxminvalue, input);
else
    help util_map_minmax
    error('Wrong input - method.');
end


end

