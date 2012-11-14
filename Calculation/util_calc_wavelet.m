function [ccfs, bound] = util_calc_wavelet(wavelet_data, Fs, FFTMax)
%UTIL_CALC_WAVELET Summary of this function goes here
%   Detailed explanation goes here

% Wavelet form
wname = 'morl';

% Sampling period
delta = 1/Fs;

% Frequency resolution
Step = 0.2;

% Center frequency (Hz)
cfreq = centfrq(wname, 8);

% Define the frequency
Freq= (0.1:Step:FFTMax);
for j = 1:size(Freq,2)
    % Frequency to scale
    ScaleW(j) = cfreq / (delta*Freq(j));
end

% Wavelet02 calculation
ccfs = cwt(wavelet_data, ScaleW, wname, 'scal');
ccfs = ccfs .^ 2;
ccfs = rot90(ccfs); % Rot array

% Smooth
%ccfsS = smooth(ccfs, size(wavelet_data, 2)*3/100);
ccfsS = smooth(ccfs, 3);
ccfs = reshape(ccfsS, size(ccfs,1), size(ccfs,2));
ccfs = rot90(ccfs);
ccfs = fliplr(ccfs);
ccfs = (ccfs) / (max(max(ccfs(1:(size(ccfs,1)-5),:)))); % Normalize

% Significant area
nSTDs = 2.58;   % 99% significant level
nSTDs95 = 1.96; % 95% significant level
bound = mean(mean(ccfs,1)) + nSTDs95/(size(ccfs,1).^(1/2));



end

