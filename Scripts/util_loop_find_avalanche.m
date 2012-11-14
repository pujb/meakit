function [ locations sizes lengths vectors network_vectors seq spks amps ] = util_loop_find_avalanche( filename, gnd, result_dir )
%UTIL_LOOP_FIND_AVALANCHE Loop func, used for finding avalanches in a
%mcdfile.
%   Note: filename should be in full path format.
%   Example:
%       util_perform_op_in_directory('G:\MC_Rack Data\Fe','[ locations sizes lengths vectors network_vectors seq spks amps ] = util_loop_find_avalanche( %file, [28], 'G:\Result' );', 'G:\Result', '*.mcd', 'locations sizes lengths vectors network_vectors seq spks amps', 'is_recursive', true, 'verbose', true);
%
%   Created on Aug/18/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2010-09-19  Bug fix.

[ d, spif ] = util_load_spike_trigger_mcdstream('isCompact', 1, 'filename', filename);
[ locations sizes lengths vectors network_vectors seq spks amps ] = util_detect_avalanche( spif, gnd, 'method_size', 'unique', 'calc_amp', 'mean-p2p');
[ s_p s_x s_a s_fitresult s_gof ] = util_plot_avalanche_hist( sizes, 'S(#Electrode)' );
[ l_p l_x l_a l_fitresult l_gof ] = util_plot_avalanche_hist( lengths, 'L' );
[ spk_p spk_x spk_a spk_fitresult spk_gof ] = util_plot_avalanche_hist( spks, 'S(nLFPs)' );
[ amp_p amp_x amp_a amp_fitresult amp_gof ] = util_plot_avalanche_hist( amps, 'Mean(LFPs)' );

end

