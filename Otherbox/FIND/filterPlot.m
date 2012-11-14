function h=filterPlot(varargin)
%function call will look this way:
%filterPlot('selected_filterType',selected_filterType,'filterIDs',filterIDs,...
% 'Input2',Input2,'Input1',Input1);
% H1 line
% Help text; use something like:
%-%% <summary text>
%-%%
%-%% Parameters to be passed as parameter-value pairs:
%-%%
%-%% %%%%% Obligatory Parameters %%%%%
%-%%
%-%% 'parameter1': Does this and that. Takes vector as argument. etc.
%-%%
%-%% 'parameter2': Does this and that.
%-%% Possible values:
%-%%    'value1' - does this. And that.
%-%%
%-%%    'value2' - does something else.
%-%%
%-%% 'parameter3':
%-%% parameter3',[start,end]
%-%% Does this and that.
%-%%
%-%% %%%%% Optional Parameters %%%%%
%-%%
%-%% ...
%-%%
%-%% Further comments:
%-%%
%-%% ...
%-%%
%-%% Notes:
%-%%
%-%% - ...
%-%% - ...
%-%% ...
%-%% --------------------------------------------------
%-%% Original References of this tool
%-%% Futhere References: Analysis used in .....
%-%% Author of this Function (Year)
%-%% Original Version by .... (if applicable)
%-%% Example Call..

global nsFile; %-% if needed

% obligatory argument names
obligatoryArgs={'selected_filterType','selectedidx','Input2','Input1'}; %-% e.g. {'x','y'}

% optional arguments names with default values
optionalArgs={};

errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,''); %used this format so that the '\n' are converted
end

% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);

%getting name of dataset
if calledfromgui()==1
    disp('fct. called from gui')
    fullName=get(findobj('Tag','FIND_GUI_fileInUseText'),'String');
    dataSet=fullName(length(pwd)+2:end);
else
    disp('fct. called from commandline')
    dataSet='';
end

% some checks here
if ~isfield(nsFile,'Analog') || ~isfield(nsFile.Analog,'Data')
    error('FIND:noAnalogData','No analog data found in nsFile variable.');
end
if ~isfield(nsFile,'Segment') || ~isfield(nsFile.Segment,'Data')
    error('FIND:noSegmentData','No segment data found in nsFile variable.');
end

%get entitytypes for all selected entities
entitytype=[];
for ii=1:length(selectedidx)
    entitytype(ii)=nsFile.EntityInfo(selectedidx(ii)).EntityType;
end


selEvents=[]; EventPlot=false;
selNeural=[]; NeuralPlot=false;
selSegments=[];NeuralfSegPlot=false;

