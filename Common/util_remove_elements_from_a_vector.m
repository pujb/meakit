function [ vector ] = util_remove_elements_from_a_vector( vector, standard )
%UTIL_REMOVE_ELEMENTS_FROM_A_VECTOR Delete elements from a vector by a
%given standard.
%   Input:
%           vector:     The given vector.
%           standard:   The given standard.
%                       'nan' / 'empty': All nan/empty elements will be
%                                        removed.
%                       other: All elements == standard will be removed.
%   Output:
%           vector:     The modified vector.
%
%   Created on Mar/22/2011 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

if strcmpi(standard, 'nan')
    vector(isnan(vector)) = [];
elseif strcmpi(standard, 'empty')
    vector(isempty(vector)) = [];
else
    vector(vector == standard) = [];
end


end

