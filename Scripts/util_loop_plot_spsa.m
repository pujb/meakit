function util_loop_plot_spsa( filename )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[ ~, spif ] = util_load_spike_trigger_mcdstream('isCompact',1,'filename',filename);
h = util_plot_spsa(spif);
[~, filename, ~] = fileparts(filename);
title(filename);
saveas(h, filename, 'jpg');
close(h);

end

