function sortSpikesGUI()
% GUI for operating the sortSpikes function.
%
% here a couple of parameters and methods can be chosen
% used as UI to parameter value pair generation for the
% command line function sortSpikes.m
%
% Rmeier 21.12.06
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de


global nsFile;

global BUTTON_HEIGHT;
global LABEL_HEIGHT;
global MESSAGEBAR_PANEL_HEIGHT;
global MESSAGEBAR_LEFT_OFFSET;
global MESSAGEBAR_RIGHT_OFFSET;


try

    % Check if the sortSpikes GUI is already open
    if ishandle(findobj('tag', 'sortSpikesGUI'))
        close(findobj('tag', 'sortSpikesGUI'));
    end;

    % GUI window
    GUIxPos=20;
    GUIyPos=20;
    GUIwidth=70;
    GUIheight=22;

    GUIwindow=figure('Units','characters',...
        'Position',[GUIxPos GUIyPos GUIwidth GUIheight], ...
        'Tag','sortSpikesGUI', ...
        'Name','Spikes Sorting GUI',...
        'MenuBar','none',...
        'NumberTitle','off',...
        'resize','off');

    % panels
    centralPanel=uipanel('Parent',GUIwindow,...
        'Units','characters',...
        'Position',[0 MESSAGEBAR_PANEL_HEIGHT ...
        GUIwidth (GUIheight-MESSAGEBAR_PANEL_HEIGHT)],...
        'Tag','sortSpikesGUI_centralPanel',...
        'BackgroundColor', [0.8 0.8 0.8]);

    messageBarPanel=uipanel('Parent',GUIwindow,...
        'Units','characters',...
        'Position',[0 0 ...
        GUIwidth MESSAGEBAR_PANEL_HEIGHT],...
        'Tag','sortSpikesGUI_messageBarPanel');

    % message bar
    messageBarPanelPos=get(messageBarPanel,'Position');
    uicontrol('Parent',messageBarPanel,...
        'Units','characters',...
        'Position',[(messageBarPanelPos(1)+MESSAGEBAR_LEFT_OFFSET) ...
        (messageBarPanelPos(2)) ...
        (messageBarPanelPos(3)-MESSAGEBAR_RIGHT_OFFSET) ...
        LABEL_HEIGHT],...
        'Tag','sortSpikesGUI_messageBarText',...
        'Enable','on',...
        'String','',...
        'HorizontalAlignment','left',...
        'Style','text');

    % button to run the tool
    uicontrol('Parent',centralPanel,...
        'Units','characters',...
        'Position',[10 0.5 10 (BUTTON_HEIGHT)],...
        'Style','pushbutton',...
        'String','RUN',...
        'Tag','sortSpikesGUI_sortSpikesPushbutton',...
        'Enable','on',...
        'Callback',@sortSpikesPushbuttonCallback);

 % button to start preselection or presorting
    uicontrol('Parent',centralPanel,...
        'Units','characters',...
        'Position',[5    2.5    20 (BUTTON_HEIGHT)],...
        'Style','pushbutton',...
        'String','Preselection + RUN',...
        'Tag','sortSpikesGUI_sortSpikesPushbutton',...
        'Enable','on',...
        'Callback',@preSelectSpikesPushbuttonCallback);

    
    
    % plot sorted spikes button
    uicontrol('Parent',centralPanel,...
        'Units','characters',...
        'Position',[35 1 20 BUTTON_HEIGHT],...
        'Style','PushButton',...
        'String','Show Clusters',...
        'Tag','sortSpikesGUI_plotResultsPushbutton',...
        'Enable','on',...
        'Callback',@plotSortedSpikesPushbuttonCallback);

    % analyzes outliers button
    uicontrol('Parent',centralPanel,...
        'Units','characters',...
        'Position',[35 3 20 BUTTON_HEIGHT],...
        'Style','PushButton',...
        'String','Outlier Analysis',...
        'Tag','sortSpikesGUI_analyzeOutliersPushbutton',...
        'Enable','on',...
        'Callback',@analyzeOutliersPushbuttonCallback);

    % determine the data traces
    uicontrol('Parent',centralPanel,...
        'Units','characters',...
        'Position',[35   16.5    20  LABEL_HEIGHT ],...
        'Style','edit',...
        'String','[]',...
        'Tag','sortSpikesGUI_selectedEntity',...
        'Enable','on');

    % text label
    uicontrol('Parent',centralPanel,...
        'Units','characters',...
        'Position',[35   18    20    LABEL_HEIGHT],...
        'Style','text',...
        'String','[EntityIDs]',...
        'Tag','sortSpikesGUI_selectedEntityLabelText',...
        'Enable','on');


    % segment data info listbox
    uicontrol('Parent',centralPanel,...
        'Units','characters',...
        'Position',[35    6    30    7],...
        'Style','ListBox',...
        'String','No data loaded',...
        'Tag','sortSpikesGUI_segmentDataListbox',...
        'Enable','on');

    SegStruct=structure2text(nsFile.Segment);
    SegStruct{2}='Segment';
    set(findobj(GUIwindow,'Tag','sortSpikesGUI_segmentDataListbox'),...
        'String',SegStruct);

    %     % Write the default values into the select Data Vector box
    %     if isfield(nsFile,'Segment') && isfield(nsFile.Segment,'Data') ...
    %             && ~isempty(nsFile.Segment.Data)
    %         tmp=['[1:' num2str(size(nsFile.Segment.Data,2)) ']'];
    %     else
    %         tmp='[]';
    %     end
    %
    set(findobj(GUIwindow,'Tag','sortSpikesGUI_selectedEntity'),'String',1);

    %%%%%%%% Radio buttons for selecting the dimension reduction method. %%%%%%%

    buttonGroup = uibuttongroup('Visible','off',...
        'Units','characters',...
        'Position',[5 13 20 (4*BUTTON_HEIGHT+1.5)],...
        'Parent',centralPanel,...
        'Tag','sortSpikesGUI_dimReductionButtongroup',...
        'Title','Dim. Reduction' );
    % 'SelectionChangeFcn',@dimReductionSelectionCallback


    downsamplingButton = uicontrol('Style','Radio',...
        'String','downsampling',...
        'Units','characters',...
        'Position',[1 0.25 18 BUTTON_HEIGHT],...
        'Parent',buttonGroup,...
        'Tag','sortSpikesGUI_downsamplingRadiobutton',...
        'HandleVisibility','on');
    uicontrol('Style','Radio',...
        'String','PCA',...
        'Enable','off',...
        'Units','characters',...
        'pos',[1 BUTTON_HEIGHT+.25 18 BUTTON_HEIGHT],...
        'Parent',buttonGroup,...
        'Tag','sortSpikesGUI_PCAradiobutton',...
        'HandleVisibility','on');
    uicontrol('Style','Radio',...
        'String','ICA',...
        'Enable','off',...
        'Units','characters',...
        'pos',[1 2*BUTTON_HEIGHT+.25 18 BUTTON_HEIGHT],...
        'Parent',buttonGroup,...
        'Tag','sortSpikesGUI_ICAradiobutton',...
        'HandleVisibility','on');
    parameterButton = uicontrol('Style','Radio',...
        'String','parameters',...
        'Units','characters',...
        'Position',[1 3*BUTTON_HEIGHT+.25 18 BUTTON_HEIGHT],...
        'Parent',buttonGroup,...
        'Tag','sortSpikesGUI_parameterRadiobutton',...
        'HandleVisibility','on');
    set(buttonGroup,'SelectedObject',downsamplingButton);  % Select one Default
    set(buttonGroup,'Visible','on');


    %%%%%%%%%% Radio buttons for selecting the clustering method. %%%%%%%%%

    buttonGroup2 = uibuttongroup('Visible','off',...
        'Units','characters',...
        'Position',[5 8 20 (2*BUTTON_HEIGHT+1.5)],...
        'Parent',centralPanel,...
        'Tag','sortSpikesGUI_sortMethodButtongroup',...
        'Title','clustering Meth.' );

    KlustaKwikButton = uicontrol('Style','Radio',...
        'String','KlustaKwik',...
        'Units','characters',...
        'Position',[1 0 18 BUTTON_HEIGHT],...
        'Parent',buttonGroup2,...
        'Tag','sortSpikesGUI_KlustaKwikRadiobutton',...
        'HandleVisibility','on');
    k_meansButton=uicontrol('Style','Radio',...
        'String','kmeans',...
        'Enable','on',...
        'Units','characters',...
        'pos',[1 BUTTON_HEIGHT 18 BUTTON_HEIGHT],...
        'Parent',buttonGroup2,...
        'Tag','sortSpikesGUI_kmeansRadiobutton',...
        'HandleVisibility','on');

    set(buttonGroup2,'SelectedObject',k_meansButton);  % Select one Default
    set(buttonGroup2,'Visible','on');

    % determine which clusters to be clustered
    uicontrol('Parent',centralPanel,...
        'Units','characters',...
        'Position',[5    5.3    20  LABEL_HEIGHT ],...
        'Style','edit',...
        'String','[2:5]',...
        'Tag','sortSpikesGUI_selectedNClusters',...
        'Enable','on');

    % text label
    uicontrol('Parent',centralPanel,...
        'Units','characters',...
        'Position',[5    6.5    20    LABEL_HEIGHT],...
        'Style','text',...
        'String','[number of clusters]',...
        'Tag','sortSpikesGUI_nClustersText',...
        'Enable','on');



