function txt_array=detectSpikes(varargin)
% Performs Spike Detection on Analog Data.
% function txt_array=detectSpikes(varargin)
%
% detectSpikes uses the following parameters, all to passed as
% parameter-value-pairs.
%
% %%%%% Obligatory Parameters %%%%%
%
% 'analogEntityIndices': Indices of selected Entities to detect spikes
%
% %%%%% Optional Parameters %%%%%
%
% 'thresholdFactor': determines the threshold to detect spikes,
%   Default: thresholdFactor=5;
%
% 'methodeNumber': determines the detection methode ,
%   Default: methodNumber=1 (The rect. N times median).
%
%   GENERAL OPTIONS
%       the detection can either be done on absolute or on normal data
%       case 1: The rect. N times median
%       case 2: The rect. mean +/- SD
%       case 3: The mean +/- SD
%       case 4: with known median
%       case 5: CoB
%
% 'makeCutouts': option to generate cutouts around the detected spikes
%   Default: makeCutouts=false;
%
%   GENERAL OPTIONS
%       define the extent of the cutout window ('cutBefore' to 'cutAfter')
%       Default: cutBefore=0.001;
%       Default: cutAfter=0.001;
%
% 'sortSpikes': there is the option to sort the detected spikes directly
%   This option is only valid if cutouts are generated simultaneously.
%   Default: sortSpikes=false;
%'selectDeadTime': To sort out multiple threshold crossings in one spike form
%   'deadTime': time in which no new spike can occur.
%'loadMode': new neural and segment data can either overwrite old data or
%   be appended, default prompts the user
%'offset': if the neural data is appended to existing data, there has to be
%   added the offset time.
% polarity: if the detection should find negative maxima, positive or both
%
%
% Example:
% text_report=detectSpikes('analogEntityIndices',selected_Data_Vectors,...
%                   'methodNumber',3,'thresholdFactor',5,'makeCutouts',0);
%
%  %%%%%%% Further Options %%%%%%%%%%
%
% filter the data by using lowPassFilter
% (can be set manual only)
% Defaults:
%       doFilter=true;
%       lowPassFilterFrequency=1000; % in Hz
%
% RETRIEVING INFORMATION
%
% Results are added to the global nsFile structure!
%
% Spikes are stored in 'neuralData';
% Possibly generated cutouts are stored in 'segmentData';
%
% txt_array provides information about the number of detected spikes and
% used parameters to the user
%
% (0) R. Meier Feb 07 meier@biologie.uni-freiburg.de
% 
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de


% the Varargin variables - with some DEFAULTS for safety
doFilter=true;
lowPassFilterFrequency=1000; % in Hz

global nsFile;

% obligatory argument names
obligatoryArgs={'analogEntityIndices'};

% optional arguments names with default values
optionalArgs={...
    'thresholdFactor',...
    'methodNumber',...
    'absoluteFlag',...
    'knownMedian',...
    'SpikeSorting',...
    'makeCutouts',...
    'showSpikes', ...
    'selectDeadTime',...
    'deadTime',...
    'cutBefore',...
    'cutAfter',...
    'loadMode',...
    'offset'...
    'polarity'};
thresholdFactor=5;
methodNumber=1;
knownMedian=20;
SpikeSorting=false;
makeCutouts=false;
showSpikes=false;
selectDeadTime=false;
deadTime=0.002;
cutBefore=0.001;
cutAfter=0.002;
loadMode='prompt';
offset=0;
polarity='negative';

% Valid var names provided? Otherwise, error is generated. You can also
% supply functions to test the validity of the values, see checkPVP for
% details.
errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,''); %used this format so that the '\n' are converted
end

% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);
warning off all

if ~isfield(nsFile,'Analog') || ~isfield(nsFile.Analog,'Data') ...
        || isempty(nsFile.Analog.Data)
    error('FIND:noAnalogData','No analog data found in nsFile variable.');
end

txt_array='Text - Report: detectSpikes';

