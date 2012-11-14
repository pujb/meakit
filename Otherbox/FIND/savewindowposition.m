function savewindowposition
hwindow=gcf;
FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');

if strcmp(get(hwindow,'Name'),'browseEntitiesGUI')
    FIND_GUIdata.GUIpos.browseEntitiesGUI=get(hwindow,'Position');
end

set(findobj('Tag','FIND_GUI'),'UserData',FIND_GUIdata);
%FIND_GUIdata.GUIpos.browseEntitiesGUI