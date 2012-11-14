function [ converted ] = util_escape_string( inputs )
%UTIL_ESCAPE_STRING Convert escape sequence into string
%   We just replace '\' into '\\'
%
%   Created on Aug/17/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

converted = strrep(inputs, '\', '\\');

end

