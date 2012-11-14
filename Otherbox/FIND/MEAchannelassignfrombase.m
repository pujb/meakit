function MEAchannelassignfrombase(mapname)
try
    map=evalin('base',mapname{1});
catch
    errordlg('Variable with that name does not exist in base workspace','variable does not exist');
    return
end
FIND_GUIdata.MEAmap=map;
set(findobj('Tag','FIND_GUI'),'UserData',FIND_GUIdata);
delete(findobj('Tag','var2mealayout'));
delete(findobj('Tag','MEAchannelassign'));
MEAchannelassignGUI;