for ii=1:length(selectedidx)
    % -------------------------------------------------------------
    if entitytype(ii)==2 %Analog
        PosSelecidx=find(nsFile.Analog.DataentityIDs==selectedidx(ii));
        %get sampling rate and data
        mysampfreq=nsFile.Analog.Info(PosSelecidx).SampleRate;
        actualx=nsFile.Analog.Data(:,PosSelecidx);
        
        %%%%%%%%%%%%%%%% SavGol %%%%%%%%%%%%%%%
        if strcmp(selected_filterType,'Savgol')
            %make xaxis
            myx=sgolayfilt(actualx,Input2,Input1);
            
        end
        %%%%%%%%%%%%%%%% Lowpass %%%%%%%%%%%%%%%
        if strcmp(selected_filterType,'Lowpass')
            d=fdesign.lowpass('n,fc',50, Input1,mysampfreq)
            h=design(d,'window','window',{@chebwin,50})
            myx = filter(h, actualx);
            
        end
        
        %%%%%%%%%%%%%%%% Highpass %%%%%%%%%%%%%%%
        if strcmp(selected_filterType,'Highpass')
            d=fdesign.highpass('n,fc',50, Input1,mysampfreq)
            h=design(d,'window','window',{@chebwin,50})
            myx = filter(h, actualx);
        end
        
        %%%%%%%%%%%%%%%% Bandpass %%%%%%%%%%%%%%%
        if strcmp(selected_filterType,'Bandpass')
            d=fdesign.bandpass('n,fc1,fc2', 50,Input1, Input2,mysampfreq)
            h=design(d,'window','window',{@chebwin,50})
            myx = filter(h, actualx);
        end
        
        %%%%%%%%%%%%%%%% Bandstop %%%%%%%%%%%%%%%
        if strcmp(selected_filterType,'Bandstop')
            d=fdesign.bandstop('n,fc1,fc2', 50,Input1, Input2,mysampfreq)
            h=design(d,'window','window',{@chebwin,50})
            myx = filter(h, actualx);
        end
        
        %create plot command
        myxaxis=0:1/mysampfreq:(size(nsFile.Analog.Data,1)-1)/mysampfreq;
        mydatawindowwidth=(size(nsFile.Analog.Data,1))/(mysampfreq*5);
        scrollplot(mydatawindowwidth,myxaxis,nsFile.Analog.Data(:,PosSelecidx),...
            myxaxis,myx);
        set(gcf,'Name',['Filtering DataentityID ',num2str(selectedidx(ii))]);
        hold on;
        ax(1)=subplot(2,1,1), title({[dataSet,'_DataentityID ',num2str(selectedidx(ii)),...
            ' _ Entitytype: analog'];[];['before filtering']},'Interpreter','none');
        ax(2)=subplot(2,1,2),title({[('After applying'),selected_filterType,' filter']},...
            'Interpreter','none');
        linkaxes(ax);
        
        newdata.Analog.Data=myx;
        newdata.Analog.Info=nsFile.Analog.Info(PosSelecidx);
        newdata.Analog.Info.EntityLabel='filtered_Data';
        newdata.Analog.DataentityIDs=max([[nsFile.EntityInfo.EntityID],[nsFile.Analog.DataentityIDs],...
            [nsFile.Event.EntityID],[nsFile.Segment.DataentityIDs],[nsFile.Neural.EntityID]])+1;
        [usedIDs]=store_ns_newanalogdata('newdata',newdata);
        if ~isempty(usedIDs)
            newIDpos=find(nsFile.Analog.DataentityIDs==usedIDs);
            nsFile.Analog.Info(newIDpos).EntityID=usedIDs;
        end
        
        % -------------------------------------------------------------
    elseif entitytype(ii)==3 % Segment
        PosSelecData=find([nsFile.Segment.DataentityIDs]==selectedidx(ii));
        
        %get sampling rate
        if isfield(nsFile.EntityInfo(selectedidx(ii)),'Info') &&...
                isfield(nsFile.EntityInfo(selectedidx(ii)).Info, 'SampleRate')
            PosSelecidx=find([nsFile.EntityInfo(:).EntityID]==selectedidx(ii));
            mysampfreq=nsFile.EntityInfo(PosSelecidx).Info.SampleRate;
            myxlen=(size(nsFile.Segment.Data{ii},1))/mysampfreq; %[s]
            xaxname='time [s]';
        elseif isfield(nsFile.Segment.Info(PosSelecData),'SampleRate')
            mysampfreq=nsFile.Segment.Info(PosSelecData).SampleRate;
            myxlen=(size(nsFile.Segment.Data{PosSelecData},1))/mysampfreq; %[s]
            xaxname='time [s]';
        elseif isfield(nsFile.FileInfo, 'TimeStampResolution')
            mysampfreq=nsFile.FileInfo.TimeStampResolution;
            PosSelecidx=find([nsFile.Segment.DataentityIDs]==selectedidx(ii));
            myxlen=(size(nsFile.Segment.Data{PosSelecidx},1))/mysampfreq; %[s]
            xaxname='time [s]';
        else
            mysampfreq=1;
            PosSelecidx=find([nsFile.Segment.DataentityIDs]==selectedidx(ii));
            myxlen=size(nsFile.Segment.Data{PosSelecidx},1); %[sampling steps]
            xaxname='sampling steps';
            disp('to get timeaxis load up Infos for Segmentdata first');
        end
        
        % plot all cutouts
        figure('NumberTitle','off');
        for tt=1:size(nsFile.Segment.Data{PosSelecData},2)
            plot(0:(1/mysampfreq):(myxlen-1/mysampfreq), ...
                nsFile.Segment.Data{PosSelecData}(1:end,tt),'Color',rand(1,3));
            hold on;
            
            %filter data
            for tt=1:size(nsFile.Segment.Data{PosSelecData},2)
                % handle each singel segment stream like a analog one
                filtSigSeg(:,tt)=sgolayfilt(nsFile.Segment.Data{PosSelecData}(:,tt),PolynomialOrder,FrameSize);
            end
            set(gcf,'Name',['Dataentity ',num2str(selectedidx(ii)),' Entitytype:',' segment']);
            % save filtered data somewhere
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % plot unfiltered and filtered mean of entity
            figure('NumberTitle','off','Name',['Filtering Dataentity ',...
                num2str(selectedidx(ii)),'Entitytype:',' segment']);
            meanRaw=mean(nsFile.Segment.Data{PosSelecData},2);
            meanFilt=mean(filtSigSeg,2);
            plot(0:(1/mysampfreq):(myxlen-1/mysampfreq),meanRaw,'r',...
                0:(1/mysampfreq):(myxlen-1/mysampfreq),meanFilt,'g');
            hold on;
            legend('unfiltered','filtered');
            xlabel(gca,xaxname);
            title({dataSet;[];['all stored segments in Dataentity',num2str(selectedidx(ii))]},'Interpreter','none');
            title({['DataentityID: ',num2str(selectedidx(ii))];[];['mean Segment data - unfilterd and filtered']},...
                'Interpreter','none');
            hold off;
        end
                
    else
        warning(['Filtering only available for analog and segment data - for EntityID :',...
            num2str(selectedidx(ii)),' not available'])
    end
end
