classdef grid_data
    % object that contains the actual data
    properties 
        data
        info
        plotprops
    end
    methods
        function thisobj=grid_data(mydata,varargin)
            %infostruct is varargin{1}
            if strcmp(class(mydata),'udo_pointer')
                thisobj.data=mydata;
                thisobj.info.gridlayout=mydata.gridlayout;
%                 thisobj.info.
            end
                      
            thisobj.plotprops.sweepnumber=1;
            thisobj.plotprops.showdata=logical(1);
            thisobj.data=mydata;
            thisobj.info=varargin{1};
            
        end
        function [ymin ymax allmin allmax]=ylimits(thisobj)
            % helptext
            if strcmp(class(thisobj.data),'udo_pointer')
                switch(questdlg('This is a UDO-type object. Calculating minima and maxima for all entries is potentially very time consuming. Are you sure you want to continue?','UDO warning','Yes','Set manually','Cancel','Cancel'))
                    case 'Yes'
                        hwaitbar=waitbar(0,'Calculating extrema','Name','initialize Display');
                        for sweep=1:size(thisobj.data,3)
                            waitbar(sweep/size(thisobj.data,3),hwaitbar,['Calculating extrema ',num2str(sweep),'/',num2str(size(thisobj.data,3))]);
                            tmpmin(:,sweep)=min(thisobj.data(:,:,sweep)');
                            tmpmax(:,sweep)=max(thisobj.data(:,:,sweep)');
                        end
                        close(hwaitbar)
                        ymin=min(tmpmin(:));
                        ymax=max(tmpmax(:));
                        allmin=tmpmin;
                        allmax=tmpmax;
                    case 'Set manually'
                        dlgoption.Resize='on';
                        tmplimits=inputdlg({['enter upper y limit for object ''', thisobj.info.name,''''] ,'enter lower y limit'},['manual y limits']);
                        %check if any of the entered values are not doubles
                        values=cell2mat(cellfun(@str2num,tmplimits,'UniformOutput',false));
                        if any(cellfun(@isempty,cellfun(@str2num,tmplimits,'UniformOutput',false))) || ...
                                any(isnan(cell2mat(cellfun(@str2num,tmplimits,'UniformOutput',false)))) || ...
                                any(isinf(cell2mat(cellfun(@str2num,tmplimits,'UniformOutput',false))));
                           errordlg('not a legal value for y limits.');
                           error('not a legal value for y limits.');
                           error('calculation of y minima and maxima aborted by user.');
                        elseif diff(values) >= 0
                           errordlg('upper limit must be a larger value than lower limit');
                           error('calculation of y minima and maxima aborted by user.');
                        end
                        ymax=values(1);
                        ymin=values(2);
                    otherwise
                        error('calculation of y minima and maxima aborted by user.');
                end
            else
                ymin=min(thisobj.data(:));
                ymax=max(thisobj.data(:));
            end
        end
        function [xmin xmax]=xlimits(thisobj);
%             keyboard;
            xmin=thisobj.info.offset;
            xmax=size(thisobj.data,2)/thisobj.info.fsamp+thisobj.info.offset;
%             xmin=thisobj.info.xlimit(1);
%             xmax=thisobj.info.xlimit(2);
        end
        function [out]=fsamp(thisobj)
            out=thisobj.info.fsamp;
        end
    end 
end