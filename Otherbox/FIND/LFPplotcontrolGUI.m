function LFPplotcontrolGUI()
%
% a.kilias 09/09
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

global BUTTON_HEIGHT;
global LABEL_HEIGHT;
global MESSAGEBAR_PANEL_HEIGHT;
global MESSAGEBAR_LEFT_OFFSET;
global MESSAGEBAR_RIGHT_OFFSET;

try
    %%
    if ishandle(findobj('tag', 'LFPplotcontrolGUI'))
        close(findobj('tag', 'LFPplotcontrolGUI'));
    end;
    
    %%%%%%%%%%%%%%%%%%% GUI window %%%%%%%%%%%%%%%%%%%
    GUIxPos=2;
    GUIyPos=2;
    GUIwidth=150;
    GUIheight=20;
    
    GUIwindow=figure('Units','characters',...
        'Position',[GUIxPos GUIyPos GUIwidth 1.3*GUIheight], ...
        'Tag','LFPplotcontrolGUI', ...
        'Name','Plot Control GUI',...
        'MenuBar','none',...
        'NumberTitle','off',...
        'resize','off');
    
    %%%%%%%%%%%%%%%%%%%% panels %%%%%%%%%%%%%%%%%%%
    leftPanel=uipanel('Parent',GUIwindow,...
        'Units','characters',...
        'Position',[0  MESSAGEBAR_PANEL_HEIGHT ...
        GUIwidth/4  ((1.3*GUIheight)-MESSAGEBAR_PANEL_HEIGHT)],...
        'Tag','plotcontrolGUI_leftPanel',...
        'BackgroundColor', [0.8 0.8 0.8]);
    
    centralPanel=uipanel('Parent',GUIwindow,...
        'Units','characters',...
        'Position',[GUIwidth*1/4 MESSAGEBAR_PANEL_HEIGHT+ ...
        ((1.3*GUIheight)-MESSAGEBAR_PANEL_HEIGHT)*1/5 ...
        GUIwidth*3/4 ((1.3*GUIheight)-MESSAGEBAR_PANEL_HEIGHT)*3/5],...
        'Tag','plotcontrolGUI_centralPanel',...
        'BackgroundColor', [0.8 0.8 0.8]);
    
    lowerPanel=uipanel('Parent',GUIwindow,...
        'Units','characters',...
        'Position',[GUIwidth*1/4 MESSAGEBAR_PANEL_HEIGHT ...
        GUIwidth*3/4 ((1.3*GUIheight)-MESSAGEBAR_PANEL_HEIGHT)*1/5],...
        'Tag','plotcontrolGUI_lowerPanel',...
        'BackgroundColor', [0.8 0.8 0.8]);
    
    upperPanel=uipanel('Parent',GUIwindow,...
        'Units','characters',...
        'Position',[GUIwidth*1/4 MESSAGEBAR_PANEL_HEIGHT+ ...
        (((1.3*GUIheight)-MESSAGEBAR_PANEL_HEIGHT)*4/5) ...
        GUIwidth*3/4 ((1.3*GUIheight)-MESSAGEBAR_PANEL_HEIGHT)*1/5],...
        'Tag','plotcontrolGUI_upperPanel',...
        'BackgroundColor', [0.8 0.8 0.8]);
    
    % message bar
    messageBarPanel=uipanel('Parent',GUIwindow,...
        'Units','characters',...
        'Position',[0 0 ...
        GUIwidth MESSAGEBAR_PANEL_HEIGHT],...
        'Tag','plotcontrolGUI_messageBarPanel');
    
    messageBarPanelPos=get(messageBarPanel,'Position');
    uicontrol('Parent',messageBarPanel,...
        'Units','characters',...
        'Position',[(messageBarPanelPos(1)+MESSAGEBAR_LEFT_OFFSET) ...
        (messageBarPanelPos(2)) ...
        (messageBarPanelPos(3)-MESSAGEBAR_RIGHT_OFFSET) ...
        LABEL_HEIGHT],...
        'Tag','plotcontrolGUI_messageBarText',...
        'Enable','on',...
        'String','',...
        'HorizontalAlignment','left',...
        'Style','text');
    
    %% Data Selection
    % available Data
    uicontrol('Parent',leftPanel,...
        'Units','Characters',...
        'Position',[0.5 22.5 16 LABEL_HEIGHT*1.3],...
        'Style','Text',...
        'FontWeight','bold',...
        'String','available Data:',...
        'Tag','LFPplotcontrol_availableDatatxt',...
        'HorizontalAlignment','left',...
        'BackgroundColor', [0.8 0.8 0.8],...
        'Enable','on');
    evalin('base','varlist=whos;');
    evalin('base','globalvarlist=find(cellfun(@(x) strcmp(x,''udo_pointer''),{varlist.class}));');
    uicontrol('Parent',leftPanel,...
        'Units','Characters',...
        'Position',[1 15.5 30 LABEL_HEIGHT*6.5],...
        'Style','ListBox',...
        'String',evalin('base','{varlist(globalvarlist).name}') ,...
        'Tag','LFPplotcontrol_availableDataListBox',...
        'HorizontalAlignment','left',...
        'Enable','on',...
        'Tooltipstring','select dataobject to plot',...
        'Callback',@SelectDataCallback);
    evalin('base','clear globalvarlist varlist');
    
    % Data to show
    uicontrol('Parent',leftPanel,...
        'Units','Characters',...
        'Position',[0.5 13.2 16 LABEL_HEIGHT*1.3],...
        'Style','Text',...
        'FontWeight','bold',...
        'String','Data to show:',...
        'Tag','LFPplotcontrol_selectedDatatxt',...
        'HorizontalAlignment','left',...
        'BackgroundColor', [0.8 0.8 0.8],...
        'Enable','on');
    uicontrol('Parent',leftPanel,...
        'Units','Characters',...
        'Position',[1 5.8 30 LABEL_HEIGHT*6.5],...
        'Style','ListBox',...
        'String','',...
        'Tag','LFPplotcontrol_selectedDataListBox',...
        'Enable','on',...
        'Tooltipstring','select dataobject to delete it from the selection list',...
        'UserData','',...
        'Callback',@UnselectDataCallback);
    
    % manually set threshold
    uicontrol('Parent',leftPanel,...
        'Units','Characters',...
        'Position',[0.5 3.3 20 BUTTON_HEIGHT],...
        'Style','Checkbox',...
        'FontWeight','bold',...
        'String','set Threshold:',...
        'Tag','LFPplotcontrol_Threshold',...
        'HorizontalAlignment','left',...
        'BackgroundColor', [0.8 0.8 0.8],...
        'Enable','off',...
        'HandleVisibility','off',...
        'Callback',@setThresholdCallback);
    
    uicontrol('Parent',leftPanel,...
        'Units','Characters',...
        'Position',[23 3.2 5.5 LABEL_HEIGHT*1.3],...
        'Style','Edit',...
        'String','',...
        'Tag','LFPplotcontrol_Thresholdedit',...
        'Enable','off');
    
    uicontrol('Parent',leftPanel,...
        'Units','Characters',...
        'Position',[29 3.4 7 LABEL_HEIGHT],...
        'Style','Text',...
        'String','[mV]',...
        'Tag','LFPplotcontrol_ThresholdUnittxt',...
        'HorizontalAlignment','left',...
        'BackgroundColor', [0.8 0.8 0.8],...
        'Enable','off');
    
    uicontrol('Parent',leftPanel,...
        'Units','Characters',...
        'Position',[12 0.5 22 BUTTON_HEIGHT*1.3],...
        'Style','pushbutton',...
        'String','create plot-object',...
        'Tag','LFPplotcontrol_PlotButton',...
        'Callback',@CreateplotObject_callback,...
        'Enable','on');
    
    %% plot object selection to apply properties
    
    uicontrol('Parent',upperPanel,...
        'Units','Characters',...
        'Position',[0.5 2.4 22 LABEL_HEIGHT*1.3] ,...
        'Style','Text',...
        'FontWeight','bold',...
        'String','select data trace: ',...
        'BackgroundColor', [0.8 0.8 0.8],...
        'Tag','LFPplotcontrol_plotPropDatatxt',...
        'HorizontalAlignment','left',...
        'Enable','off');
    
    uicontrol('Parent',upperPanel,...
        'Units','Characters',...
        'Position',[28 2.4 30 LABEL_HEIGHT*1.3],...
        'Style','popupmenu',...
        'String',{' - choose - '},...
        'HorizontalAlignment','Center',...
        'Tag','LFPplotcontrol_plotPropDataPullDown',...
        'Callback',@setPlotprops_callback,...
        'Enable','off');
    
    
    
    %% plot properties
    
    uicontrol('Parent',centralPanel,...
        'Units','Characters',...
        'Position',[0.5 12.5 20 LABEL_HEIGHT*1.3],...
        'Style','Text',...
        'FontWeight','bold',...
        'BackgroundColor', [0.8 0.8 0.8],...
        'String','Plot Properties: ',...
        'Tag','LFPplotcontrol_plotProptxt',...
        'Enable','off');
    
    %  visibility
    uicontrol('Parent',centralPanel,...
        'Units','Characters',...
        'Position',[28 11.5 30 BUTTON_HEIGHT*1.3],...
        'Style','Checkbox',...
        'String',' show data trace ',...
        'BackgroundColor', [0.8 0.8 0.8],...
        'Tag','LFPplotcontrol_traceVisibility',...
        'HorizontalAlignment','left',...
        'Value',1,...
        'Callback',@Visibilty_Callback,...
        'Enable','off');
    
    % color
    uicontrol('Parent',centralPanel,...
        'Units','Characters',...
        'Position',[3 8.5 22 LABEL_HEIGHT*1.1],...
        'Style','Text',...
        'String','change trace color: ',...
        'BackgroundColor', [0.8 0.8 0.8],...
        'Tag','LFPplotcontrol_plotPropColortxt',...
        'HorizontalAlignment','left',...
        'Enable','off');
    uicontrol('Parent',centralPanel,...
        'Units','Characters',...
        'Position',[28 8.5 30 LABEL_HEIGHT*1.3],...
        'Style','edit',...
        'String','[0 0 1]',...
        'Tag','LFPplotcontrol_plotPropDataColorEdit',...
        'HorizontalAlignment','Center',...
        'Enable','off');
    uicontrol('Parent',centralPanel,...
        'Units','Characters',...
        'Position',[60 8.5 20 BUTTON_HEIGHT*1.2],...
        'Style','pushbutton',...
        'String','select',...
        'HorizontalAlignment','Center',...
        'Tag','LFPplotcontrol_plotPropDataColorselect',...
        'Callback',@colorselection_callback,...
        'Enable','off');
    
    % offset
    uicontrol('Parent',centralPanel,...
        'Units','Characters',...
        'Position',[3 6.5 22 LABEL_HEIGHT*1.1],...
        'Style','Text',...
        'String','Offset: ',...
        'BackgroundColor', [0.8 0.8 0.8],...
        'Tag','LFPplotcontrol_plotPropOffsettxt',...
        'HorizontalAlignment','left',...
        'Enable','off');
    uicontrol('Parent',centralPanel,...
        'Units','Characters',...
        'Position',[28 6.5 30 LABEL_HEIGHT*1.3],...
        'Style','edit',...
        'String','0',...
        'Tag','LFPplotcontrol_plotPropDataOffsetEdit',...
        'HorizontalAlignment','Center',...
        'Enable','off');
    uicontrol('Parent',centralPanel,...
        'Units','Characters',...
        'Position',[58 6.5 5 LABEL_HEIGHT*1.2],...
        'Style','Text',...
        'String','[ms]',...
        'BackgroundColor', [0.8 0.8 0.8],...
        'Tag','LFPplotcontrol_plotPropDataOffsetUnit',...
        'HorizontalAlignment','Center',...
        'Enable','off');
    
    % sweeps
    uicontrol('Parent',centralPanel,...
        'Units','Characters',...
        'Position',[3 2 22 LABEL_HEIGHT*1.1],...
        'Style','Text',...
        'BackgroundColor', [0.8 0.8 0.8],...
        'String','sweep:',...
        'Tag','LFPplotcontrol_sweeptxt',...
        'HorizontalAlignment','left',...
        'Enable','off');
    % next & back
    uicontrol('Parent',centralPanel,...
        'Units','Characters',...
        'Position',[28 2 12 BUTTON_HEIGHT*1.3],...
        'Style','Pushbutton',...
        'String','BACK < ',...
        'Tag','LFPplotcontrol_sweepBACK',...
        'Callback',@jumpSweep_callback,...
        'Enable','off');
    uicontrol('Parent',centralPanel,...
        'Units','Characters',...
        'Position',[58 2 12 BUTTON_HEIGHT*1.3],...
        'Style','Pushbutton',...
        'String',' > NEXT',...
        'Tag','LFPplotcontrol_sweepNEXT',...
        'Callback',@jumpSweep_callback,...
        'Enable','off');
    % set sweep directly
    uicontrol('Parent',centralPanel,...
        'Units','Characters',...
        'Position',[44.5 2 5 LABEL_HEIGHT*1.5],...
        'Style','Edit',...
        'String','1',...
        'Tag','LFPplotcontrol_sweepedit',...
        'Callback',@jumpSweep_callback,...
        'Enable','off');
    uicontrol('Parent',centralPanel,...
        'Units','Characters',...
        'Position',[50.5 2 7 LABEL_HEIGHT*1.2],...
        'Style','Text',...
        'String','/0',...
        'Tag','LFPplotcontrol_sweepMaxtxt',...
        'HorizontalAlignment','left',...
        'BackgroundColor', [0.8 0.8 0.8],...
        'Enable','off');
    
    
    %% apply and run
    
    % reset & apply & save
    uicontrol('Parent',lowerPanel,...
        'Units','Characters',...
        'Position',[36 0.5 15 BUTTON_HEIGHT*1.3],...
        'Style','Pushbutton',...
        'String','Export',...
        'Tag','LFPplotcontrol_Export',...
        'Callback',@lfpPlot_Export_callback,...
        'Enable','off',...
        'HandleVisibility','off');
    
    uicontrol('Parent',lowerPanel,...
        'Units','Characters',...
        'Position',[72 0.5 15 BUTTON_HEIGHT*1.3],...
        'Style','Pushbutton',...
        'String','Reset',...
        'Callback',@lfpPlot_Reset_callback,...
        'Tag','LFPplotcontrol_Reset',...
        'Enable','off');
    
    uicontrol('Parent',lowerPanel,...
        'Units','Characters',...
        'Position',[90 0.5 15 BUTTON_HEIGHT*1.3],...
        'Style','Pushbutton',...
        'String','Apply',...
        'Callback',@lfpPlot_Apply_callback,...
        'Tag','LFPplotcontrol_Apply',...
        'Enable','off');
    
    uicontrol('Parent',lowerPanel,...
        'Units','Characters',...
        'Position',[54 0.5 15 BUTTON_HEIGHT*1.3],...
        'Style','Pushbutton',...
        'String','Reset all',...
        'Callback',@lfpPlot_ResetAll_callback,...
        'Tag','LFPplotcontrol_ResetAll',...
        'Enable','off');
    
