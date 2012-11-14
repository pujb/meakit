function FIND_GUI()
% GUI for extracting and handling neuronal data.
%
% Data sources can be files stored in Neuroshare compatible data files.
% Furthermore, additional data formats are in the
% process of being incorporated like GDF (Goettingen Data Format) and data
% acquired with Meabench.
%
% Markus Nenniger 2005-2007, mnenniger@gmx.net
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

% makes sure that no other windows of the same type are open

global nsFile;

if ishandle(findobj('tag', 'FIND_GUI'))
    close(findobj('tag', 'FIND_GUI'));
end;


% default values for button size etc. to be used in the main window and the
% sub windows; units in characters

global BUTTON_HEIGHT;
global LABEL_HEIGHT;
global MESSAGEBAR_PANEL_HEIGHT
global MESSAGEBAR_LEFT_OFFSET %for placement in panel
global MESSAGEBAR_RIGHT_OFFSET

BUTTON_HEIGHT=1.35;
LABEL_HEIGHT=1.1;
MESSAGEBAR_PANEL_HEIGHT=1.5;
MESSAGEBAR_LEFT_OFFSET=1;
MESSAGEBAR_RIGHT_OFFSET=2;

% Initialize FIND settings. These are stored in a variable called
% FIND_GUIdata, which will then be used to set the 'UserData' property of
% the GUI figure after it is created below. Access with
% FIND_GUIdata = get(findobj('Tag','FIND_GUI'),'UserData');
% Furthemore, the nsFile variable is initialized.
init_FIND;
% path(path,'Loader_FIND');

% the global ones are needed within the
% resize function
global MAIN_MIN_WIDTH;
global MAIN_MIN_HEIGHT;

%some panels are flexible in one or both dimensions, in these cases the
%values below are minimal values
topPanelHeight=6;
topPanelWidth=157;
leftPanelHeight=13;
leftPanelWidth=33;
rightPanelHeight=13;
rightPanelWidth=topPanelWidth-leftPanelWidth;
bottomPanelHeight=8;
bottomPanelWidth=topPanelWidth;
messageBarPanelWidth=bottomPanelWidth;


MAIN_MIN_WIDTH=topPanelWidth;
MAIN_MIN_HEIGHT=topPanelHeight+rightPanelHeight+bottomPanelHeight+ ...
    MESSAGEBAR_PANEL_HEIGHT;


mainWindow=figure('Units','characters',...
    'Position',[20 5 MAIN_MIN_WIDTH MAIN_MIN_HEIGHT], ...
    'Tag','FIND_GUI', ...
    'Name','FIND Data Handling Interface',...
    'DeleteFcn',@deleteMain,...
    'ResizeFcn',@resizeCallback,...
    'CloseRequestFcn',@my_closereq,...
    'NumberTitle','off',...
    'MenuBar','none');

set(mainWindow,'UserData',FIND_GUIdata);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Help menu%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

helpMenu=uimenu('Parent',mainWindow,...
    'Label','&Help');

uimenu('Parent',helpMenu,...
    'Label','What does this GUI do?',...
    'Callback','disp(''For detailed and actual help call generate_documentation.m and have a look at the html tree. '')');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% panels %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%size parameters see above main window initialization

topPanel=uipanel('Parent',mainWindow,...
    'Units','characters',...
    'Position',[0 (MAIN_MIN_HEIGHT-topPanelHeight)...
    topPanelWidth topPanelHeight],...
    'Tag','FIND_GUI_topPanel',...
    'BackgroundColor', [0.8 0.8 0.8]);

leftPanel=uipanel('Parent',mainWindow,...
    'Units','characters',...
    'Position',[0 ...
    (bottomPanelHeight+MESSAGEBAR_PANEL_HEIGHT)...
    leftPanelWidth leftPanelHeight],...
    'Tag','FIND_GUI_leftPanel',...
    'BackgroundColor', [0.8 0.8 0.8]);

rightPanel=uipanel('Parent',mainWindow,...
    'Units','characters',...
    'Position',[leftPanelWidth ...
    (bottomPanelHeight+MESSAGEBAR_PANEL_HEIGHT)...
    rightPanelWidth rightPanelHeight],...
    'Tag','FIND_GUI_rightPanel',...
    'BackgroundColor', [0.8 0.8 0.8]);

bottomPanel=uipanel('Parent',mainWindow,...
    'Units','characters',...
    'Position',[0 MESSAGEBAR_PANEL_HEIGHT ...
    bottomPanelWidth bottomPanelHeight],...
    'Tag','FIND_GUI_bottomPanel',...
    'BackgroundColor', [0.8 0.8 0.8]);

messageBarPanel=uipanel('Parent',mainWindow,...
    'Units','characters',...
    'Position',[0 0 ...
    messageBarPanelWidth MESSAGEBAR_PANEL_HEIGHT],...
    'Tag','FIND_GUI_messageBarPanel');


% find logo top right; a little bit clumsy because of the units
oldUnits=get(topPanel,'Units');
set(topPanel,'Units','pixels');
topPanelpos=get(topPanel,'Position');
axes('Parent', topPanel,'Units', 'pixels'); %logo

set(topPanel,'Units',oldUnits);

