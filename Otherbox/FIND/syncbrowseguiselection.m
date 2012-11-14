function syncbrowseguiselection()

if isempty(findobj('Name','browseEntitiesGUI')) || isempty(findobj('Tag','MEAchannelsselectGUI'))
    return
end
hent=findobj('Name','browseEntitiesGUI');
hmea=findobj('Tag','MEAchannelsselectGUI');
%which entities are selected (in FIND_GUI userdata)

FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');

%this is only the actual change
%FIND_GUIdata.IDselected(str2num(get(gcbo,'Tag')))=get(gcbo,'Value');

%write to browseEntitiesGUI
if gcf==hent
    entIDinMEA=FIND_GUIdata.MEAmap;
    tmphandle=findobj(hmea,'Style','Checkbox');
    for ii=1:length(tmphandle)
        if ismember(str2num(get(tmphandle(ii),'Tag')),find(FIND_GUIdata.IDselected))
            set(tmphandle(ii),'Value',1)
        else
            set(tmphandle(ii),'Value',0)
        end
    end
elseif gcf==hmea
    %write to MEAchannelsselectGUI
    tmphandle=findobj(hent,'Style','Checkbox');
    for ii=1:length(tmphandle)
        %+1 compensates for entries set as "unassigned".
        if ismember(str2num(get(tmphandle(ii),'Tag')),find(FIND_GUIdata.IDselected))
            set(tmphandle(ii),'Value',1)
        else
            set(tmphandle(ii),'Value',0)
        end
    end
end


%write to browseEntitiesGUI