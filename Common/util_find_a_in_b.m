function [ isFind loc_a loc_b ] = util_find_a_in_b( a, b, varargin )
%UTIL_FIND_A_IN_B Find whether one element of B equals each element of A
%   Looking into all elements of the collection B, to find out if one or
%   more elements equals the value of each element in A. If no elements in 
%   B equals A, then it returns false; else it will return true and the
%   first location of the matched elements in b.
%
%   Input:
%       a,b:    Both should be a 1D array
%       a,b,string_mode:
%               if string_more is true, then a/b must be a cell array like
%               {'one','two','three'}. We will compare these two arrays
%               by each cell.
%   Returns:
%       isFind: The flag indicating the results of all finding. If A
%               contains multiple elements, this flag only reflects the
%               result of all rounds of searching, i.e. if only a matches b
%               just once, it will be true no matter the later searches.
%       loc_a:  The index (in A) of the element which is of a but also
%               found in b.
%       loc_b:  The index (in B) of the element which is of a but also
%               found in b.
%
%   Created on May/4/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

%   $Revision:
%       PJB#2010-06-11  Adding the ability of processing cell array
%                       (numberic/string)

% Get the parameters
pvpmod(varargin);

if ~exist('string_mode', 'var')
    string_mode = false;
end

% Init
isFind = false;
loc_a = [];
loc_b = [];

if string_mode
    % Compare by strings
    
    % Check running condition
    if ~iscell(a) || ~iscell(b)
        error('String mode needs two cell array.');
    end
    
    for i = 1:length(a)
        for j = 1:length(b)
            if strcmp(b{j}, a{i})
                isFind = true;
                loc_a = [loc_a i];
                loc_b = [loc_b j];
            end
        end
    end
else
    % Compare by digits (Numberic Mode)
    for i = 1:length(a)
        % Get the current element in a
        if iscell(a)
            current_a = a{i};
        else
            current_a = a(i);
        end
        
        % Search in b with current_a
        if iscell(b)
            % if b is a cell array, turn it into a matrix temporally
            find_result = find([b{:}] == current_a, 1);
        else
            % if b is a normal matrix
            find_result = find(b == current_a, 1);
        end
        
        if ~isempty( find_result )
            isFind = true;
            loc_a = [loc_a i];
            loc_b = [loc_b find_result];
        end
    end
end
end

