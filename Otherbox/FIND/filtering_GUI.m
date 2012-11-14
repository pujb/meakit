% script to set filtering GUI in basicProcessingGUI

set(radioGroup,'SelectedObject',[radioButtonFilter]);
set(radioGroup,'UserData','filtering');

headline_txt1=uicontrol('Parent',rightPanel,...
    'Units','characters',...
    'Position',[5   26   65    LABEL_HEIGHT*1.2],...
    'Style','text',...
    'String','define parameters for filtering',...
    'Tag','headline1_txt',...
    'FontWeight','bold',...
    'Enable','on');
headline_txt2=uicontrol('Parent',rightPanel,...
    'Units','characters',...
    'Position',[5   24    65    LABEL_HEIGHT*2],...
    'Style','text',...
    'String',{['(select appropiate filter type)']},...
    'Tag','headline2_txt',...
    'FontWeight','normal',...
    'Enable','on');


%%%% Filter Type Selection Radio Group
radioGroupfilterType = uibuttongroup('visible','off',...
    'Units','characters',...
    'Position',[6 18 63 LABEL_HEIGHT*4.5],...
    'Parent',rightPanel,...
    'Tag','filterTypeSelectionGUI_radioGroupfilterType',...
    'Title','Filter Type');

radioButtonSavgol = uicontrol('Style','Radio',...
    'String','Savgol',...
    'Units','characters',...
    'pos',[1 2 20 BUTTON_HEIGHT],...
    'parent',radioGroupfilterType,...
    'HandleVisibility','off',...
    'Enable','on',...
    'Tag','filterTypeSelectionGUI_radioGroupfilterType');

radioButtonOther = uicontrol('Style','Radio',...
    'String','Other',...
    'Units','characters',...
    'pos',[1 0.5 20 BUTTON_HEIGHT],...
    'parent',radioGroupfilterType,...
    'HandleVisibility','off',...
    'Enable','off',...
    'Tag','filterTypeSelectionGUI_radioGroupfilterType');

radioButtonLowpass = uicontrol('Style','Radio',...
    'String','Lowpass',...
    'Units','characters',...
    'pos',[21 2 20 BUTTON_HEIGHT],...
    'parent',radioGroupfilterType,...
    'HandleVisibility','off',...
    'Enable','on',...
    'Tag','filterTypeSelectionGUI_radioGroupfilterType');

radioButtonHighpass = uicontrol('Style','Radio',...
    'String','Highpass',...
    'Units','characters',...
    'pos',[21 0.5 20 BUTTON_HEIGHT],...
    'parent',radioGroupfilterType,...
    'HandleVisibility','off',...
    'Enable','on',...
    'Tag','filterTypeSelectionGUI_radioGroupfilterType');

radioButtonBandpass = uicontrol('Style','Radio',...
    'String','Bandpass',...
    'Units','characters',...
    'pos',[43 2 18 BUTTON_HEIGHT],...
    'parent',radioGroupfilterType,...
    'HandleVisibility','off',...
    'Enable','on',...
    'Tag','filterTypeSelectionGUI_radioGroupfilterType');

radioButtonBandstop = uicontrol('Style','Radio',...
    'String','Bandstop',...
    'Units','characters',...
    'pos',[43 0.5 18 BUTTON_HEIGHT],...
    'parent',radioGroupfilterType,...
    'HandleVisibility','off',...
    'Enable','on',...
    'Tag','filterTypeSelectionGUI_radioGroupfilterType');

set(radioGroupfilterType,'SelectionChangeFcn',@selectfilterType_callback);
set(radioGroupfilterType,'SelectedObject',[radioButtonSavgol]);
set(radioGroupfilterType,'UserData','Savgol');
set(radioGroupfilterType,'Visible','on');

% necessary for all filter types
EntityID_texthandle=uicontrol('Parent',rightPanel,...
            'Units','characters',...
            'Position',[6 15 30 LABEL_HEIGHT],...
            'Style','text',...
            'String','Analog / Segment EntityIDs :',...
            'Tag','dataID_txt',...
            'Enable','on');
        EntityID_edit=uicontrol('Parent',rightPanel,...
            'Units','characters',...
            'Position',[39 15 15 LABEL_HEIGHT],...
            'Style','edit',...
            'String','[1]',...
            'Tag','dataID_edit',...
            'Enable','on');
  
        % field 1
       Input1_txt=uicontrol('Parent',rightPanel,...
            'Units','characters',...
            'Position',[6 12 30 LABEL_HEIGHT],...
            'Style','text',...
            'String','Frame Size',...
            'Tag','Input1_txt',...
            'Enable','on');
        Input1_edit=uicontrol('Parent',rightPanel,...
            'Units','characters',...
            'Position',[39 12 15 LABEL_HEIGHT],...
            'Style','edit',...
            'String','[19]',...
            'Tag','Input1_edit',...
            'Enable','on');
        
        % field 2
        Input2_txt=uicontrol('Parent',rightPanel,...
            'Units','characters',...
            'Position',[6 9 30 LABEL_HEIGHT],...
            'Style','text',...
            'String','Polynomial Order',...
            'Tag','Input2_txt',...
            'Enable','on');
        Input2_edit=uicontrol('Parent',rightPanel,...
            'Units','characters',...
            'Position',[39 9 15 LABEL_HEIGHT],...
            'Style','edit',...
            'String','[7]',...
            'Tag','Input2_edit',...
            'Enable','on');
        

% Run button
uicontrol('Parent',rightPanel,...
    'Units','characters',...
    'Position',[55 1 20 BUTTON_HEIGHT*1.5],...
    'Style','pushbutton',...
    'String','Filter',...
    'Tag','Sagvolfiltering_RUN_GUIpushbutton',...
    'Enable','on',...
    'Callback',@filtering_Callback);

% Advance setting button
AdvancedSetting = uicontrol('Style','check',...
    'String','Advanced Settings',...
    'Units','characters',...
    'pos',[6 1 30 BUTTON_HEIGHT],...
    'parent',rightPanel,...
    'HandleVisibility','off',...
    'Tag','FilterGUIcheckbox_AdvancedSetting');
