classdef udo_pointer < handle
    % Unified Data Object
    % multipurpose data access object. this object contains a link to a
    % data file and will work only if the set path is unchanged.
    
    % Markus Nenniger
    % find.bccn.uni-freiburg.de
  
    properties 
        %data
        fileinfo=struct('FileType',[],...
            'EntityCount',[],...
            'TimeStampResolution',[],...
            'TimeSpan',[],...
            'AppName',[],...
            'Time_Year',[],...
            'Time_Month',[],...
            'Time_Day',[],...
            'Time_Hour',[],...
            'Time_Min',[],...
            'Time_Sec',[],...
            'Time_MilliSec',[],...
            'FileComment',[],...
            'Datatypespresent',[]);
        paths=struct('dll',[],'file',[],'dllname',[]);
        datainfo 
        entityID
        objsize
        gridlayout
        fsamp
        name='';
        rgbcol=[1 0 0];
        offset=0;
        workflow=struct('fun',[],'arg',[],'mode',[]);
        window=struct('trigtime',[],'wwidth',[],'offset',[],'mode');
    end
        
    methods
        function thisUDO=udo_pointer(filename,dllname,entityIDs,gridlayout)
            %dllname is really dllpath....
            fileinfo=FIND_loader_MEA('fileName',filename,'DLLpath',dllname,'fileInfo',1,'tovar',1);
            entityinfo=FIND_loader_MEA('fileName',filename,'DLLpath',dllname,'entityInfo',entityIDs,'tovar',1);
            segmentinfo=FIND_loader_MEA('fileName',filename,'DLLpath',dllname,'segmentInfo',entityIDs,'tovar',1);
            if length(unique([entityinfo.EntityType]))>1
                errordlg('UDO may only contain entities of one type','more than one entitytype selected');
                return;
            end
            
            thisUDO.entityID=entityIDs;
            
            %determine filetype
            switch lower(filename(end-3:end)) % sometimes filename endings are in Capitals.
                case '.mcd' %Multi Channel Systems
                    DLLName = 'nsMCDLibrary.dll';
                case '.smr' % PC spike2, Cambridge Electronic Design Ltd.
                    DLLName = 'NSCEDSON.DLL';
                case '.son' % Mac spike2, Cambridge Electronic Design Ltd.
                    DLLName = 'NSCEDSON.DLL';
                case '.map' % Alpha Omega Eng.
                    DLLName = 'nsAOLibrary.dll';
                    %     case '' %Cambridge Electronics. DLL is somehow bugged and can't be
                    %     loaded.
                    %         DLLName = 'CFS32.dll';
                case '.nex' % Nex Technologies (NeuroExplorer)
                    DLLName = 'NeuroExplorerNeuroShareLibrary.dll';
                case '.plx' % Plexon Inc.
                    DLLName = 'nsPlxLibrary.dll';
                case '.stb' % Tucker-Davis
                    DLLName = 'nsTDTLib.dll';
                case {'.nev','.ns1','.ns2','.ns3','.ns4','.ns5'} % Cyberkinetics Inc., Library for Cerebus file group
                    DLLName = 'nsNEVLibrary.dll';
                    %         case  '.sif' || '.nix' || '.toc' || '.cpp' ||
                    %         '.vcproj' ???
                    %             DLLName = 'nsNEVLibrary.dll';
                case '.nsn' % Neuroshare Native File Format '.nsn'
                    DLLName = 'nsNSNLibrary.dll';
                case 'pike' % could be meabench .spike file
                    if strcmp(lower(fileName(end-5:end)),'.spike')
                        loadNoNsFile('fileName', fileName,'segmentData', segmentData,'eventData',eventData,'neuralData',neuralData);
                        DLLName = 'none neuroshare import';
                    end
                otherwise
                    % prompt user for DLL file?
                    error('no DLL available for this type of file');
            end
            thisUDO.paths.dll=[dllname,'\',DLLName];
            thisUDO.paths.file=filename;
            
            
            %%determine object size
            
            %dim1: entityIDs
            objsize(1)=length(entityIDs);
            
            %dim2: number of data points per sweep
            objsize(2)=segmentinfo(1).MinSampleCount;
            
            %dim3: number of sweeps per entityID
            objsize(3)=entityinfo(1).ItemCount;
            
            thisUDO.objsize=objsize;
            thisUDO.gridlayout=gridlayout;
            thisUDO.fsamp=1/fileinfo.TimeStampResolution;
            thisUDO.name='';
            thisUDO.rgbcol=[1 0 0];
            thisUDO.offset=0;
            
        end
        function out=end(A,B,C)
            out=A.objsize(B);
        end
        
        %% subsref
        %output arguments:
        % mydata - requested data
        % plotinfo
        function [mydata,alltime,infostruct] = subsref(A,S)
            % alltime contains individual time axes for all sweeps.
            % infostruct contains various info
            
            % loadmode can also be 'byID'
            loadmode_legal={'index','bypos','byID'};
            loadmode='index';
            
            
            
            % 2 output arguments only
            if nargout > 2
                error('too many output arguments');
            end
            
            %
            % pass arguments on for input like
            % 'object.field(x)'
            % works only for a single dot...
            %
            %
            
            if length(S)==1 && strcmp(S.type,'.')
                mydata=eval(['A.',S.subs]);
                return;
            elseif length(S)==2 && strcmp(S(1).type,'.')
                %check if
                tmpfun=@(x)strcmp(x,S(1).subs);
                if any(cellfun(tmpfun,loadmode_legal))
                    % or by entity ID (vector)
                    loadmode=S(1).subs;
                    S=S(2:end);
                %in principle this should work now
                elseif any(cellfun(tmpfun,methods(A)))
                    %mydata=eval(['A.',S(1).subs,'(',num2str(S(2).subs{:}),')']);
                    myfun=eval(['@A.',S(1).subs]);
                    A=myfun(S(2).subs{:});
                    return;
                elseif any(cellfun(tmpfun,properties(A)))
                    disp('arguments omitted, returning property values');
                    myfun=eval(['A.',S(1).subs]);
                    return;
                else
                    error('method or property unknown.');
                end
                
            end
            
            %catch errors: wrong bracket type, wrong number of subscripts
            mysubs=cell(length(S.subs),1);
            if strcmp(S.type,'{}') || strcmp(S.type,'[]')
                error('Object must be adressed as matrix (round brackets)');
            end
            if length(S.subs)<length(A.objsize)
                error('subscripts must be specified for all dimensions');
            end
            
            
            % convert ':' to meaningful indices and put S.subs in mysubs
            for ii=1:length(S.subs)
                if ischar(S.subs{ii})
                    if strcmp(S.subs{ii},':')
                        mysubs{ii}=1:A.objsize(ii);
                    end
                else
                    mysubs{ii}=S.subs{ii};
                end
            end
            
            % retrieve entities by position (m x 2
            % array of doubles, [row column]) if necessary
            if size(mysubs{1},1)>1
                loadmode='bypos';
            end
            
            % index mode is default, so do not change anything
            switch loadmode
                %this is rather alpha stage (MN)
                case 'bypos'
                    mylayout=A.gridlayout;
                    mysubs{1}=mylayout(sub2ind(size(mylayout),mysubs{1}(:,1),mysubs{1}(:,2)));
                    if mysubs{1}==0
                        error('no electrode assigned for this position');
                    end
                    [mysubs{1},mysubs{1}]=intersect(A.entityID,[mysubs{1}]);
                case 'byID'
                    % get indices for this object from entityIDs. kinda
                    % pointless though since entityIDs are used for
                    % loading.
                    [mysubs{1},mysubs{1}]=intersect(A.entityID,[mysubs{1}]);
            end
            
            
            %% load data
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%% BEGIN LOADING %%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %open file and dll
            myfile=A.paths.file;
            mydll=A.paths.dll;
            [nsresult] = ns_SetLibrary(mydll);
            [nsresult, hfile] = ns_OpenFile(myfile);
            %small errorcheck
            if A.objsize(2) < max(mysubs{2})
                error('dataidx not available');
            end
            
            
            % evaluate memory requirements
            % the issue is the memory overhead created by the use of double
            % variables and the returned 'Data' variable being somewhat
            % longer than SampleCount. how exactly is not known to the
            % author (MN) and is tested.
            %
            % memory requirement has to be balanced against
            % speed (more loopy --> less memory, but slower).
            %
            % test - assumption: all sweeps are of equal length.
            %
            [ns_RESULT, TimeStamp, Data, SampleCount, UnitID]=ns_GetSegmentData(hfile,A.entityID(1),mysubs{3}(1));
            
            
            %calculate maximum memory requirement for loading all data in
            %one go. calculations do not consider workflow memory
            %requirements.
            

            dim1=length(A.entityID); % IDs
            dim2=length(Data); %sweeplength
            dim3=length(mysubs{3}); %number of sweeps
            finallength=length(mysubs{2}); %number of requested dataindices
            
            mlongdouble=dim1*dim2*dim3*8;
            mlongsingle=dim1*dim2*dim3*4;
            mshortsingle=dim1*finallength*dim3*4;
            
            maxmem=max([mlongdouble+mlongsingle,mlongsingle+mshortsingle]);
            
            % evaluate if maxmem is available
            maxavail=memory;
            
            %% checks for differen
            
            
            %simplest case: it will be less than 50 megabyte - everyone
            %should have that...
            if maxmem <= 50e6 || maxmem<=maxavail.MaxPossibleArrayBytes
                %load everything in one go
                [ns_RESULT, TimeStamp, tmpData, SampleCount, UnitID]=ns_GetSegmentData(hfile,A.entityID,mysubs{3});
                tmpData=single(tmpData);
                if dim3==1 && dim1==1
                    tmpData=tmpData(1,mysubs{2});
                elseif dim3>1 && dim1==1
                    tmpData=tmpData(mysubs{2},:);
                elseif dim3==1 && dim1>1
                    tmpData=tmpData(mysubs{2},:);
                    tmpData=shiftdim(tmpData,1);
                elseif dim3>1 && dim1>1
                    tmpData=tmpData(mysubs{2},:,:);
                    tmpData=shiftdim(tmpData,2);
                end
                myTime=TimeStamp(:,1);
                mydata=tmpData;
                clear tmpData;
            else %load in chunks
                
                %maxspace that is temporarily taken up by 1 sweep;
                maxchunk=max(8*(dim2+length(mysubs{2}))+4*dim2+length(mysubs{2}))+max(4*dim2+length(mysubs{2})+4*length(mysubs{2}));
                maxavail=memory;
                
                
                %maximum memory taken up by loaded data
                %in single precision.
                maxdatamem=2*dim1*dim3*length(mysubs{2})*4;
                
                %leave at least 300kb for windows fluctuations and
                %housekeeping
                nsweeps=floor((maxavail.MaxPossibleArrayBytes-300000-maxdatamem)/maxchunk);
                if nsweeps==0;
                    error('out of memory');
                end
                %initialize pointers
                idxnextID=1;
                idxnextswp=1;
                
                %variables containing IDs and sweeps
                myIDs=A.entityID;
                myswps=mysubs{3};
                
                dataloaded=0;
                myTime=[];
                
                %% check for special requirements from workflow functions
                if any(cellfun(@(x)strcmp(x,'allswps'),A.workflow.mode))
                    allswps=1;
                else
                    allswps=0;
                end
                
                %% loading routine
                while dataloaded==0
                    idxthisID=idxnextID;
                    idxthisswp=idxnextswp;
                    idxswpstoload=[];
                    idxIDstoload=[];
                    if floor(nsweeps/dim3)==0
                        %nsweeps is not large enough to load all sweeps for 1 ID in
                        %one go
                        if allswps==1;
                            error('OUT of memory, free some memory before trying this operation. maybe try ''pack''');
                        elseif idxthisswp == 1
                            %load sweeps, increase idxnextswp accordingly
                            idxswpstoload=idxthisswp:idxthisswp+nsweeps-1
                            swpstoload=myswps(idxswpstoload);
                            
                            idxIDstoload=idxthisID
                            IDstoload=myIDs(idxIDstoload);
                            
                            idxnextswp=idxthisswp+nsweeps;
                        elseif idxthisswp~=1 && (idxthisswp + nsweeps - 1) < dim3
                            %load sweeps, increase idxnextswp accordingly
                            
                            idxswpstoload=idxthisswp:idxthisswp+nsweeps-1
                            swpstoload=myswps(idxswpstoload);
                            
                            idxIDstoload=idxthisID
                            IDstoload=myIDs(idxIDstoload);
                            
                            idxnextswp=idxthisswp+nsweeps;
                        elseif idxthisswp~=1 && (idxthisswp + nsweeps - 1) >= dim3
                            %load remaining sweeps for this ID
                            
                            idxswpstoload=idxthisswp:length(myswps);
                            swpstoload=myswps(idxswpstoload);
                            
                            idxIDstoload=idxthisID;
                            IDstoload=myIDs(idxIDstoload);
                            %set idxnextswp to 1
                            idxnextswp=1;
                            %increase idxnextID
                            idxnextID=idxthisID+1;
                        end
                        
                        %nsweeps is large enough to load all sweeps for one or more
                        %IDs in one go
                    elseif floor(nsweeps/dim3) >= 1
                        %load as many whole IDs as possible
                        idxswpstoload=1:length(myswps);
                        swpstoload=myswps(idxswpstoload);
                        
                        
                        idxIDstoload=idxthisID:min([idxthisID+floor(nsweeps/dim3)-1,length(A.entityID)]);
                        IDstoload=myIDs(idxIDstoload);
                        %increase idxnextID accordingly
                        idxnextID=idxthisID+floor(nsweeps/dim3);
                    end
                    %load data
                    %disp(['now loading sweeps',num2str(swpstoload),' for IDs ',num2str(IDstoload)]);
                    [ns_RESULT, TimeStamp, tmpData, SampleCount, UnitID]=ns_GetSegmentData(hfile,IDstoload,swpstoload);
                    %process data
                    %can this cause out of memory?
                    tmpData=single(tmpData);
                    myTime(idxIDstoload)=TimeStamp(:,1);
                    %cut tmpData
                    if length(swpstoload)==1 && length(IDstoload)==1
                        tmpData=tmpData(1,mysubs{2});

                    elseif length(swpstoload)>1 && length(IDstoload)==1
                        tmpData=tmpData(mysubs{2},:);
                    
                    elseif length(swpstoload)==1 && length(IDstoload)>1
                        tmpData=tmpData(mysubs{2},:);
                        tmpData=shiftdim(tmpData,1);
                    
                    elseif length(swpstoload)>1 && length(IDstoload)>1
                        tmpData=tmpData(mysubs{2},:,:);
                        tmpData=shiftdim(tmpData,2);
                    end
                    %attach tmpData to existing Data
                    
                    %% divide sweep into windows if desired
                    
                    %% process data all sweeps for one electrode
                    for wfID=1:size(tmpData,1)
                        A.workflow
                    end
                    
                    %% process data one sweep at a time 
                    % strcmp(workflow.mode,'singleswp')
                    %wf=workflow
                    %fun, args, modes
                    
                    %for now, process smallest data units (sweep/window) in
                    %a loop...
                    for wfID=1:size(tmpData,1)
                        for wfswp=1:size(tmpData,3)
                            for wfwin=1:size(tmpData,4)
                                for wf_step=1:length(A.workflow)
                                    tmpData2(wfID,:,wfswp,wfwin)=A.workflow(wf_step).fun(tmpData(wfID,:,wfswp,wfwin),A.workflow(wf_step).args{:});
                                    tmpData=tmpData2;
                                end
                            end
                        end
                    end
                    clear tmpData2
                    
                    %%
                    mydata(idxIDstoload,:,idxIDstoload)=tmpData;
                    if idxnextID > length(A.entityID);
                        dataloaded=1;
                    end
                end
                
            end
            

            ns_CloseFile(hfile);
            clear mexprog;
            
            
            % prepare information containing structure in case of a 2nd
            % output argument
            if nargout>=2
                %generate timescales;
                myTime=repmat(myTime,1,SampleCount(1));
                taxis=0:1/A.info.fsamp:(SampleCount(1)-1)/A.info.fsamp;
                taxis=repmat(taxis,size(myTime,1),1);
                alltime=myTime+taxis;
            elseif nargout==3
                infostruct=A.info;
                infostruct.entityIDs=A.entityID(mysubs{1});
            end
        end

        %% length
        function out=length(A)
            out=max(A.objsize);
        end
        function out=size(A,varargin)
            if isempty(varargin);
                out=A.objsize;
            elseif nargin > 2
                error('too many input arguments');
            elseif length(varargin{1})>1
                error('too many input arguments');
            elseif ismember(varargin{1},1:length(A.objsize))
                out=A.objsize(varargin{1});
            else
                error(['object has only ' num2str(length(A.objsize)) ' dimensions' ]);
            end
        end
        %% layout
        function out=layout(A)
            
            out=A.gridlayout;
        end
        %% timestamp
        function out=timestamp(A)
            out=1/A.fsamp;
        end
        %% info
        function [infostruct]=info(A)
            infostruct.fsamp=A.fsamp;
            infostruct.layout=A.gridlayout;
            infostruct.entityIDs=A.entityID;
            infostruct.name=A.name;
            infostruct.rgbcol=A.rgbcol;
            infostruct.offset=A.offset;
        end
        %% minmax
        function out=minmax(A)
            keyboard;
            
        end
        function thisobj=settrigger(thisobj,trigtime,wwidth,offset,mode)
            thisobj.window.trigtime=trigtime;
            thisobj.window.wwidth=wwidth;
            thisobj.window.offset=offset;
            thisobj.window.mode=mode;
        end
    end
    
end