%image(imread('find_logo.png'));
set(gca,'DataAspectRatioMode','manual', 'Visible','off',...
    'Position', [0 0 topPanelpos(4) topPanelpos(4)]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% file loading controls %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


uicontrol('Parent',topPanel,...
    'Units','characters',...
    'Position',[2    3.42  15    LABEL_HEIGHT],...
    'Tag','FIND_GUI_filenameLabelText',...
    'Enable','on',...
    'String','File to load:',...
    'Style','text');

uicontrol('Parent',topPanel,...
    'Units','characters',...
    'Position',[19.75    3.42    72.5    LABEL_HEIGHT],...
    'Tag','FIND_GUI_dataFileEdit',...
    'Enable','on',...
    'Style','edit',...
    'BackgroundColor','w',...
    'TooltipString','Enter filename here; path can be relative.',...
    'Callback',@dataFileEditCallback);

uicontrol('Parent',topPanel,...
    'Units','characters',...
    'Position',[92.25    3.295    15    BUTTON_HEIGHT],...
    'Tag','FIND_GUI_browseDataFilePushbutton',...
    'String','Browse',...
    'Enable','on',...
    'TooltipString','Browse filesystem for file to load.',...
    'Callback',@browseDataFilePushbuttonCallback);


uicontrol('Parent',topPanel,...
    'Units','characters',...
    'Position',[2    1.72    15    LABEL_HEIGHT],...
    'Tag','FIND_GUI_fileInUseLabelText',...
    'Enable','on',...
    'String','File in use:',...
    'Style','text');

% contains the string used to load the data file

uicontrol('Parent',topPanel,...
    'Units','characters',...
    'Position',[19.75 1.72    87.5    LABEL_HEIGHT],...
    'Tag','FIND_GUI_fileInUseText',...
    'Enable','on',...
    'Tooltipstring','currently selected file',...
    'Style','text');


%%%%%%%%%%%%% info selection controls %%%%%%%%%%%%%%


% title
uicontrol('Parent',topPanel,...
    'Units','characters',...
    'Position',[118.75    4    30    LABEL_HEIGHT],...
    'Tag','FIND_GUI_infoCheckboxesLabelText',...
    'Enable','on',...
    'String','Entity info to retrieve',...
    'Tooltipstring',' Retrieve info for these entity types when loading the file. ',...
    'Style','text');


% all

uicontrol('Parent', topPanel,...
    'Units','characters',...
    'Position',[112    2.1  3    LABEL_HEIGHT],...
    'Tag','FIND_GUI_allInfoCheckbox',...
    'Tooltipstring','Retrieve info for all entity types when loading the file.',...
    'Value',0,...
    'Style','checkbox',...
    'BackgroundColor',[0.8 0.8 0.8],...
    'Callback',@allInfoCheckboxCallback);

uicontrol('Parent',topPanel,...
    'Units','characters',...
    'Position',[115.5    2.1    10    LABEL_HEIGHT],...
    'Tag','FIND_GUI_allInfoLabelText',...
    'Tooltipstring','Retrieve info for all entity types when loading the file.',...
    'Enable','on',...
    'String','All',...
    'Style','text');



% general

uicontrol('Parent', topPanel,...
    'Units','characters',...
    'Position',[112    .5  3    LABEL_HEIGHT],...
    'Tag','FIND_GUI_generalInfoCheckbox',...
    'Enable','off',...
    'Tooltipstring','Retrieve general entity info when loading the file.',...
    'Value',1,...
    'Style','checkbox',...
    'BackgroundColor',[0.8 0.8 0.8]);

uicontrol('Parent',topPanel,...
    'Units','characters',...
    'Position',[115.5    .5    10    LABEL_HEIGHT],...
    'Tag','FIND_GUI_generalInfoLabelText',...
    'Tooltipstring','Retrieve general entity info when loading the file.',...
    'Enable','on',...
    'String','General',...
    'Style','text');


% event

uicontrol('Parent', topPanel,...
    'Units','characters',...
    'Position',[126.5    2.1    3    LABEL_HEIGHT],...
    'Tag','FIND_GUI_eventInfoCheckbox',...
    'Enable','on',...
    'Tooltipstring','Retrieve info for event entities when loading the file.',...
    'Style','checkbox',...
    'BackgroundColor',[0.8 0.8 0.8]);

uicontrol('Parent',topPanel,...
    'Units','characters',...
    'Position',[130    2.1   10    LABEL_HEIGHT],...
    'Tag','FIND_GUI_eventInfoLabelText',...
    'Tooltipstring','Retrieve info for event entities when loading the file.',...
    'Enable','on',...
    'String','Event',...
    'Style','text');

% analog

uicontrol('Parent', topPanel,...
    'Units','characters',...
    'Position',[126.5    0.5    3    LABEL_HEIGHT],...
    'Tag','FIND_GUI_analogInfoCheckbox',...
    'Enable','on',...
    'Tooltipstring','Retrieve info for analog entities when loading the file.',...
    'Style','checkbox',...
    'BackgroundColor',[0.8 0.8 0.8]);

uicontrol('Parent',topPanel,...
    'Units','characters',...
    'Position',[130    0.5    10    LABEL_HEIGHT],...
    'Tag','FIND_GUI_analogInfoLabelText',...
    'Tooltipstring','Retrieve info for analog entities when loading the file.',...
    'Enable','on',...
    'String','Analog',...
    'Style','text');



% segment

uicontrol('Parent', topPanel,...
    'Units','characters',...
    'Position',[141    2.1    3    LABEL_HEIGHT],...
    'Tag','FIND_GUI_segmentInfoCheckbox',...
    'Enable','on',...
    'Tooltipstring','Retrieve info for segment entities when loading the file.',...
    'Style','checkbox',...
    'BackgroundColor',[0.8 0.8 0.8]);

uicontrol('Parent',topPanel,...
    'Units','characters',...
    'Position',[144.5    2.1    10    LABEL_HEIGHT],...
    'Tag','FIND_GUI_segmentInfoLabelText',...
    'Tooltipstring','Retrieve info for segment entities when loading the file.',...
    'Enable','on',...
    'String','Segment',...
    'Style','text');

% neural

uicontrol('Parent', topPanel,...
    'Units','characters',...
    'Position',[141    0.5    3    LABEL_HEIGHT],...
    'Tag','FIND_GUI_neuralInfoCheckbox',...
    'Enable','on',...
    'Tooltipstring','Retrieve info for neural entities when loading the file.',...
    'Style','checkbox',...
    'BackgroundColor',[0.8 0.8 0.8]);

uicontrol('Parent',topPanel,...
    'Units','characters',...
    'Position',[144.5    0.5    10    LABEL_HEIGHT],...
    'Tag','FIND_GUI_neuralInfoLabelText',...
    'Tooltipstring','Retrieve info for neural entities when loading the file.',...
    'Enable','on',...
    'String','Neural',...
    'Style','text');


% browse entities

uicontrol('Parent',leftPanel,...
    'Units','characters',...
    'Position',[4   10    25    BUTTON_HEIGHT],... %0.55
    'Style','pushbutton',...
    'String','Browse Entities',...
    'Tag','FIND_GUI_browseEntitiesPushbutton',...
    'Enable','on',...
    'Callback',@browseEntitiesPushbuttonCallback);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% info boxes %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% fileinfo - BOX

uicontrol('Parent',rightPanel,...
    'Units','normalized',...
    'Position',[0.03    0.05    0.45    0.9],...
    'Style','ListBox',...
    'String','Fileinfo',...
    'Tag','FIND_GUI_fileInfoListBox',...
    'HorizontalAlignment','left',...
    'Enable','on');

% Structure INFO Listobox
uicontrol('Parent',rightPanel,...
    'Units','normalized',...
    'Position',[0.52    0.05    0.45    0.9],...
    'Style','ListBox',...
    'String',structure2text(nsFile),...
    'Tag','FIND_GUI_structureInfoListBox',...
    'Enable','on',...
'Callback',@interactiveDataoverview);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% tool buttons %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% analog data based Spike Detection

uicontrol('Parent',bottomPanel,...
    'Units','characters',...
    'Position',[3 5 25 LABEL_HEIGHT],...
    'Style','text',...
    'FontWeight','bold',...
    'FontSize',9,...
    'String','Data analysis: ',...
     'BackgroundColor', [0.8 0.8 0.8],...
    'Tag','FIND_GUI_eventpopup',...
    'Enable','on');

%%%%%%% event %%%%%%%
uicontrol('Parent',bottomPanel,...
    'Units','characters',...
    'Position',[5 3 20 LABEL_HEIGHT],...
    'Style','text',...
    'String','1 - event',...
    'Tag','FIND_GUI_eventpopup',...
    'Enable','on');

uicontrol('Parent',bottomPanel,...
    'Units','characters',...
    'Position',[5 1 20 BUTTON_HEIGHT],...
    'Style','popupmenu',...
    'String',{'- choose -','import Trigger','set manual'},...
    'Tag','FIND_GUI_eventpopup',...
    'TooltipString','choose method for event data',...
    'Enable','on',...
    'Callback',@FIND_GUI_popup_Callback);

%%%%%%% analog %%%%%%%
uicontrol('Parent',bottomPanel,...
    'Units','characters',...
    'Position',[28 3 20 LABEL_HEIGHT],...
    'Style','text',...
    'String','2 - analog',...
    'Tag','FIND_GUI_analogpopup_txt',...
    'Enable','on');
uicontrol('Parent',bottomPanel,...    
    'Units','characters',...    
    'Position',[28 1 20 BUTTON_HEIGHT],...    
    'Style','popupmenu',...    
    'String',{'- choose -','CleanData','detect spikes','filter','NLI','Receptive Fields'},...    
    'Tag','FIND_GUI_analogpopup',...    
    'TooltipString','choose method for processing of analog data',...    
    'Enable','on',...    
    'Callback',@FIND_GUI_popup_Callback);

%%%%%%% segment %%%%%%%
uicontrol('Parent',bottomPanel,...
    'Units','characters',...
    'Position',[51 3 20 LABEL_HEIGHT],...
    'Style','text',...
    'String','3 - segment',...
    'Tag','FIND_GUI_segmentpopup_txt',...
    'Enable','on');
uicontrol('Parent',bottomPanel,...
    'Units','characters',...
    'Position',[51 1 20 BUTTON_HEIGHT],...
    'Style','popupmenu',...
    'String',{'- choose -','filter','JPSTH','LFP Analysis','NLI','PSTH',...
    'rasterPlot','SpikeSorting'},...
    'Tag','FIND_GUI_segmentpopup',...
    'TooltipString','choose method for processing of segment data',...
    'Enable','on',...
    'Callback',@FIND_GUI_popup_Callback);

%%%%%%% neural %%%%%%%
uicontrol('Parent',bottomPanel,...
    'Units','characters',...
    'Position',[74 3 20 LABEL_HEIGHT],...
    'Style','text',...
    'String','4 - neural',...
    'Tag','FIND_GUI_neuralpopup_txt',...
    'Enable','on');
uicontrol('Parent',bottomPanel,...
    'Units','characters',...
    'Position',[74 1 20 BUTTON_HEIGHT],...
    'Style','popupmenu',...
    'String',{'- choose -','AutoAlign','ISI distribution','NLI',...
    'PSTH','rasterPlot','UnitaryEvents'},...
    'TooltipString','choose method for processing of neural data',...
    'Tag','FIND_GUI_neuralpopup',...
    'Enable','on',...
    'Callback',@FIND_GUI_popup_Callback);

%%%%%%% simulation %%%%%%%
uicontrol('Parent',bottomPanel,...
    'Units','characters',...
    'Position',[102 5 25 LABEL_HEIGHT],...
    'Style','text',...
    'FontWeight','bold',...
    'FontSize',9,...
    'String','Simulation tools:',...
     'BackgroundColor', [0.8 0.8 0.8],...
    'Tag','FIND_GUI_simulation',...
    'Enable','on');

uicontrol('Parent',bottomPanel,...
    'Units','characters',...
    'Position',[105 1 20 BUTTON_HEIGHT],...
    'Style','popupmenu',...
    'String',{'- choose -','Gamma Process','ParPoPro'},...
    'TooltipString','choose simulation environment',...
    'Tag','FIND_GUI_simulationpopup',...
    'Enable','on',...
    'Callback',@FIND_GUI_popup_Callback);

%%%%%%% export %%%%%%%

uicontrol('Parent',bottomPanel,...
    'Units','characters',...
    'Position',[130 5 25 LABEL_HEIGHT],...
    'Style','text',...
    'FontWeight','bold',...
    'FontSize',9,...
    'String','Export data:',...
     'BackgroundColor', [0.8 0.8 0.8],...
    'Tag','FIND_GUI_export',...
    'Enable','on');

uicontrol('Parent',bottomPanel,...
    'Units','characters',...
    'Position',[134 1 20 BUTTON_HEIGHT],...
    'Style','popupmenu',...
    'String',{'- choose -', 'GDF' ,'HDF5' ,'MAT', 'STA'},...
    'Tag','FIND_GUI_exportpopup',...
    'TooltipString','choose file format',...
    'Enable','on',...
    'Callback',@FIND_GUI_popup_Callback);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% MESSAGEBAR %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

messageBarPanelpos=get(messageBarPanel,'Position');

uicontrol('Parent',messageBarPanel,...
    'Units','characters',...
    'Position',[(messageBarPanelpos(1)+MESSAGEBAR_LEFT_OFFSET) ...
    (messageBarPanelpos(2)) ...
    (messageBarPanelpos(3)-MESSAGEBAR_RIGHT_OFFSET) ...
    LABEL_HEIGHT],...
    'Tag','messageBar',...
    'Enable','on',...
    'String','Welcome to FIND!',...
    'HorizontalAlignment','left',...
    'Style','text');


% prevent main window from becoming the target for graphics output
set(mainWindow,'HandleVisibility','on');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%% filehandling functions %%%%%%%%%%%%%%%%%%%%


function loadDataFile(fullFileName)
%Compile necessary information from the FIND_GUI settings and then load
%data file using the FIND_loader.
%
%loadDataFile compiles a list of parameter value pairs to pass to
%FIND_loader depending on which checkboxes for information about entities
%are checked. For documentation of FIND_loader parameters, see help
%FIND_loader.
%
%loadDataFile will be called either from dataFileEditCallback or from
%browseDataFilePushbuttonCallback. These correspond to either using the
%edit box or the browse button to determine the fullFileName (which
%includes the path, which does not have to be absolute.).

global nsFile;

try
    
    postMessage('');
    postMessage('Busy - please wait...');
    
    
    if ~isempty(nsFile.Analog.Data)||~isempty(nsFile.Segment.Data{1})||...
            ~isempty(nsFile.Event.TimeStamp{1})||~isempty(nsFile.Neural.Data{1})||...
            ~isempty(nsFile.EntityInfo(1).EntityLabel)
        loadModeSwitch=questdlg('Data already exists in the nsFile variable! Partially overwriting might arouse problems!',...
            'Do you want to reset FIND?', ...
            'reset','cancel','cancel');
        if strcmp(loadModeSwitch, 'reset')
            clear global nsFile;
            %whos;
            evalin('base','init_FIND;');
            whos;
            %global nsFile;
            %whos;
        else
            warning('already data in the variable - conflicts possible');
        end
    end
    
    
    PVPlist={'fileInfo',1};
    
    %compile list of parameter value pairs to pass to FIND_loader depending on
    %which checkboxes for information about entities are checked. for
    %documentation of FIND_loader parameters, see help FIND_loader.
    
    % this checkbox cant be unchecked
    if get(findobj(gcf,'Tag','FIND_GUI_generalInfoCheckbox'),'Value')==1
        PVPlist{length(PVPlist)+1}='entityInfo';
        PVPlist{length(PVPlist)+1}='all';
    end
    
    % analog entity information. stored in nsFile.Analog.Info
    if get(findobj(gcf,'Tag','FIND_GUI_analogInfoCheckbox'),'Value')==1
        PVPlist{length(PVPlist)+1}='analogInfo';
        PVPlist{length(PVPlist)+1}='all';
    end
    
    % event entity information. stored in nsFile.event.Info
    if get(findobj(gcf,'Tag','FIND_GUI_eventInfoCheckbox'),'Value')==1
        PVPlist{length(PVPlist)+1}='eventInfo';
        PVPlist{length(PVPlist)+1}='all';
    end
    
    % segment entity information. stored in nsFile.segment.Info
    if get(findobj(gcf,'Tag','FIND_GUI_segmentInfoCheckbox'),'Value')==1
        PVPlist{length(PVPlist)+1}='segmentInfo';
        PVPlist{length(PVPlist)+1}='all';
    end
    
    % neural entity information. stored in nsFile.Neural.Info
    if get(findobj(gcf,'Tag','FIND_GUI_neuralInfoCheckbox'),'Value')==1
        PVPlist{length(PVPlist)+1}='neuralInfo';
        PVPlist{length(PVPlist)+1}='all';
    end
    
    % dll path stored in the UserData (loaded from init.m)
    FIND_GUIdata = get(findobj('Tag','FIND_GUI'),'UserData');
    DLLpath=FIND_GUIdata.DLLpath;
    
    FIND_loader('fileName',fullFileName,'DLLpath',DLLpath, PVPlist{:});
    
    %show which file is in use in the GUI.
    set(findobj(gcf,'Tag','FIND_GUI_fileInUseText'),'String',fullFileName);
    %Also setting the current data file in the edit box.
    set(findobj(gcf,'Tag','FIND_GUI_dataFileEdit'),'String',fullFileName);
    
    evalin('caller','global nsFile');
    
    global nsFile;
    % get values for all fields in nsFile.FileInfo (general file info) and
    % write the in the big textbox (streamfileinfobox) in the main GUI.
    tempFieldNames=fieldnames(nsFile.FileInfo);
    tempFieldContent=struct2cell(nsFile.FileInfo);
    for ii = 1: size(tempFieldNames,1)
        tempString{ii}=strcat(tempFieldNames{ii},':  ',num2str(tempFieldContent{ii}));
    end
    set(findobj(gcbf,'Tag','FIND_GUI_fileInfoListBox'),'String',tempString);
    
    
    %%% Get the structure-info and write it into the list box
    set(findobj(gcbf,'Tag','FIND_GUI_structureInfoListBox'),'String',structure2text(nsFile));
    
    
    % (re)set selected entities
    FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
    FIND_GUIdata.IDselected=zeros(1,length(nsFile.EntityInfo));
    set(findobj('Tag','FIND_GUI'),'UserData',FIND_GUIdata);
    postMessage('...done.');
catch
    handleError(lasterror);
end


function dataFileEditCallback(source,event)
% Callback for the data file edit box. Calls loadDataFile().
%
fullFileName=get(findobj(gcf,'Tag','FIND_GUI_dataFileEdit'),'String');
try
    loadDataFile(fullFileName);
catch
    handleError(lasterror);
end


function browseDataFilePushbuttonCallback(source,event)
% Callback for the "browse" button, allows user to browse the filesystem
% to select a data file. Calls loadDataFile().

%%% THIS IS A ON THE FLY WORKAROUND of the uigetfile bug on some releases on
%%% linux --> see matlab bug report for details:
% % %
% % % Summary  	   	uigetfile sometimes works incorrectly on Linux platforms.
% % % Report ID 	  	259878
% % % Date Last Modified 	  	14 Nov 2006
% % % Product 	  	MATLABå¨
% % % Exists In Version 	  	7.0.1, 7.0.4, 7.1, 7.2, 7.3
% % % Exists In Release 	  	R14SP1, R14SP2, R14SP3, R2006a, R2006b
% % % Fixed In Version 	  	7.4
% % % Fixed In Release 	  	R2007a

if isunix
    setappdata(0,'UseNativeSystemDialogs',false);
    postMessage('Changed UI dialogs (LINUX only) as a workaround for matlab bug report ID: 259878');
end

%%% end of MATLAB Bugfix

prevFile=get(findobj(gcf,'Tag','FIND_GUI_dataFileEdit'),'String');
if ~isempty(prevFile)
    [prevSearchPath, name, ext, versn]=fileparts(prevFile);
    FIND_Path=pwd;
    cd(prevSearchPath)
end

[dataFileName,dataFilePath,filterSpec]=uigetfile({'*.*','all files';
    '*.mcd','MCRack files';...
    '*.smr','smr files';...
    '*.map','Alpha Omega files';...
    '*.nex','NeuroExplorer files';...
    '*.plx','Plexon files';...
    '*.stb','Tucker Davis files';...
    '*.spike','Meabench spike files';...
    '*.gdf','Gerstein Dataformat';...
    '*.mat','Matlab format files (containing an exported nsFile)'});

if dataFilePath==0, return, end; % if the action is cancelled do nothing

if ~isempty(prevFile)
    cd(FIND_Path);
end

loadDataFile(fullfile(dataFilePath,dataFileName));


function allInfoCheckboxCallback(source, event)
% Clicking the 'all' checkbox checks/unchecks all other info checkboxes
% accordingly.

allCheckedValue=get(findobj(gcf,'Tag','FIND_GUI_allInfoCheckbox'),'Value');

set(findobj(gcf,'Tag','FIND_GUI_eventInfoCheckbox'), 'Value',allCheckedValue)
set(findobj(gcf,'Tag','FIND_GUI_analogInfoCheckbox'), 'Value',allCheckedValue)
set(findobj(gcf,'Tag','FIND_GUI_segmentInfoCheckbox'), 'Value',allCheckedValue)
set(findobj(gcf,'Tag','FIND_GUI_neuralInfoCheckbox'), 'Value',allCheckedValue)


function browseEntitiesPushbuttonCallback(source,event)
%this starts up browseEntitiesGUI, enabling the user to browse through the datafile
%entities.

global nsFile
try
    postMessage(''); % Clean up prior messages.
    fileInUse=get(findobj('Tag','FIND_GUI_fileInUseText'),'String');
    if isempty(fileInUse)
        error('FIND:noFileLoaded','');
    else
        browseEntitiesGUI();
    end
catch
    handleError(lasterror);
end

%%% Get the structure-info and write it into the list box Update after
%%% Browsing!
set(findobj(gcbf,'Tag','FIND_GUI_structureInfoListBox'),'String',structure2text(nsFile));


%%%%%%%%%%% tool functions %%%%%%%%%%%%%%%%%%%%


function FIND_GUI_popup_Callback(source,event)

global nsFile
a=get(source,'String');
methodSelection=a{get(source,'Value')};


switch methodSelection        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    case '- choose -'
        return;
    %%%%%%%%%%%%% detect spikes %%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    case 'detect spikes'        
        % After loading of the data, spike detection may be performed!        
        % IMHO unnecessary to issue a warning here        
        try            
            postMessage(''); 
           if isempty(nsFile.Analog.Data)
               postMessage('Please load analog data first');
               return;
           end
            detectSpikesGUI();        
        catch
            handleError(lasterror);        
        end
        set(findobj(gcbf,'Tag','FIND_GUI_structureInfoListBox'),'String',structure2text(nsFile));
        %%% Get the structure-info and write it into the list box Update after
        %%% Browsing!
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%% none linear interdependences %%%%%%%%%%%%%
    case 'NLI'
        try
            postMessage(''); 
            NLITVtoolGUI();
        catch
            handleError(lasterror);
        end
          
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         %%%%%%%%%%%%%%%% sort spikes %%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'SpikeSorting'
        try
            postMessage('');
            if isempty(nsFile.Segment.Data{1})
                postMessage('missing segment data');
                return;
            end
            sortSpikesGUI();
        catch
            handleError(lasterror);
        end
        
        %%% Get the structure-info and write it into the list box Update after
        %%% Browsing!
        set(findobj(gcbf,'Tag','FIND_GUI_structureInfoListBox'),'String',structure2text(nsFile));
        
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         %%%%%%%%%%%%%%%% simulate gamma process %%%%%%%%%%%%%%%%
    case 'Gamma Process'
        postMessage(''); % Clean up prior messages.
        simulateGammaGUI();
        
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%% import data from GDF file%%%%%%%%%%%%%%%
    case 'import Trigger'
        try
            postMessage(''); % Clean up prior messages.
            postMessage('Busy - please wait...');
            importGDF_GUI();
            postMessage('...done.');
        catch
            handleError(lasterror);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%% export data %%%%%%%%%%%%%%%%
    case {'HDF5' , 'GDF' , 'STA','MAT'}
        try
            postMessage(''); % Clean up prior messages.          
            DataExport_GUI('selected_Export',methodSelection);
        catch
            handleError(lasterror);
        end
        
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%% Unitary Events %%%%%%%%%%%%%
    case 'UnitaryEvents'
        try
            postMessage(''); % Clean up prior messages.
            if exist('startue.m','file')
                % it is there ?
                postMessage('Found Unitary Event Toolbox, starting...');
                temp= get(findobj('tag','FIND_GUI'),'UserData');
                cd([temp.FINDpath,filesep, 'UnitaryEvents']);
                splashscreen('create');
                startue;
                
            else
                postMessage('Unitary Event Toolbox files not found.');
                answer=questdlg(...
                    'Unitary Events Toolbox files need to be added to the MATLAB search path - continue?',...
                    'Add UE to path',...
                    'Yes',...
                    'Cancel',...
                    'Yes'); %last is default
                if strcmp(answer,'Yes')
                    temp= get(findobj('tag','FIND_GUI'),'UserData');
                    path(path,[temp.FINDpath,filesep, 'UnitaryEvents']);
                    postMessage('Found Unitary Event Toolbox, starting...');
                    cd([temp.FINDpath,filesep, 'UnitaryEvents']);
                    splashscreen('create');
                    startue;
                end
                %disp('Unitary Event Toolbox not found - change your path Variablea ccordingly (addpath ...)');
                %error('Unitary Event Toolbox not found - change your path Variable accordingly (addpath ...)');
            end
        catch
            handleError(lasterror);
        end
        
        
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%% Receptive Fields %%%%%%%%%%%%%
    case 'Receptive Fields'
        postMessage(''); % Clean up prior messages.
        if exist('makeStrfGUI.m','file')
            % it is there ?
            postMessage('Found makeStrf Toolbox, starting...');
            makeStrfGUI;
            
        else
            postMessage('makeStrf Toolbox files not found.');
            answer=questdlg(...
                'makeStrf Toolbox files need to be added to the MATLAB search path - continue?',...
                'Add makeStrf to path',...
                'Yes',...
                'Cancel',...
                'Yes'); %last is default
            if strcmp(answer,'Yes')
                addpath('receptiveFields');
                postMessage('Found makeStrf Toolbox, starting...');
                makeStrfGUI;
            end
        end
        
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%% AutoAlign %%%%%%%%%%%%%
    case 'AutoAlign'
        try
            postMessage('starting AutoAlign GUI'); % Clean up prior messages.
            %-% some checks maybe here?
            autoAlignGUI(); %-% usually no arguments should be necessary
        catch
            handleError(lasterror);
        end
        
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%% ParPoPro %%%%%%%%%%%%%
        
    case 'ParPoPro'
        try
            postMessage(''); % Clean up prior messages.
            if exist('ParPoPro.m','file')
                postMessage('The ParPoPro Toolbox requires the Matlab Statistics_Toolbox for some functions! Found ParPoPro Toolbox, starting...');
                ParPoPro;
            else
                postMessage('ParPoPro Toolbox files not found.');
                answer=questdlg(...
                    'Note: The ParPoPro Toolbox requires the Matlab Statistics_Toolbox for some functions! ParPoPro Toolbox files need to be added to the MATLAB search path - continue?',...
                    'Add ParPoPro Toolbox to path',...
                    'Yes',...
                    'Cancel',...
                    'Yes');
                if strcmp(answer,'Yes')
                    path(path,'ParPoPro');
                    path(path,'ParPoPro\Concatination');
                    path(path,'ParPoPro\CorrelatedProcesses');
                    path(path,'ParPoPro\Data');
                    path(path,'ParPoPro\GUI');
                    path(path,'ParPoPro\DataHandling');
                    path(path,'ParPoPro\Display');
                    path(path,'ParPoPro\SingleProcesses');
                    postMessage('Found ParPoPro Toolbox, starting...');
                    ParPoPro;
                end
                
            end
        catch
            handleError(lasterror);
        end
        
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%% CleanData %%%%%%%%%%%%%
    case 'CleanData'
        try
            postMessage(''); 
            if isempty(nsFile.Analog.Data)
                postMessage('Please load analog data first');
                return;
            else
                postMessage('starting CleanData GUI');
            end
            CleanDataGUI();
            postMessage('...done');
        catch
            handleError(lasterror);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%% basicProcessing tools %%%%%%%%%%%%%
    case {'rasterPlot','PSTH','filter','ISI distribution'}
        try
            postMessage('');     
            postMessage('starting basic Processing GUI'); 
            basicProcessingGUI('selected_Process',methodSelection); %-% usually no arguments should be necessary
        catch
            handleError(lasterror);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%% LFP Tools %%%%%%%%%%%%%%%%%%%%%
    case 'LFP Analysis'
        try
            postMessage(''); 
            varlist=evalin('base','whos;');
            udo_list=find(cellfun(@(x) strcmp(x,'udo_pointer'),{varlist.class}));
            if isempty(udo_list)
                postMessage('Please create data object first');
                return;
            else
                postMessage('starting LFP Analysis');
            end
            % LFPworkflow_GUI;
            LFPplotcontrolGUI;
        catch
            handleError(lasterror);
        end
        
    case {'set manual'}
        try
            postMessage(''); % Clean up prior messages.
            postMessage('starting to set Trigger manually'); % Clean up prior messages.
            TriggerTable_GUI(); %-% usually no arguments should be necessary
        catch
            handleError(lasterror);
        end
%     case{ 'show' , 'split Entity'}
%         postMessage('not implemented yet');
%         return;
        
     case{'ISI distribution'}
       keyboard; 
    %%%%%%%%%%%%%%%%%%%%Not implemented function of anolog title%%%%%%%%%%%%%%    
    case{'JPSTH'}
        postMessage('sorry, implementation is not finished yet - no access');
        return;
%         showselecteddatapulldown=uimenu('Parent',datamenu,...
%     'Label','Preview selected entities',...
%     'Callback','showdata(''selectedentities'',1)');
        
    otherwise
        error('FIND: unknown analysis, simulation or exporting method');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% GUI functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function deleteMain(source,event)
% if the main window is closed, close all other windows too
try
    close(findobj('Name','browseEntitiesGUI'));
    close(findobj('Name','Filter settings'));
    close(findobj('Name','CleanData GUI'));
    close(findobj('Name','Spike Detection GUI'));
    close(findobj('Name','Spikes Sorting GUI'));
    close(findobj('Name','basic Processing GUI'));
    close(findobj('Name','autoAlign GUI'));
    close(findobj('Name','Data Export GUI'));
    close(findobj('Name','Non linear interdependencies GUI'));
    close(findobj('Name','Gamma Process Simulation GUI'));
    close(findobj('Name','Import GDF GUI'));
catch
end

function interactiveDataoverview(source,event)
global nsFile
newdisp={};
recentView=get(source,'String');
headline=strtrim(recentView{2});
selectedView=strtrim(recentView{get(source,'Value')});

if ~strcmp(selectedView,'..') && ~isempty(selectedView)
    if strcmp(headline,'nsFile') && ~strcmp(selectedView,headline)
        newOverview=eval(['nsFile.',selectedView]);
    elseif strcmp(selectedView,headline) || strcmp(selectedView,'Info')
        return;
    elseif ~strcmp(headline,'nsFile') && ismember(selectedView,fieldnames(nsFile))
        newOverview=eval(['nsFile.',headline,'.',selectedView]);
    elseif ~strcmp(headline,'nsFile') && ~ismember(selectedView,fieldnames(nsFile)) && ...
            ~any(strcmp(selectedView(1),{'[','{','('}))
        newOverview=eval(['nsFile.',headline,'.',selectedView]);
        if isempty(newOverview)
            newdisp={[''],[selectedView],['                []']};
        elseif isempty(newOverview) && ~ismember(headline,{'Analog','FileInfo','EntityInfo'})
            newdisp={[''],[selectedView],[blanks(15),'{[]}']};
        elseif iscell(newOverview)
           tempcell=cellfun(@size,newOverview,'UniformOutput',0);
           newdisp={[''],[selectedView]};
           for uu=1:length(tempcell)
               newdisp{2+uu}=[blanks(15),'[',num2str(tempcell{uu}(1)),'x',num2str(tempcell{uu}(2)),']'];
           end
        elseif isvector(newOverview)
            newdisp={[''],[selectedView],[''],...
                num2str(newOverview)};
        elseif isstr(newOverview)
             newdisp={[''],[selectedView],[blanks(15),newOverview]};
        else 
          newdisp={[''],[selectedView],[blanks(15),'[',...
               num2str(size(newOverview,1)),'x',num2str(size(newOverview,2)),']']};
        end
        newdisp{1}='..';
        set(source,'String',newdisp,'Value',[2]);
        return;
    else
        return;
    end
    newdisp=(formatstructtree(cssm2cell(cssm(newOverview,selectedView,1),selectedView),15));
    newdisp{2}=strtrim(newdisp{2});
    newdisp{1}='..';
else
    newdisp=structure2text(nsFile);
end

set(source,'String',newdisp,'Value',[2]);


function resizeCallback(scr,evt)
%% Resizing panels as needed; the panels are
%% flexible as long as the window is larger than a minimal size.
%% For smaller sizes, the window contents are cropped.

global MAIN_MIN_WIDTH;
global MAIN_MIN_HEIGHT;

mainPos=get(gcbo,'Position');

%yOffset is used to align the panels with respect to the top of the window,
%not the bottom.
yOffset=min(0,mainPos(4)-MAIN_MIN_HEIGHT);

%for calculating the new panel positions the 'virtual' main position is
%set in such a way that the window contents are cropped if the window
%is too small
mainPos(3)=max(MAIN_MIN_WIDTH,mainPos(3));
mainPos(4)=max(MAIN_MIN_HEIGHT,mainPos(4));

%retrieving positions of panels
mainChildren=get(gcbo,'children');
topPanel=(findobj(mainChildren,'Tag','FIND_GUI_topPanel'));
leftPanel=(findobj(mainChildren,'Tag','FIND_GUI_leftPanel'));
rightPanel=(findobj(mainChildren,'Tag','FIND_GUI_rightPanel'));
bottomPanel=(findobj(mainChildren,'Tag','FIND_GUI_bottomPanel'));
messageBarPanel=(findobj(mainChildren,'Tag','FIND_GUI_messageBarPanel'));

topPanelpos=get(topPanel, 'Position');
leftPanelpos=get(leftPanel, 'Position');
rightPanelpos=get(rightPanel, 'Position');
bottomPanelpos=get(bottomPanel, 'Position');
messageBarPanelpos=get(messageBarPanel, 'Position');

%new panel positons
%bottom-, top- & messagepanel are fixed height and their positions can be
%computed from the main window's position
newTopPanelPos=[0    (mainPos(4)-topPanelpos(4)+yOffset) ...
    mainPos(3)   topPanelpos(4)];
newBottomPanelPos=[0 (yOffset+messageBarPanelpos(4)) ...
    mainPos(3) bottomPanelpos(4)];
newMessageBarPanelPos=[0 yOffset ...
    mainPos(3) messageBarPanelpos(4)];

%left and right panels' y positions depend on the others' updated positions
newLeftPanelPos=[0 ...
    (newTopPanelPos(2)-leftPanelpos(4))...
    leftPanelpos(3)...
    (leftPanelpos(4))];
newRightPanelPos=[leftPanelpos(3)...
    (newBottomPanelPos(2)+newBottomPanelPos(4))...
    (mainPos(3)-leftPanelpos(3))...
    (mainPos(4)-topPanelpos(4)-bottomPanelpos(4)-messageBarPanelpos(4))];

%setting new positions
set(topPanel,'Position',newTopPanelPos);
set(bottomPanel,'Position', newBottomPanelPos);
set(messageBarPanel,'Position', newMessageBarPanelPos);
set(leftPanel,'Position', newLeftPanelPos);
set(rightPanel,'Position', newRightPanelPos);


function my_closereq(src,evnt)
% Close request function asking the option to save data

   selection = questdlg('Save session before quitting?',...
      'Close Request Function',...
      'Yes','No','Cancel','Yes'); 
   switch selection, 
      case 'Yes',       
          
          [MATfileName, pathName] = uiputfile( ...
              {'*.mat','*.mat (containing an exported nsFile)'}, ...
              'Choose filename');
          if MATfileName==0 && pathName==0
              return;
          else
              stdExportMAT('outputFile',fullfile(pathName, MATfileName));
          end
          delete(gcf)
       case 'No'
         delete(gcf)
      case 'Cancel'
          return; 
   end


    
