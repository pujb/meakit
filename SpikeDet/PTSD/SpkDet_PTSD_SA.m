function [spikesValue, spikesTime]= SpkDet_PTSD_SA(data, thresh, plp, rp, npa);

%=================================================================
%
% SpikeDetection_PTSD
%
% The calling syntax is:
%
%	  [spkValues, spkTimeStamps] = SpkDet_PTSD_SA(data, thresh, plp, rp, npa)
%
%      data   -> signal raw data to analyze (should be normalized)
%      thresh -> threshold to overcome in order to detect a spike
%      plp    -> peak lifetime period
%      rp     -> refractory period
%      npa    -> negative peak assignement. True to assign the spike time stamp
%                to the negative peak, false to assign it to the higher peak
%
%
%
% Neuroengineering and Bio-nano Technologies Group – NBT
% Department of Biophysical and Electronic Engineering – DIBE
% University of Genova
% Via All'Opera Pia, 11a – 16145 Genova, Italy
%
% Created  on 11/02/2008 by Alessandro Maccione and Mauro Gandolfo
%
%=================================================================



%initializing variables
spikesValue=[];
spikesTime=[];
overlap   = 5;
newIndex  = 1;
indexPeak = 1;
n=length(data);

%cycle on data
for index=2:n-1

    %jump to the new position for scanning data
    if index < newIndex, continue, end
    
    %if there is a peak, i.e. a relative max (or min)
    if (abs(data(index)) > abs(data(index-1)))&& ...
       (abs(data(index)) >=abs(data(index+1)))

        %collect the start peak time and value
        sTimePeak  = index;         
        sValuePeak = data(index);
        
        %control on the end of the array
        if (index + plp) > n
            interval = n - index;
        else
            interval = plp;
        end
        
        % if start peak is positive, search for a minimum within the interval of possible peak duration
        if sValuePeak > 0
            
            %store the minimum
            [eValuePeak eTimePeak] = min(data(index : index+interval));
            %eventually store a new max between start peak and the minimum found
            [sValuePeak sTimePeak] = max(data(index : index+eTimePeak-1));          

            %if the min is found at the end of the interval check if signal
            %continues to decrease
            if (eTimePeak == interval + 1)&&((index + interval + overlap) < n)
                %in this case store the new min
                [eValuePeak eTimePeak] = min(data(index : index+interval+overlap)); 
            end
            
            %update the timestamp with the absolute position inside the
            %data array
            eTimePeak = eTimePeak + index - 1;      
            sTimePeak = sTimePeak + index - 1;
            
        % if instead it is negative, search for a maximum
        else
            [eValuePeak eTimePeak] = max(data(index : index+interval));
            [sValuePeak sTimePeak] = min(data(index : index+eTimePeak-1));

            if (eTimePeak == interval + 1)&&((index + interval + overlap) < n)
               [eValuePeak eTimePeak] = max(data(index : index+interval+overlap));
            end
            eTimePeak = eTimePeak + index - 1;
            sTimePeak = sTimePeak + index - 1;
        end
        
        % if the difference overlap the threshold
        if abs(sValuePeak - eValuePeak) >= thresh
            
            %value is assumed to be the difference
            spikesValue(indexPeak) = abs(sValuePeak - eValuePeak);
            
            % with the following code the timestamp is assigned to the
            % negative peak
            if (npa)
                if sValuePeak < eValuePeak
                   spikesTime(indexPeak)  = sTimePeak;
                else
                   spikesTime(indexPeak)  = eTimePeak;
                end
            % with the following code the timestamp is assigned to the
            % higher peak
            else
                if abs(sValuePeak) > abs(eValuePeak)
                    spikesTime(indexPeak)  = sTimePeak;
                else
                    spikesTime(indexPeak)  = eTimePeak;
                end
            end

            % set properly newIndex 
            if ((spikesTime(indexPeak) + rp) > eTimePeak) && ((spikesTime(indexPeak) + rp) < n)
                newIndex = spikesTime(indexPeak) + rp;
            else
                newIndex = eTimePeak + 1;
            end
            indexPeak = indexPeak + 1;
        end
    end
end