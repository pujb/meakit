function myvalues=loadmealayout(source)

%somehow you always need it...
global nsFile;

FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');

%if no mpa exists, initialize something
if ~isfield(FIND_GUIdata,'MEAmap')
    FIND_GUIdata.MEAmap=ones(8,8);
end
myvalues=FIND_GUIdata.MEAmap;

if strcmp(source,'file')
    myvarname=uigetfile('*.m','Matlab Variable');
    load(myvarname,'-mat');
end

if ~all(size(myvalues)==size(FIND_GUIdata.MEAmap))
    FIND_GUIdata.MEAmap=myvalues;
    set(findobj('Tag','FIND_GUI'),'UserData',FIND_GUIdata);
    delete(findobj('Tag','MEAchannelassign'));
    MEAchannelassignGUI;
end


hassigngui=findobj('Tag','MEAchannelassign');
mych=findobj(hassigngui,'Style','popupmenu');

assigned=find(myvalues~=0);

%check for bad IDs and set flag accordingly
therearebadIDs=0;
if any(~ismember(myvalues(assigned),1:nsFile.FileInfo.EntityCount))
           therearebadIDs=1;
end

%note: unassigned ID are also considered "bad" - since they are set to
%"unassigned" that does not matter though...
idxbadIDs=~ismember(myvalues,1:nsFile.FileInfo.EntityCount);
myvalues(idxbadIDs)=0;

for ii=1:length(mych)
    %+1 compensates for "unassigned" entries, so that .MEAmap can actually
    %contain entityIDs
    %also do a check to see if IDs are in range...
    %
    %caution... something went wrong here...
    if idxbadIDs(ii)==1;
        set(mych(ii),'Value',1);
    else
        set(mych(ii),'Value',myvalues(ii)+1);
    end
end
if therearebadIDs
    errordlg('One or more of the assigned entityIDs could not be found in nsFile and were set as unassigned.','non-available IDs found')
    uiwait
end
FIND_GUIdata.MEAmap=myvalues;
set(findobj('Tag','FIND_GUI'),'UserData',FIND_GUIdata);
savemealayout('FIND_GUI');