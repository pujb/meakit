function [ mmse_mean mmse_std ] = util_calc_mmse( spif, gnds, varargin)
%UTIL_CALC_MMSE Calc Multivariate Multiscale Entropy from SPIF
%   For detailed information, check PHYSICAL REVIEW E 84, 061918 (2011)
%
%   Input:
%           spif:           Spike Information Structure
%           gnds:           Grounding electrode, and other electrodes you want to
%                           exclude.
%           only_activ_ch:  Calc MMSE only on active electrodes, based on
%                           threshold. [default: 1]
%           threshold:      Used with only_activ_ch, [default: 1]
%           binwidth:       Bin width for coarse procedure, [default: 1000 in ms]
%           scales:         Default: 20
%           reps:           How many times you want to calc on the same
%                           scale. [default: 5]
%
%
%   Output:
%           mmse_mean:      Mean MMSE (kk times)
%           mmse_std:       STD of MMSE_MEAN
%
%   Examples:
%           [mmse_mean mmse_std] = util_calc_mmse( spif, 15, 'only_activ_ch', 1, 'threshold', 5, 'binwidth', 1000)
%
%   Created on Sep/14/2012 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2012-09-15  Adding varibles check and progressing information.

pvpmod(varargin);

if ~exist('only_activ_ch', 'var')
    only_activ_ch = 1;
end

if ~exist('threshold', 'var')
    threshold = 1;
end

if ~exist('binwidth', 'var')
    binwidth = 1000;
end

if ~exist('scales', 'var')
    scales = 20;
end

if ~exist('reps', 'var')
    reps = 5;
end


fprintf('Parsing bins... '); tic;
network_vectors = util_calc_network_vector( spif, gnds, 'only_activ_ch', only_activ_ch, 'threshold', threshold, 'bin', binwidth); t = fix(toc);
fprintf(' Done ~ %d seconds, %d active channels. %d datapoints in each channel.\n', t, size(network_vectors, 1), size(network_vectors, 2));
if size(network_vectors, 1) < 3
    disp('Not enough active channels'); mmse_mean=0; mmse_std=0;
    return;
end

network_vectors = network_vectors';


% Coarse Procedure
MM = full(max(network_vectors, [], 1));
mm = full(min(network_vectors, [], 1));

for i = 1:size(network_vectors, 2)
    network_vectors(:, i) = (network_vectors(:, i) - mm(i)) / (MM(i) - mm(i));
end

network_vectors = zscore(network_vectors);

% Get MMSE
[n,b]=size(network_vectors);
sd = sum(std(network_vectors));
r = 0.15*sd;
epsilon=scales;

util_show_progress_init('rounding');
fprintf('Calculating MMSE... '); tic;
workload = 0;

%
% PLEASE NOTE: KK means how many times do you want to calc to get the avg
% of MMSE. and epsilon means the scale factor.
%
for kk=1:reps
    % The scale factor means the non-overlapping moving window of the time
    % series in the width of epsilon
    for j=1:epsilon
        for p=1:b
            % extract network_vectors(:,p) first to improve speed
            time_series = network_vectors(:,p);
            for i=1:n/j
                y(i)=0;
                for k=1:j
                    %y(i)=y(i)+network_vectors((i-1)*j+k,p);
                    y(i)=y(i)+time_series((i-1)*j+k);
                end
                y(i)=y(i)/j;
            end
            z=y(1:floor(n/j));
            X(:,p)=z;
        end
        M = ones(1,b) * 2;
        tau=ones(1,b);
        e=mvsampen_full(M,r,tau,X');
        SE(j)=e;
        clear X;
        workload = workload + 1;
        util_show_progress_rounding(workload/(kk*epsilon));
        %disp(['epsilon=' num2str(j) ',kk=' num2str(kk)])
    end
    MSE(kk,:)=SE;
end

% disp 'done'
t = fix(toc);
util_show_progress_rounding(100);
fprintf('Procedure used ~ %d seconds.\n', t);

mmse_mean= mean(MSE,1);
mmse_std=std(MSE,1,1);

figure
errorbar(mmse_mean,mmse_std,'-ob')

end

