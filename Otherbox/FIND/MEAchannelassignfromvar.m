function MEAchannelassignfromvar(map)
FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
FIND_GUIdata.MEAmap=map;
set(findobj('Tag','FIND_GUI'),'UserData',FIND_GUIdata);
loadmealayout('FIND_GUI')