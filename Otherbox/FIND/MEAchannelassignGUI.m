function MEAchannelassignGUI(varargin)

global nsFile;

FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
if ~isfield(FIND_GUIdata,'MEAmap')
    FIND_GUIdata.MEAmap=ones(8,8);
end
%default settings

[meawidth,meaheight]=size(FIND_GUIdata.MEAmap);


pvpmod(varargin);


for ii=1:length(nsFile.EntityInfo)
    enttypes(ii)=nsFile.EntityInfo(ii).EntityType;
    entlabels{ii}=nsFile.EntityInfo(ii).EntityLabel;
    entIDs{ii}=nsFile.EntityInfo(ii).EntityID;
end

for ii=1:length(entlabels)
    entlabels{ii}=[entlabels{ii},' (',num2str(entIDs{ii}),')'];
end


mypopup={'Style','popupmenu',....
    'String',['unassigned' entlabels],...
    'Callback','savemealayout(''FIND_GUI'')'};


for ii=1:meaheight
    mygeom{ii}=ones(meawidth,1);
end

for ii=1:meaheight*meawidth
    myuilist{ii}=mypopup;
end

meacell={'geomhoriz',{ones(meawidth)},...
    'geomvert',{ones(meaheight)}};

myhandles=supergui('geomhoriz', mygeom, 'uilist', myuilist);
set(gcf,'Tag','MEAchannelassign');
set(gcf,'Units','normalized');
set(gcf,'Name', 'Assigne MEA Channels');
set(gcf,'Position',[0.05 0.5 0.9 0.4]);
loadmealayout('FIND_GUI');

pdlayouts=uimenu('Parent',gcf,...
    'Label','&MEA Layout');

uimenu('Parent',pdlayouts,...
    'Label','Save layout',...
    'Callback','savemealayout(''file'');');

uimenu('Parent',pdlayouts,...
    'Label','Load saved layout',...
    'Callback','loadmealayout(''file'');');

uimenu('Parent',pdlayouts,...
    'Label','------------------','enable','off');

uimenu('Parent',pdlayouts,...
    'Label','Load MEA Layout and channelmap',...
    'Callback','loadmeageometryandmap');

uimenu('Parent',pdlayouts,...
    'Label','View MEA Geometry file',...
    'Callback','viewmeageometry');

uimenu('Parent',pdlayouts,...
    'Label','------------------','enable','off');

uimenu('Parent',pdlayouts,...
    'Label','set grid',...
    'Callback','setmeageometryGUI');

uimenu('Parent',pdlayouts,...
    'Label','manually assign entityIDs',...
    'Callback','meatableassignGUI');

uimenu('Parent',pdlayouts,...
    'Label','------------------','enable','off');

uimenu('Parent',pdlayouts,...
    'Label','read layout from variable in workspace',...
    'Callback','var2mealayout');

uimenu('Parent',pdlayouts,...
    'Label','export layout to variable ''MEAlayout''',...
    'Callback','mealayout2var');


meachannels=uimenu('Parent',gcf,...
    'Label','&Channels');

uimenu('Parent',meachannels,...
    'Label','Flip up/down',...
    'Callback','transformassignment(''ud'')');

uimenu('Parent',meachannels,...
    'Label','Flip left/right',...
    'Callback','transformassignment(''lr'')');

uimenu('Parent',meachannels,...
    'Label','Rotate clockwise',...
    'Callback','transformassignment(''cw'')');

uimenu('Parent',meachannels,...
    'Label','Rotate counter-clockwise',...
    'Callback','transformassignment(''ccw'')');

uimenu('Parent',meachannels,...
    'Label','increase/decrease all IDs',...
    'Callback','shiftMEAassignmentGUI');
% assign trigger channel here or in other GUI?
% triggerchannel=uimenu('Parent',gcf,...
%     'Label','&Trigger');



%has been moved to main FIND_GUI
% uimenu('Parent',meachannels,...
%     'Label','Assign channels',...
%     'Callback','assignmeachannelsGUI');
% 
% uimenu('Parent',meachannels,...
%     'Label','Select channels',...
%     'Callback','selectmeachannelsGUI');

