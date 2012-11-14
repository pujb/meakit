function divsection = util_convert_bintable_to_divsection( bin_table )
%UTIL_CONVERT_bin_table_TO_DIVSECTION Converts the bin_table which generated
%by util_print_bins_with_files() to div_section.
%   The format of divsection:
%       divsection(1) = n, which means the first point is in DIV n.
%
%   Created on Sep/09/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

% Get how many DIVs
num_divs = size(bin_table, 1);

divsection = [];
for i = 1:num_divs
    [~] = evalc(['divsection(' num2str(bin_table{i, 2}) ':' num2str(bin_table{i, 3}) ')=' num2str(bin_table{i, 4})]);
end

end

