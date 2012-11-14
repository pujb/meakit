close all
clear all
[ d, spif ] = util_load_spike_trigger_mcdstream('isCompact',1);
[ spif ] = util_convert_spif_with_amplitude( d, spif );
[ locations sizes lengths vectors network_vectors seq spks amps] = util_detect_avalanche( spif, [28], 'method_size', 'unique', 'calc_amp', 'mean-p2p');
[ locations sizes lengths vectors network_vectors seq spks amps] = util_detect_avalanche( spif, [28], 'method_size', 'repetitive', 'calc_amp', 'none');
[ s_p s_x s_a s_fitresult s_gof ] = util_plot_avalanche_hist( sizes, 'S(#Electrode)' );
[ l_p l_x l_a l_fitresult l_gof ] = util_plot_avalanche_hist( lengths, 'L' );
[ spk_p spk_x spk_a spk_fitresult spk_gof ] = util_plot_avalanche_hist( spks, 'S(nLFPs)' );
[ amp_p amp_x amp_a amp_fitresult amp_gof ] = util_plot_avalanche_hist( amps, 'Mean(LFPs)' );
[ bp ] = util_calc_avalanche_branching_parameter( lengths, vectors, 'method', 'spk', 'network_vectors', network_vectors, 'ava_loc', locations );



clear all
[ ~, spif ] = util_load_spike_trigger_mcdstream('isCompact',1);
[ locations sizes lengths vectors ] = util_detect_avalanche( spif, [28], 'binwidth', 3 );
[ bp ] = util_calc_avalanche_branching_parameter( lengths, vectors, 'method', 'elec', 'network_vectors', network_vectors, 'ava_loc', locations );
util_plot_avalanche_hist( sizes, 'S' );
util_plot_avalanche_hist( lengths, 'L' );



close all
clear all
[ spif ] = util_load_spike_trigger_mcdstream_from_multiple_files('isCompact',1);
[ locations sizes lengths vectors ] = util_detect_avalanche( spif, [15] );
[ locations sizes lengths vectors network_vectors seq spks amps] = util_detect_avalanche( spif, [15], 'method_size', 'repetitive', 'calc_amp', 'none');
[ prob edges slope fitresult gof] = util_plot_avalanche_hist( sizes, 'S' );
util_plot_avalanche_hist( lengths, 'L' );


clear all
[ spif ] = util_load_spike_trigger_mcdstream_from_multiple_files('isCompact',1);
[ locations sizes lengths vectors ] = util_detect_avalanche( spif, [28] );
util_plot_avalanche_hist( sizes, 'S' );
util_plot_avalanche_hist( lengths, 'L' );