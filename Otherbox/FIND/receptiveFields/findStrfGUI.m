function findStrfGUI()



global BUTTON_HEIGHT;
GUIwindow=figure('Units','characters',...
    'Position',[191.4 64.9231 121.8 9.15385], ...
    'Tag','makeStrfNIGUI', ...
    'Name','findStrfGUI',...
    'MenuBar','none',...
    'NumberTitle','off',...
    'resize','off');

buttonHeight=BUTTON_HEIGHT/9.15385;


%% Buttons
    uicontrol('Parent',GUIwindow,...
        'Units','normalized',...
        'Position',[0.01    0.6    0.24  buttonHeight],... 
        'Style','pushbutton',...
        'String','find Strf by smoothing',...
        'Tag','findStrfGUI_findRFanalysisPushbutton',...
        'Enable','on',...
        'Callback',@extractOnsetsPushbuttonCallback); 
   
    
    uicontrol('Parent',GUIwindow,...
        'Units','normalized',...
        'Position',[0.26    0.6    0.24 buttonHeight],... 
        'Style','pushbutton',...
        'String','find centers for sorting',...
        'Tag','findStrfGUI_center2sort_analysisPushbutton',...
        'Enable','on',...
        'Callback',@extractOnsetsPushbuttonCallback); 
    
    uicontrol('Parent',GUIwindow,...
        'Units','normalized',...
        'Position',[0.51    0.6    0.24  buttonHeight],... 
        'Style','pushbutton',...
        'String','sorting to centers',...
        'Tag','findStrfGUI_center2sort_analysisPushbutton',...
        'Enable','on',...
        'Callback',@extractOnsetsPushbuttonCallback);    
    
        uicontrol('Parent',GUIwindow,...
        'Units','normalized',...
        'Position',[0.76    0.6    0.24   buttonHeight],... 
        'Style','pushbutton',...
        'String','evaluate sorting',...
        'Tag','findStrfGUI_center2sort_analysisPushbutton',...
        'Enable','on',...
        'Callback',@extractOnsetsPushbuttonCallback);   
    

% --- Executes on button press in findStrfGUI_findRFanalysis.
function findStrfGUI_findRFanalysis_Callback(hObject, eventdata, handles)
clusterThreshold=str2num(get(findobj('Tag','findStrfGUI_clusterThreshold'),'String'));
valueThreshold=str2num(get(findobj('Tag','findStrfGUI_valueThreshold'),'String'));
selectedResponse=str2num(get(findobj('Tag','makeStrfGwnGUI_selectedResponseEntities'),'String'));
global nsFile STA rfCenters
rfCenters=findStrf('STA', STA, 'analogEntityIndex', selectedResponse,'valueThreshold',valueThreshold,'clusterThreshold',clusterThreshold);



% --- Executes on button press in findStrfGUI_center2sort.
function findStrfGUI_center2sort_Callback(hObject, eventdata, handles)
clusterThreshold=str2num(get(findobj('Tag','findStrfGUI_clusterThreshold'),'String'));
valueThreshold=str2num(get(findobj('Tag','findStrfGUI_valueThreshold'),'String'));
selectedResponse=str2num(get(findobj('Tag','makeStrfGwnGUI_selectedResponseEntities'),'String'));
global nsFile STA rfCenters
rfCenters=findStrf('STA', STA, 'analogEntityIndex', selectedResponse,'valueThreshold',valueThreshold,'clusterThreshold',clusterThreshold,'units',0);


function findStrfGUI_sort_Callback(hObject, eventdata, handles)
selectedResponse=str2num(get(findobj('Tag','makeStrfGwnGUI_selectedResponseEntities'),'String'));
refreshRate=str2num(get(findobj('Tag','makeStrfGwnGUI_selectedRate'),'String'));
trialDuration=str2num(get(findobj('Tag','makeStrfGwnGUI_selectedTrialDuration'),'String'));
global linearizedStimulus rfCenters STA
centerSort('rfCenters',rfCenters,'analogEntityIDs',selectedResponse,'stimulus',linearizedStimulus,'frameDuration',refreshRate,'trialDuration',trialDuration,'STA', STA);  

function findStrfGUI_evaluate_Callback(hObject, eventdata, handles)
selectedResponse=str2num(get(findobj('Tag','makeStrfGwnGUI_selectedResponseEntities'),'String'));
evaluateSorting('analogEntityIDs',selectedResponse);


