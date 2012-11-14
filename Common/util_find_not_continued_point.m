function [ endp ] = util_find_not_continued_point( in_vector, startp, step, method )
%UTIL_FIND_NOT_CONTINUED_POINT Search the input vector to find out the
%first not-continued point in the list
%   Input:
%           in_vector:  Input vector
%           startp:     The start location of the input vector
%           step:       if in_vector(i+1) - in_vector(i) == step, we will
%                       say that the continuity is kept. otherwise, i+1
%                       will be the breakpoint.
%           method:     The comparing method, '>', '>=', '<', '<='
%   Output:
%           endp:       Returns the breakpoint.
%
%   Created on Jul/31/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2011-03-07  Speed up! (not use 'diff' and 'find')

% For speed, we will not check any parameters, BE CAREFUL!

% Old version
% First diff, then find(,1)

if strcmp(method, '>')
    for i = startp:(length(in_vector) - 1)
        if (in_vector(i + 1) - in_vector(i)) > step
            endp = i + startp;
            return;
        end
    end
    endp = [];
elseif strcmp(method, '>=')
    for i = startp:(length(in_vector) - 1)
        if (in_vector(i + 1) - in_vector(i)) >= step
            endp = i + startp;
            return;
        end
    end
    endp = [];
elseif strcmp(method, '<')
    for i = startp:(length(in_vector) - 1)
        if (in_vector(i + 1) - in_vector(i)) < step
            endp = i + startp;
            return;
        end
    end
    endp = [];
elseif strcmp(method, '<=')
    for i = startp:(length(in_vector) - 1)
        if (in_vector(i + 1) - in_vector(i)) <= step
            endp = i + startp;
            return;
        end
    end
    endp = [];
end

end
