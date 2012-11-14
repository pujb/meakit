function result = util_check_two_files_are_continuous_recording( filenames, timestamps )
%UTIL_CHECK_TWO_FILES_ARE_CONTINUOUS_RECORDING Check if the given two files
%are recorded continously (like ..., ...0001.mcd)
%   Input:
%           filenames:  Cell array of filenames (used to compare their names)
%           timestamps: Recording start time (in datenum).
%   Output:
%           Returns true if two are recorded continously.
%
%   Created on Sep/07/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

% First check if two files have identified recording start time
if timestamps(1) == timestamps(2)
    % Check if two files have identified names
    % e.g. n1237-20070811 spike 600s0001.mcd
    
    name1 = filenames{1};
    name2 = filenames{2};
    findresult1 = regexpi(name1, '(?x)[0-9][0-9][0-9][0-9].mcd', 'once');
    findresult2 = regexpi(name2, '(?x)[0-9][0-9][0-9][0-9].mcd', 'once');
    
    if isempty(findresult1) && isempty(findresult2)
        % The same start time, but neither have *000? filename
        result = false;
        return;
    end
    
    if isempty(findresult1)
        if strcmpi(name1(1:(findresult2(1)-1)), name2(1:(findresult2(1)-1)))
            result = true;
            return;
        else
            result = false;
            return;
        end
    elseif isempty(findresult2)
        if strcmpi(name1(1:(findresult1(1)-1)), name2(1:(findresult1(1)-1)))
            result = true;
            return;
        else
            result = false;
            return;
        end
    end
    
    result = false;
else
    result = false;
end

end