catch
    close(findobj('tag', 'LFPplotcontrolGUI'));
    rethrow(lasterror);
end

%list all available objects
function SelectDataCallback(source,event)
s=get(source,'String');
v=get(source,'Value');
selectedList=get(findobj('Tag','LFPplotcontrol_selectedDataListBox'),'UserData');

if isempty(selectedList)
    selectedList{1}=s{v};
else
    if ~any(ismember(s{v},selectedList));
        selectedList{end+1}=s{v};
    end
end
set(findobj('Tag','LFPplotcontrol_selectedDataListBox'),'UserData',...
    selectedList,'String',selectedList);

% select all object to plot
function UnselectDataCallback(source,event)
s=get(source,'String');
v=get(source,'Value');
selectedList=get(source,'UserData');
updatedList='';

if isempty(s{v})
    return;
else
    ind=find(strcmp(s{v},selectedList));
    count=0;
    for zz=1:numel(selectedList)
        if zz~=ind && ~isempty(selectedList{zz})
            count=count+1;
            updatedList{count}=selectedList{zz};
        end
    end
end

set(source,'UserData',updatedList,'String',updatedList,'Value',1);

% en- or disable threshold input
function setThresholdCallback(source,event)
if (get(source,'Value')) == 1
    set(findobj('Tag','LFPplotcontrol_Thresholdedit'),'Enable','on');
    set(findobj('Tag','LFPplotcontrol_ThresholdUnittxt'),'Enable','on');
