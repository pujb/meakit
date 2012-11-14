function loadMATfile(varargin)
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
% (0) antje kilias 08/09
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

global nsFile;

% obligatory argument names
obligatoryArgs={'fileName',...
    'analogData', ...
    'eventData', ...
    'segmentData', ...
    'neuralData'};

% optional arguments names with default values
optionalArgs={};

% set defaults
analogData=0;
eventData=0;
segmentData=0;
neuralData=0;

errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,'');
end

% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);

try
    tinfo=whos('-file', fileName);
    % catch all manual save commands
    if any(strcmp('nsFile',{tinfo.name}))
        if ~any(ismember(analogData(3:end),[13,11]))
            disp('only EntityID 11, 13 and 16 available')
        end   
        a=load(fileName,'nsFile');
        nsFile=a.nsFile;
        disp('*.mat file can''t be uploaded sequentially - whole file loaded');
        %     elseif any(strcmp('FileInfo',{tinfo.name})) && any(strcmp('EntityInfo',{tinfo.name}))
        %         if analogData~=0
        %             keyboard;
        %             a=load(fileName,'Analog');
        %             if strcmp('all',analogData) || isempty(setdiff(a.Analog.DataentityIDs,analogData(3:end)))
        %                 newdata.Analog=a.Analog;
        %
        %                 noImport=find(~ismember((3:end),a.Analog.DataentityIDs));
        %                 if ~isempty(noImport)
        %                     disp(['IDs [ ',num2str(analogData(2+noImport)),' ] were not exported from original file into *.mat file --> IMPORT IMPOSSIBLE!']);
        %                 end
        %
        %             elseif any(ismember(analogData(3:end),a.Analog.DataentityIDs)) && ~isempty(setdiff(a.Analog.DataentityIDs,analogData(3:end)))
        %                 [c,i]=ismember(analogData(3:end),a.Analog.DataentityIDs);
        %                 i=nonzeros(i);
        %                 newdata.Analog.Data=a.Analog.Data(analogData(1):analogData(2),i);
        %                 newdata.Analog.DataentityIDs=a.Analog.DataentityIDs(i);
        %                 newdata.Analog.Info=a.Analog.Info(i);
        %
        %                 noImport=find(~ismember(analogData(3:end),a.Analog.DataentityIDs));
        %                 if ~isempty(noImport)
        %                     disp(['IDs [ ',num2str(analogData(2+noImport)),' ] were not exported from original file into *.mat file --> IMPORT IMPOSSIBLE!']);
        %                 end
        %             elseif all(ismember(analogData(:,3:end),[nsFile.EntityInfo.EntityID])) && ...
        %                     ~any(ismember(analogData(:,3:end),a.Analog.DataentityIDs))
        %                 disp(['IDs [ ',num2str(analogData(3:end)),' ] were not exported from original file into *.mat file --> IMPORT IMPOSSIBLE!']);
        %                 clear a;
        %             else
        %                 error('FIND: wrong input for analogData')
        %             end
        %             store_ns_newanalogdata('newdata',newdata);
        %             clear a;
        %         end
        %
        %         %%%%%%%%%%%%%%%%%%%%%%%%%%% EventData %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %         if eventData~=0
        %             a=load(fileName,'Event');
        %             if strcmp('all',eventData) || isempty(setdiff(a.Event.EntityID,eventData(3:end)))
        %                 newdata.Event=a.Event;
        %                 EventDataOrigin={a.Event(:).Info.EntityLabel};
        %
        %                 noImport=find(~ismember(eventData(3:end),a.Event.EntityID));
        %                 if ~isempty(noImport)
        %                     disp(['IDs [ ',num2str(eventData(2+noImport)),' ] were not exported from original file into *.mat file --> IMPORT IMPOSSIBLE!']);
        %                 end
        %
        %                 store_ns_neweventdata('newdata',newdata,'DataOrigin',EventDataOrigin);
        %                 clear a;
        %             elseif any(ismember(eventData(3:end),a.Event.EntityID)) && ~isempty(setdiff(a.Event.EntityID,eventData(3:end)))
        %                 [c,i]=ismember(eventData(3:end),a.Event.EntityID);
        %                 i=nonzeros(i);
        %                 for tt=1:numel(i)
        %                     newdata.Event.TimeStamp{tt}=a.Event.TimeStamp{i(tt)};
        %                     newdata.Event.Data{tt}=a.Event.Data{i(tt)};
        %                     newdata.Event.DataSize{tt}=a.Event.DataSize{i(tt)};
        %                     EventDataOrigin{tt}=a.Event.Info(i(tt)).EntityLabel;
        %                 end
        %                 newdata.Event.EntityID=a.Event.EntityID(i);
        %                 newdata.Event.Info=a.Event.Info(i);
        %                 noImport=find(~ismember(eventData(3:end),a.Event.EntityID));
        %                 if ~isempty(noImport)
        %                     disp(['IDs [ ',num2str(eventData(2+noImport)),' ] were not exported from original file into *.mat file --> IMPORT IMPOSSIBLE!']);
        %                 end
        %                 store_ns_neweventdata('newdata',newdata,'DataOrigin',EventDataOrigin);
        %                 clear a;
        %             elseif all(ismember(eventData(:,3:end),[nsFile.EntityInfo.EntityID])) && ...
        %                     ~any(ismember(eventData(:,3:end),a.Event.EntityID))
        %                 disp(['IDs [ ',num2str(eventData(3:end)),' ] were not exported from original file into *.mat file --> IMPORT IMPOSSIBLE!']);
        %                 clear a;
        %             else
        %                 error('FIND: wrong input for eventData')
        %             end
        %         end
        %
        %         %%%%%%%%%%%%%%%%%%%%%%%%%%% SegmentData %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %         if segmentData ~= 0;
        %             a=load(fileName,'Segment');
        %             if strcmp('all',segmentData) || isempty(setdiff(a.Segment.DataentityIDs,segmentData(3:end)))
        %                 newdata.Segment=a.Segment;
        %                 if isfield('Info',a.Segment)
        %                     SegmentDataOrigin={a.Segment(:).Info.EntityLabel};
        %                 else
        %                     SegmentDataOrigin=mat2cell(repmat('imported from mat file',size(a.Segment.Data,2),1),ones(1,size(a.Segment.Data,2)));
        %                 end
        %                 noImport=find(~ismember(segmentData(3:end),a.Segment.DataentityIDs));
        %                 if ~isempty(noImport)
        %                     disp(['IDs [ ',num2str(segmentData(2+noImport)),' ] were not exported from original file into *.mat file --> IMPORT IMPOSSIBLE!']);
        %                 end
        %
        %                 store_ns_newsegmentdata('newdata',newdata,'DataOrigin',SegmentDataOrigin);
        %                 clear a;
        %             elseif any(ismember(segmentData(3:end),a.Segment.DataentityIDs)) && ~isempty(setdiff(a.Segment.DataentityIDs,segmentData(3:end)))
        %                 [c,i]=ismember(segmentData(3:end),a.Segment.DataentityIDs);
        %                 i=nonzeros(i);
        %                 for tt=1:numel(i)
        %                     newdata.Segment.TimeStamp{tt}=a.Segment.TimeStamp{i(tt)};
        %                     newdata.Segment.Data{tt}=a.Segment.Data{i(tt)};
        %                     newdata.Segment.UnitID{i}=a.Segment.UnitID{i(tt)};
        %                     newdata.Segment.SampleCount{i}=a.Segment.SampleCount{i(tt)};
        %                     if isfield('Info',a.Segment)
        %                         SegmentDataOrigin{tt}=a.Segment.Info(i(tt)).EntityLabel;
        %                     end
        %                 end
        %                 newdata.Segment.DataentityIDs=a.Segment.DataentityIDs(i);
        %                 if isfield('Info',a.Segment)
        %                     newdata.Segment.Info=a.Segment.Info(i);
        %                 else
        %                     SegmentDataOrigin=mat2cell(repmat('imported from mat file',size(s.Segment.Data,2),1),ones(1,size(a.Segment.Data,2)));
        %                 end
        %
        %                 noImport=find(~ismember(segmentData(3:end),a.Segment.DataentityIDs));
        %                 if ~isempty(noImport)
        %                     disp(['IDs [ ',num2str(segmentData(2+noImport)),' ] were not exported from original file into *.mat file --> IMPORT IMPOSSIBLE!']);
        %                 end
        %
        %                 store_ns_newsegmentdata('newdata',newdata,'DataOrigin',SegmentDataOrigin);
        %                 clear a;
        %             elseif all(ismember(segmentData(:,3:end),[nsFile.EntityInfo.EntityID])) && ...
        %                     ~any(ismember(segmentData(:,3:end),a.Segemen.DataentityIDs))
        %                 disp(['IDs [ ',num2str(segmentData(3:end)),' ] were not exported from original file into *.mat file --> IMPORT IMPOSSIBLE!']);
        %                 clear a;
        %             else
        %                 error('FIND: wrong input for eventData')
        %             end
        %         end
        %
        %         %%%%%%%%%%%%%%%%%%%%%%%%%%% NeuralData %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %         if neuralData~=0
        %             a=load(fileName,'Neural');
        %             if strcmp('all',neuralData) || isempty(setdiff(a.Neural.EntityID,neuralData(3:end)))
        %                 newdata.Neural=a.Neural;
        %                 NeuralDataOrigin={a.Neural(:).Info.Label};
        %
        %                 noImport=find(~ismember(neuralData(3:end),a.Neural.EntityID));
        %                 if ~isempty(noImport)
        %                     disp(['IDs [ ',num2str(neuralData(2+noImport)),' ] were not exported from original file into *.mat file --> IMPORT IMPOSSIBLE!']);
        %                 end
        %
        %                 store_ns_newneuraldata('newdata',newdata,'DataOrigin',NeuralDataOrigin);
        %                 clear a;
        %             elseif any(ismember(neuralData(3:end),a.Neural.EntityID)) && ~isempty(setdiff(a.Neural.EntityID,neuralData(3:end)))
        %                 [c,i]=ismember(neuralData(3:end),a.Neural.EntityID);
        %                 i=nonzeros(i);
        %                 for tt=1:numel(i)
        %                     newdata.Neural.Data{tt}=a.Neural.Data{i(tt)};
        %                     NeuralDataOrigin{tt}=a.Neural.Info(i(tt)).Label;
        %                 end
        %                 newdata.Neural.EntityID=a.Neural.EntityID(i);
        %                 newdata.Neural.Info=a.Neural.Info(i);
        %
        %                 noImport=find(~ismember(neuralData(3:end),a.Neural.EntityID));
        %                 if ~isempty(noImport)
        %                     disp(['IDs [ ',num2str(neuralData(2+noImport)),' ] were not exported from original file into *.mat file --> IMPORT IMPOSSIBLE!']);
        %                 end
        %
        %                 store_ns_newneuraldata('newdata',newdata,'DataOrigin',NeuralDataOrigin);
        %                 clear a;
        %             elseif all(ismember(neuralData(:,3:end),[nsFile.EntityInfo.EntityID])) && ...
        %                     ~any(ismember(neuralData(:,3:end),a.Neural.EntityID))
        %                 disp(['IDs [ ',num2str(neuralData(3:end)),' ] were not exported from original file into *.mat file --> IMPORT IMPOSSIBLE!']);
        %                 clear a;
        %             else
        %                 error('FIND: wrong input for eventData')
        %             end
        %         end
    else
        error('browsed *.mat file does not contain a FIND compatible nsFile structure');
    end
catch
    rethrow(lasterror)
end

