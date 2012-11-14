% function neuroshare2HDF(filenameNS,filenameHDF)
% function neuroshare2HDF
% enables user to transfer data from all neuroshare formats into a HDF file
%
% filenameNS =  name of neuroshare compatible file
% filenameHDF = name for hdf5 file inclusive ending

[pathstr, recordName, ext, versn] = fileparts(filenameNS);

getFile=neuroshare_Loader_all(filenameNS);

%% obligatory Information:


intwarning('off');
record_root  = [ '/' recordName ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DLLNAME & FILENAME
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DLLName_Idx=find(cell2mat(cellfun(@(x) strcmp(x,'DLLName'),getFile,'UniformOutput',0)),1);
DLLName                         = char(getFile{DLLName_Idx,2});
fileName                        = char(filenameNS);

hdf5write(filenameHDF, [ record_root '/DLLName' ],DLLName,...
    [ record_root '/FileName' ],fileName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FILEINFO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FileInfo_Idx=find(cell2mat(cellfun(@(x) strcmp(x,'FileInfo'),getFile,'UniformOutput',0)),1);

FileInfo.FileType               =   char(getFile{FileInfo_Idx,2}.FileType);
FileInfo.EntityCount            = uint32(getFile{FileInfo_Idx,2}.EntityCount);
FileInfo.TimeStampResolution    = double(getFile{FileInfo_Idx,2}.TimeStampResolution);
FileInfo.TimeSpan               = uint32(getFile{FileInfo_Idx,2}.TimeSpan);
FileInfo.AppName                =   char(getFile{FileInfo_Idx,2}.AppName);
FileInfo.Time_Year              = uint32(getFile{FileInfo_Idx,2}.Time_Year);
FileInfo.Time_Month             = uint32(getFile{FileInfo_Idx,2}.Time_Month);
FileInfo.Time_Day               = uint32(getFile{FileInfo_Idx,2}.Time_Day);
FileInfo.Time_Hour              = uint32(getFile{FileInfo_Idx,2}.Time_Hour);
FileInfo.Time_Min               = uint32(getFile{FileInfo_Idx,2}.Time_Min);
FileInfo.Time_Sec               = uint32(getFile{FileInfo_Idx,2}.Time_Sec);
FileInfo.Time_MilliSec          = uint32(getFile{FileInfo_Idx,2}.Time_MilliSec);
FileInfo.FileComment            =   char(getFile{FileInfo_Idx,2}.FileComment);

hdf5write(filenameHDF,[ record_root '/FileInfo' ],FileInfo,'writemode','append');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LIBRARYINFO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LibraryInfo_Idx=find(cell2mat(cellfun(@(x) strcmp(x,'LibraryInfo'),getFile,'UniformOutput',0)),1);

LibraryInfo.LibVersionMaj       = uint32(getFile{LibraryInfo_Idx,2}.LibVersionMaj);
LibraryInfo.LibVersionMin       = uint32(getFile{LibraryInfo_Idx,2}.LibVersionMin);
LibraryInfo.APIVersionMaj       = uint32(getFile{LibraryInfo_Idx,2}.APIVersionMaj);
LibraryInfo.APIVersionMin       = uint32(getFile{LibraryInfo_Idx,2}.APIVersionMin);
LibraryInfo.Description         =   char(getFile{LibraryInfo_Idx,2}.Description);
LibraryInfo.Creator             =   char(getFile{LibraryInfo_Idx,2}.Creator);
LibraryInfo.Time_Year           = uint32(getFile{LibraryInfo_Idx,2}.Time_Year);
LibraryInfo.Time_Month          = uint32(getFile{LibraryInfo_Idx,2}.Time_Month);
LibraryInfo.Time_Day            = uint32(getFile{LibraryInfo_Idx,2}.Time_Day);
LibraryInfo.Flags               =   char(getFile{LibraryInfo_Idx,2}.Flags);
LibraryInfo.MaxFiles            = uint32(getFile{LibraryInfo_Idx,2}.MaxFiles);
LibraryInfo.FileDescCount       = uint32(getFile{LibraryInfo_Idx,2}.FileDescCount);

hdf5write(filenameHDF,[ record_root '/LibraryInfo/General' ],LibraryInfo,'writemode','append');

for gg=1:getFile{LibraryInfo_Idx,2}.FileDescCount
    LibraryInfo_FileDesc.Description    =   char(getFile{LibraryInfo_Idx,2}.FileDesc(gg).Description);
    LibraryInfo_FileDesc.Extension      =   char(getFile{LibraryInfo_Idx,2}.FileDesc(gg).Extension);
    LibraryInfo_FileDesc.MacCodes       =   char(getFile{LibraryInfo_Idx,2}.FileDesc(gg).MacCodes);
    LibraryInfo_FileDesc.MagicCode      =   char(getFile{LibraryInfo_Idx,2}.FileDesc(gg).MagicCode);
    hdf5write(filenameHDF,[ record_root '/LibraryInfo/FileDesc/'  sprintf('%d',gg)],LibraryInfo_FileDesc,'writemode','append');
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get internal IDs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

analogentityIDs=getFile{find(cell2mat(cellfun(@(x) strcmp(x,'analogentityIDs'),getFile,'UniformOutput',0)),1),2};
evententityIDs=getFile{find(cell2mat(cellfun(@(x) strcmp(x,'evententityIDs'),getFile,'UniformOutput',0)),1),2};
neuralentityIDs=getFile{find(cell2mat(cellfun(@(x) strcmp(x,'neuralentityIDs'),getFile,'UniformOutput',0)),1),2};
segmententityIDs=getFile{find(cell2mat(cellfun(@(x) strcmp(x,'segmententityIDs'),getFile,'UniformOutput',0)),1),2};

EntityInfo_Idx=find(cell2mat(cellfun(@(x) strcmp(x,'EntityInfo'),getFile,'UniformOutput',0)),1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% analog data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(analogentityIDs)
    AnalogData_Idx=find(cell2mat(cellfun(@(x) strcmp(x,'AnalogData'),getFile,'UniformOutput',0)),1);
    AnalogInfo_Idx=find(cell2mat(cellfun(@(x) strcmp(x,'AnalogInfo'),getFile,'UniformOutput',0)),1);
    AnalogContCount_Idx=find(cell2mat(cellfun(@(x) strcmp(x,'AnalogData'),getFile,'UniformOutput',0)),1);
    
    analog_root = [ record_root '/Analog' ];
    
    for i=1:size(getFile{AnalogData_Idx,2},2)
        
        % get data
        analog_leaf = [ analog_root '/' sprintf('%d',i) ];
        analogData  = double(getFile{AnalogData_Idx,2}(:,i));
        hdf5write(filenameHDF,analog_leaf,analogData,'writemode','append');
        
        if isempty(analogData)
            continue;
        end
        
        % set Info as attribute
        attribute.AttachedTo = analog_leaf;
        attribute.AttachType = 'dataset';
        
        % loop over all accessable fields
        attributeNames=fieldnames(getFile{AnalogInfo_Idx,2});
        for f=1:size(attributeNames,1)
            attribute.Name = attributeNames{f};
            try
                if ~ischar(eval(['getFile{AnalogInfo_Idx,2}(i).' attribute.Name]))
                    currentAttribute= eval(['double(getFile{AnalogInfo_Idx,2}(i).' attribute.Name ')']);
                else
                    currentAttribute= eval(['char(getFile{AnalogInfo_Idx,2}(i).' attribute.Name ')']);
                end
                hdf5write(filenameHDF,attribute,currentAttribute,'writemode','append');
            catch
                currentAttribute= char('conversion to hdf failed');
                hdf5write(filenameHDF,attribute,currentAttribute,'writemode','append');
            end
        end
        attribute.Name = 'AnalogContCount';
        currentAttribute= double(getFile{AnalogContCount_Idx,2}(i));
        hdf5write(filenameHDF,attribute,currentAttribute,'writemode','append');
        
        % add EntityInfo for every entity
        attributeNames=fieldnames(getFile{EntityInfo_Idx,2});
        
        for e=1:size(attributeNames,1)
            attribute.Name = attributeNames{e};
            try
                if ~ischar(eval(['getFile{EntityInfo_Idx,2}(analogentityIDs(i)).' attribute.Name]))
                    currentAttribute= eval(['double(getFile{EntityInfo_Idx,2}(analogentityIDs(i)).' attribute.Name ')']);
                else
                    currentAttribute= eval(['char(getFile{EntityInfo_Idx,2}(analogentityIDs(i)).' attribute.Name ')']);
                end
                hdf5write(filenameHDF,attribute,currentAttribute,'writemode','append');
            catch
                currentAttribute= char('conversion to hdf failed');
                hdf5write(filenameHDF,attribute,currentAttribute,'writemode','append');
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% event data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(evententityIDs)
    EventData_Idx=find(cell2mat(cellfun(@(x) strcmp(x,'EventData'),getFile,'UniformOutput',0)),1);
    EventInfo_Idx=find(cell2mat(cellfun(@(x) strcmp(x,'EventInfo'),getFile,'UniformOutput',0)),1);
    EventTimeStamp_Idx=find(cell2mat(cellfun(@(x) strcmp(x,'EventTimeStamp'),getFile,'UniformOutput',0)),1);
    EventDataSize_Idx=find(cell2mat(cellfun(@(x) strcmp(x,'EventDataSize'),getFile,'UniformOutput',0)),1);
    
    event_root = [ record_root '/Event' ];
    
    for i=1:size(getFile{EventData_Idx,2},2)
        
        % get trigger times
        eventStamp_leaf = [ event_root '/' sprintf('%d',i) '/TimeStamp'];
        eventTimeStamp  = double(getFile{EventTimeStamp_Idx,2}(:,i));
        hdf5write(filenameHDF,eventStamp_leaf,eventTimeStamp,'writemode','append');
        
        % get trigger data
        eventData_leaf = [ event_root '/' sprintf('%d',i) '/Data'];
        eventData  = double(getFile{EventData_Idx,2}(:,i));
        hdf5write(filenameHDF,eventData_leaf,eventData,'writemode','append');
        
        if isempty(eventTimeStamp)
            continue;
        end
        
        % set Info as attribute
        attribute.AttachedTo = eventStamp_leaf;
        attribute.AttachType = 'dataset';
        
        % loop over all accessable fields
        attributeNames=fieldnames(getFile{EventInfo_Idx,2});
        for f=1:size(attributeNames,1)
            attribute.Name = attributeNames{f};
            try
                if ~ischar(eval(['getFile{EventInfo_Idx,2}(i).' attribute.Name]))
                    currentAttribute= eval(['double(getFile{EventInfo_Idx,2}(i).' attribute.Name ')']);
                else
                    currentAttribute= eval(['char(getFile{EventInfo_Idx,2}(i).' attribute.Name ')']);
                end
                hdf5write(filenameHDF,attribute,currentAttribute,'writemode','append');
            catch
                currentAttribute= char('conversion to hdf failed');
                hdf5write(filenameHDF,attribute,currentAttribute,'writemode','append');
            end
        end
        
        attribute.Name = 'EventDataSize';
        currentAttribute= double(getFile{EventDataSize_Idx,2}(i));
        hdf5write(filenameHDF,attribute,currentAttribute,'writemode','append');
        
        % add EntityInfo for every entity
        attributeNames=fieldnames(getFile{EntityInfo_Idx,2});
        
        for e=1:size(attributeNames,1)
            attribute.Name = attributeNames{e};
            try
                if ~ischar(eval(['getFile{EntityInfo_Idx,2}(evententityIDs(i)).' attribute.Name]))
                    currentAttribute= eval(['double(getFile{EntityInfo_Idx,2}(evententityIDs(i)).' attribute.Name ')']);
                else
                    currentAttribute= eval(['char(getFile{EntityInfo_Idx,2}(evententityIDs(i)).' attribute.Name ')']);
                end
                hdf5write(filenameHDF,attribute,currentAttribute,'writemode','append');
            catch
                currentAttribute= char('conversion to hdf failed');
                hdf5write(filenameHDF,attribute,currentAttribute,'writemode','append');
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% segment data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(segmententityIDs)
    
    SegmentData_Idx=find(cell2mat(cellfun(@(x) strcmp(x,'SegmentData'),getFile,'UniformOutput',0)),1);
    SegmentInfo_Idx=find(cell2mat(cellfun(@(x) strcmp(x,'SegmentInfo'),getFile,'UniformOutput',0)),1);
    SegmentTimeStamp_Idx=find(cell2mat(cellfun(@(x) strcmp(x,'SegmentTimeStamp'),getFile,'UniformOutput',0)),1);
    SegmentSampleCount_Idx=find(cell2mat(cellfun(@(x) strcmp(x,'SegmentSampleCount'),getFile,'UniformOutput',0)),1);
    SegmentUnitID_Idx=find(cell2mat(cellfun(@(x) strcmp(x,'SegmentUnitID'),getFile,'UniformOutput',0)),1);
    
    segment_root = [ record_root '/Segment' ];
    
    for i=1:size(getFile{SegmentData_Idx,2},3)
        
        % get spike times
        segmentStamp_leaf = [ segment_root '/' sprintf('%d',i) '/TimeStamp'];
        segmentTimeStamp  = double(getFile{SegmentTimeStamp_Idx,2}(:,i));
        hdf5write(filenameHDF,segmentStamp_leaf,segmentTimeStamp,'writemode','append');
        
        % get unitIDs
        segmentUnitID_leaf = [ segment_root '/' sprintf('%d',i) '/UnitID'];
        segmentUnitID  = double(getFile{SegmentUnitID_Idx,2}(:,i));
        hdf5write(filenameHDF,segmentUnitID_leaf,segmentUnitID,'writemode','append');
        
        % get sample counts
        segmentSample_leaf = [ segment_root '/' sprintf('%d',i) '/SampleCount'];
        segmentSampleCount  = double(getFile{SegmentSampleCount_Idx,2}(:,i));
        hdf5write(filenameHDF,segmentSample_leaf,segmentSampleCount,'writemode','append');
        
        % get spike waveforms
        segmentData_leaf = [ segment_root '/' sprintf('%d',i) '/Data'];
        segmentData  = double(getFile{SegmentData_Idx,2}(:,:,i));
        hdf5write(filenameHDF,segmentData_leaf,segmentData,'writemode','append');
        
        if isempty(segmentTimeStamp)
            continue;
        end
        
        % set Info as attribute
        attribute.AttachedTo = segmentData_leaf;
        attribute.AttachType = 'dataset';
        
        % loop over all accessable fields
        attributeNames=fieldnames(getFile{SegmentInfo_Idx,2});
        for f=1:size(attributeNames,1)
            attribute.Name = attributeNames{f};
            try
                if ~ischar(eval(['getFile{SegmentInfo_Idx,2}(i).' attribute.Name]))
                    currentAttribute= eval(['double(getFile{SegmentInfo_Idx,2}(i).' attribute.Name ')']);
                else
                    currentAttribute= eval(['char(getFile{SegmentInfo_Idx,2}(i).' attribute.Name ')']);
                end
                hdf5write(filenameHDF,attribute,currentAttribute,'writemode','append');
            catch
                currentAttribute= char('conversion to hdf failed');
                hdf5write(filenameHDF,attribute,currentAttribute,'writemode','append');
            end
        end
        
        % add EntityInfo for every entity
        attributeNames=fieldnames(getFile{EntityInfo_Idx,2});
        
        for e=1:size(attributeNames,1)
            attribute.Name = attributeNames{e};
            try
                if ~ischar(eval(['getFile{EntityInfo_Idx,2}(segmententityIDs(i)).' attribute.Name]))
                    currentAttribute= eval(['double(getFile{EntityInfo_Idx,2}(segmententityIDs(i)).' attribute.Name ')']);
                else
                    currentAttribute= eval(['char(getFile{EntityInfo_Idx,2}(segmententityIDs(i)).' attribute.Name ')']);
                end
                hdf5write(filenameHDF,attribute,currentAttribute,'writemode','append');
            catch
                currentAttribute= char('conversion to hdf failed');
                hdf5write(filenameHDF,attribute,currentAttribute,'writemode','append');
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% neural data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(neuralentityIDs)

    NeuralData_Idx=find(cell2mat(cellfun(@(x) strcmp(x,'NeuralData'),getFile,'UniformOutput',0)),1);
    NeuralInfo_Idx=find(cell2mat(cellfun(@(x) strcmp(x,'NeuralInfo'),getFile,'UniformOutput',0)),1);
    
    neural_root = [ record_root '/Neural' ];
    
    for i=1:size(getFile{NeuralData_Idx,2},2)
        
        % get spike times
        neural_leaf = [ neural_root '/' sprintf('%d',i) '/Data'];
        neuralData  = double(getFile{NeuralData_Idx,2}(:,i));
        hdf5write(filenameHDF,neural_leaf,neuralData,'writemode','append');
        
        if isempty(neuralData)
            continue;
        end
        
        % set Info as attribute
        attribute.AttachedTo = neural_leaf;
        attribute.AttachType = 'dataset';
        
        % loop over all accessable fields
        attributeNames=fieldnames(getFile{NeuralInfo_Idx,2});
        for f=1:size(attributeNames,1)
            attribute.Name = attributeNames{f};
            try
                if ~ischar(eval(['getFile{NeuralInfo_Idx,2}(i).' attribute.Name]))
                    currentAttribute= eval(['double(getFile{NeuralInfo_Idx,2}(i).' attribute.Name ')']);
                else
                    currentAttribute= eval(['char(getFile{NeuralInfo_Idx,2}(i).' attribute.Name ')']);
                end
                hdf5write(filenameHDF,attribute,currentAttribute,'writemode','append');
            catch
                currentAttribute= char('conversion to hdf failed');
                hdf5write(filenameHDF,attribute,currentAttribute,'writemode','append');
            end
        end
        
        % add EntityInfo for every entity
        attributeNames=fieldnames(getFile{EntityInfo_Idx,2});
        
        for e=1:size(attributeNames,1)
            attribute.Name = attributeNames{e};
            try
                if ~ischar(eval(['getFile{EntityInfo_Idx,2}(neuralentityIDs(i)).' attribute.Name]))
                    currentAttribute= eval(['double(getFile{EntityInfo_Idx,2}(neuralentityIDs(i)).' attribute.Name ')']);
                else
                    currentAttribute= eval(['char(getFile{EntityInfo_Idx,2}(neuralentityIDs(i)).' attribute.Name ')']);
                end
                hdf5write(filenameHDF,attribute,currentAttribute,'writemode','append');
            catch
                currentAttribute= char('conversion to hdf failed');
                hdf5write(filenameHDF,attribute,currentAttribute,'writemode','append');
            end
        end
    end 
end

% end