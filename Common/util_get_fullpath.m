function [ fullpath ] = util_get_fullpath( thepath )
%UTIL_GET_FULLPATH Get the full path from either full path or relative
%path. (Only can be used with path, not filename)
%
%   Created on Aug/18/2009 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

pwd_push = pwd;
cd(thepath);
fullpath = pwd;
cd(pwd_push);

end

