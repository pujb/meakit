function loadNoNsFile(varargin)
% Selectively load neural data entities from none Neuroshare compatible data
% files.
% function loadNoNsFile(varargin)
% loadNoNsFile contains load-functions for some kinds of files for which no
% neuroshare DLL is given.
%
%%%%% implemented types of data: %%%%%%%%
%
% 'meabench':
%
% meabench2neuroshare_Info loads the Info and the Eventdata for all
% meabench spike files
%
% meabench2neuroshare_Data loads the Segmentdata for selected Events of
% meabench spike files
%
%%%%% Notes: %%%%%%%%%
%
% a.kilias 10/07
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

global nsFile; %-% if needed

try
    % obligatory argument names & validity test functions

    obligatoryArgs={'fileName'};

    % optional arguments names with default values
    optionalArgs={'fileInfo', ...
        'entityInfo', ...
        'analogData', ...
        'analogInfo', ...
        'eventData', ...
        'eventInfo', ...
        'segmentData', ...
        'segmentInfo', ...
        'neuralData', ...
        'neuralInfo', ...
        {'info', @(val) strcmp(val,'all') || val==0},...
        'libraryInfo',...
        {'loadMode', @(val) ismember(val,{'prompt','append','overwrite'})},...
        {'zeroPadding', @(val) ismember(val,{'prompt','yes'})}...
        };


    % default parameter values
    loadMode = 'prompt';
    zeroPadding = 'prompt';
    info = 0;
    fileInfo = 0;
    entityInfo = 0;
    analogData = 0;
    analogInfo = 0;
    eventData = 0;
    eventInfo = 0;
    segmentData = 0;
    segmentInfo = 0;
    neuralData = 0;
    neuralInfo = 0;
    libraryInfo = 0;


    errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
    if ~isempty(errorMessage)
        error(errorMessage,''); %used this format so that the '\n' are converted
    end

    % loading parameter value pairs into workspace, overwriting defaul values
    pvpmod(varargin);

    % select the type of
    switch lower(fileName(end-3:end)) % sometimes filename endings are in Capitals.
        case '.smr'
            % loading info only
            if sum(segmentData~=0)==0 && sum(eventData~=0)==0 && sum(neuralData~=0)==0 && sum(analogData~=0)==0
                disp({'data import via MATLAB SON Library' ;...
                    'by Malcolm Lidierth (version 2.31)'});
                SON2neuroshare_Info('fileName', fileName);
            else % load channels and info
                % load infos only if not already present
                if isempty(nsFile.FileInfo.EntityCount)
                    disp({'data import via MATLAB SON Library' ;...
                        'by Malcolm Lidierth (version 2.31)'});
                    SON2neuroshare_Info('fileName', fileName);
                end
                % load data
                % Notice that partial loading of data stored in one channel is recently
                % not possible!
                SON2neuroshare_Data('fileName', fileName,'segmentData', segmentData,...
                    'eventData',eventData,'neuralData',neuralData,'analogData',analogData)
            end
        case '.gdf'
            keyboard;
           % import GDF
           importGDF('fileName',fileName);
           
           % set entity Infos manual
           for aa=union(nsFile.Event.EntityID,nsFile.Neural.EntityID);
               nsFile.EntityInfo(aa).EntityID=aa;
               if ismember(aa,nsFile.Event.EntityID)
                   nsFile.EntityInfo(aa).ItemCount=numel(nsFile.Event.TimeStamp{find(nsFile.Event.EntityID==aa)});
               else
                   nsFile.EntityInfo(aa).ItemCount=numel(nsFile.Neural.Data{find(nsFile.Neural.EntityID==aa)});
               end
           end
           nsFile.EntityInfo(nsFile.Event.EntityID).EntityType=1;
           nsFile.EntityInfo(nsFile.Neural.EntityID).EntityType=4;
           nsFile.EntityInfo(nsFile.Event.EntityID).EntityLabel='GDF trigger';
           nsFile.EntityInfo(nsFile.Neural.EntityID).EntityLabel='GDF neuron';
           
           % set fileinfo
           nsFile.FileInfo.EntityCount
           nsFile.FileInfo.FileComment
           nsFile.FileInfo.Time_Day
           nsFile.FileInfo.Time_Hour
           nsFile.FileInfo.Time_Min
           nsFile.FileInfo.Time_MilliSec
           nsFile.FileInfo.TimeSpan
           
        case '.mat'
               %%%%%%%%%%%%% browse option (get infos) %%%%%%%%%%%%
               tinfo=whos('-file', fileName);
               % catch all manual save commands
               if any(strcmp('nsFile',{tinfo.name}))
                   try
                       a=load(fileName,'nsFile');
                       nsFile.FileInfo=  a.nsFile.FileInfo;
                       nsFile.FileInfo.FileComment=[char(nsFile.FileInfo.FileComment),' -- imported form mat file'];
                       nsFile.EntityInfo= a.nsFile.EntityInfo;
                       clear a;
                   catch
                       error('file structure mismatch - required fields nsFile.FileInfo and/or nsFile.EntityInfo missing');
                   end
               elseif any(strcmp('FileInfo',{tinfo.name})) && any(strcmp('EntityInfo',{tinfo.name}))
                   try
                       a=load(fileName,'FileInfo','EntityInfo'); 
                       nsFile.FileInfo=  a.FileInfo;
                       nsFile.FileInfo.FileComment=[char(nsFile.FileInfo.FileComment),' -- imported form mat file'];
                       nsFile.EntityInfo= a.EntityInfo;
                   catch
                       error('file structure mismatch - required fields nsFile.FileInfo and/or nsFile.EntityInfo missing');
                   end
               else
                   error('browsed *.mat file does not contain a FIND compatible nsFile structure')          
               end
               %%%%%%%%%%%% load data %%%%%%%%%%%%
            if any(([segmentData,eventData,neuralData,analogData])==1) ||...
                    any(strcmp('all',{segmentData,eventData,neuralData,analogData}))
                loadMATfile('fileName', fileName,'segmentData', segmentData,...
                    'eventData',eventData,'neuralData',neuralData,'analogData',analogData)
            end
            
        case 'pike'
            if strcmp(lower(fileName(end-5:end)),'.spike')
                postMessage('loading meabench data...');

                if exist(fileName)==0
                    error([fileName ' : File not found!']);
                end

                %%% NO PRIOR Knowledge Function call:
                %meabench2neuroshare_Info('fileName',fileName);

                % check if '.desc' file is available, (is normally created
                % simultaeously with all '.spike' files)
                descFileName=strcat(fileName,'.desc');
                [descResult]=isfile(descFileName);

                %%% Load info and spiketimes for all channels %%%
                if sum(segmentData~=0)==0 && sum(eventData~=0)==0 && sum(neuralData~=0)==0
                    if descResult==1
                        disp(strcat('additionaly: ', fileName,'.desc file uploaded'));
                        meabench2neuroshare_Info('fileName',fileName,'descFileName',descFileName,'loadMode','prompt');
                    elseif descResult==0
                        disp(strcat('additional .desc File: ',fileName,'.desc can NOT be uploaded'));
                        meabench2neuroshare_Info('fileName',fileName,'loadMode','prompt');
                    else
                        error('while searching for additional .desc file');
                    end
                    clear descFileName;
                end

                %%% Load segment data %%%
                if segmentData~=0
                    if strcmp(segmentData,'all')
                        segmentData=[1,1,[nsFile.EntityInfo(find(nsFile.EntityInfo.EntityType==3)).EntityID]];
                    end
                    % load context data for single channel
                    disp(['selected EntityID (type segment = meabench context data): ', num2str(segmentData(3:end)), ' // selected HW channel= ', num2str(segmentData(3:end)-1)]);
                    meabench2neuroshare_Data('fileName',fileName,'segmentData',segmentData,'loadMode','prompt');
                end
                if neuralData~=0
                    disp('Neural Data already loaded');
                    %%% Load event data %%%
                end
                if eventData~=0
                    if strcmp(eventData,'all')
                        eventData=[1,1,[nsFile.EntityInfo(find(nsFile.EntityInfo.EntityType==1)).EntityID]];
                    end
                    disp(['selected EntityID (type event = meabench trigger): ', num2str(eventData(3:end)),' // selected HW channel= ', num2str(eventData(3:end)-1)]);
                    meabench2neuroshare_Data('fileName',fileName,'eventData',eventData,'loadMode','prompt');
                end
            else
                error('no loading function available for this file format')
            end
        otherwise
            % prompt user for DLL file? or other loading file
            error('no loading function available for this file format')
    end

catch
    rethrow(lasterror);
end