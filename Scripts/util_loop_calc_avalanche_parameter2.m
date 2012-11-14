function [sizes lengths vectors] = util_loop_calc_avalanche_parameter2( data_filename, result_dirname, gnd )
%UTIL_LOOP_CALC_AVALANCHE_PARAMETERS2 Get avalanche parameters and save
%them into CSVs.
%
%   Created on Apr/08/2011 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

[ d, spif ] = util_load_spike_trigger_mcdstream('isCompact', 1, 'filename', data_filename);

% ISI/RATE
[ ~, ~, ~, mean_isi ] = util_calc_isi( spif, 'gnds', gnd, 'network_mode', 1, 'isi_mode', 'histo', 'binedge', [0:0.1:5]);
[ spb, ~, ~, ~ ] = util_calc_rate( spif, 'bin', 1000, 'gnd', gnd );
mean_rate = mean(spb);
std_rate = std(spb);
sem_rate = util_calc_sem(spb);
window = mean_isi / 2;
if window > 2
    window = 1;
end

% AVALANCHE
[ ~, sizes lengths vectors , ~, ~ , ~, ~] = util_detect_avalanche( spif, gnd, 'binwidth', window, 'method_size', 'unique', 'calc_amp', 'none');
[ ~, ~, alpha, ~, ~] = util_plot_avalanche_hist( sizes, 'S', 'doplot', 0, 'method', 'polyfit' );

% BP
[ bp bp_std bp_sem bp_1 bp_1_std bp_1_sem ] = util_calc_avalanche_branching_parameter( lengths, vectors );


% DIV
fid = fopen([fileparts(data_filename) filesep 'culdate.txt'], 'a+');
culdate = fscanf(fid, '%s');
fclose(fid);
DIV = fix(getfield(d, 'recordingdate') - datenum(culdate));

% save

fid = fopen([result_dirname filesep 'filename.csv'], 'a+');
fprintf(fid, '%s \r\n', data_filename); 
fclose(fid);

fid = fopen([result_dirname filesep 'DIV.csv'], 'a+');
fprintf(fid, '%d \r\n', DIV); 
fclose(fid);

fid = fopen([result_dirname filesep 'ISI.csv'], 'a+');
fprintf(fid, '%f \r\n', mean_isi); 
fclose(fid);

fid = fopen([result_dirname filesep 'RATE_MEAN.csv'], 'a+');
fprintf(fid, '%f \r\n', mean_rate); 
fclose(fid);

fid = fopen([result_dirname filesep 'RATE_STD.csv'], 'a+');
fprintf(fid, '%f \r\n', std_rate); 
fclose(fid);

fid = fopen([result_dirname filesep 'RATE_SEM.csv'], 'a+');
fprintf(fid, '%f \r\n', sem_rate); 
fclose(fid);

fid = fopen([result_dirname filesep 'ALPHA.csv'], 'a+');
fprintf(fid, '%f \r\n', alpha); 
fclose(fid);

fid = fopen([result_dirname filesep 'BP.csv'], 'a+');
fprintf(fid, '%f \r\n', bp); 
fclose(fid);

fid = fopen([result_dirname filesep 'BP_STD.csv'], 'a+');
fprintf(fid, '%f \r\n', bp_std); 
fclose(fid);

fid = fopen([result_dirname filesep 'BP_SEM.csv'], 'a+');
fprintf(fid, '%f \r\n', bp_sem); 
fclose(fid);

fid = fopen([result_dirname filesep 'BP_1.csv'], 'a+');
fprintf(fid, '%f \r\n', bp_1); 
fclose(fid);

fid = fopen([result_dirname filesep 'BP_1_STD.csv'], 'a+');
fprintf(fid, '%f \r\n', bp_1_std); 
fclose(fid);

fid = fopen([result_dirname filesep 'BP_1_SEM.csv'], 'a+');
fprintf(fid, '%f \r\n', bp_1_sem); 
fclose(fid);



end

