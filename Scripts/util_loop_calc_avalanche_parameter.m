function [ sizes alpha bp bp_1 mean_isi mean_rate ] = util_loop_calc_avalanche_parameter( filename, gnd, result_dir )
%UTIL_LOOP_CALC_AVALANCHE_PARAMETER Loop func, used for finding avalanches in a
%mcdfile, then get branching parameter(sigma) / alpha
%   Try V2<======================================
%   Note: filename should be in full path format.
%   Example:
%       util_perform_op_in_directory('G:\Data\Develop\n1276-20080513','[ sizes alpha bp bp_1 mean_isi mean_rate ] = util_loop_calc_avalanche_parameter( %file, [28], %dir );', 'G:\Result', '*.mcd', 'sizes alpha bp bp_1 mean_isi mean_rate', 'is_recursive', true, 'verbose', true, 'sorttype', 'byRecAsc');
%
%   Created on Mar/21/2011 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2011-03-23  Bug fix / Adding file output

persistent loop_times;  % used to count how many times this function is being called
persistent total_loop;  % how many files
persistent culdate;     % when was it cultured

% Init loop times
if isempty(loop_times)
    loop_times = 1;
    % PLEASE CHANGE THIS ACCORDING TO YOUR CULTURE DATE
    culdate = inputdlg('Culture Date (e.g. 2008-04-03): ', 'util_loop_calc_avalanche_parameter.m');
    % PLEASE CHANGE THIS ACCORDING TO THE NUMBER OF FILES WILL BE PROCESSED
    total_loop = inputdlg('How many files: ', 'util_loop_calc_avalanche_parameter.m');
    total_loop = str2num(total_loop{:});
else
    loop_times = loop_times + 1;
end
% define the color of drawing lines
lcolor = [1 1 1] - (loop_times / total_loop) * 0.8;
if loop_times == total_loop
    clear loop_times;
end


[ d, spif ] = util_load_spike_trigger_mcdstream('isCompact', 1, 'filename', filename);
[ ~, ~, ~, mean_isi ] = util_calc_isi( spif, 'gnds', gnd, 'network_mode', 1, 'isi_mode', 'histo', 'binedge', [0:0.1:5]);
[ spb, ~, ~, ~ ] = util_calc_rate( spif, 'bin', 1000, 'gnd', gnd );
mean_rate = mean(spb);
window = mean_isi / 2;
if window > 2
    window = 1;
end
[ ~, sizes lengths vectors , ~, ~ , ~, ~] = util_detect_avalanche( spif, gnd, 'binwidth', window, 'method_size', 'unique', 'calc_amp', 'none');
[ ~, ~, alpha, ~, ~] = util_plot_avalanche_hist( sizes, 'S', 'draw_slope', 1, 'overlay', 1, 'lcolor', lcolor, 'mcolor', [0 0 0] );
[ bp bp_1 ] = util_calc_avalanche_branching_parameter( lengths, vectors );


DIV = fix(getfield(d, 'recordingdate') - datenum(culdate));

% save
fid = fopen([result_dir filesep 'DIV.csv'], 'a+');
fprintf(fid, '%d \r\n', DIV); 
fclose(fid);

fid = fopen([result_dir filesep 'filename.csv'], 'a+');
fprintf(fid, '%s \r\n', filename); 
fclose(fid);

fid = fopen([result_dir filesep 'alpha.csv'], 'a+');
fprintf(fid, '%f \r\n', alpha); 
fclose(fid);

fid = fopen([result_dir filesep 'bp.csv'], 'a+');
fprintf(fid, '%f \r\n', bp); 
fclose(fid);

fid = fopen([result_dir filesep 'bp_1.csv'], 'a+');
fprintf(fid, '%f \r\n', bp_1); 
fclose(fid);

fid = fopen([result_dir filesep 'mean_isi.csv'], 'a+');
fprintf(fid, '%f \r\n', mean_isi); 
fclose(fid);

fid = fopen([result_dir filesep 'mean_rate.csv'], 'a+');
fprintf(fid, '%f \r\n', mean_rate); 
fclose(fid);


end

