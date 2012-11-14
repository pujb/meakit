function setselectedentityID(varargin)
% retrieves selected entityIDs and checks appropriate boxes in GUI
%
% Markus Nenniger 06
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

global nsFile;
hcheckbox=gcbo;
if ~isempty(varargin)
    hcheckbox=varargin{1};
end
FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
FIND_GUIdata.IDselected(str2num(get(hcheckbox,'Tag')))=get(hcheckbox,'Value');


    %does this actually do anything????
if get(hcheckbox,'Value')
    selectedID=str2num(get(hcheckbox,'Tag'));
end

% % select only one Event Entity
% avaiEvents=find([nsFile.EntityInfo(:).EntityType]==1);
% selectedEvents=avaiEvents(FIND_GUIdata.IDselected(avaiEvents)==1);
% 
% if length(selectedEvents)>1
%     unselectedEvent=setdiff(selectedEvents,selectedID);
%     PosUnselectedEvent=find([nsFile.EntityInfo(:).EntityID]==unselectedEvent);
%     FIND_GUIdata.IDselected(PosUnselectedEvent)=0;
%     set(findobj('Tag',num2str(unselectedEvent)),'Value',0);
% end

set(findobj('Tag','FIND_GUI'),'UserData',FIND_GUIdata);
syncbrowseguiselection;