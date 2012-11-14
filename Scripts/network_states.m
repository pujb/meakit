[ spif ] = util_load_spike_trigger_mcdstream_from_multiple_files('isCompact',1);
[ ~, spif ] = util_load_spike_trigger_mcdstream('isCompact',1);
%[ network_vectors ] = util_calc_network_vector( spif, [15], 'only_activ_ch', true, 'bin', 1000);
binwidth = 10000;
active_threshold = 10;
[ network_vectors seq ] = util_calc_network_vector( spif, [15], 'only_activ_ch', true, 'bin', binwidth);
[ network_vectors seq ] = util_calc_network_vector( spif, [28], 'only_activ_ch', false, 'bin', binwidth);
bin_table = util_print_bins_with_files('binwidth', binwidth, 'culdate', '2008-12-09');

channel_threshold = mean(max(network_vectors))/2
channel_threshold = 1

[ matrix ] = util_calc_similarity_matrix( network_vectors, 'method', 'allornone', 'threshold', channel_threshold);
figure, imshow(matrix); axis xy, util_set_colorbar( jet ); xlabel(['Bin # (' num2str(binwidth) ' ms)']); ylabel(['Bin # (' num2str(binwidth) ' ms)'])

[mappedX mapping] = compute_mapping(matrix, 'PCA');

util_plot_scatter_with_lines(mappedX(:,1),mappedX(:,2), 'labels', {'PC 1', 'PC 2'}, 'lineoff', 1)
util_plot_scatter_with_lines(mappedX(:,1),mappedX(:,2),'z', mappedX(:,3), 'labels', {'PC 1', 'PC 2', 'PC 3'}, 'lineoff', 1)
section = [1665:end];
util_plot_scatter_with_lines(mappedX(section,1),mappedX(section,2), 'labels', {'PCA 1', 'PCA 2'}, 'lineoff', 1)

[ ~, ~, ~, ~, ~, ~, ~, result, eval ] = util_evaluate_cluster(mappedX(:, 1:2), 'gk', 3);
[ subscript ] = util_extract_cluster( mappedX, result, 0.8, 'labels', {'PCA 1', 'PCA 2'});
[ elec_cluster ] = util_plot_state_trans( network_vectors, seq, subscript, 'all', 'threshold', 0, 'remove0', 0, 'method', 'im');
[ state_trans ] = util_calc_state_transition_rate( subscript );
[ ch_state ] = util_plot_channel_of_state( network_vectors, seq, subscript, active_threshold, 'dots', 'subplots', 1 );
[ ch_state ] = util_plot_channel_of_state( network_vectors, seq, subscript, active_threshold, 'hier', 'hp', 0);

figure, scatter(mappedX(:,1),mappedX(:,2),5, 'filled')




states_pca_all_overlapped:

spif  = util_load_spike_trigger_mcdstream_from_multiple_files('isCompact',1);
binwidth = 10000; active_threshold = 10; channel_threshold = 1;
[network_vectors seq ] = util_calc_network_vector( spif, [28], 'only_activ_ch', true, 'bin', binwidth);
bin_table = util_print_bins_with_files('binwidth', binwidth, 'culdate', 'ask');
matrix  = util_calc_similarity_matrix( network_vectors, 'method', 'rate', 'threshold', channel_threshold);
[mappedX mapping] = compute_mapping(matrix, 'PCA');

figure, imshow(matrix); axis xy, util_set_colorbar( jet ); xlabel(['Bin # (' num2str(binwidth) ' ms)']); ylabel(['Bin # (' num2str(binwidth) ' ms)'])
util_plot_scatter_with_lines(mappedX(:,1),mappedX(:,2), 'labels', {'PC 1', 'PC 2'}, 'lineoff', 1)
[overlapped std_distance] = util_calc_pca_overlap( mappedX, bin_table, 'radius', 'std' );