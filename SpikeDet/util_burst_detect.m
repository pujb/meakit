function [  ] = util_burst_detect( spif, ch, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


hwid = util_convert_ch2hw(ch);
[ isi, seq, ~, ~, ~, ~, binedge ] = util_calc_isi( spif, 'normed', 1, 'isi_mode', 'loghisto', 'network_mode', 0 );
% mpd:      minimum distance required between two peaks (e.g. 2), measured
%           in points.
% voidParamTh: minimum void parameter required for the two returned peaks to be well separated.
% ISITh:    maximum time window to look for the peak corresponding to intra-burst ISIs (e.g. 100
%           ms), measured in ms.
mpd = 2;
voidParamTh = 0.7;
ISITh = 100;
[ ISImax, pks, flags ] = calcISImax(binedge{hwid}, isi{hwid}, mpd, voidParamTh, ISITh);


[~, ~, ~, ~, spb] = util_calc_rate(spif, 'gnd', 15, 'bin', 1, 'mode', 'electrode');
% ISImaxTh:     value of ISI in ms (e.g. 100 ms) that determines whether the
%               burst detection uses one (only ISImax) or two thresholds 
%               (the first one for the burst core - ISImaxTh - 
%               and the second one for extending the burst core at the 
%               boundaries - ISImax);
% maxISImax:    maximum value allowed for ISImax (in ms); if ISImax >
%               maxISImax, then ISImaxTh is used for burst detection;
% sf:           sampling frequency (samples per second);
% minNumSpikes: minimum number of spikes in a burst.
ISImaxTh = 100;
maxISImaxTh = 1000;
sf = 1000;
minNumSpikes = 3;
[burstTrain, burstEventTrain] = burstDetection(spb(:,hwid), ISImax, flags, ISImaxTh, maxISImaxTh, sf, minNumSpikes);
% burstTrain:   matrix (size number_of_bursts x 6) containing the following data:
%               1st col: time instant in which the burst begins (samples)
%               2nd col: time instant in which the burst ends (samples)
%               3rd col: number of spikes in each burst
%               4th col: duration (seconds)
%               5th col: inter-burst interval (between the end of the burst
%               and the begin of the following one) (seconds)
%               6th col: burst period (time interval between the begin of the burst
%               and the begin of the following one) (seconds)
% burstEventTrain:  sparse array ([number of samples x 1]), containing 1
%                   when a burst begins (time instant of the first spike of
%                   each burst), 0 elsewhere;

% plot
locationX = spif.spiketimes{hwid};
locationY = ones(length(locationX),1);
figure,
plot([locationX,locationX]', [locationY-0.3,locationY+0.3]', 'k');
xlim([0 10000])

% plot burst
hold on
for i = 1:size(burstTrain, 1)
    line([burstTrain(i,1), burstTrain(i,2)],[1.35, 1.35], 'Color','r','LineWidth',4)
end
xlim([0 10000])
hold off


end