% get the parameters needed
FIND_GUIdata = get(findobj('Tag','FIND_GUI'),'UserData');
for tt=1:length(analogEntityIndices)
    if sum(nsFile.Analog.DataentityIDs==analogEntityIndices(tt))>0
        posEntityID(tt)=find(nsFile.Analog.DataentityIDs==analogEntityIndices(tt));
    else
        error('FIND:noAnalogData','No analog data referring to the choosen Entity.');
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% spike detection
switch methodNumber

    case 5 %CoB
        
        disp('chosen Method: CoB')
        txt_array=strvcat(txt_array,'chosen Method: CoB');
        
        % checking the path for CoB spike detection
        postMessage(''); % Clean up prior messages.
            if exist('spbyrcob.m','file')
                % is the path set to spikedetection folder?
                postMessage('The path set to spikedetection folder, starting...');
                                
            else
                postMessage('The path is NOT set to spikedetection folder');
                answer=questdlg(...
                    'spikedetection folder need to be added to the MATLAB search path - continue?',...
                    'Add spikedetection to path',...
                    'Yes',...
                    'Cancel',...
                    'Yes'); %last is default
                if strcmp(answer,'Yes')
                    path(path,'spikedetection');
                    postMessage('The path set to spikedetection folder, starting...');
                end
            end
        
            for ii=1:length(posEntityID)
                %% do the Detection

                      samp= nsFile.Analog.Info(posEntityID(ii)).SampleRate;
                      signal=nsFile.Analog.Data(:,posEntityID(ii));
                      
                      load('testdata.mat');                                     
                      [hpsig]=highpass(signal, samp, 300);
                      spkidx = spbyrcob(hpsig,samp, 256, .03, 1,1);                    % spike detection by CoB Method
                      Threshold=1;
                    spike_times{ii}=spkidx*samp;
                      %  spkidx = spbyplain(hpsig, samp, 2.5, 2.5, 1);         % spike detection by  plain method
