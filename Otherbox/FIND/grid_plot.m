classdef grid_plot < handle
    % UNTITLED Summary of this class goes here
    % Detailed explanation goes here
    properties
        gridlayout
        dataobj
        dataobjID
        displayhandle = NaN;
        subplothandles
        gxlim
        gylim
        settings
    end
    
    methods
        
        %% this is the constructor
        function mydisplay=grid_plot(varargin)
            
            % possible arguments: layoutmatrix,
            
            %% general settings
            mydisplay.settings.nextplotID=1;
            mydisplay.gridlayout=NaN;
        end
        
        %% add new data object
        function import(mydisplay, mydata, infostruct)
            
            %determine global minimal and maxima(or use set minima/maxima - needs to be implemented)
            if ~isempty(mydisplay.gylim)
                mydisplay.gylim=[min(mydata(:)) max(mydata(:))];
            elseif 1
                
            else
                
            end
            
            %assign handle to data
            %put data in plot window
            
            for dataidx=1:length(infostruct.entityIDs)
                [grow,gcol]=find(infostruct.layout==infostruct.entityIDs(dataidx));
                subplothandles(grow,gcol)=subplot('Position',spcoords{grow,gcol});
                tmpplothandles(grow,gcol)=plot(tmptime,mydata(dataidx,:,1));
                axis tight
                ylim(mydisplay.gylim)
                set(gca,'yticklabel',[]) ;
                set(gca,'xticklabel',[]) ;
                box off
            end
        end
        
        %% export data and infostruct from a dataobject
        function export
            
        end
        
        %% attach a data object
        function thisobj=attach(thisobj,dataobject)
            if isnan(thisobj.gridlayout)
                %if no layout set yet
                thisobj.gridlayout=size(dataobject.data.gridlayout);
            elseif ~all(thisobj.gridlayout==size(dataobject.data.gridlayout))
                % if layout differs
                error('gridlayout for new data is not compatible with present layout');
            end
            thisobj.dataobjID=[thisobj.dataobjID thisobj.settings.nextplotID];
            thisobj.settings.nextplotID=thisobj.settings.nextplotID+1;
            thisobj.dataobj=[thisobj.dataobj dataobject];
        end
        
        %% remove data object by objectID or name
        function remove(thisobj,myobjID)
            %by name
            if isa(myobjID,'char')
                tmp=[thisobj.dataobj.info];
                idxobjID=find(cellfun(@(mychar)strcmp(mychar,myobjID),{tmp.names}));
            elseif isa(myobjID,'double')
                idxobjID=myobjID;
            end
            %find
            idxobjID=find(thisobj.dataobjID==idxobjID);
            %delete
            thisobj.dataobjID(idxobjID)=[];
            thisobj.dataobj(idxobjID)=[];
        end
        
        %% remove data object, add one with same settings
        function replace(varargin)
            
        end
        %% detach dataobject
        function detach
            
        end
        %% (re)check global minimum and maximum of all/ all visible
        %% dataobjects
        function thisobj=gyminmax(thisobj,varargin)
            
            %set forall to "1" if you want to get gminmax for all(even
            %invisible) plots
            
            forall=0;
            pvpmod(varargin);
            if forall==1
                idxvis=length(gpobj.dataobj);
            elseif forall==0             %determine which are visible
                tmp=[thisobj.dataobj.plotprops];
                idxvis=find([tmp.showdata]);
            else error('illegal argments');
            end
            
            %switch between UDO-use and data stored in memory
            tmpmin=[];
            tmpmax=[];
            for ii=idxvis
                if isa(thisobj.dataobj(ii).data,'udo_pointer')
                    [objtmpmin objtmpmax]=thisobj.dataobj(ii).ylimits;
                    tmpmin=[tmpmin objtmpmin];
                    tmpmax=[tmpmax objtmpmax];
                else
                    tmpmin=[tmpmin min(thisobj.dataobj(ii).data(:))];
                    tmpmax=[tmpmax max(thisobj.dataobj(ii).data(:))];
                end
            end
            thisobj.gylim=[min(tmpmin) max(tmpmax)];
        end
        
        function thisobj=gxminmax(thisobj,varargin)
            
            %set forall to "1" if you want to get gxminmax for all(even
            %invisible) plots
            
            forall=0;
            pvpmod(varargin);
            if forall==1
                idxvis=length(gpobj.dataobj);
            elseif forall==0             %determine which are visible
                tmp=[thisobj.dataobj.plotprops];
                idxvis=find([tmp.showdata]);
            else error('illegal argments');
            end
            
            tmpmin=[];
            tmpmax=[];
            for ii=idxvis
                [dxmin dxmax]=thisobj.dataobj(ii).xlimits;
                tmpmin=[tmpmin dxmin];
                tmpmax=[tmpmax dxmax];
            end
            thisobj.gxlim=[min(tmpmin) max(tmpmax)];
        end
        %% draw display window
        function thisobj=initializedisplay(thisobj)
            % this creates a new window
            
            thisobj.displayhandle=figure('Units','normalized',...
                'Position',[0.2 0.4 0.6 0.4], ...
                'Tag','Grid_plot object display window', ...
                'Name','data display',...
                'DeleteFcn',@grid_plot_delete,...
                'NumberTitle','off',...
                'Color',[1 1 1],...
                'MenuBar','none');
            
            %... and the subplots
            
            nrow=thisobj.gridlayout(1);
            ncol=thisobj.gridlayout(2);
            
            % get coordinates for enlarged subplots
            spcoords=scalesubplots(nrow,ncol);
            
            %get global limits if not already set
            if isempty(thisobj.gxlim)
                thisobj.gxminmax;
            end
            if isempty(thisobj.gylim)
                thisobj.gyminmax;
            end
            
            for ii=1:prod(thisobj.gridlayout)
                subplothandles(ii)=subplot('Position',spcoords{ii});
                set(subplothandles(ii),'ButtonDownFcn',@zoomInSubplot2);
                % set limits
                xlim([thisobj.gxlim]);
                ylim([thisobj.gylim]);
                hold on;
            end
            
            thisobj.subplothandles=subplothandles;
            %thisobj.subplothandles=tindex(subplothandles,nrow,ncol);
            
        end
        
        function thisobj=draw(thisobj,varargin)
            % varargin{1}=dataobjID
            % varargin{2}=modified property
            init_flag=0;
            %% initialize display window if necessary
            if ~ishandle(thisobj.displayhandle)
                thisobj.initializedisplay;
                init_flag=1;
            end
            
            %% if only partial update is required - save time
            if ~isempty(varargin)
                if numel(varargin)~=2
                    error('partial plot update requires 2 input arguments');
                else
                    % get handles
                    updateSubs=[];
                    for pp=1:numel(thisobj.displayhandle)
                        tp=get(thisobj.displayhandle(pp),'Children');
                        if pp==1
                            % take only active subplots
                            updateSubs=[updateSubs; ...
                                tp(find(thisobj.dataobj(varargin{1}).data.gridlayout~=0))];
                        else
                            updateSubs=[updateSubs;tp];
                        end
                    end
                    
                    % in every plot same number of data traces, so just
                    % test first
                    if numel(get(updateSubs(1),'children')) > numel(thisobj.dataobj)
                        error('too many data traces - reference lost, please close plot and start again');
                    end
                    updatePlot=get(updateSubs,'Children');
                    if ~isempty(find(cellfun(@isempty , updatePlot), 1))
                        warning('some plots with handle error can''t be updated');
                        updatePlot=updatePlot(find(cellfun(@isempty , updatePlot)==0));
                    end
                    updateH=cellfun(@(x) x(varargin{1}),updatePlot);
                    
                    switch varargin{2}
                        case 'color'
                            set(updateH,'Color', thisobj.dataobj(varargin{1}).info.rgbcol);
                        case 'showdata'
                            if (thisobj.dataobj(varargin{1}).plotprops.showdata)
                                set(updateH,'Visible','on');
                            else
                                set(updateH,'Visible','off');
                            end
                        otherwise
                            error('unknown draw option for grid_plot object');
                    end
                end
            else
                %% replace plots or initial draw
                if  ~init_flag
                    for oo=1:numel(thisobj.subplothandles)
                        cla(thisobj.subplothandles(oo));
                    end
                end
                %
                %             %set gridlayout
                %             mydisplay.gridlayout=infostruct.layout;
                % %
                %             %create matrix containing handles
                %             tmpplothandles=NaN(nrow,ncol);
                %
                % loop over datasets
                for ii=1:length(thisobj.dataobj)
                    if thisobj.dataobj(ii).plotprops.showdata==1
                        fsamp=thisobj.dataobj(ii).info.fsamp;
                        datalength=size(thisobj.dataobj(ii).data,2);
                    end
                    
                    %%create time axis
                    
                    %check overlap with gminmax
                    [dxmin dxmax]=thisobj.dataobj(ii).xlimits;
                    
                    %plotlimits
                    
                    pxmin=max([dxmin thisobj.gxlim(1)]);
                    pxmax=min([dxmax thisobj.gxlim(2)]);
                    
                    plottime=dxmin:1/thisobj.dataobj(ii).fsamp:dxmax-1/thisobj.dataobj(ii).fsamp;
                    idxtoolow=find(plottime<thisobj.gxlim(1));
                    idxtoohigh=find(plottime>thisobj.gxlim(2));
                    idxyplot=setdiff(1:length(plottime),union(idxtoolow,idxtoohigh));
                    
                    sweepnumber=thisobj.dataobj(ii).plotprops.sweepnumber;
                    tmpobjlayout=unique(thisobj.dataobj(ii).data.gridlayout);
                    activID=tmpobjlayout(tmpobjlayout>0);
                    plotDataMat= thisobj.dataobj(ii).data(activID',idxyplot,sweepnumber);
                    
                    % now loop over plots
                    for activesubplot=1:length(thisobj.subplothandles)
                        %check if channel is deactivated;
                        %                     activesubplot;
                        
                        %check if channel is deactivated;
                        %assignment of temporary var necessary because of
                        %unresolved subsref issues with UDO!
                        tmpobjlayout=thisobj.dataobj(ii).data.gridlayout;
                        if tmpobjlayout(activesubplot)==0
                            continue;
                        else
                            Matpos=find(activID==tmpobjlayout(activesubplot));
                        end
                        
                        % resolve entityID assignment from gridlayout
                        elcidx=find(thisobj.dataobj(ii).data.entityID==tmpobjlayout(activesubplot));
                        if isempty(elcidx)
                            text(plottime(round(length(plottime)/3)),mean(thisobj.gylim),'bad ID')  ;
                            continue    ;
                        end
                        
                        plot(thisobj.subplothandles(activesubplot),plottime(idxyplot),...
                            plotDataMat(Matpos,:,1),...
                            'Color',thisobj.dataobj(ii).info.rgbcol);
                        
                        if (thisobj.dataobj(ii).plotprops.showdata)
                            set(thisobj.subplothandles(activesubplot),'Visible','on');
                        else
                            set(thisobj.subplothandles(activesubplot),'Visible','off');
                        end
                        
                    end
                end
                
                
                %             for dataidx=1:length(infostruct.entityIDs)
                %                 [grow,gcol]=find(infostruct.layout==infostruct.entityIDs(dataidx));
                %
                %                 tmpplothandles(grow,gcol)=plot(tmptime,mydata(dataidx,:,1));
                %                 axis tight
                %                 ylim(mydisplay.gylim)
                %                 set(gca,'yticklabel',[]) ;
                %                 set(gca,'xticklabel',[]) ;
                %                 box off
                %             end
                
                
                % replace subplots too
                
                if numel(thisobj.displayhandle)>1
                    for kk=2:numel(thisobj.displayhandle)
                        sourceSubPlot=get(thisobj.displayhandle(kk),'UserData');
                        close(thisobj.displayhandle(kk));
                        zoomInSubplot2(sourceSubPlot,[]);
                    end
                end
            end
        end
        
        %% change xaxis scale
        function xlim(minmax)
            
        end
        
        %% change yaxis scale
        function ylim(minmax)
            
        end
        %% overview of attached objects
        function [names,IDs,type]=content(thisobj)
            for ii=1:length(thisobj.dataobj)
                names{ii}=thisobj.dataobj(ii).info.name;
                IDs(ii)=thisobj.dataobjID(ii);
                type{ii}=class(thisobj.dataobj(ii).data);
            end
        end
        
        %% update after changing in lower objects
        function thisobj=update(thisobj,dataobj,param)
            %             disp('hello world')
            %             keyboard;
            if ~ischar(param)
                error('Parameter has to be char');
            end
            if ~isa(dataobj,'grid_data')
                error('only grid data objects allowed');
            end
            objName=cellfun(@(x) x.name, {thisobj.dataobj.info},'UniformOutput',0);
            objInd=find(strcmp(objName,dataobj.info.name));
            eval(['thisobj.dataobj(objInd).' param '=dataobj.' param ';']);
            if strcmp('info.offset',param)
                thisobj.gxminmax;
            end
        end
    end
end


function grid_plot_delete(source,event)
varlist=evalin('base','whos');
objname={varlist(strcmp({varlist.class},'grid_plot')).name};

close(evalin('base',[objname{1} '.displayhandle']));

if numel(objname)>1
    error('No bijective assignment of grid_plot object possible (more than one found)');
end

displayhandles=evalin('base',[objname{1} '.displayhandle;']);
resideHs=setdiff(displayhandles,source);
evalin('base',[objname{1} '.displayhandle= NaN;']);
evalin('base',[objname{1} '.subplothandles=[];']);
end


function zoomInSubplot2(source,event)
try
    varlist=evalin('base','whos');
    objname={varlist(strcmp({varlist.class},'grid_plot')).name};
    
    if numel(objname)>1
        error('No bijective assignment of grid_plot object possible (more than one found)');
    end
    
    ID=evalin('base',['find(ceil(' objname{1} '.subplothandles)==round(' num2str(source) '));']);
    
    % row-wise
    row=evalin('base',['rem(' num2str(ID) ',' objname{1}  '.gridlayout(1));'])+1;
    col=evalin('base',['floor(' num2str(ID) '/' objname{1} '.gridlayout(1));'])+1;

    ud=get(evalin('base',[objname{1} '.displayhandle']),'UserData');
    if iscell(ud)
        a =ismember(source,[ud{:}]);
    else
        a = ismember(source,ud);
    end
    if a
        disp([num2str(col) '/' num2str(row) ' - already exists']);
        return;
    end
    
    try
        xval=get(get(source,'Children'),'XData');
        yval=get(get(source,'Children'),'YData');
        rgbcol=get(get(source,'Children'),'Color');
        visibility=get(get(source,'Children'),'Visible');
    catch
        disp('requested subplot is empty');
        return;
    end
    if isempty(xval) || isempty(yval)
        disp('requested subplot is empty');
        return;
    end
    
    zoomfigH=figure('Name',[num2str(row) '/' num2str(col)] ,'NumberTitle','off',...
        'DeleteFcn',@DeleteZoomPlot,'UserData',source);
    
    evalin('base',[objname{1} '.displayhandle=[' objname{1} '.displayhandle,' num2str(zoomfigH) '];' ]);
    
    if iscell(xval)
        for oo=1:length(xval)
            plot(xval{oo},yval{oo},'Color',rgbcol{oo},'Visible',visibility{oo});
            hold on;
        end
    else
        plot(xval,yval,'Color',rgbcol,'Visible',visibility);
        drawnow;
    end
    axis tight;
catch
    rethrow(lasterror)
end
end


function DeleteZoomPlot(source,event)

varlist=evalin('base','whos');
objname={varlist(strcmp({varlist.class},'grid_plot')).name};

if numel(objname)>1
    error('No bijective assignment of grid_plot object possible (more than one found)');
end

displayhandles=evalin('base',[objname{1} '.displayhandle;']);
resideHs=setdiff(displayhandles,source);
evalin('base',[objname{1} '.displayhandle=[' num2str(resideHs) '];']);

end