catch
    % if error occurs here, the window is closed, the error is rethrown
    % and then catched by the main window
    close(findobj('tag', 'sortSpikesGUI'));
    rethrow(lasterror);
end


%%%%%%%%%%%%%%% FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%obsolete:

%function dimReductionSelectionCallback(source,eventdata)
%
%selected=get(get(source,'SelectedObject'),'Tag');
%get(source,'SelectedObject');
%radioGroup=findobj('Tag','Radio_group');
%set(radioGroup,'UserData',selected);


function plotSortedSpikesPushbuttonCallback(a,b)
% which Data Vectors
tmp=findobj('Tag','sortSpikesGUI_selectedEntity');
user_string =get(tmp(1),'String'); % use first VALUE IF MULTIPLE FIGURES ARE OPEN
selected_Entities=eval((user_string));
global nsFile;
if ~ismember(selected_Entities,nsFile.Segment.DataentityIDs);
    postMessage('Please load segment data first!')
elseif unique(nsFile.Segment.UnitID{find(nsFile.Segment.DataentityIDs==selected_Entities)})==0
    postMessage('Please do clustering first!')
else
    plotSortedSpikes(selected_Entities);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sortSpikesPushbuttonCallback(a,b)
global nsFile;

try
    if ~isfield(nsFile,'Segment') || ~isfield(nsFile.Segment,'Data') ...
            || isempty(nsFile.Segment.Data)
        error('FIND:noSegmentData','No segment data found in nsFile variable.');
    end

    %%% grab parameters:
    tmp=findobj('Tag','sortSpikesGUI_selectedEntity');
    user_string =get(tmp(1),'String'); % use first VALUE IF MULTIPLE FIGURES ARE OPEN
    selected_Entities=eval((user_string));
    tmp=findobj('Tag','sortSpikesGUI_selectedNClusters');
    selectedNClusters=eval(get(tmp(1),'String')); % use first VALUE IF MULTIPLE FIGURES ARE OPEN

    if ~ismember(selected_Entities,nsFile.Segment.DataentityIDs);
        postMessage('Please load segment data first!')
    else
        if ~isvector(selected_Entities)
            error('Invalid data vector indices.');
        end
        % posting 'busy' message
        postMessage('Busy - please wait...');


        % which Methods
        buttonGroup=findobj('Tag','sortSpikesGUI_dimReductionButtongroup');
        tagSelecDimReduc=get(get(buttonGroup,'SelectedObject'),'Tag');

        buttonGroup2=findobj('Tag','sortSpikesGUI_sortMethodButtongroup');
        tagSelecCluster=get(get(buttonGroup2,'SelectedObject'),'Tag');

        %%% start sorting
        sortSpikes('tagSelecDimReduc',tagSelecDimReduc,'tagSelecCluster',tagSelecCluster,...
            'selected_Entities',selected_Entities,'nClusters',selectedNClusters);

        postMessage('...done.');
    end