%                       [spikes, idx, classes]=sortspk(hpsig, spkidx, samp, 1, 1, 4);

                % Return the Values to the NS structure

                neuralData=spike_times{ii} / samp ;
                if selectDeadTime
                    deadSpike = detectSpikes_deadtime(nsFile.Analog.Data(:,posEntityID(ii)), spike_times{ii}, neuralData, deadTime);
                    neuralData=neuralData(~deadSpike);
                    spike_times{ii}=spike_times{ii}(~deadSpike);                
                end
                newdata.Neural.Data{ii}=neuralData ;
                newdata.Neural.EntityID(ii)=nsFile.Analog.DataentityIDs(posEntityID(ii));
                DataOrigin{ii}=['detected Spikes in analog Data (EntityID : ',num2str(newdata.Neural.EntityID(ii)),' )'];
            end
    
    case 4 %with known median

        disp('chosen Method: known median')
        txt_array=strvcat(txt_array,'chosen Method: known median');
        t=1;
        for ii=1:length(posEntityID)
            Threshold(ii)=thresholdFactor*knownMedian(t);

            % Let's centre each spike on the peaks rather than the threshold
            % crossing. Detect peaks that are suprathreshold.
            diffData = diff(nsFile.Analog.Data(:,posEntityID(ii)));
            pPeaks   = [0; diffData > 0] & [diffData <= 0; 0];  % positive peaks (up then down)
            nPeaks   = [0; diffData < 0] & [diffData >= 0; 0];  % nergative peaks (down then up)
            
            
            %% do the Detection
            switch polarity
                case 'negative'
                    nThresh         = nsFile.Analog.Data(:,posEntityID(ii)) < -Threshold(ii);
                    spike_times{ii} = find(nThresh & nPeaks);
                case 'positive'                    
                    pThresh         = nsFile.Analog.Data(:,posEntityID(ii)) > Threshold(ii);
                    spike_times{ii} = find(pThresh & pPeaks);
                case 'both'
                    % perform positive and negative separate to avoid
                    % detecting a positive peak that is less than the
                    % negative threshold, etc.
                    nThresh = nsFile.Analog.Data(:,posEntityID(ii)) < -Threshold(ii);
                    nThresh = nThresh & nPeaks;
                    pThresh = nsFile.Analog.Data(:,posEntityID(ii)) > Threshold(ii);
                    pThresh = pThresh & pPeaks;
                    spike_times{ii} = find(nThresh | pThresh);
            end
           
            % Return the Values to the NS structure
            % wh=nsFile.Analog.DataentityIDs(posEntityID(ii));
            srate=nsFile.Analog.Info(posEntityID(ii)).SampleRate;
            neuralData=spike_times{ii} / srate ;
            if selectDeadTime
                deadSpike = detectSpikes_deadtime(nsFile.Analog.Data(:,posEntityID(ii)), spike_times{ii}, neuralData, deadTime);
                neuralData=neuralData(~deadSpike);
                spike_times{ii}=spike_times{ii}(~deadSpike);                
            end
            newdata.Neural.Data{ii}=neuralData ;
            newdata.Neural.EntityID(ii)=nsFile.Analog.DataentityIDs(posEntityID(ii));
            DataOrigin{ii}=['detected Spikes in analog Data (EntityID : ',num2str(newdata.Neural.EntityID(ii)),' )'];
            t=t+1;
        end

    case 3 % The mean +/- SD
        disp('chosen Method: Mean +/- SD');
        txt_array=strvcat(txt_array,'chosen Method: Mean +/- SD');
        for ii=1:length(posEntityID)  % Go over the data traces
            if doFilter==true
                Nyquist=1/2/ (1/ nsFile.Analog.Info(posEntityID(ii)).SampleRate);
                f=lowPassFilterFrequency/(Nyquist);
                [b,a]=cheby1(2,0.1,f);
                filtered_data=filtfilt(b,a,nsFile.Analog.Data(:,posEntityID(ii)));
                MeanDataTrace(ii)=mean((filtered_data));
                SDDataTrace(ii)=std(filtered_data);
            else
                MeanDataTrace(ii)=mean((nsFile.Analog.Data(:,posEntityID(ii))));
                SDDataTrace(ii)=std(nsFile.Analog.Data(:,posEntityID(ii)));
            end
            disp(['Mean=',num2str(MeanDataTrace(ii)),', Std=',num2str(SDDataTrace(ii))]);
            
            % Let's centre each spike on the peaks rather than the threshold
            % crossing. Detect peaks that are suprathreshold.
            diffData = diff(nsFile.Analog.Data(:,posEntityID(ii)));
            pPeaks   = [0; diffData > 0] & [diffData <= 0; 0];  % positive peaks (up then down)
            nPeaks   = [0; diffData < 0] & [diffData >= 0; 0];  % nergative peaks (down then up)
            
            switch polarity
                case 'negative'                    
                    Threshold(ii)   = MeanDataTrace(ii) - thresholdFactor * SDDataTrace(ii);
                    nThresh         = nsFile.Analog.Data(:,posEntityID(ii)) < Threshold(ii);
                    spike_times{ii} = find(nThresh & nPeaks);
                case 'positive'
                    Threshold(ii)   = MeanDataTrace(ii) + thresholdFactor * SDDataTrace(ii);
                    pThresh         = nsFile.Analog.Data(:,posEntityID(ii)) > Threshold(ii);
                    spike_times{ii} = find(pThresh & pPeaks);
                case 'both'
                    % perform positive and negative separate to avoid
                    % detecting a positive peak that is less than the
                    % negative threshold, etc.
                    Threshold(ii)   = MeanDataTrace(ii) - thresholdFactor * SDDataTrace(ii);
                    nThresh         = nsFile.Analog.Data(:,posEntityID(ii)) < Threshold(ii);
                    nThresh         = nThresh & nPeaks;
                    Threshold(ii)   = MeanDataTrace(ii) + thresholdFactor * SDDataTrace(ii);
                    pThresh         = nsFile.Analog.Data(:,posEntityID(ii)) > Threshold(ii);
                    pThresh         = pThresh & pPeaks;
                    spike_times{ii} = find(nThresh | pThresh);
            end
           
            % Return the Values to the NS structure
            % wh=nsFile.Analog.DataentityIDs(posEntityID(ii));
            srate=nsFile.Analog.Info(posEntityID(ii)).SampleRate;
            neuralData=spike_times{ii} / srate ;
            if selectDeadTime
                deadSpike = detectSpikes_deadtime(nsFile.Analog.Data(:,posEntityID(ii)), spike_times{ii}, neuralData, deadTime);
                neuralData=neuralData(~deadSpike);
                spike_times{ii}=spike_times{ii}(~deadSpike);                
            end
            newdata.Neural.Data{ii}=neuralData ;
            newdata.Neural.EntityID(ii)=nsFile.Analog.DataentityIDs(posEntityID(ii));
            DataOrigin{ii}=['detected Spikes in analog Data (EntityID : ',num2str(newdata.Neural.EntityID(ii)),' )'];
        end

    case 2 % The rect. mean +/- SD
        disp('chosen Method: rect. Mean +/- SD');
        txt_array=strvcat(txt_array,'chosen Method: rect. Mean +/- SD');
        for ii=1:length(posEntityID)  % Go over the data traces

            if doFilter==true
                Nyquist=1/2/ (1/ nsFile.Analog.Info(posEntityID(ii)).SampleRate);
                f=lowPassFilterFrequency/(Nyquist);
                [b,a]=cheby1(2,0.1,f);
                filtered_data=filtfilt(b,a,nsFile.Analog.Data(:,posEntityID(ii)));
                MeanDataTrace(ii)=mean(abs(filtered_data));
                SDDataTrace(ii)=std(abs(filtered_data));
            else
                MeanDataTrace(ii)=mean(abs(nsFile.Analog.Data(:,posEntityID(ii))));
                SDDataTrace(ii)=std(abs(nsFile.Analog.Data(:,posEntityID(ii))));
            end


            % Let's centre each spike on the peaks rather than the threshold
            % crossing. Detect peaks that are suprathreshold.
            diffData = diff(nsFile.Analog.Data(:,posEntityID(ii)));
            pPeaks   = [0; diffData > 0] & [diffData <= 0; 0];  % positive peaks (up then down)
            nPeaks   = [0; diffData < 0] & [diffData >= 0; 0];  % nergative peaks (down then up)
            

            %% do the Detection
            switch polarity
                case 'negative' 
                    Threshold(ii)   = -MeanDataTrace(ii) - thresholdFactor * SDDataTrace(ii);
                    nThresh         = nsFile.Analog.Data(:,posEntityID(ii)) < Threshold(ii);
                    spike_times{ii} = find(nThresh & nPeaks);                    
                case 'positive'    
                    Threshold(ii)   = MeanDataTrace(ii) + thresholdFactor * SDDataTrace(ii);
                    pThresh         = nsFile.Analog.Data(:,posEntityID(ii)) > Threshold(ii);
                    spike_times{ii} = find(pThresh & pPeaks);                    
                case 'both'      
                    % perform positive and negative separate to avoid
                    % detecting a positive peak that is less than the
                    % negative threshold, etc.
                    Threshold(ii)   = -MeanDataTrace(ii) - thresholdFactor * SDDataTrace(ii);
                    nThresh         = nsFile.Analog.Data(:,posEntityID(ii)) < Threshold(ii);
                    nThresh         = nThresh & nPeaks;
                    Threshold(ii)   = MeanDataTrace(ii) + thresholdFactor * SDDataTrace(ii);
                    pThresh         = nsFile.Analog.Data(:,posEntityID(ii)) > Threshold(ii);
                    pThresh         = pThresh & pPeaks;                                        
                    spike_times{ii} = find(pThresh | nThresh);
            end
           
            % Return the Values to the NS structure
            % wh=nsFile.Analog.DataentityIDs(posEntityID(ii));
            srate=nsFile.Analog.Info(posEntityID(ii)).SampleRate;
            neuralData=spike_times{ii} / srate ;
            if selectDeadTime
                deadSpike = detectSpikes_deadtime(nsFile.Analog.Data(:,posEntityID(ii)), spike_times{ii}, neuralData, deadTime);
                neuralData=neuralData(~deadSpike);
                spike_times{ii}=spike_times{ii}(~deadSpike);                
            end
            newdata.Neural.Data{ii}=neuralData;
            newdata.Neural.EntityID(ii)=nsFile.Analog.DataentityIDs(posEntityID(ii));
            DataOrigin{ii}=['detected Spikes in analog Data (EntityID : ',num2str(newdata.Neural.EntityID(ii)),' )'];
        end

    case 1 % The rect. N times median
        disp('chosen Method: rect. N* Median');
        txt_array=strvcat(txt_array,'chosen Method: rect. N* Median');
        for ii=1:length(posEntityID)  % Go over the data traces

            if doFilter==true
                Nyquist=1/2/ (1/ nsFile.Analog.Info(posEntityID(ii)).SampleRate);
                f=lowPassFilterFrequency/(Nyquist);
                [b,a]=cheby1(2,0.1,f);
                filtered_data=filtfilt(b,a,nsFile.Analog.Data(:,posEntityID(ii)));
                MedianDataTrace(ii)=median(abs(filtered_data));
            else
                MedianDataTrace(ii)=median(abs(nsFile.Analog.Data(:,posEntityID(ii))));
            end
            disp(['the rect. Median of Entity ', num2str(nsFile.Analog.DataentityIDs(posEntityID(ii))),' is ' num2str(MedianDataTrace(ii))])

            
            % Let's centre each spike on the peaks rather than the threshold
            % crossing. Detect peaks that are suprathreshold.
            diffData = diff(nsFile.Analog.Data(:,posEntityID(ii)));
            pPeaks   = [0; diffData > 0] & [diffData <= 0; 0];  % positive peaks (up then down)
            nPeaks   = [0; diffData < 0] & [diffData >= 0; 0];  % nergative peaks (down then up)
            
            
            %% do the Detection
            switch polarity
                case 'negative'            
                    Threshold(ii)   = -thresholdFactor*MedianDataTrace(ii);
                    nThresh         = nsFile.Analog.Data(:,posEntityID(ii)) < Threshold(ii);
                    spike_times{ii} = find(nThresh & nPeaks);                                        
                case 'positive'            
                    Threshold(ii)   = thresholdFactor * MedianDataTrace(ii);
                    pThresh         = nsFile.Analog.Data(:,posEntityID(ii)) > Threshold(ii);
                    spike_times{ii} = find(pThresh & pPeaks);                                        
                case 'both'
                    Threshold(ii)   = -thresholdFactor*MedianDataTrace(ii);
                    nThresh         = nsFile.Analog.Data(:,posEntityID(ii)) < Threshold(ii);
                    nThresh         = nThresh & nPeaks;                                        
                    Threshold(ii)   = thresholdFactor * MedianDataTrace(ii);
                    pThresh         = nsFile.Analog.Data(:,posEntityID(ii)) > Threshold(ii);
                    pThresh         = pThresh & pPeaks;                                        
                    spike_times{ii} = find(pThresh | nThresh);                                        
            end
            

            % Return the Values to the NS structure
            % wh=nsFile.Analog.DataentityIDs(ii);
            srate=nsFile.Analog.Info(posEntityID(ii)).SampleRate;
            % if the spikes are detected in a loop, the offset time has to
            % be added
            neuralData=(spike_times{ii}+offset) / srate ;
            if selectDeadTime
                deadSpike = detectSpikes_deadtime(nsFile.Analog.Data(:,posEntityID(ii)), spike_times{ii}, neuralData, deadTime);
                neuralData=neuralData(~deadSpike);
                spike_times{ii}=spike_times{ii}(~deadSpike);                
            end

            newdata.Neural.Data{ii}=neuralData; % UNITS: SECONDS!
            newdata.Neural.EntityID(ii)=nsFile.Analog.DataentityIDs(posEntityID(ii));
            DataOrigin{ii}=['detected Spikes in analog Data (EntityID : ',num2str(newdata.Neural.EntityID(ii)),' )'];

        end
    otherwise
        txt_array=strvcat(txt_array,'Unknown method. -> Check the parameters: ');
        error(['Unknown method. -> Check the parameters: ']);
