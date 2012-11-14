function [ sem ] = util_calc_sem( vector )
%UTIL_CALC_SEM Get the standard error of the mean (SEM)
%   Calculate the standard error of the mean.
%   
%   Jiangbo Pu / May-31-2010

sem = std(vector) / sqrt( length(vector) );

end

