function shiftMEAassignment(myshift,varargin)
fromgui=0;
pvpmod(varargin);
global nsFile

%get, change, errorcatch, , save
FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
myvalues=FIND_GUIdata.MEAmap;
newMEAmap=myvalues+myshift;
%"unassigned" electrode selections are NOT changed
newMEAmap(find(myvalues==0))=0;

%errorcatching - assigned electrodes must be within bounds of valid entityIDs.
assigned=find(myvalues~=0);
if any(~ismember(newMEAmap(assigned),1:nsFile.FileInfo.EntityCount))
    if fromgui==1
        errordlg('not a valid entityID','Assignment contains non valid entityID')
    end
    error('Assignment contains non valid entityID')
end

FIND_GUIdata.MEAmap=newMEAmap;
set(findobj('Tag','FIND_GUI'),'UserData',FIND_GUIdata);

%savemealayout('FIND_GUI');
if fromgui==1
    loadmealayout('FIND_GUI');
end