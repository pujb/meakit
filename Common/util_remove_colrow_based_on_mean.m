function [result] = util_remove_colrow_based_on_mean(matrix, threshold, varargin)
%UTIL_REMOVE_COLROW_BASED_ON_MEAN Remove the column / row of the matrix by
%a threshold.
%   Averaging along each column / row, removing the one which mean < threshold
%   Input:
%           matrix, threshold.
%           method: 'col'[default] / 'row'
%
%   Created on Dec/12/2008 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2009-06-18  Change name and add comments
%       PJB#2010-08-18  Add 'method'

% Analyze parameter
pvpmod(varargin);

if ~exist('method', 'var')
    method = 'col';
end

if strcmpi(method, 'col')
    % MEAN OF EACH COLUMN
    mean_val = mean(matrix, 1);
    matrix(:, mean_val < threshold | isnan(mean_val) | isempty(mean_val)) = [];
elseif strcmpi(method, 'row')
    % MEAN OF EACH ROW
    mean_val = mean(matrix, 2);
    matrix(mean_val < threshold | isnan(mean_val) | isempty(mean_val), :) = [];
else
    error('Not supported yet.');
end
    
result = matrix;

end