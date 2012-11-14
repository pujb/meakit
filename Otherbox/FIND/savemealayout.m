function savemealayout(target)
hassigngui=findobj('Tag','MEAchannelassign');
mych=findobj(hassigngui,'Style','popupmenu');
FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');

myvalues=reshape(cell2mat(get(mych,'Value')),size(FIND_GUIdata.MEAmap));
%compensate for the "unassigned" entry
myvalues=myvalues-1;

if strcmp(target,'FIND_GUI')
    FIND_GUIdata.MEAmap=myvalues;
    set(findobj('Tag','FIND_GUI'),'UserData',FIND_GUIdata);
elseif strcmp(target,'file')
    myvarname=uiputfile('*.m','Matlab Variable');
    save(myvarname,'myvalues');
end

if(ishandle(findobj('Tag','MEAchannelsselectGUI')))
    warndlg('MEA Electrode assignment changed. Please close and reload MEA entity selection GUI');
end