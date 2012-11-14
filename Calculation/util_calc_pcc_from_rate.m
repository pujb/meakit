function [ pcc ] = util_calc_pcc_from_rate( spif, varargin )
%UTIL_CALC_PCC_FROM_RATE Get Pearson Corr. between electrodes v.s. Time
%   Input:
%           spif:       Spike information structure
%           bin:        Bin width, default = 1000 ms.
%           bin_int:    Bin width, for counting spike rate, default = 100 ms.
%           startend:    Section width, used for separating the whole data into
%                       several segments, to avoid OUT OF MEMORY.
%                       default = [], i.e: All, but you can provide bin number to separate it. 
%                       Note: [start end] are in bins, not times in ms./s.
%           gnd:        Grounding electrode. default = [].
%                       If you provide [15], it will automatically add four
%                       corner electrodes.
%           threshold: 
%                       if spike per bin of any channel < threshold, the
%                       channel will be removed (not an active channel).
%                       THIS WILL NOT AFFECT THE OUTPUT OF electrode*
%
%
%   Output:
%          elec_sd: S.D. per electrode v.s Time
%
%   Created on Jun/08/2012 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%       PJB#2012-06-15 CHG: Add sectioned calculation support.

% Analyzing parameters
pvpmod(varargin);

if ~exist('bin', 'var')
    bin = 1000;
end

if ~exist('bin_int', 'var')
    bin_int = 100;
end

if ~exist('gnd', 'var')
    gnd = [];
end

if ~exist('threshold', 'var')
    threshold = 0;
end

if  ~exist('startend', 'var')
    startend = [];
end

% Get firing rate
[ ~,~,~,~, rate, ~,~,~ ] = util_calc_rate( spif, 'bin', bin_int, 'gnd', gnd, 'threshold', threshold, 'mode', 'electrode' );

% Determine STARTEND
n_bins = size(rate, 1);
if startend(2) > n_bins || startend(1) < 1 || startend(1) > startend(2)
    error('STARTEND should be in correct bin range.')
end

% Slice the data by STARTEND
rate = rate(startend, :);

% Get sliding window length
w_len = fix(bin/bin_int);

fprintf('Working...')
pcc = util_moving_window(rate, w_len, 'cont', @corr);
fprintf('Done.\n')

end

