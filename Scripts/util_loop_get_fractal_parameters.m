function util_loop_get_fractal_parameters( data_filename, result_dirname, gnd )
%UTIL_LOOP_GET_FRACTAL_PARAMETERS Get DFA/Hurst Exponent/Minkowski
%Dimension of each file.
%
%   Created on Apr/08/2011 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

[ d, spif ] = util_load_spike_trigger_mcdstream('isCompact', 1, 'filename', data_filename);
[DF_mean DF_std] = util_get_fractal_dim( spif, gnd, 'threshold', 1 );
[DFA_mean DFA_std] = util_get_fractal_dfa( spif, gnd, 'threshold', 1 );
[H_mean H_std] = util_get_fractal_hurst( spif, gnd, 'threshold', 1 );

% Active Channel Number
threshold = 1;
[~, ~, ~, ~, ~, avg] = util_calc_rate(spif, 'gnd', gnd, 'bin', 1000, 'mode', 'electrode');
if threshold == 0
    chlist = find( avg>threshold );
elseif threshold > 0
    chlist = find( avg>=threshold );
else
    error('threshold must >= 0');
end
num_chlist = length(chlist);

% DIV
fid = fopen([fileparts(data_filename) filesep 'culdate.txt'], 'r');
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

fid = fopen([result_dirname filesep 'ActiveChNum.csv'], 'a+');
fprintf(fid, '%d \r\n', num_chlist); 
fclose(fid);

fid = fopen([result_dirname filesep 'DFA_MEAN.csv'], 'a+');
fprintf(fid, '%f \r\n', DFA_mean); 
fclose(fid);

fid = fopen([result_dirname filesep 'DFA_STD.csv'], 'a+');
fprintf(fid, '%f \r\n', DFA_std); 
fclose(fid);

fid = fopen([result_dirname filesep 'DF_MEAN.csv'], 'a+');
fprintf(fid, '%f \r\n', DF_mean); 
fclose(fid);

fid = fopen([result_dirname filesep 'DF_STD.csv'], 'a+');
fprintf(fid, '%f \r\n', DF_std); 
fclose(fid);

fid = fopen([result_dirname filesep 'H_MEAN.csv'], 'a+');
fprintf(fid, '%f \r\n', H_mean); 
fclose(fid);

fid = fopen([result_dirname filesep 'H_STD.csv'], 'a+');
fprintf(fid, '%f \r\n', H_std); 
fclose(fid);

end

