function MEAchannelsselectGUI()

%load stuff
global nsFile
FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');

[meawidth meaheight]=size(FIND_GUIdata.MEAmap);
if isempty([nsFile.EntityInfo.EntityID])
    postMessage('Please load data first!');
    return;
end

for ii=1:length(nsFile.EntityInfo)
    enttypes(ii)=nsFile.EntityInfo(ii).EntityType;
    entlabels{ii}=nsFile.EntityInfo(ii).EntityLabel;
    entIDs{ii}=nsFile.EntityInfo(ii).EntityID;
end

for ii=1:length(entlabels)
    entlabels{ii}=[entlabels{ii},' (EID:',num2str(entIDs{ii}),')'];
end

entlabels=['unassigned' entlabels];

if ~isfield(FIND_GUIdata,'MEAmap')
    FIND_GUIdata.MEAmap=ones(8,8);
end
myvalues=FIND_GUIdata.MEAmap;
myvalues=flipud(fliplr(myvalues));
for ii=1:meaheight
    slxngeom{ii}=repmat([1 3],1,meawidth);
end
for ii=1:meaheight*meawidth
    slxnuilist{ii*2-1}={'style','checkbox','Tag',num2str(myvalues(ii)),'Callback','setselectedentityID'};
    slxnuilist{ii*2}={'style','text','string',entlabels{myvalues(ii)+1}};
end
myslxnhandles=supergui('geomhoriz', slxngeom, 'uilist', slxnuilist);
set(gcf,'Units','normalized');
set(gcf,'Name','Select MEA Channels');
set(gcf,'Position',[0.1 0.5 0.8 0.4]);
set(gcf,'Tag','MEAchannelsselectGUI');
%workaround for annoying checkbox frame issue
boxhandles=findobj(gcf,'Style','Checkbox');
boxpos=get(boxhandles,'Position');
for ii=1:length(boxhandles);
    boxpos{ii}(2)=boxpos{ii}(2)+boxpos{ii}(4)/2+0.013;
    boxpos{ii}(4)=0.03;
    set(boxhandles(ii),'Position',boxpos{ii});
end

%initialize selection
if ~isfield(FIND_GUIdata,'IDselected')
    FIND_GUIdata.IDselected=zeros(1,length(nsFile.EntityInfo));
    set(findobj('Tag','FIND_GUI'),'UserData',FIND_GUIdata);
end

% if something is already selected, check boxes now
entIDinMEA=FIND_GUIdata.MEAmap;
hmea=gcf;
tmphandle=findobj(hmea,'Style','Checkbox');
for ii=1:length(tmphandle)
    if ismember(str2num(get(tmphandle(ii),'Tag')),find(FIND_GUIdata.IDselected))
        set(tmphandle(ii),'Value',1);
    else
        set(tmphandle(ii),'Value',0);
    end
end

unassignedboxes=findobj(gcf,'Tag','0');
for ii=unassignedboxes
    set(ii,'enable','off');
end

pdlayouts=uimenu('Parent',gcf,...
    'Label','&Selection');

uimenu('Parent',pdlayouts,...
    'Label','select all',...
    'Callback','MEAselectall');

uimenu('Parent',pdlayouts,...
    'Label','clear',...
    'Callback','MEAunselectall');

uimenu('Parent',pdlayouts,...
    'Label','preview selected',...
    'Callback','preview_mxn');

