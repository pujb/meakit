function util_set_xtick( rate, bin )
%UTIL_SET_XTICK Set X axis by bin-width and numbers.
%   Rate:   The bin array (we use the length of it, i.e. bin numbers)
%   Bin:    Bin width.
%
%   Created on May/16/2011 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

% Get X Range
range = length(rate);
time_range = range * bin;
set(gca,'XLim',[0 (range+0.5)])

% Adjust
if range < 20
    unit = ['bin * ' num2str(bin)];
    ticks = get(gca, 'XTick');
    ticklabel = get(gca, 'XTickLabel');
elseif time_range < 1000
    unit = 'ms';
    ticks = get(gca, 'XTick');
    ticklabel = get(gca, 'XTickLabel');
elseif time_range < 1000*50 % 50 s
    unit = 's';
    ticks = 0:(1000/bin*5):range; % 5 s
    ticklabel = (0:(1000/bin*5):range) .* (bin/1000);
elseif time_range < 1000*1000 % 1000 s
    unit = 's';
    ticks = 0:(1000/bin*100):range; % 100 s
    ticklabel = (0:(1000/bin*100):range) .* (bin/1000);
else
    unit = 'min';
    ticks = 0:(1000*60/bin*10):range; % 10 min
    ticklabel = (0:(1000*60/bin*10):range) .* (bin/1000/60);
end

xlabel(['Time (' unit ')']);
set(gca,'XTick', ticks)
set(gca,'XTickLabel',ticklabel)

end

