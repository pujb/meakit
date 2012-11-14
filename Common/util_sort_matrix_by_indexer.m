function result = util_sort_matrix_by_indexer(additional_vector, matrix, varargin)
%UTIL_SORT_MATRIX_BY_INDEXER Sort matrix by additional indexing vector
%   The matrix and the additional_vector should have the same number of
%   rows. Usually, each row of the matrix shuold correspond to the row of
%   additional_vector.
%
%   Input:
%           additional_vector:      We will sort this vector and get the
%                                   new indexing which will also be used to
%                                   sort the matrix (by its rows) in the
%                                   same way.
%           matrix:                 You want to rearrange this matrix by
%                                   its rows (columns not changed).
%           method:                 'asc' [default] / 'des'.
%
%   Output:
%           result:                 Sorted matrix.
%
%   Example:
%           util_sort_matrix_by_indexer([3 2 1], [1 2 3; 4 5 6; 7 8 9])
%   then, = 
%           7     8     9
%           4     5     6
%           1     2     3
%
%   Created on Dec/08/2008 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2010-08-18  Adding comments and simplify the coding.
%                       Adding 'method' parameter.


% sort 'additional_vector' and returns the index
[~, indexer] = sort(additional_vector);

result = matrix(indexer, :);

end