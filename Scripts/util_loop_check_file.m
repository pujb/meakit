function util_loop_check_file( data_filename )
%UTIL_LOOP_GET_FRACTAL_PARAMETERS Get DFA/Hurst Exponent/Minkowski
%Dimension of each file.
%util_perform_op_in_directory( 'E:\pu\Data', '[cc_matrix xc_matrix
%mi_matrix nmi_matrix sync_matrix bc_cc bc_xc bc_mi bc_nmi bc_sync] =
%util_loop_calc_topo( %file, %dir, 28 )', 'F:\Pu\Ava', '*.mcd', 'cc_matrix
%xc_matrix mi_matrix nmi_matrix sync_matrix bc_cc bc_xc bc_mi bc_nmi
%bc_sync', 'is_recursive', 1, 'verbose', 1, 'sorttype', 'byRecAsc' );   
%   Created on Apr/08/2011 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

util_load_spike_trigger_mcdstream('isCompact', 1, 'filename', data_filename);


end


