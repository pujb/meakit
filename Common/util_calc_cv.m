function [ cv ] = util_calc_cv( vector )
%UTIL_CALC_CV Get the coefficient of variation of the given vector.
%   Input:
%           vector:     Given vector;
%   Output:
%           cv:         The ratio of the standard deviation to the mean.
%
%   Comparison to standard deviation [wiki]
%   * Advantages:
%   The coefficient of variation is useful because the standard deviation of
%   data must always be understood in the context of the mean of the data. 
%   The coefficient of variation is a dimensionless number. 
%   So when comparing between data sets with different units or widely different means, 
%   one should use the coefficient of variation for comparison instead of the standard deviation.
%   * Disadvantages:
%   When the mean value is near zero, the coefficient of variation is
%   sensitive to small changes in the mean, limiting its usefulness.
%   Unlike the standard deviation, it cannot be used to construct confidence intervals for the mean.
%
%   Created on Aug/24/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

mean_v = mean(vector);
if mean_v == 0
    error('CV is only defined when MEAN is not ZERO.');
end

cv = std(vector) / mean_v;

end

