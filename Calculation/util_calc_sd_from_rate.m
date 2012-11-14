function [ elec_sd ] = util_calc_sd_from_rate( spif, varargin )
%UTIL_CALC_SD_FROM_RATE Get the S.D. of every electrode (based on Spike
%rate)
%   Input:
%           spif:   Spike information structure
%           bin:    Bin width, default = 1000 ms.
%           bin_int:Bin width, for counting spike rate, default = 100 ms.
%           gnd:    Grounding electrode. default = [].
%                   If you provide [15], it will automatically add four
%                   corner electrodes.
%           threshold: 
%                   if spike per bin of any channel < threshold, the
%                   channel will be removed (not an active channel).
%                   THIS WILL NOT AFFECT THE OUTPUT OF electrode*
%
%
%   Output:
%          elec_sd: S.D. per electrode v.s Time
%
%   Created on Jun/08/2012 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2012-06-10 CHG: Remove normalization: Rate normalization
%                      should be performed using mean rate of each
%                      recording session.
%       PJB#2012-06-11 CHG: Add Multi-core support.


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

% Get firing rate
[ ~,~,~,~, rate, ~,~,~ ] = util_calc_rate( spif, 'bin', bin_int, 'gnd', gnd, 'threshold', threshold, 'mode', 'electrode' );

n_elec = size(rate, 2);
n_bins = size(rate, 1);

% Get sliding window length
w_len = fix(bin/bin_int);
elec_sd = zeros(n_bins-w_len+2, n_elec);

fprintf('Working...Elec.')

% Matlabpool
% If we didn't start multiple workers, start them now
if matlabpool('size') == 0
    matlabpool;
end

parfor i = 1:n_elec
    % Don't Normalize by simply using mean rate, Because the firing rate in
    % the long-term recording is always near 1 or just NaN
    % rate(:,i) = rate(:,i) / mean(rate(:,i));
    % util_show_workinfo(['elec.' num2str(util_convert_hw2ch(i)) ' rate bin [' num2str(bin_int) ' ms], window [' num2str(w_len) '/' num2str(n_bins) ']'], 0);
    fprintf([num2str(util_convert_hw2ch(i)) '.']);
    elec_sd(:,i) = util_moving_window(rate(:,i), w_len, 'cont', @std);
end

fprintf('Done.\n')


end

