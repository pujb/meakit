function [ bp bp_std bp_sem bp_1 bp_1_std bp_1_sem ] = util_calc_avalanche_branching_parameter( ava_length, ava_vector, varargin )
%UTIL_CALC_AVALANCHE_BRANCHING_PARAMETER Calculate the branching parameter
%of neuronal avalanches.
%   Based on the results of avalanche detection. We first calculate the
%   number of ancestors and descendants in each avalanche (na, nd).
%   Then, d = nd / na. (if length = 1, then nd = 0).
%   Then, pd = the probability of d's existence.
%   Finally, bp = sum(d*pd);
%
%   Reference:
%              Journal of Neuroscience Methods 169 (2008) 405¨C416 - 'spk'
%              The Journal of Neuroscience 23(35) (2003) 11167¨C11177 - 'elec'
%
%   Input:
%           ava_length:   The length of each avalanche (number of bins)
%           ava_vector:   Which electrodes are active in each bin
%           method:       'elec': Electrode ancestor / descendant [default]
%                         'spk' : Spike ancestor / descendant
%           network_vectors: The returned network_vectors after detecting
%                         avalanches. (needed when method = 'spk')
%           ava_loc:      The start bin of each avalanche.
%                         (needed when method = 'spk')
%           precision:    Bin precision, default = 0.001
%   Output:
%           bp:           Branching parameter (sigma).
%           bp_1:         Assuming only one ancestor.
%   
%   Example:
%           [ bp ] = util_calc_avalanche_branching_parameter( lengths,
%           vectors, 'method', 'spk', 'network_vectors', network_vectors,
%           'ava_loc', locations );
%       
%           [ bp ] = util_calc_avalanche_branching_parameter( lengths,
%           vectors );
%
%   Created on Sep/16/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2011-03-07  Change the algorithm to match the new storage
%                       pattern of "ava_vector" which is the output of
%                       util_detect_avalanche (a.k.a vector).
%       PJB#2011-03-08  Adding bp_1 output.


% Check parameters
pvpmod(varargin);

if ~exist('method', 'var')
    method = 'elec';
end

if ~exist('precision', 'var')
    precision = 0.001;
end

if strcmpi(method, 'spk')
    if ~exist('network_vectors', 'var') || ~exist('ava_loc', 'var')
        error('network_vectors and ava_loc must be provided.');
    end
elseif strcmpi(method, 'elec')
    % do nothing
else
    error(['Not supported method - ' method]);
end

% Number of avalanches
num_ava = length(ava_length);

if strcmpi(method, 'spk')
    % LFP ancestors / descendants, refer to JNM paper.
    
    % init
    d = zeros(1, num_ava);
    
    % loop to find d
    for i = 1:num_ava
        if ava_length(i) == 1
            d(i) = 0;   % Because nd = 0
        else
            d(i) = sum(network_vectors(:, ava_loc(i) + 1)) / sum(network_vectors(:, ava_loc(i)));
        end
    end
    
    % Calc the probability of each d
    bp = 0;
    edges = [0:precision:max(d)];
    pd = histc(d, edges) / length(d);
    for i = 1:length(edges)
        if i < length(edges)
            values = d( (d >= edges(i)) & (d < edges(i+1)));
        else
            values = d( (d >= edges(i)) );
        end
        bp = bp + sum(values * pd(i));
    end
elseif strcmpi(method, 'elec')
    % Electrode ancestors / descendants, refer to JNS / JNM paper.
    % Please note, we do not follows the algorithms in JNS paper exactly.
    % But the basic concept is identical.
    
    % init
    d = zeros(1, num_ava, 'double');
    n_a_individual = zeros(1, num_ava, 'double');
    n_d_individual = zeros(1, num_ava, 'double');
    
    % Collecting ancestors and descendants in all avalanches
    for i = 1:num_ava
        current_avalanche_frames = ava_vector{i};
        % Collecting number of electrode ancestors in each avalanche
        n_a_individual(i) = length(current_avalanche_frames{1});
        % Collecting number of electrode descendants in each avalanche
        if size(current_avalanche_frames, 2) >= 2
            n_d_individual(i) = length(current_avalanche_frames{2});
        else
            n_d_individual(i) = 0;
        end
        
        %d(i) = ( n_d_individual(i) / n_a_individual(i) );
        d(i) = round(n_d_individual(i) / n_a_individual(i));
    end

    bp = mean(d);
    bp_std = std(d);
    bp_sem = util_calc_sem(d);
    
    bp_1 = mean(n_d_individual);
    bp_1_std = std(n_d_individual);
    bp_1_sem = util_calc_sem(n_d_individual);
end

end

