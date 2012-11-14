function deadSpike = detectSpikes_deadtime(analogData, spikeTimes, neuralData, deadTime)

% detectSpikes_deadtime.m
%
% Removes oppositely signed spikes within the deadTime constraint.
% Used by detectSpikes.
%
% The old method:
%
%   agap=find(diff(neuralData)>deadTime)+1;
%   neuralData=neuralData(agap);
%   pike_times{ii}=spike_times{ii}(agap);
%
% is too stringent, and will remove unnecessary spikes.
% For example spikes arriving at 0.0000, 0.0005, 0.0010:
% With dead time of 0.001, we should keep spike 1 and 3
% but the original routine keeps only spike 1.
% 
% The dead time is necessary for conseuctiveoppositely signed peaks anyway,
% as they are likely to belong to the same spike.

disp(['Removing oppositely signed spikes arriving within ', num2str(deadTime), ' s.']);
signSpike = sign(analogData(spikeTimes));
diffSign  = diff(signSpike) ~= 0;
deadSpike = diff(neuralData) < deadTime;
deadSpike = [0; deadSpike & diffSign];
                
% now for sequences such as nSpike pSpike nSpike pSpike
% we want to remove every 2nd spike so we get:
% nSpike xxx nSpike xxx
% I cannot think of a vectorized way, looping for now
for s = 2:length(deadSpike),
    if deadSpike(s-1) && deadSpike(s)
        deadSpike(s) = 0;
    end
end

disp([num2str(sum(deadSpike)), ' spikes removed.']);                
                