end
if sum(cellfun(@isempty, newdata.Neural.Data))==size(newdata.Neural.Data,2) %all cells are empty
    disp('No spikes detected!');
    return;
else
    store_ns_newneuraldata('newdata',newdata,'DataOrigin',DataOrigin);
    % no changes in  EntityInfo
end

% generate some Report
for ii=1:length(posEntityID(ii))
    txt_array=strvcat(txt_array,'EntityID:');
    txt_array=strvcat(txt_array,num2str(nsFile.Analog.DataentityIDs(posEntityID(ii))));
    txt_array=strvcat(txt_array,'# Spikes:');
    txt_array=strvcat(txt_array,num2str(length(newdata.Neural.Data{ii})));
    txt_array=strvcat(txt_array,'threshold: +/-');
    txt_array=strvcat(txt_array,num2str(Threshold(ii)));
end


%disp('Finished Spike Detection');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot the data

if showSpikes

    for ii=1:length(posEntityID)

        % SamplingRate
        tempdt=1/nsFile.Analog.Info(posEntityID(ii)).SampleRate;
        myxlim=(length(nsFile.Analog.Data(:,posEntityID(ii)))-1);

        figure('Name','detected Spikes', 'NumberTitle', 'off');

        % subplot 1 -  display raw data
        subplot(5,1,3:5);

        plot(0:tempdt:(myxlim*tempdt),nsFile.Analog.Data(1:end,posEntityID(ii)));

        axis tight;
        ax=axis;
        %     xlim([-1;(myxlim*tempdt+1)]);
        xlabel('time [s]');

        % check the unit field exists and not empty
        if ~isfield(nsFile.Analog.Info, 'Units') || isempty({nsFile.Analog.Info.Units})
            nsFile.Analog.Info.Units=' ';
        end
        
        % expand on specific units
        ScaleUnit = '';
        if nsFile.Analog.Info(posEntityID(ii)).Units(end) == 'V'
            ScaleUnit='voltage';
        elseif nsFile.Analog.Info(posEntityID(ii)).Units(end) == 'A'
            ScaleUnit='current';
        else
            disp('Unknown Scale Unit ')
        end
        ylabel({[ScaleUnit ' [' nsFile.Analog.Info(posEntityID(ii)).Units ']']});
        title('raw data');
        hold on;
        if methodNumber==3
            line([0 myxlim*tempdt],[ Threshold(ii) Threshold(ii) ],'Color','g');
        else
            line([0 myxlim*tempdt],[ Threshold(ii) Threshold(ii) ],'Color','g');
            line([0 myxlim*tempdt],[-Threshold(ii) -Threshold(ii)],'Color','r');
        end
        % subplot 2 - display spikes
        subplot(5,1,1);

        if ~isempty(newdata.Neural.Data{:,ii})
            bar((newdata.Neural.Data{:,ii}), ones(length(newdata.Neural.Data{:,ii}),1));
        else
            line([0  myxlim*tempdt],[0 0]);
        end
        grid on;
        set(gca,'YTickLabel',{' ';'spikes';' '});
        xlim([0;(myxlim*tempdt+1)]);
        title('spikes');
        axis([ax(1:2) 0 1]);

    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  if CUTOUTS are desired:
