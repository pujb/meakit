function [filtData, myfit] = SALPA(data, N, rails, NPrePeg, NPostPeg, NPostFit, SalpaThresh, StimTimes)
%SALPA Filter data with Wagenaar and Potter's SALPA algorithm.
%    y = SALPA(data, N, rails, NPrePeg, NPostPeg, NPostFit, SalpaThresh, StimTimes)
%    returns the filtered signal 'y'.
%
%    Input arguments are as follows:
%       data: (samples x channels) matrix of data to filter
%       N: half-width of filter (in samples)
%       rails: 2 x channels matrix of filter's rails (negative rail in row
%           1, positive rail in row 2)
%       NPrePeg: number of samples to blank before a rail (peg)
%       NPostPeg: number of samples to blank after a rail
%       NPostFit: number of samples to blank after a successful fit (avoids
%          ringing)
%       SalpaThresh: threshold of data
%       StimTimes: list of indices at which a stim pulse occured
%
%    [filteredData, fit] = SALPA(...) returns the calculated fit in
%    addition to the filtered data.
% 
%    Created by: John Rolston (rolston2@gmail.com)
%    Created on: June 26, 2007
%    Last modified: May 7, 2009
%    
%    Licensed under the GPL: http://www.gnu.org/licenses/gpl.txt
%
%    Thanks to Jon Erickson for help debugging.

n = -N:N;
T = zeros(1,7);
for k = 0:6
    T(k+1) = sum(n.^k);
end

%setup S_kl
S = zeros(4,4);
for k = 0:3
    for l = 0:3
        S(k+1,l+1) = T(k+l+1);
    end
end

if (nargout == 1)
    filtData = SALPAmex4(data, N, inv(S), rails, NPrePeg, NPostPeg, NPostFit, SalpaThresh, StimTimes);
elseif (nargout == 2)
    [filtData, myfit] = SALPAmex4(data, N, inv(S), rails, NPrePeg, NPostPeg, NPostFit, SalpaThresh, StimTimes);
end