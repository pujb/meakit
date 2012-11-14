function [ connections neuron_e_i_type neuron_self_firing_type ] = util_setup_model( varargin )
%UTIL_SETUP_MODEL Init the network model.
%   Input:
%       neuron_number:          The number of neurons. [default:1000]
%       synapse_mean_number:    The average number of synapses of one
%                               neuron. [default:50]
%       synapse_err_number:     The deviation number of synases from the
%                               mean. [default:15]
%                               "50+/-15, it follows Gaussian Distribution"
%       area_side_length:       The side length of the square area. Unit:
%                               micro meter. [default:3000]
%       excitatory_percent:     The percentage of excitatory neurons in
%                               total. [default:0.7]
%       self_firing_percent:    The percentage of self-firing neurons in
%                               total. [default:0.3]
%       standard_of_nearby:     The standard of judging near-by neurons.
%                               All neurons of which distance to the
%                               current neuron <= this standard will be
%                               connected to the current neuron. Unit:
%                               micro meter. [default:15]
%       dist_limit_scope:       When we are arranging the location of
%                               neurons, it cannot be exactly the same
%                               value as the distribution wants. So this
%                               value can use to setup a range of
%                               acceptance. [default:20]
%   Output:
%       connection:             A structure holds all connections
%                               (neuron-ids and the corresponding
%                               connection length).
%       neuron_e_i_type:        To indicate the id (index) of neuron,
%                               whether it is excitatory or inhibitory.
%       neuron_self_firing_type:To indicate the id (index) of neuron,
%                               whether it is self-firing.
%
%   Created on Oct/20/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

pvpmod(varargin);

if ~exist('neuron_number', 'var')
    % The number of neurons
    neuron_number = 1000;
end

if ~exist('synapse_mean_number', 'var')
    % The mean number of synapses of each neuron
    synapse_mean_number = 50;
end

if ~exist('synapse_err_number', 'var')
    % The variation of mean number of synapses of each neuron
    synapse_err_number = 15;
end

if ~exist('area_side_length', 'var')
    % The designated area is 3000 * 3000
    area_side_length = 3000;
end




end