if makeCutouts
    newdata=[];

    %  disp('cutting the spikes');
    txt_array=strvcat(txt_array,'makeCutouts: ');

    for ii=1:length(posEntityID)

        if ~isempty(spike_times{ii})
            % Safety first -> get the actual ! Samplingrate!
            wh=analogEntityIndices(ii);
            srate=nsFile.Analog.Info(posEntityID(ii)).SampleRate;
            all_spikes=spike_times{ii};
            cutoutSamples=cutBefore*srate+cutAfter*srate+1;
            cutBeforeVector=all_spikes-(cutBefore*srate*ones(length(all_spikes),1));
            cutAfterVector=all_spikes+(cutAfter*srate*ones(length(all_spikes),1));
            % Correcting for small numerical errors
            if find(cutBeforeVector<1)
                disp('#lost a spike due to cutout boundary conditions!');
                cutBeforePos=find(cutBeforeVector>0);
                cutBeforeVector=cutBeforeVector(cutBeforePos);
                all_spikes=all_spikes(cutBeforePos);
                cutAfterVector=cutAfterVector(cutBeforePos);
            elseif find(cutAfterVector>length(nsFile.Analog.Data(:,posEntityID(ii))))
                disp('#lost a spike due to cutout boundary conditions!');
                cutAfterSmall=find(cutAfterVector<length(nsFile.Analog.Data(:,posEntityID(ii))));
                cutBeforeVector=cutBeforeVector(cutAfterSmall);
                all_spikes=all_spikes(cutAfterSmall);
                cutAfterVector=cutAfterVector(cutAfterSmall);
            end
            spikeLength = round((cutBefore + cutAfter) * srate);
            spikeVecs = repmat((0:spikeLength-1)', 1, length(all_spikes));
            spikeVecs = bsxfun(@plus, spikeVecs, round(cutBeforeVector'));
            spike_cuts = nsFile.Analog.Data(spikeVecs,posEntityID(ii));
            spike_cuts = reshape(spike_cuts, spikeLength, []);
            newdata.Segment.Data{ii}=spike_cuts;
            clear spike_cuts;
            clear spikeVecs;
            %if these spikes are appended to existing ones, an offset has
            %to be added
            newdata.Segment.TimeStamp{ii}=(all_spikes+offset)./srate';
            newdata.Segment.UnitID{ii}=zeros(length(all_spikes),1);
            newdata.Segment.SampleCount{ii}=cutoutSamples*ones(length(all_spikes),1);
            newdata.Segment.DataentityIDs(ii)=nsFile.Analog.DataentityIDs(posEntityID(ii));
            DataOrigin{ii}=['cut out Spikes in analog Data (EntityID : ',num2str(newdata.Segment.DataentityIDs(ii)),' )'];
        else
            warning('no spikes detected! change threshold!');
            return;
        end
    end
    % push the cutouts into the nsFile Variable
    % tempidx=analogEntityIndices;
    if sum(cellfun(@isempty, nsFile.Neural.Data))==size(nsFile.Neural.Data,2) %all cells are empty
        disp('No spikes detected!');
        return
    else
        store_ns_newsegmentdata('newdata',newdata,'DataOrigin',DataOrigin);
    end
    clear newdata; %% Clean up!
    %disp('done with cutting');

    %%%%  if SORTING is needed:
    if makeCutouts && SpikeSorting
        disp('Starting the Spike Sorting for current channel ...')

        %%% start sorting
%         sortSpikes('tagSelecDimReduc','sortSpikesGUI_downsamplingRadiobutton',...
        sortSpikes('tagSelecDimReduc','sortSpikesGUI_downsamplingRadiobutton',...   
            'nClusters',[2:5],...
            'tagSelecCluster','sortSpikesGUI_kmeansRadiobutton',...
            'selected_Entities',analogEntityIndices);
        txt_array=strvcat(txt_array,'SORTED them');
    end

else
    disp(' cutouts were not generated!');
end

%%% end of detectSpikes.m
