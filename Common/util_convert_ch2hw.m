function [results] = util_convert_ch2hw(input)
%UTIL_CONVERT_CH2HW Convert channel ID into hardware ID
%   Accept locations in 8*8,return serials as in 64 channels
%   Input:
%       input:      Channel ID (12 ~ 87)
%   Output:
%       results:    Hardware ID (1 ~ 64)
%
%   Created on Apr/15/2008 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

%   $Revision:
%       PJB#2010-07-22  Make this function to accept a vector, not only a
%                       number.
%   
results = zeros(1, length(input));

for i = 1:length(input)
    tmp = num2str(input(i));
    a = str2num(tmp(1));
    b = str2num(tmp(2));
    
    results(i) = (a-1)*8 + b;
end
end