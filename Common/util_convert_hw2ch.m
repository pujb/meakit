function [results] = util_convert_hw2ch(input)
%UTIL_CONVERT_CH2HW Convert hardware ID into channel ID
%   Accept serials as in 64 channels, return locations in 8*8
%   Input:
%       results:    Hardware ID (1 ~ 64)
%   Output:
%       input:      Channel ID (12 ~ 87)
%
%   Created on Apr/15/2008 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

%   $Revision:
%       PJB#2010-07-22  Make this function to accept a vector, not only a
%                       number.
%   
results = zeros(1, length(input), 'double');

for i = 1:length(input)
    results(i) = ceil(input(i)/8)*2 + input(i) + 8;
end
end
