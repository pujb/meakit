function shiftMEAassignmentGUI()

shiftMEAassignmentGUI=figure('Units','Normalized',...
    'Tag','shiftMEAassignmentGUI', ...
    'Name','Shift assigned entityIDs',...
    'NumberTitle','off',...
    'MenuBar','none');

GUItextbox=uicontrol('Parent',shiftMEAassignmentGUI,...
    'Tag','GUItextbox',...
    'Style','text',...
    'String','Shift assigned IDs by ...',...
    'Units','Characters',...
    'Position',[3 7 22 1.5]);

GUIinputbox=uicontrol('Parent',shiftMEAassignmentGUI,...
    'Units','Characters',...
    'Style','edit',...
    'Tag','GUIinputbox',...
    'String','0',...
    'Units','Characters',...
    'Position',[5 5 18 1.5]);

shiftassignmentpushbutton=uicontrol('Parent',shiftMEAassignmentGUI,...
    'Units','Characters',...
    'Style','pushbutton',...
    'String','do it',...
    'Units','Characters',...
    'Callback','shiftMEAassignment(str2num(get(findobj(''Tag'',''GUIinputbox''),''String'')),''fromgui'',1)',...
    'Position',[5 3 18 1.5]);

%move new figure to center of existing figure
tmppos=get(findobj('Tag','MEAchannelassign'),'Position');
tmppos=[sum([tmppos(1) tmppos(3)/2]),sum([tmppos(2) tmppos(4)/2])];
set(shiftMEAassignmentGUI,'Position',[tmppos 0.1 0.1]);
set(shiftMEAassignmentGUI,'Units','Characters');
tmppos2=get(shiftMEAassignmentGUI,'Position');
set(shiftMEAassignmentGUI,'Position',[tmppos2(1)-14 tmppos2(2)-5 28 9]);