else
    set(findobj('Tag','LFPplotcontrol_Thresholdedit'),'Enable','off');
    set(findobj('Tag','LFPplotcontrol_ThresholdUnittxt'),'Enable','off');
end

% to hide data trace in plot
function Visibilty_Callback(source,event)
if (get(source,'Value')) == 1
    set(get(findobj('tag','plotcontrolGUI_centralPanel'),'Children'),'Enable','on');
else
    set(get(findobj('tag','plotcontrolGUI_centralPanel'),'Children'),'Enable','off');
    set(source,'Enable','on');
end

% select color by ginput
function colorselection_callback(source,event)
color = eval(get(findobj('tag','LFPplotcontrol_plotPropDataColorEdit'),'String'));
out=colorselect_GUI(color);
set(findobj('Tag','LFPplotcontrol_plotPropDataColorEdit'),'String',...
    ['[',[num2str(out)],']']);

% create grid_plot and grid_data objects
function CreateplotObject_callback(source,event)
try
    selectedObject=get(findobj('Tag','LFPplotcontrol_selectedDataListBox'),'UserData');
    if isempty(selectedObject)
        postMessage('Please select object first');
        return;
    end
    
    varlist=evalin('base','whos;');
    if any(strcmp('myGridPlot',{varlist.name}))
        myGridPlot=evalin('base','myGridPlot');
        objName=cellfun(@(x) x.name, {myGridPlot.dataobj.info},'UniformOutput',0);
    else
        myGridPlot=grid_plot;
        assignin('base','myGridPlot',myGridPlot);
        objName={};
    end
    for tt=1:numel(selectedObject)
        varname{tt}=[selectedObject{tt} '_PlotObj'];
        % create only new one
        if ~ismember(varname{tt}, objName)
            % myGridData=grid_data(myUDO,myUDO.info);
            evalin('base',[varname{tt} '=grid_data(' selectedObject{tt} ',' selectedObject{tt} '.info);']);
            evalin('base',[varname{tt}, '.info.name=''',varname{tt},''';']);
            evalin('base',['myGridPlot=myGridPlot.attach(' varname{tt} ');']);
        end
    end

    % delete overhang
    if ~isempty(myGridPlot.dataobj)
        objName=cellfun(@(x) x.name, {myGridPlot.dataobj.info},'UniformOutput',0);
        remove=find(~ismember(objName,varname));
        if ~isempty(remove)
            removeID=myGridPlot.dataobjID(remove);
            keyboard;
            for bb=1:numel(removeID)
                evalin('base',['myGridPlot=myGridPlot.remove(' num2str(removeID(bb)) ');']);
            end
        end
        myGridPlot= myGridPlot.draw;
    end
    
catch
    rethrow(lasterror);
end

set(get(findobj('tag','plotcontrolGUI_upperPanel'),'Children'),'Enable','on');
set(get(findobj('tag','plotcontrolGUI_lowerPanel'),'Children'),'Enable','on');
set(get(findobj('tag','plotcontrolGUI_centralPanel'),'Children'),'Enable','on');

set(findobj('tag','LFPplotcontrol_plotPropDataPullDown'),'string',varname);

evalin('base',['set(findobj(''tag'',''LFPplotcontrol_plotPropDataColorEdit''),''String'',[''['' num2str(' varname{1} '.info.rgbcol) '']'']);']);
evalin('base',['set(findobj(''tag'',''LFPplotcontrol_plotPropDataOffsetEdit''),''String'',[ num2str(' varname{1} '.info.offset)]);']);
evalin('base',['set(findobj(''tag'',''LFPplotcontrol_sweepedit''),''String'',[ num2str(' varname{1} '.plotprops.sweepnumber)]);']);
evalin('base',['set(findobj(''tag'',''LFPplotcontrol_sweepMaxtxt''),''String'',[''/'' num2str(size(' varname{1} '.data,3))]);']);

% choose data set and show existing properties
function setPlotprops_callback(source,event)
try
    s=get(source,'String');
    v=get(source,'Value');
    
    evalin('base',['set(findobj(''tag'',''LFPplotcontrol_plotPropDataColorEdit''),''String'',[''['' num2str(' s{v} '.info.rgbcol) '']'']);']);
    evalin('base',['set(findobj(''tag'',''LFPplotcontrol_plotPropDataOffsetEdit''),''String'',[ num2str(' s{v} '.info.offset)]);']);
    evalin('base',['set(findobj(''tag'',''LFPplotcontrol_sweepedit''),''String'',[ num2str(' s{v} '.plotprops.sweepnumber)]);']);
    evalin('base',['set(findobj(''tag'',''LFPplotcontrol_sweepMaxtxt''),''String'',[''/'' num2str(size(' s{v} '.data,3))]);']);
    evalin('base',['set(findobj(''tag'',''LFPplotcontrol_traceVisibility''),''Value'', ' s{v} '.plotprops.showdata);']);
    
    if (get(findobj('tag','LFPplotcontrol_traceVisibility'),'Value')) == 1
        set(get(findobj('tag','plotcontrolGUI_centralPanel'),'Children'),'Enable','on');
    else
        set(get(findobj('tag','plotcontrolGUI_centralPanel'),'Children'),'Enable','off');
        set(findobj('tag','LFPplotcontrol_traceVisibility'),'Enable','on');
    end
catch
    rethrow(lasterror)
end

% jump one sweep for- or backward
function jumpSweep_callback(source,event)
try
    s= get(findobj('tag','LFPplotcontrol_plotPropDataPullDown'),'String');
    v= get(findobj('tag','LFPplotcontrol_plotPropDataPullDown'),'Value');
    
    if strcmp('LFPplotcontrol_sweepNEXT',get(source,'tag'))
        newSweepID=evalin('base',[s{v} '.plotprops.sweepnumber'])+1;
    elseif strcmp('LFPplotcontrol_sweepBACK',get(source,'tag'))
        newSweepID=evalin('base',[s{v} '.plotprops.sweepnumber'])-1;
    else
        newSweepID=str2num(get(source,'String'));
    end
    if newSweepID > evalin('base',['size(' s{v} '.data,3)']) || ...
            newSweepID <= 0
        postMessage('Requested sweep does not exist!')
        return;
    end
    evalin('base',[s{v} '.plotprops.sweepnumber = ' num2str(newSweepID)]);
    evalin('base',['set(findobj(''tag'',''LFPplotcontrol_sweepedit''),''String'',[ num2str(' s{v} '.plotprops.sweepnumber)]);']);
    
    myGridPlot=evalin('base','myGridPlot');
    myGridPlot= myGridPlot.update(evalin('base',s{v}),'plotprops.sweepnumber');
    myGridPlot= myGridPlot.draw;
    assignin('base','myGridPlot',myGridPlot);
catch
    rethrow(lasterror)
end

% apply setting and plot
function lfpPlot_Apply_callback(source,event)
try
    completRedraw=0;
    s = get(findobj('tag','LFPplotcontrol_plotPropDataPullDown'),'String');
    v = get(findobj('tag','LFPplotcontrol_plotPropDataPullDown'),'Value');
    
    myGridPlot=evalin('base','myGridPlot');
    % update color
    color = eval(get(findobj('tag','LFPplotcontrol_plotPropDataColorEdit'),'String'));
    % first check if changed
    if ~isequal(color,evalin('base',[s{v} '.info.rgbcol']))
        disp('color updated')
        evalin('base',[s{v} '.info.rgbcol =[ ' num2str(color) '];']);
        myGridPlot=myGridPlot.update(evalin('base',s{v}),'info.rgbcol');
        myGridPlot=myGridPlot.draw(v,'color');
    end
    
    % block Visibility
    visibility=get(findobj('tag','LFPplotcontrol_traceVisibility'),'Value');
    if logical(visibility)  ~=  evalin('base',[s{v} '.plotprops.showdata'])
        disp('visibility updated')
        evalin('base',[s{v} '.plotprops.showdata =' num2str(visibility) ';']);
        myGridPlot=myGridPlot.update(evalin('base',s{v}),'plotprops.showdata');
        myGridPlot=myGridPlot.draw(v,'showdata');
    end
    
    %updata offset
    offset = eval(get(findobj('tag','LFPplotcontrol_plotPropDataOffsetEdit'),'String'));
    if offset ~=  evalin('base',[s{v} '.info.offset'])
        disp('offset updated')
        evalin('base',[s{v} '.info.offset = ' num2str(offset) ';']);
        myGridPlot=myGridPlot.update(evalin('base',s{v}),'info.offset');
        completRedraw=1;
    end
    
    % update sweep
    newSweepID = eval(get(findobj('tag','LFPplotcontrol_sweepedit'),'String'));
    if newSweepID > evalin('base',['size(' s{v} '.data,3)']) || ...
            newSweepID <= 0
        postMessage('Requested sweep does not exist!')
        return;
    end
    if newSweepID ~=  evalin('base',[s{v} '.plotprops.sweepnumber'])
        disp('sweep updated')
        evalin('base',[s{v} '.plotprops.sweepnumber = ' num2str(newSweepID) ';']);
        myGridPlot=myGridPlot.update(evalin('base',s{v}),'plotprops.sweepnumber');
        completRedraw=1;
    end
    if completRedraw
        myGridPlot=myGridPlot.draw;
    end
    if isnan(myGridPlot.displayhandle)
        myGridPlot= myGridPlot.draw;
    end
    assignin('base','myGridPlot',myGridPlot);
    
catch
    rethrow(lasterror)
end

% reset settings to standard
function lfpPlot_Reset_callback
try
    s = get(findobj('tag','LFPplotcontrol_plotPropDataPullDown'),'String');
    v = get(findobj('tag','LFPplotcontrol_plotPropDataPullDown'),'Value');
    
    myGridPlot=evalin('base','myGridPlot');
    
    evalin('base',[s{v} '.info.offset=0']);
    evalin('base',[s{v} '.plotprops.sweepnumber=1;']);
    evalin('base',[s{v} '.info.rgbcol=[1 0 0];']);
    evalin('base',[s{v} '.plotprops.showdata=1;']);
    
    myGridPlot= myGridPlot.update(evalin('base',s{v}),'info.offset');
    myGridPlot= myGridPlot.update(evalin('base',s{v}),'plotprops.sweepnumber');
    myGridPlot= myGridPlot.update(evalin('base',s{v}),'info.rgbcol');
    myGridPlot= myGridPlot.update(evalin('base',s{v}),'plotprops.showdata');
    
    myGridPlot= myGridPlot.draw;
    postMessage('Settings were reseted to standard values');
    
catch
    rethrow(lasterror)
end

% reset setting of all objects
function lfpPlot_ResetAll_callback(source,event)
try
    s = get(findobj('tag','LFPplotcontrol_plotPropDataPullDown'),'String');
    myGridPlot=evalin('base','myGridPlot');
    
    for v=1:numel(s)
        
        evalin('base',[s{v} '.info.offset=0']);
        evalin('base',[s{v} '.plotprops.sweepnumber=1;']);
        evalin('base',[s{v} '.info.rgbcol=[1 0 0];']);
        evalin('base',[s{v} '.plotprops.showdata=1;']);
        
        myGridPlot= myGridPlot.update(evalin('base',s{v}),'info.offset');
        myGridPlot= myGridPlot.update(evalin('base',s{v}),'plotprops.sweepnumber');
        myGridPlot= myGridPlot.update(evalin('base',s{v}),'info.rgbcol');
        myGridPlot= myGridPlot.update(evalin('base',s{v}),'plotprops.showdata');
        
    end
    myGridPlot= myGridPlot.draw;
    postMessage('Settings were reseted to standard values');
    
catch
    rethrow(lasterror)
end

% export data object
function lfpPlot_Export_callback(source,event)
try
    postMessage('Not implemented yet');
catch
    rethrow(lasterror)
end

