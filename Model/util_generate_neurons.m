function [csim_electrodes csim_neurons csim_synapses] = util_generate_neurons( varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%   The work began on Sep/1/2010
%   The first version of worked distribution was done on Sep/21/2010
%   Modifying distribution started since Oct/1/2010
%   The first version of worked csim connection network was done on
%   Oct/12/2010

pvpmod(varargin);
csim('reset');
csim('destroy');

if ~exist('neuron_number', 'var')
    neuron_number = 1000;
end

if ~exist('excitatory_percent', 'var')
    excitatory_percent = 0.7;
end

if ~exist('self_firing_percent', 'var')
    self_firing_percent = 0.3;
end

if ~exist('conduction_velocity', 'var')
    conduction_velocity = 0.3; % meter / second
end

if ~exist('connection_distribution', 'var')
    connection_distribution = 'normal';
end

AREA_SIZE = 3000;   % Micro-meters
EXCITATORY_FLAG = 1;
INHIBITORY_FLAG = 2;
SYNAPSES_PER_NEURON_MEAN = 50;
SYNAPSES_PER_NEURON_ERROR = 15;
DISTRIBUTION_REFINE_LENGTH_NEARBY_STANDARD = 15;
DISTRIBUTION_RANDOM_SCOPE = 20;

% Generate the locations of neurons randomly
fprintf('\nSetting locations of neurons... ');
neuron_location = randi([0 AREA_SIZE], [neuron_number, 2]);
fprintf('Done.\n');

% Generate the types of neurons randomly
fprintf('Setting types of neurons... ');
excitatory_neuron_number = neuron_number * excitatory_percent;
inhibitory_neuron_number = neuron_number - excitatory_neuron_number;
neuron_type = [ones(1, excitatory_neuron_number) * EXCITATORY_FLAG ones(1, inhibitory_neuron_number) * INHIBITORY_FLAG];
neuron_type = neuron_type(randperm(neuron_number));
fprintf('Done.\n');

% Generate the number of synapses of each individual neurons (normally distributed - Gaussian)
fprintf('Setting synapses number of each neuron... ');
synapse_number = round(SYNAPSES_PER_NEURON_MEAN + SYNAPSES_PER_NEURON_ERROR * randn(neuron_number, 1));
sum_synapse_number = sum(synapse_number);
fprintf('Done.\n');

% Connect neurons accoring to their locations and number of synapses
% coonections.location(:, 1) is x, (:, 2) is y of the neurons connected to
% the current neuron.
fprintf('Constructing connections according to the neural distribution... ');
connections = struct('locations', cell(neuron_number, 1), 'length', cell(neuron_number, 1));
neural_distribution_curve = load_neural_distribution(); % Load distribution curve
for i = 1:neuron_number
    % The location of current neuron
    this_locxy = neuron_location(i, :);
    
    % The ids of neurons will be connected to this neurons
    connected_id = [];
    
    % Get the distances from the current neuron to other neurons
    all_connected_length = zeros(neuron_number, 1);
    for j = 1:neuron_number
        all_connected_length(j) = euclidean_dist(this_locxy, neuron_location(j, :));
    end
    
    % Find all nearby neurons (not itself)
    nearby_index = find( all_connected_length <= DISTRIBUTION_REFINE_LENGTH_NEARBY_STANDARD & all_connected_length ~= 0);
    nearby_index = nearby_index';
    
    % Make sure we do have available synapses to connect more neurons
    num_left_synapses = synapse_number(i) - length(nearby_index);
    
    if num_left_synapses < 0
        % There's not enough synapses, choose those nearest
        distance_of_nearby_index = all_connected_length(nearby_index);
        [~, sorted_index] = sort(distance_of_nearby_index, 1, 'ascend');
        nearby_index = nearby_index(sorted_index);
        % Update the connected id
        connected_id = nearby_index(1:synapse_number(i));
    elseif num_left_synapses == 0
        % Do nothing
        connected_id = nearby_index;
    else
        % Save nearby neurons first
        connected_id = nearby_index;
        % Randomly select the neurons
        % The neurons prefer to connect nearby neighbors, but also some few
        % faraway ones.
        
        % First we should make sure how many neurons left can be choosen
        % randomly (not those nearby ones and itself)
        left_neuron_pool = setdiff((1:neuron_number), [nearby_index i]);
        
        % Select neurons one by one and make sure the connection length is
        % fit to our predefined distribution
        for j = 1:num_left_synapses
            % Randomly select one neuron
            candidate_id = left_neuron_pool(randi(length(left_neuron_pool), 1));
            
            % This can be used to control the probability of keeping the
            % original distribution (1 - x, x is the original%)
            if rand > 1
                connected_id = [connected_id candidate_id];
            else
                % Get the limit
                rand_limit = neuralrnd(neural_distribution_curve);
                % Init search limit (to avoid dead-loops)
                num_searched_neurons = 1;
                % Get distance from current candidate to this neuron
                candidate_distance = euclidean_dist(this_locxy, neuron_location(candidate_id, :));
                while (candidate_distance > rand_limit + DISTRIBUTION_RANDOM_SCOPE || candidate_distance < rand_limit - DISTRIBUTION_RANDOM_SCOPE)
                    % Re-find one candidate
                    candidate_id = left_neuron_pool(randi(length(left_neuron_pool), 1));
                    % Recalc the distance
                    candidate_distance = euclidean_dist(this_locxy, neuron_location(candidate_id, :));
                    
                    % Increase search times
                    num_searched_neurons = num_searched_neurons + 1;
                    % Safety check
                    if num_searched_neurons >= neuron_number - 1
                        % Update the limit to avoid dead-loops
                        rand_limit = neuralrnd(neural_distribution_curve);
                        % Reset search limit
                        num_searched_neurons = 1;
                    end
                end
                % Save
                connected_id = [connected_id candidate_id];
            end
        end
    end

    % Refresh (and save) the location indices (refined)
    connections(i).locations = connected_id;
    
    % Save the lengths (refined)
    connected_locxy = neuron_location(connected_id, :);
    for j = 1:synapse_number(i)
        connections(i).length(j) = euclidean_dist(this_locxy, connected_locxy(j, :));
    end
    
    % Progress
    if ~mod(i, 10)
        util_show_progress_rounding(i/neuron_number*100);
    end
end

% See the distribution of connection length
connection_lengths_all = [];
for i = 1:neuron_number
    connection_lengths_all = [connection_lengths_all connections(i).length];
end
connection_lengths_distribution_bins = 1:3:max(connection_lengths_all);
connection_lengths_distribution = histc(connection_lengths_all, connection_lengths_distribution_bins);
figure, scatter(connection_lengths_distribution_bins, connection_lengths_distribution, '.');
disp('Connection Length Distribution has been plotted.');ylim([0 350]);xlim([0 4500]);title('Connection Length Distribution');xlabel('Connection Length (um)');ylabel('Number of Synapses');

% Connect neurons using CSIM

% Create the object of all neurons
fprintf('\nCreating and setting neuron models... ');
csim_neurons = zeros(neuron_number, 1);
for i = 1:neuron_number
    % Create
    csim_neurons(i) = csim('create', 'LifNeuron');
    % Set properties
    csim('set', csim_neurons(i), 'Vresting', -0.07, 'Vinit', -0.07, 'Vthresh', -0.054, 'Vreset', -0.06, 'Trefract', 0.003, 'Cm', 3e-8, 'Rm', 1e6);
    % Set SELF_FIRING
    if rand <= self_firing_percent
        % This neurons is self-firing
        csim('set', csim_neurons(i), 'Inoise', 30e-9);
    else
        % This neuron is not self-firing.
        csim('set', csim_neurons(i), 'Inoise', 10e-9);
    end
    % Set Excitatory/Inhibitory
    if neuron_type(i) == EXCITATORY_FLAG
        csim('set', csim_neurons(i), 'type', 0);
    elseif neuron_type(i) == INHIBITORY_FLAG
        csim('set', csim_neurons(i), 'type', 1);
    end
end
fprintf('Done.\n');

% Form the synapses
fprintf('Creating and setting synapses models and connecting neurons through synapses... ');
csim_synapses = zeros(sum_synapse_number, 1);
total_count_synapses = 0;
for i = 1:neuron_number
    if neuron_type(i) == EXCITATORY_FLAG
        % All synapses started from this neuron should be STDP excitatory
        % synapses
        for j = 1:synapse_number(i)
            total_count_synapses = total_count_synapses + 1;
            % Create synapse
            csim_synapses(total_count_synapses) = csim('create', 'DynamicStdpSynapse');
            % Calc the connection velocity
            conn_v = euclidean_dist(neuron_location(i, :), neuron_location(connections(i).locations(j), :)) / 1e6 / conduction_velocity;
            % Set properties
            csim('set', csim_synapses(total_count_synapses), 'r0', 1, 'U', 0.5, 'u0', 0.5, 'D', 800e-3, 'F', 1, 'tau', 3e-3, 'Apos', 0.5, 'Aneg', 0.5*1.05/100, 'taupos', 20e-3, 'tauneg', 20e-3, 'Wex', 0.1, 'mupos', 1, 'muneg', 1, 'tauspre', 34e-3, 'tauspost', 75e-3, 'delay', conn_v, 'W', 0.05);
            % Connect
            %csim('connect', csim_neurons(connections(i).locations(j)), csim_neurons(i), csim_synapses(total_count_synapses));
            csim('connect', csim_synapses(total_count_synapses), csim_neurons(i));
            csim('connect', csim_neurons(connections(i).locations(j)), csim_synapses(total_count_synapses));
        end
    elseif neuron_type(i) == INHIBITORY_FLAG
        % All synapses started from this neuron should be inhibitory
        % Frequency-dependent synapses
        for j = 1:synapse_number(i)
            total_count_synapses = total_count_synapses + 1;
            % Create synapse
            csim_synapses(total_count_synapses) = csim('create', 'DynamicSpikingSynapse');
            % Calc the connection velocity
            conn_v = euclidean_dist(neuron_location(i, :), neuron_location(connections(i).locations(j), :)) / 1e6 / conduction_velocity;
            % Set properties
            csim('set', csim_synapses(total_count_synapses), 'r0', 1, 'U', 0.5, 'u0', 0.5, 'D', 800e-3, 'F', 1, 'tau', 3e-3, 'delay', conn_v, 'W', -0.05);
            % Connect
            %csim('connect', csim_neurons(connections(i).locations(j)), csim_neurons(i), csim_synapses(total_count_synapses));
            csim('connect', csim_synapses(total_count_synapses), csim_neurons(i));
            csim('connect', csim_neurons(connections(i).locations(j)), csim_synapses(total_count_synapses));
         end
    end
end
fprintf('Done.\n');

% Create electrodes
fprintf('Creating and connecting electrodes to closest neurons... ');
csim_electrodes = zeros(8, 8);
electrodes_location = zeros(8, 8, 2);
for row = 1:8
    for col = 1:8
        if (row == 1 && col == 1) || (row == 1 && col == 8) || (row == 8 && col == 1) || (row == 8 && col == 8)
            continue;
        end
        % Create
        csim_electrodes(row, col) = csim('create', 'Recorder');
        csim('set', csim_electrodes(row, col), 'dt', 100e-6, 'Tprealloc', 100);
        electrodes_location(row, col, :) = [row * 333, col * 333];
        
        % Connect 5 +/- 1 closest neurons
        
        % How many neurons this recorder?
        rec_number = round(5 + 1 * randn);
        % Search all neurons & Sort
        distance = zeros(neuron_number, 1);
        for i = 1:neuron_number
            distance(i) = euclidean_dist(electrodes_location(row, col, :), neuron_location(i, :));
        end
        [~, sorted_index] = sort(distance, 1, 'ascend');
        % Connect
        for i = 1:rec_number
            csim('connect', csim_electrodes(row, col), csim_neurons(sorted_index(i)), 'Vm');
        end
    end
end
fprintf('Done.\n');

% Plot the network
fprintf('\nCreating model plot... ');
figure, hold on
fprintf('Links... ');
for i = 1:neuron_number
    loc_x = neuron_location(i, 1);
    loc_y = neuron_location(i, 2);
    for j = 1:synapse_number(i)
        conn_id = connections(i).locations(j);
        conn_x = neuron_location(conn_id, 1);
        conn_y = neuron_location(conn_id, 2);
        if neuron_type(i) == EXCITATORY_FLAG
            plot([loc_x conn_x], [loc_y conn_y], 'Color', [1 0 0]);
        elseif neuron_type(i) == INHIBITORY_FLAG
            plot([loc_x conn_x], [loc_y conn_y], 'Color', [0 0 1]);
        end
    end
end
fprintf('Neurons... ');
for i = 1:neuron_number
    loc_x = neuron_location(i, 1);
    loc_y = neuron_location(i, 2);
    if neuron_type(i) == EXCITATORY_FLAG
        scatter(loc_x, loc_y,'MarkerFaceColor', [1 0 0], 'MarkerEdgeColor', [1 1 1], 'SizeData', 60, 'Marker', 'o');
    elseif neuron_type(i) == INHIBITORY_FLAG
        scatter(loc_x, loc_y,'MarkerFaceColor', [0 0 1], 'MarkerEdgeColor', [1 1 1], 'SizeData', 60, 'Marker', 's');
    end
end
fprintf('Electrodes... ');
for row = 1:8
    for col = 1:8
        if (row == 1 && col == 1) || (row == 1 && col == 8) || (row == 8 && col == 1) || (row == 8 && col == 8)
            continue;
        end
        scatter(electrodes_location(row, col, 1),electrodes_location(row, col, 2), 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', 'none', 'SizeData', 144);
    end
end
hold off;
fprintf('Done.\n');

% Set the network
csim('set', 'dt', 100e-6);

end

function distance = euclidean_dist(a, b)
% Calculate the eulidean distance between two points, a and b.
% a(1) = a.x, a(2) = a.y
distance = sqrt((b(1) - a(1)) ^ 2 + (b(2) - a(2)) ^ 2);
end

function number = neuralrnd(neural_distribution_curve)
number = anyrnd(neural_distribution_curve, 1, 1);
end

function distribution = load_neural_distribution()
distribution = load([util_get_toolbox_root() filesep 'Model' filesep 'connection_length_distribution.mat'], 'neural_distribution_curve');
distribution = distribution.neural_distribution_curve;
% enlength to 4.14
new_i = [distribution(:,1); (4002:4140)'];  % The original size is (4001,2).
new_v = [distribution(:,2);ones(4140-4001,1)*distribution(end,2)];
distribution = [new_i new_v];
distribution(:,2) = distribution(:,2) + 5;
end