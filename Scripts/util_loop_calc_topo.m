function [cc_matrix xc_matrix mi_matrix nmi_matrix bc_cc bc_xc bc_mi bc_nmi] = util_loop_calc_topo( data_filename, result_dirname, gnd )
%UTIL_LOOP_CALC_TOPO Get Topology parameters
%util_perform_op_in_directory( 'E:\pu\Data', '[cc_matrix xc_matrix mi_matrix nmi_matrix sync_matrix bc_cc bc_xc bc_mi bc_nmi bc_sync] = util_loop_calc_topo( %file, %dir, 28 )', 'F:\Pu\Ava', '*.mcd', 'cc_matrix xc_matrix mi_matrix nmi_matrix sync_matrix bc_cc bc_xc bc_mi bc_nmi bc_sync', 'is_recursive', 1, 'verbose', 1, 'sorttype', 'byRecAsc' );   
%
%   Created on Apr/08/2011 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

[ d, spif ] = util_load_spike_trigger_mcdstream('isCompact', 1, 'filename', data_filename);

% MATRIX
%[ cc_matrix ] = util_calc_corr_matrix( spif, gnd, 'threshold', 1, 'method', 'cc-hist');
%[ xc_matrix ] = util_calc_corr_matrix( spif, gnd, 'threshold', 1, 'method', 'cc-xcorr');
%[ mi_matrix ] = util_calc_corr_matrix( spif, gnd, 'threshold', 1, 'method', 'migram', 'bin', 5);
[ nmi_matrix ] = util_calc_corr_matrix( spif, gnd, 'threshold', 1, 'method', 'nmi');

%A_cc = util_get_assortativity( cc_matrix, 'thresholding', 0.1, 'thresholding_method', 'percent' );
%A_xc = util_get_assortativity( xc_matrix, 'thresholding', 0.1, 'thresholding_method', 'percent' );
%A_mi = util_get_assortativity( mi_matrix, 'thresholding', 0.1, 'thresholding_method', 'percent' );
A_nmi = util_get_assortativity( nmi_matrix, 'thresholding', 0.1, 'thresholding_method', 'percent' );

%bc_cc = util_get_betweenness( cc_matrix, 'thresholding', 0.1, 'thresholding_method', 'percent', 'betweenness_threshold', 50 );
%bc_xc = util_get_betweenness( xc_matrix, 'thresholding', 0.1, 'thresholding_method', 'percent', 'betweenness_threshold', 50 );
%bc_mi = util_get_betweenness( mi_matrix, 'thresholding', 0.1, 'thresholding_method', 'percent', 'betweenness_threshold', 50 );
bc_nmi = util_get_betweenness( nmi_matrix, 'thresholding', 0.1, 'thresholding_method', 'percent', 'betweenness_threshold', 50 );

cc_matrix = []; xc_matrix = []; mi_matrix = [];
A_cc = 0; A_xc = 0; A_mi = 0;
bc_cc = 0; bc_xc = 0; bc_mi = 0;

% DIV
fid = fopen([fileparts(data_filename) filesep 'culdate.txt'], 'r');
culdate = fscanf(fid, '%s');
fclose(fid);
DIV = fix(getfield(d, 'recordingdate') - datenum(culdate));

% save
fid = fopen([result_dirname filesep 'A_cc.csv'], 'a+');
fprintf(fid, '%f \r\n', A_cc); 
fclose(fid);

fid = fopen([result_dirname filesep 'A_xc.csv'], 'a+');
fprintf(fid, '%f \r\n', A_xc); 
fclose(fid);

fid = fopen([result_dirname filesep 'A_mi.csv'], 'a+');
fprintf(fid, '%f \r\n', A_mi); 
fclose(fid);

fid = fopen([result_dirname filesep 'A_nmi.csv'], 'a+');
fprintf(fid, '%f \r\n', A_nmi); 
fclose(fid);





end