catch
    handleError(lasterror);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function analyzeOutliersPushbuttonCallback(a,b)
% function analyzeOutliersPushbuttonCallback(a,b)
% Calls the Outlier Analysis function.


global nsFile;

try
    tmp=findobj('Tag','sortSpikesGUI_selectedEntity');
    user_string =get(tmp(1),'String'); % use first VALUE IF MULTIPLE FIGURES ARE OPEN
    selected_Entities=eval((user_string));

    if ~ismember(selected_Entities,nsFile.Segment.DataentityIDs);
        postMessage('Please load segment data first!')
    else
        if ~isvector(selected_Entities)
            error('Invalid data vector indices.');
        end
        % posting 'busy' message
        postMessage('Busy - please wait...');
        disp('starting Outlier Analysis');
        analyzeOutliers(selected_Entities);
    end
catch
    handleError(lasterror);
end


function preSelectSpikesPushbuttonCallback(a,b)
% calls interactive preselection window

global nsFile;

try 
    if ~isfield(nsFile,'Segment') || ~isfield(nsFile.Segment,'Data') ...
            || isempty(nsFile.Segment.Data)
        error('FIND:noSegmentData','No segment data found in nsFile variable.');
    end
    % posting 'busy' message
    postMessage('Busy - please wait...');


    %%% grab parameters:
    tmp=findobj('Tag','sortSpikesGUI_selectedEntity');
    user_string =get(tmp(1),'String'); % use first VALUE IF MULTIPLE FIGURES ARE OPEN
    selected_Entities=eval((user_string));
   
    if ~isvector(selected_Entities)
        error('Invalid data vector indices.');
    end
    if ~ismember(selected_Entities,nsFile.Segment.DataentityIDs);
        postMessage('Please load segment data first!');
        return;
    elseif length(selected_Entities)~=1
        postMessage('Presorting of more than one Entity not implemented yet.');
        return;
    else
        %%% start preselection
        manPreSorting('selected_Entities',selected_Entities);
        postMessage('...done.');
    end

catch
    rethrow(lasterror)
end
