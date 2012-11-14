function manPreSorting(varargin)
% function manPreSorting
% Performs manual presorting on Segment Data.
%
% %%%%% Obligatory Parameters %%%%%
%
% 'selected_Data_Vectors': Indices of selected spikes to sort spikes
%
% Example:
% manPreSorting('selected_Entities',[12]);
%
%
% RETRIEVING INFORMATION
%
% Results are added to the global nsFile structure!
% clusters are stored in 'nsFile.Segment.UnitID';
%
%
% (0) A. Kilias kilias
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de



global nsFile;

global BUTTON_HEIGHT;
global LABEL_HEIGHT;
global MESSAGEBAR_PANEL_HEIGHT;
global MESSAGEBAR_LEFT_OFFSET;
global MESSAGEBAR_RIGHT_OFFSET;

set(0,'Units','characters');
scrsz = get(0,'ScreenSize');

if scrsz(3)>260 || scrsz(4)>80
    % restict max size, case of more than 1 screen
    scrsz(3)= 256 ;
    scrsz(4)=79;
end
GUIxPos=scrsz(1)+2;
GUIyPos=scrsz(2)+2;
GUIwidth=scrsz(3)*(9/10);
GUIheight=scrsz(4)*(8/10);



% GUIxPos=1;
% GUIyPos=1;
% GUIwidth=scrsz(3);
% GUIheight=scrsz(4);

% obligatory argument names
obligatoryArgs={{'selected_Entities',@(val) isnumeric(val)&& length(val)==1}}; %-% e.g. {'x','y'}

optionalArgs={};

errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,''); %used this format so that the '\n' are converted
end

pvpmod(varargin);

% find out if there is segment data in the nsFile
if ~isfield(nsFile,'Segment') || ~isfield(nsFile.Segment,'Data') ...
        || isempty(nsFile.Segment.Data)
    error('FIND:noSegmentData','No segment data found in nsFile variable.');
end

%find out if all selected entities contain segment data
for kk=1:length(selected_Entities)
    if isempty(nsFile.Segment.DataentityIDs)
        error('FIND:noSegmentData','No segment data found in nsFile variable.');
    elseif (nsFile.Segment.DataentityIDs==selected_Entities(kk))==0
        error('FIND:noSegmentData','No segment data found in nsFile variable.');
    else
        posEntities(kk)=find(nsFile.Segment.DataentityIDs==selected_Entities(kk));
    end
end

set(findobj('Tag','sortSpikesGUI'),'Visible','off')


% one window for all selected data streams
try
    % Check if the SpikesPreSelect_GUI is already open
    if ishandle(findobj('tag', 'SpikesPreSelect_GUI'))
        close(findobj('tag', 'SpikesPreSelect_GUI'));
    end

    % get all the possible values
    % make PCA
    ii=1;
    segs=nsFile.Segment.Data{posEntities(ii)}';
    stdr = std(segs);
    if any(stdr==0)
        sr=segs;
        disp('not previously weighted to std');
    else
        sr = segs./repmat(stdr,size(segs,1),1);
    end
    %Now you are ready to find the principal components.
    [coefs,scores,variances,t2] = princomp(sr);

    % get amplitude and area und graph
    maxA=max(nsFile.Segment.Data{posEntities(ii)});
    minA=min(nsFile.Segment.Data{posEntities(ii)});
    Amplitude=(maxA+abs(minA))';
    Mini=minA';
    Maxi=maxA';

    % value under curve
    Integral=(sum(abs(nsFile.Segment.Data{posEntities(ii)})))';

    % initial Plot
    DataMatrix=[scores(:,1:3),Integral,Amplitude,Mini,Maxi];
    selectParam=[6;4;7;2;1];
    discardList=[];
    selectionList=[];
    fixedList={[]};

    % GUI window
    GUIwindow=figure('Units','characters',...
        'Position',[GUIxPos GUIyPos GUIwidth GUIheight], ...
        'Tag','SpikesPreSelect_GUI', ...
        'Name','PreSelection of Spike',...
        'NumberTitle','off',...
        'resize','off');   %         'MenuBar','none',...

    % panels
    upperLeftPanel=uipanel('Parent',GUIwindow,...
        'Units','characters',...
        'Position',[0 (GUIheight)/2 ...
        GUIwidth/2 GUIheight/2],...
        'Tag','SpikesPreSelect_GUI_upperLeftPanel',...
        'BorderType','none',...
        'BackgroundColor', [0.8 0.8 0.8]);
    % panels
    upperRightPanel=uipanel('Parent',GUIwindow,...
        'Units','characters',...
        'Position',[GUIwidth/2 (GUIheight)/2 ...
        GUIwidth (GUIheight)/2],...
        'Tag','SpikesPreSelect_GUI_upperRightPanel',...
        'BorderType','none',...
        'BackgroundColor', [0.8 0.8 0.8]);
    % panels
    lowerLeftPanel=uipanel('Parent',GUIwindow,...
        'Units','characters',...
        'Position',[0 MESSAGEBAR_PANEL_HEIGHT ...
        GUIwidth/2 (GUIheight-MESSAGEBAR_PANEL_HEIGHT)/2],...
        'Tag','SpikesPreSelect_GUI_lowerLeftPanel',...
        'BorderType','none',...
        'BackgroundColor', [0.8 0.8 0.8]);
    % panels
    lowerRightPanel=uipanel('Parent',GUIwindow,...
        'Units','characters',...
        'Position',[GUIwidth/2 MESSAGEBAR_PANEL_HEIGHT ...
        GUIwidth/2 (GUIheight-MESSAGEBAR_PANEL_HEIGHT)/2],...
        'Tag','SpikesPreSelect_GUI_lowerRightPanel',...
        'BorderType','none',...
        'BackgroundColor', [0.8 0.8 0.8]);

    messageBarPanel=uipanel('Parent',GUIwindow,...
        'Units','characters',...
        'Position',[0 0 ...
        GUIwidth MESSAGEBAR_PANEL_HEIGHT],...
        'Tag','SpikesPreSelect_GUI_messageBarPanel');

    % message bar
    messageBarPanelPos=get(messageBarPanel,'Position');
    uicontrol('Parent',messageBarPanel,...
        'Units','characters',...
        'Position',[(messageBarPanelPos(1)+MESSAGEBAR_LEFT_OFFSET) ...
        (messageBarPanelPos(2)) ...
        (messageBarPanelPos(3)-MESSAGEBAR_RIGHT_OFFSET) ...
        LABEL_HEIGHT],...
        'Tag','SpikesPreSelect_GUI_messageBarText',...
        'Enable','on',...
        'String','',...
        'HorizontalAlignment','left',...
        'Style','text');

    subplot(2,2,1)
    set(gca,'Units','characters');
    posOut=get(findobj('Tag','SpikesPreSelect_GUI_upperLeftPanel'),'Position');
    posIn=get(gca,'Position'); %[left bottom width height]
    fringe(1:2)=abs(posOut(1:2)-posIn(1:2)); %[left bottom right top]
    fringe(3)=abs(GUIwidth-(posIn(3)+posIn(1)));
    fringe(4)=abs(GUIheight-(posIn(4)+posIn(2)));

    hOffset=0.5;
    a=0.5*(GUIwidth/34);
    b=1*(GUIwidth/34);
    c=2*(GUIwidth/34);

    button_length=16;
    pannel_width=GUIwidth/2;
    pannel_height=GUIheight/2;

    % popmenu to control axes
    stringX1 = uicontrol('Parent',upperLeftPanel,...
        'Style','text',...
        'Units','characters',...
        'String','X axes',...
        'Position',[a hOffset c BUTTON_HEIGHT]);

    popX1 = uicontrol('Parent',upperLeftPanel,...
        'Units','characters',...
        'Style','popupmenu',...
        'String',{'PC 1','PC 2','PC 3', 'Integral','Amplitude','Minimum','Maximum'},...
        'Value',6,...
        'Tag','popX1',...
        'Position',[2*a+c hOffset c BUTTON_HEIGHT],...
        'UserData',{DataMatrix,discardList,fixedList},...
        'Callback',@popup_Callback);

    stringY1 = uicontrol('Parent',upperLeftPanel,...
        'Style','text',...
        'Units','characters',...
        'String','Y axes',...
        'Position',[2*a+2*c+b hOffset c BUTTON_HEIGHT]);

    popY1 = uicontrol('Parent',upperLeftPanel,...
        'Units','characters',...
        'Style','popupmenu',...
        'String',{'PC 1','PC 2','PC 3', 'Integral','Amplitude','Minimum','Maximum'},...
        'Position',[3*a+3*c+b hOffset c BUTTON_HEIGHT],...
        'Value',4,...
        'Tag','popY1',...
        'UserData',{DataMatrix,discardList},...
        'Callback',@popup_Callback);

    stringZ1 = uicontrol('Parent',upperLeftPanel,...
        'Style','text',...
        'Units','characters',...
        'String','Z axes',...
        'Position',[3*a+4*c+2*b hOffset c BUTTON_HEIGHT]);

    popZ1 = uicontrol('Parent',upperLeftPanel,...
        'Units','characters',...
        'Style','popupmenu',...
        'String',{'PC 1','PC 2','PC 3', 'Integral','Amplitude','Minimum','Maximum'},...
        'Position',[4*a+5*c+2*b hOffset c BUTTON_HEIGHT],...
        'Value',7,...
        'Tag','popZ1',...
        'UserData',{DataMatrix,discardList,fixedList},...
        'Callback',@popup_Callback);

    % grap parameters from sort spikes gui
    user_string=get(findobj('Tag','sortSpikesGUI_selectedEntity'),'String');
    selected_Entities=eval((user_string));
    txt_array='';
    txt_array=strcat('EntityID : ', num2str(selected_Entities),'  __ ');

    if get(findobj('Tag','sortSpikesGUI_parameterRadiobutton'),'Value')
        txt_array=strcat(txt_array,' DimensionReduction :  ',' Parameter','  __  ');
    elseif get(findobj('Tag','sortSpikesGUI_downsamplingRadiobutton'),'Value')
        txt_array=strcat(txt_array,' DimensionReduction :  ',' downsampling','  __  ');
    else
        txt_array=strcat(txt_array,' DimensionReduction :  ',' unknown','  __ ');
    end

    nClust=findobj('Tag','sortSpikesGUI_selectedNClusters');
    nClusters=eval(get(nClust(1),'String'));
    if get(findobj('Tag','sortSpikesGUI_kmeansRadiobutton'),'Value')
        txt_array=strcat(txt_array,' # Cluster :  ', num2str(nClusters),'  __ ',' sorting Method: ',' k means');
    elseif get(findobj('Tag','sortSpikesGUI_KlustaKwikRadiobutton'),'Value')
        txt_array=strcat(txt_array,' max # Cluster :  ', num2str(max(nClusters)),'  __ ',' sorting Method:',' Klustakwik');
    else
        txt_array=strcat(txt_array,' # Cluster :  ', num2str(nClusters),'  __ ',' sorting Method: ','> unknown');
    end


    % report sorting parameters from sortSpikesGUI
    % text label
    uicontrol('Parent',upperLeftPanel,...
        'Units','characters',...
        'Position',[1 pannel_height-LABEL_HEIGHT*1.5-1 pannel_width LABEL_HEIGHT*1.5],...
        'Style','text',...
        'FontWeight','bold',....
        'ForegroundColor','r',...
        'String',txt_array,...
        'Tag','SpikesPreSelectGUI_ParameterListbox',...
        'Enable','on');



    subplot(2,2,2)

    posOut2=get(findobj('Tag','SpikesPreSelect_GUI_upperRightPanel'),'Position');
    set(gca,'Units','characters');
    posIn2=get(gca,'Position'); %[left bottom width height]
    fringe2(1:2)=abs(posOut2(1:2)-posIn2(1:2)); %[left bottom right top]
    fringe2(3)=abs(GUIwidth-(posIn2(3)+posIn2(1)));
    fringe2(4)=abs(GUIheight-(posIn2(4)+posIn2(2)));

    hOffset=0.5;
    topOffset=abs((fringe2(4)-LABEL_HEIGHT*2)/2);
    rightOffset=abs(fringe2(3)-(button_length))/2;

    % right pannel
    stringX2 = uicontrol('Parent',upperRightPanel,...
        'Style','text',...
        'Units','characters',...
        'String','X axes',...
        'Position',[b hOffset c BUTTON_HEIGHT]);

    popX2 = uicontrol('Parent',upperRightPanel,...
        'Units','characters',...
        'Style','popupmenu',...
        'String',{'PC 1','PC 2','PC 3', 'Integral','Amplitude','Minimum','Maximum'},...
        'Position',[b+a+c hOffset c BUTTON_HEIGHT],...
        'Value',2,...
        'Tag','popX2',...
        'UserData',{DataMatrix,discardList,fixedList},...
        'Callback',@popup_Callback);

    stringY2 = uicontrol('Parent',upperRightPanel,...
        'Style','text',...
        'Units','characters',...
        'String','Y axes',...
        'Position',[2*b+2*a+2*c hOffset c BUTTON_HEIGHT]);

    popY2 = uicontrol('Parent',upperRightPanel,...
        'Units','characters',...
        'Style','popupmenu',...
        'String',{'PC 1','PC 2','PC 3', 'Integral','Amplitude','Minimum','Maximum'},...
        'Position',[2*b+3*a+3*c  hOffset c BUTTON_HEIGHT],...
        'Value',1,...
        'Tag','popY2',...
        'UserData',{DataMatrix,discardList,fixedList},...
        'Callback',@popup_Callback);

    %%%% upper panel
    % short user info
    uicontrol('Parent',upperRightPanel,...
        'Units','characters',...
        'Position',[pannel_width/2-rightOffset (pannel_height-topOffset-LABEL_HEIGHT*2) pannel_width/2 LABEL_HEIGHT*2],...
        'Style','text',...
        'String',{['press ''start selection'', set edges by mouse klicks'];['into right upper subplot, finaly press enter']},...
        'Tag','SpikesPreSelectGUI_userInfo',...
        'Enable','on');

    % switch on manual selction (right upper)
    uicontrol('Parent',upperRightPanel,...
        'Units','characters',...
        'Position',[pannel_width-(button_length+rightOffset) pannel_height-fringe2(4)-BUTTON_HEIGHT*1.5 button_length BUTTON_HEIGHT*1.5],...
        'Style','pushbutton',...
        'String','start selection',...
        'Tag','SpikesPreSelectGUI_manSelectCheckbox',...
        'UserData',{DataMatrix,discardList,fixedList},...
        'Callback',@popup_Callback,...
        'Value',0,...
        'Enable','on');


    % Radio buttons for selecting add or subtract
    buttonGroup = uibuttongroup('Visible','off',...
        'Units','characters',...
        'Position',[pannel_width-(button_length+rightOffset) pannel_height-fringe2(4)-BUTTON_HEIGHT*1.5-5 button_length (3*BUTTON_HEIGHT+0.5)],...
        'Parent',upperRightPanel,...
        'Tag','SpikesPreSelectGUI_RadioDiscard',...
        'Title','apply to:' );
    OuterButton = uicontrol('Style','Radio',...
        'String','outer',...
        'Units','characters',...
        'Position',[0 0 13 BUTTON_HEIGHT],...
        'Parent',buttonGroup,...
        'Tag','SpikesPreSelectGUI_OuterRadiobutton',...
        'HandleVisibility','on');
    InnerButton = uicontrol('Style','Radio',...
        'String','inner',...
        'Units','characters',...
        'Position',[0 1.5 13 BUTTON_HEIGHT],...
        'Parent',buttonGroup,...
        'Tag','SpikesPreSelectGUI_InnerRadiobutton',...
        'HandleVisibility','on');
    set(buttonGroup,'SelectedObject',InnerButton);  % Select one Default
    set(buttonGroup,'Visible','on');


    %%% lower panel

    subplot(2,2,3)

    posOut3=get(findobj('Tag','SpikesPreSelect_GUI_lowerLeftPanel'),'Position');
    set(gca,'Units','characters');
    posIn3=get(gca,'Position'); %[left bottom width height]
    fringe3(1:2)=abs(posOut3(1:2)-posIn3(1:2)); %[left bottom right top]
    fringe3(3)=abs(GUIwidth-(posIn3(3)+posIn3(1)));
    fringe3(4)=abs(GUIheight-(posIn3(4)+posIn3(2)));

    % switch on manual selction left
    uicontrol('Parent',lowerLeftPanel,...
        'Units','characters',...
        'Position',[(fringe3(1)-button_length)/2 (posIn3(4)+posIn3(2))-BUTTON_HEIGHT*1.5-GUIyPos   button_length BUTTON_HEIGHT*1.5],...
        'Style','pushbutton',...
        'String','start selection',...
        'Tag','SpikesPreSelectGUI_manSelectCheckbox3',...
        'UserData',{DataMatrix,discardList,fixedList},...
        'Callback',@popup_Callback,...
        'Value',0,...
        'Enable','on');


    uicontrol('Parent',lowerLeftPanel,...
        'Units','characters',...
        'Position',[(fringe3(1)-button_length)/2 (posIn3(4)+posIn3(2))-BUTTON_HEIGHT*1.5-GUIyPos-BUTTON_HEIGHT*2   button_length BUTTON_HEIGHT*1.5],...
        'Style','pushbutton',...
        'String','fixed as Unit',...
        'Tag','SpikesPreSelectGUI_fixedUnitCheckbox',...
        'UserData',{DataMatrix,discardList,fixedList},...
        'Callback',@fixedUnit_Callback,...
        'Value',0,...
        'Enable','on');

    %%%% discard, add or forget
    % discard from cluster container
    uicontrol('Parent',lowerLeftPanel,...
        'Units','characters',...
        'Position',[(fringe3(1)-button_length)/2 fringe(2)+3+(BUTTON_HEIGHT*1.5)*2 button_length-4 BUTTON_HEIGHT*1.5],...
        'Style','pushbutton',...
        'String','discard',...
        'Tag','SpikesPreSelectGUI_discardCheckbox',...
        'UserData',{DataMatrix,discardList,fixedList,selectionList},...
        'Callback',@popup_Callback,...
        'Value',0,...
        'Enable','on');
    % add to cluster container
    uicontrol('Parent',lowerLeftPanel,...
        'Units','characters',...
        'Position',[(fringe3(1)-button_length)/2 fringe(2)+1.5+(BUTTON_HEIGHT*1.5) button_length-4 BUTTON_HEIGHT*1.5],...
        'Style','pushbutton',...
        'String','add',...
        'Tag','SpikesPreSelectGUI_addCheckbox',...
        'UserData',{DataMatrix,discardList,fixedList,selectionList},...
        'Callback',@popup_Callback,...
        'Value',0,...
        'Enable','on');
    % forget
    uicontrol('Parent',lowerLeftPanel,...
        'Units','characters',...
        'Position',[(fringe3(1)-button_length)/2 fringe(2) button_length-4 BUTTON_HEIGHT*1.5],...
        'Style','pushbutton',...
        'String','forget',...
        'Tag','SpikesPreSelectGUI_forgetCheckbox',...
        'UserData',{DataMatrix,discardList,fixedList,selectionList},...
        'Callback',@popup_Callback,...
        'Value',0,...
        'Enable','on');


    subplot(2,2,4)

    posOut4=get(findobj('Tag','SpikesPreSelect_GUI_lowerRightPanel'),'Position');
    set(gca,'Units','characters');
    posIn4=get(gca,'Position'); %[left bottom width height]
    fringe4(1:2)=abs(posOut4(1:2)-posIn4(1:2)); %[left bottom right top]
    fringe4(3)=abs(GUIwidth-(posIn4(3)+posIn4(1)));
    fringe4(4)=abs(GUIheight-(posIn4(4)+posIn4(2)));

    rightOffset=abs(fringe4(3)-(button_length))/2;

    % button to run the tool
    uicontrol('Parent',lowerRightPanel,...
        'Units','characters',...
        'Position',[pannel_width-(button_length+rightOffset) fringe4(2)+LABEL_HEIGHT+2.5 button_length BUTTON_HEIGHT*1.5],...
        'Style','pushbutton',...
        'String','Cluster',...
        'Tag','SpikesPreSelect_GUI_ApplyPushbutton',...
        'Enable','on',...
        'UserData',{DataMatrix,discardList,fixedList},...
        'Callback',@SpikesPreSelect_ClusterPushbuttonCallback);


    % switch on manual selction rigth
    uicontrol('Parent',lowerRightPanel,...
        'Units','characters',...
        'Position',[pannel_width-(button_length+rightOffset) (posIn4(4)+posIn4(2))-GUIyPos-BUTTON_HEIGHT*1.5 button_length BUTTON_HEIGHT*1.5],...
        'Style','pushbutton',...
        'String','start selection',...
        'Tag','SpikesPreSelectGUI_manSelectCheckbox2',...
        'UserData',{DataMatrix,discardList,fixedList},...
        'Callback',@popup_Callback,...
        'Value',0,...
        'Enable','on');

    % shrink cutout
    uicontrol('Parent',lowerRightPanel,...
        'Units','characters',...
        'Position',[pannel_width-(button_length+rightOffset) fringe4(2)+LABEL_HEIGHT+0.5 button_length LABEL_HEIGHT],...
        'Style','text',...
        'String','narrow Cutouts',...
        'Tag','SpikesPreSelectGUI_shrinkCutoutText',...
        'Enable','on');
    uicontrol('Parent',lowerRightPanel,...
        'Units','characters',...
        'Position',[pannel_width-(button_length+rightOffset) fringe4(2) button_length LABEL_HEIGHT],...
        'Style','edit',...
        'String',strcat(['[1:',num2str(nsFile.Segment.SampleCount{posEntities(ii)}(1)),']']),...
        'Tag','SpikesPreSelectGUI_shrinkCutout',...
        'Enable','on');


    refreshPlot(DataMatrix,discardList,fixedList);
catch
    % if error occurs here, the window is closed, the error is rethrown
    % and then catched by the main window
    close(findobj('tag', 'SpikesPreSelect_GUI'));
    rethrow(lasterror);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fixedUnit_Callback(source,event)
try
    % parameters {'PC 1','PC 2','PC 3', 'Integral','Amplitude','Minimum','Maximum'}
    tempUserData=get(source,'UserData');
    DataMatrix=tempUserData{1};
    discardList=tempUserData{2};
    fixedList=tempUserData{3};
    if isempty(discardList)
        postMessage('Please discard data first - only discarded could be fixed in a seperat Unit!')
    else
        if isempty(fixedList{1})
            fixedList{1}=tempUserData{2};
        else
            fixedList{end+1}=tempUserData{2};
        end
        discardList=[];
        refreshPlot(DataMatrix,discardList,fixedList);
    end
catch
    handleError(lasterror);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function popup_Callback(source,event)
try
    % parameters {'PC 1','PC 2','PC 3', 'Integral','Amplitude','Minimum','Maximum'}
    tempUserData=get(source,'UserData');
    DataMatrix=tempUserData{1};
    discardList=tempUserData{2};
    fixedList=tempUserData{3};
    refreshPlot(DataMatrix,discardList,fixedList);
catch
    handleError(lasterror);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SpikesPreSelect_ClusterPushbuttonCallback(source,event)

global nsFile;
try
    ii=1;
    tempUserData=get(source,'UserData');
    DataMatrix=tempUserData{1};
    discardList=tempUserData{2};
    fixedList=tempUserData{3};

    user_string=get(findobj('Tag','sortSpikesGUI_selectedEntity'),'String');
    selected_Entities=eval((user_string));
    posEntities(1)=find(nsFile.Segment.DataentityIDs==selected_Entities(1));
    if ~isvector(selected_Entities)
        error('Invalid data vector indices.');
    end

    clusterList=setdiff([1:nsFile.Segment.Info(posEntities(ii)).ItemCount],union(discardList,vertcat(fixedList{:})));

    if ~isempty(intersect(discardList,clusterList))
        error('FIND: error while clustering')
    end

    tmp=findobj('Tag','sortSpikesGUI_selectedNClusters');
    nClusters=eval(get(tmp(1),'String')); % use first VALUE IF MULTIPLE FIGURES ARE OPEN


    sCut=get(findobj('Tag','SpikesPreSelectGUI_shrinkCutout'),'String');
    CoutoutInterv=eval((sCut));
    clusterMatrix=nsFile.Segment.Data{posEntities(ii)}(CoutoutInterv,clusterList);


    %%%%%%%%%%%%%%%% DimensionReduction %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if  get(findobj('Tag','sortSpikesGUI_parameterRadiobutton'),'Value')
        %extracts important features of the wave forms
        disp('extracting important parameters')

        %maxima or minima and the time they are reached, first max of
        %absolute data
        [extremeValues, init_max]=max(abs(clusterMatrix));

        %find if value is negative or positive
        for q=1:length(extremeValues)
            extremeValues(q)=clusterMatrix(init_max(q),q);
        end

        %value under curve
        integral=sum(abs(clusterMatrix));
        %assign vairable
        clusterMatrixFin=[extremeValues;init_max;integral];

    elseif get(findobj('Tag','sortSpikesGUI_downsamplingRadiobutton'),'Value')
        % RESAMPLING --- very Simple!
        disp('Method: Downsampling');
        
        if size(clusterMatrix,1)>44
            clusterMatrixFin=resample(clusterMatrix,44,size(clusterMatrix,1));

            %%% show the resamping quality:

            figure('Name','Downsampling','NumberTitle', 'off');
            subplot(2,1,1);
            plot(clusterMatrix);axis tight; title('before downsampling');
            ax0=axis;
            xlabel('','fontweight','b');
            subplot(2,1,2); plot(clusterMatrixFin);axis tight; title('after downsampling');
            ax1=axis;
            xlabel('','fontweight','b');
            set(gca,'xcolor',[0 0 1]);
        else
            disp('No downsampling neccessary!');
            clusterMatrixFin=clusterMatrix;
        end
    else
        error('unknown dimension reduction method');
    end


    %%%%%%%%%%%%%%%% ClusteringMethod %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%% Klustakwik
    if get(findobj('Tag','sortSpikesGUI_KlustaKwikRadiobutton'),'Value')

        disp('Calling Klustakwik: ');
        % Start the clustering based on KlustaKwik

        FIND_GUIdata = get(findobj('Tag','FIND_GUI'),'UserData');
        postMessage('Busy - please wait...');

        allClusters=callKlustaKwik('KlustaExe',FIND_GUIdata.KlustaExe,...
            'DataMatrix',clusterMatrixFin,'nClusters',max(nClusters));

        nsFile.Segment.UnitID{posEntities(ii)}(clusterList)=allClusters;
        mC=max(allClusters);
        if ~isempty(discardList)
            nsFile.Segment.UnitID{posEntities(ii)}(discardList)=repmat(mC+1,length(discardList),1);
            mC=mC+1;
        end
        if ~isempty(fixedList{1})
            for pp=1:size(fixedList,2)
                nsFile.Segment.UnitID{posEntities(ii)}(fixedList)=repmat(mC+1,length(fixedList{pp}),1);
                mC=mC+1;
            end
        end
        disp('done with clustering.');
        postMessage('...done.');

        %%%% k_means
    elseif get(findobj('Tag','sortSpikesGUI_kmeansRadiobutton'),'Value')

        disp('Calling kmeans: ');
        postMessage('Busy - please wait...');

        %start clustering with k_means
        [pbm,allClusters]=k_means('DataMatrix',clusterMatrix,...
            'clusterData',clusterMatrixFin', 'posEntityIDs',ii,...
            'nClusters',nClusters);

        nsFile.Segment.UnitID{posEntities(ii)}(clusterList)=allClusters;
        mC=max(allClusters);
        if ~isempty(discardList)
            nsFile.Segment.UnitID{posEntities(ii)}(discardList)=repmat(mC+1,length(discardList),1);
            mC=mC+1;
        end
        if ~isempty(fixedList{1})
            for pp=1:size(fixedList,2)
                nsFile.Segment.UnitID{posEntities(ii)}(fixedList{pp})=repmat(mC+1,length(fixedList{pp}),1);
                mC=mC+1;
            end
        end
        disp('done with clustering.');
        postMessage('...done.');

        plotSortedSpikes(selected_Entities(ii));
    else
        error('unknown clustering method');
    end

    %%%%%%%%%%%%%%% Plot results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    NClusters=unique(nsFile.Segment.UnitID{posEntities(ii)});
    % set unified color code
    clist=hsv(length(NClusters)+1);

    figure('Name','ClusterOverview','NumberTitle', 'off');

    segs=nsFile.Segment.Data{posEntities(ii)}';
    stdr = std(segs);
    if any(stdr==0)
        sr=segs;
        disp('not previously weighted to std')
    else
        sr = segs./repmat(stdr,size(segs,1),1);
    end

    %Now you are ready to find the principal components.
    [coefs,scores,variances,t2] = princomp(sr);
    %print the percent which are explained with each principal component
    percent_explained = 100*variances/sum(variances)

    % plot the projections on two principal components
    CC=1;
    for kk=1:5
        for yy=kk+1:5
            subplot(4,3,CC);
            hold on;
            for t=1:length(NClusters)
                thiscluster=NClusters(t);
                plot(scores(find(nsFile.Segment.UnitID{posEntities(ii)}==thiscluster),...
                    kk),scores(find(nsFile.Segment.UnitID{posEntities(ii)}==thiscluster),yy),'+','color',clist(t,:));
                xlabel([ num2str(kk) ' PC']);
                ylabel([num2str(yy) ' PC']);
            end
            CC=CC+1;
        end
    end

    %plot a bar plot of the percent explained
    subplot(4,3,CC);
    pareto(percent_explained)
    xlabel('Principal Component')
    ylabel('Variance Explained (%)')

    %%%%%%%%%%%%%%%%%% show the extremes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [st2, index] = sort(t2,'descend'); % Sort in descending order. (to get extreme ones)

    % plot the most extreme eamples for each plot and the least extrem for
    % comparison ..

    CC=CC+1;

    subplot(4,3,CC); hold on;
    title('PCA based Outliers per Cluster')
    for tt=1:length(NClusters)
        thiscluster=NClusters(tt);

        this_extreme=index(find(nsFile.Segment.UnitID{posEntities(ii)}==thiscluster));

        plot(nsFile.Segment.Data{posEntities(ii)}(:,this_extreme(1))','color',clist(tt,:));
        plot(nsFile.Segment.Data{posEntities(ii)}(:,this_extreme(end))','--','color',clist(tt,:));
    end
    leghandle=legend('upper extreme','lower extreme','location','best');
    lp=get(leghandle,'position');
    set(leghandle,'Position',[lp(1) lp(2)-.15 lp(3:4)]);
    %%% well, there is a legend still needed somewhere ...

    %%% plot the isi distribution to get a feeling for the regularity of
    %%% the units, to distinguish them from noise
    hisi=figure;
    set(hisi,'name','Interspike Intervals Distribution','NumberTitle', 'off');
    c=0;
    for n=1:length(NClusters)
        c=c+1;
        isi=diff(nsFile.Segment.TimeStamp{posEntities(ii)}(find(nsFile.Segment.UnitID{posEntities(ii)}==n)))*1000;
        if isempty(isi)
            c=c-1;
            continue;
        end
        SpikesPerUnit=sum(nsFile.Segment.UnitID{posEntities(ii)}==n);
        edges=[0:1:max(isi)];
        isiPdf=histc(isi,edges);
        
        h(c)=subplot(length(NClusters),1,c);
        stairs(edges,isiPdf,'color',clist(n,:));
        set(gca,'TickDir','out');
        ax(:,c)=axis;
        
        if c==1
            title({sprintf('distribution of interspike intervals of DataentityID %2i',...
                nsFile.Segment.DataentityIDs(posEntities(ii)));sprintf('Unit %2i  with %2i spikes in all',...
                n,SpikesPerUnit)});
        elseif n==length(NClusters)
            title(sprintf('Unit %2i with %2i spikes in all',n,SpikesPerUnit));
            xlabel('interspike interval in ms');
            ylabel('counts');
        else
            title(sprintf('Unit %2i with %2i spikes in all',n,SpikesPerUnit));
        end
    end
    mhigh=max(ax([2,4],:),[],2);
    mlow=min(ax([1,3],:),[],2);
    linkaxes(h,'xy');
    axis([mlow(1) mhigh(1) mlow(2) mhigh(2)]);

catch
    handleError(lasterror)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [discardList]=refreshPlot(DataMatrix,discardList,fixedList)

global nsFile;
user_string=get(findobj('Tag','sortSpikesGUI_selectedEntity'),'String');
selected_Entities=eval((user_string));
posEntities(1)=find(nsFile.Segment.DataentityIDs==selected_Entities(1));

startSelection=get(findobj('Tag','SpikesPreSelectGUI_manSelectCheckbox'),'Value');
startSelection2=get(findobj('Tag','SpikesPreSelectGUI_manSelectCheckbox2'),'Value');
startSelection3=get(findobj('Tag','SpikesPreSelectGUI_manSelectCheckbox3'),'Value');

discard=get(findobj('Tag','SpikesPreSelectGUI_discardCheckbox'),'Value');
add=get(findobj('Tag','SpikesPreSelectGUI_addCheckbox'),'Value');
forget=get(findobj('Tag','SpikesPreSelectGUI_forgetCheckbox'),'Value');

param={'PC 1';'PC 2';'PC 3'; 'Integral';'Amplitude';'Minimum';'Maximum'};
X1=get(findobj('Tag','popX1'),'Value');
Y1=get(findobj('Tag','popY1'),'Value');
Z1=get(findobj('Tag','popZ1'),'Value');
Y2=get(findobj('Tag','popY2'),'Value');
X2=get(findobj('Tag','popX2'),'Value');
selectParam=[X1;Y1;Z1;X2;Y2];

Outer=get(findobj('Tag','SpikesPreSelectGUI_OuterRadiobutton'),'Value');
Inner=get(findobj('Tag','SpikesPreSelectGUI_InnerRadiobutton'),'Value');

tempUserData=get(findobj('Tag','SpikesPreSelectGUI_addCheckbox'),'Userdata');
selectedList=tempUserData{4};

try
    ii=1;
    postMessage(' ');
    clist=colormap('Lines');
    clusterList=setdiff([1:nsFile.Segment.Info(posEntities(ii)).ItemCount],union(discardList,vertcat(fixedList{:})));

    hs1=subplot(2,2,1);
    cla(hs1);
    subplot(2,2,1)
    plot3(DataMatrix(clusterList,selectParam(1)),DataMatrix(clusterList,selectParam(2)),DataMatrix(clusterList,selectParam(3)),'g*');
    hold on;
    plot3(DataMatrix(discardList,selectParam(1)),DataMatrix(discardList,selectParam(2)),DataMatrix(discardList,selectParam(3)),'r*');

    xlabel(param{selectParam(1)});
    ylabel(param{selectParam(2)});
    zlabel(param{selectParam(3)});

    hs2=subplot(2,2,2);
    cla(hs2);
    subplot(2,2,2)
    plot(DataMatrix(clusterList,selectParam(4)),DataMatrix(clusterList,selectParam(5)),'g*');
    hold on;
    plot(DataMatrix(discardList,selectParam(4)),DataMatrix(discardList,selectParam(5)),'r*');
    xlabel(param{selectParam(4)});
    ylabel(param{selectParam(5)});

    if startSelection || startSelection2 || startSelection3
        postMessage('Busy - please wait...');

        if startSelection2
            subplot(2,2,4)
            if exist('getrect')==2
                rect=getrect(gcf);
                rectangle('Position',[rect(1),rect(2),rect(3),rect(4)]);
                REC(:,1)=[rect(1);rect(1);rect(1)+rect(3);rect(1)+rect(3)];
                REC(:,2)=[rect(2);rect(2)+rect(4);rect(2);rect(2)+rect(4)];
                in_rec=[];
                in_rec = zeros(size(nsFile.Segment.Data{posEntities(ii)}(:,1:length(clusterList))));
                for tt=1:length(clusterList)
                    in_rec(:,tt)=inpolygon(1:nsFile.Segment.SampleCount{posEntities(ii)},...
                        nsFile.Segment.Data{posEntities(ii)}(:,clusterList(tt)),REC(:,1),REC(:,2));
                end
            else
                pg = ginput;
                if size(pg,1)<3
                    postMessage('Please choose minimal 3 edges!');
                    return;
                end
                c_hull = convhull(pg(:,1),pg(:,2));
                for tt=1:length(clusterList)
                    in_rec(:,tt)=inpolygon(1:nsFile.Segment.SampleCount{posEntities(ii)},...
                        nsFile.Segment.Data{posEntities(ii)}(:,clusterList(tt)),pg(c_hull,1),pg(c_hull,2));
                end

            end
            [r,col]=find(in_rec);
            InnerP=clusterList(col);
            in_poly=InnerP;
            OuterP=setdiff([1:nsFile.Segment.Info(posEntities(ii)).ItemCount],union(InnerP,vertcat(fixedList{:})));
            Inner=1;
            subplot(2,2,2)
            hold on;
            plot(DataMatrix(InnerP,selectParam(4)),DataMatrix(InnerP,selectParam(5)),'b*');

        elseif startSelection3
            subplot(2,2,3)
            if exist('getrect')==2
                rect=getrect(gcf);
                rectangle('Position',[rect(1),rect(2),rect(3),rect(4)]);
                REC(:,1)=[rect(1);rect(1);rect(1)+rect(3);rect(1)+rect(3)];
                REC(:,2)=[rect(2);rect(2)+rect(4);rect(2);rect(2)+rect(4)];
                in_rec2=[];
                in_rec2 = zeros(size(nsFile.Segment.Data{posEntities(ii)}(:,1:length(discardList))));
                for tt=1:length(discardList)
                    in_rec2(:,tt)=inpolygon(1:nsFile.Segment.SampleCount{posEntities(ii)},...
                        nsFile.Segment.Data{posEntities(ii)}(:,discardList(tt)),REC(:,1),REC(:,2));
                end
            else
                pg = ginput;
                if size(pg,1)<3
                    postMessage('Please choose minimal 3 edges!');
                    return;
                end
                c_hull = convhull(pg(:,1),pg(:,2));
                for tt=1:length(discardList)
                    in_rec2(:,tt)=inpolygon(1:nsFile.Segment.SampleCount{posEntities(ii)},...
                        nsFile.Segment.Data{posEntities(ii)}(:,discardList(tt)),pg(c_hull,1),pg(c_hull,2));
                end
            end
            [r,col]=find(in_rec2);
            InnerP=discardList(col);
            in_poly=InnerP;
            OuterP=setdiff([1:nsFile.Segment.Info(posEntities(ii)).ItemCount],union(InnerP,vertcat(fixedList{:})));
            Inner=1;

            subplot(2,2,2)
            hold on;
            plot(DataMatrix(InnerP,selectParam(4)),DataMatrix(InnerP,selectParam(5)),'b*');
        elseif startSelection
            pg=ginput;
            if size(pg,1)<3
                postMessage('Please choose minimal 3 edges!');
                return;
            end
            c_hull = convhull(pg(:,1),pg(:,2));
            in_poly =inpolygon(DataMatrix(:,selectParam(4)),DataMatrix(:,selectParam(5)),pg(c_hull,1),pg(c_hull,2));

            InnerP=find(in_poly);
            OuterP=setdiff([1:nsFile.Segment.Info(posEntities(ii)).ItemCount],union(InnerP,vertcat(fixedList{:})));
            subplot(2,2,2)
            hold on;
            plot(pg(c_hull,1),pg(c_hull,2),'b-');
            hold on;
            if Inner
                plot(DataMatrix(in_poly,selectParam(4)),DataMatrix(in_poly,selectParam(5)),'b*');
            elseif Outer
                plot(DataMatrix(OuterP,selectParam(4)),DataMatrix(OuterP,selectParam(5)),'b*');
            end
            xlabel(param{selectParam(4)});
            ylabel(param{selectParam(5)});
        end

        hs1=subplot(2,2,1);
        cla(hs1);
        subplot(2,2,1)
        plot3(DataMatrix(clusterList,selectParam(1)),DataMatrix(clusterList,selectParam(2)),DataMatrix(clusterList,selectParam(3)),'g*');
        hold on;
        plot3(DataMatrix(discardList,selectParam(1)),DataMatrix(discardList,selectParam(2)),DataMatrix(discardList,selectParam(3)),'r*');
        plot3(DataMatrix(in_poly,selectParam(1)),DataMatrix(in_poly,selectParam(2)),DataMatrix(in_poly,selectParam(3)),'b*');
        xlabel(param{selectParam(1)});
        ylabel(param{selectParam(2)});
        zlabel(param{selectParam(3)});

        if Inner
            w1=InnerP;
            w2=OuterP;
        elseif Outer
            w1=OuterP;
            w2=InnerP;
        end
        hold off;
        hs3=subplot(2,2,3);
        cla(hs3);
        subplot(2,2,3)
        if ~isempty(w1)
            plot(1:nsFile.Segment.SampleCount{posEntities(ii)}, nsFile.Segment.Data{posEntities(ii)}(:,w1),'b');
            hold on;
        end
        xlabel('sample points');
        title(['selected Spikes - DataentityID: ',num2str(selected_Entities(ii))],'Interpreter','none');

        if startSelection2
            hs4=subplot(2,2,4);
            cla(hs4);
            if ~isempty(clusterList)
                plot(1:nsFile.Segment.SampleCount{posEntities(ii)}, nsFile.Segment.Data{posEntities(ii)}(:,clusterList),'g');
                hold on;
            end
            if ~isempty(w1)
                plot(1:nsFile.Segment.SampleCount{posEntities(ii)}, nsFile.Segment.Data{posEntities(ii)}(:,w1),'b');
            end
            xlabel('sample points');
            title(['Spikes - DataentityID: ',num2str(selected_Entities(ii))],'Interpreter','none');
            hold off;
        else
            hs4=subplot(2,2,4);
            cla(hs4);
            if ~isempty(w2)
                plot(1:nsFile.Segment.SampleCount{posEntities(ii)}, nsFile.Segment.Data{posEntities(ii)}(:,w2),'g');
                hold on;
                % calculate actual mean spike
                mSpike=mean(nsFile.Segment.Data{posEntities(ii)}(:,w2),2);
                plot(1:length(mSpike),mSpike,'Color','k','LineWidth',2,'LineStyle','--');
            end
            xlabel('sample points');
            title(['remaining Spikes - DataentityID: ',num2str(selected_Entities(ii))],'Interpreter','none');
            hold off;
        end
        % set selected List (w1) to userdata
        selectedList=w1;
        set(findobj('Tag','SpikesPreSelectGUI_addCheckbox'),'Userdata',{DataMatrix,discardList,fixedList,selectedList});
        set(findobj('Tag','SpikesPreSelectGUI_discardCheckbox'),'Userdata',{DataMatrix,discardList,fixedList,selectedList});
        set(findobj('Tag','SpikesPreSelectGUI_forgetCheckbox'),'Userdata',{DataMatrix,discardList,fixedList,selectedList});
        set(findobj('Tag','SpikesPreSelectGUI_manSelectCheckbox'),'Value',0);
        set(findobj('Tag','SpikesPreSelectGUI_manSelectCheckbox2'),'Value',0);
        set(findobj('Tag','SpikesPreSelectGUI_manSelectCheckbox3'),'Value',0);

    elseif add || discard || forget

        if add
            discardList=setdiff(discardList,selectedList);
        elseif discard
            discardList=union(discardList,selectedList);
        end

        clusterList=setdiff([1:nsFile.Segment.Info(posEntities(ii)).ItemCount],union(discardList,vertcat(fixedList{:})));

        hs1=subplot(2,2,1);
        cla(hs1);
        subplot(2,2,1)
        plot3(DataMatrix(clusterList,selectParam(1)),DataMatrix(clusterList,selectParam(2)),DataMatrix(clusterList,selectParam(3)),'g*');
        hold on;
        plot3(DataMatrix(discardList,selectParam(1)),DataMatrix(discardList,selectParam(2)),DataMatrix(discardList,selectParam(3)),'r*');
        xlabel(param{selectParam(1)});
        ylabel(param{selectParam(2)});
        zlabel(param{selectParam(3)});

        hs2=subplot(2,2,2);
        cla(hs2);
        subplot(2,2,2)
        plot(DataMatrix(clusterList,selectParam(4)),DataMatrix(clusterList,selectParam(5)),'g*');
        hold on;
        plot(DataMatrix(discardList,selectParam(4)),DataMatrix(discardList,selectParam(5)),'r*');
        xlabel(param{selectParam(4)});
        ylabel(param{selectParam(5)});

        hs3=subplot(2,2,3);
        cla(hs3);
        subplot(2,2,3)
        if ~isempty(discardList)
            plot(1:nsFile.Segment.SampleCount{posEntities(ii)}, nsFile.Segment.Data{posEntities(ii)}(:,discardList),'Color',[0.5 0.5 0.5]);
            hold on;
            xlabel('sample points');
            title(['discarded Spikes - DataentityID: ',num2str(selected_Entities(ii))],'Interpreter','none');

        end
        if ~isempty(selectedList) && discard
            plot(1:nsFile.Segment.SampleCount{posEntities(ii)}, nsFile.Segment.Data{posEntities(ii)}(:,selectedList),'Color','r');
            xlabel('sample points');
            title(['discarded Spikes - DataentityID: ',num2str(selected_Entities(ii))],'Interpreter','none');
        end
        hs4=subplot(2,2,4);
        cla(hs4);
        subplot(2,2,4)
        if ~isempty(clusterList)
            plot(1:nsFile.Segment.SampleCount{posEntities(ii)}, nsFile.Segment.Data{posEntities(ii)}(:,clusterList),'Color','g');
            hold on;
            % calculate actual mean spike
            mSpike=mean(nsFile.Segment.Data{posEntities(ii)}(:,clusterList),2);
            plot(1:length(mSpike),mSpike,'Color','k','LineWidth',2,'LineStyle','--');
            xlabel('sample points');
            title(['Spikes used for sorting - DataentityID: ',num2str(selected_Entities(ii))],'Interpreter','none');
        end
        if ~isempty(selectedList) && add
            plot(1:nsFile.Segment.SampleCount{posEntities(ii)}, nsFile.Segment.Data{posEntities(ii)}(:,selectedList),'Color','r');
        end
        hold off;
        selectedList=[];
        set(findobj('Tag','SpikesPreSelectGUI_addCheckbox'),'Userdata',{DataMatrix,discardList,fixedList,selectedList});
        set(findobj('Tag','SpikesPreSelectGUI_discardCheckbox'),'Userdata',{DataMatrix,discardList,fixedList,selectedList});
        set(findobj('Tag','SpikesPreSelectGUI_forgetCheckbox'),'Userdata',{DataMatrix,discardList,fixedList,selectedList});
        set(findobj('Tag','SpikesPreSelectGUI_fixedUnitCheckbox'),'Userdata',{DataMatrix,discardList,fixedList,selectedList});
        set(findobj('Tag','SpikesPreSelectGUI_addCheckbox'),'Value',0);
        set(findobj('Tag','SpikesPreSelectGUI_discardCheckbox'),'Value',0);
        set(findobj('Tag','SpikesPreSelectGUI_forgetCheckbox'),'Value',0);
    else
        hs1=subplot(2,2,1);
        cla(hs1);
        subplot(2,2,1)
        plot3(DataMatrix(clusterList,selectParam(1)),DataMatrix(clusterList,selectParam(2)),DataMatrix(clusterList,selectParam(3)),'g*');
        hold on;
        plot3(DataMatrix(discardList,selectParam(1)),DataMatrix(discardList,selectParam(2)),DataMatrix(discardList,selectParam(3)),'r*');
        plot3(DataMatrix(selectedList,selectParam(1)),DataMatrix(selectedList,selectParam(2)),DataMatrix(selectedList,selectParam(3)),'b*');
        xlabel(param{selectParam(1)});
        ylabel(param{selectParam(2)});
        zlabel(param{selectParam(3)});

        hs2=subplot(2,2,2);
        cla(hs2);
        subplot(2,2,2)
        plot(DataMatrix(clusterList,selectParam(4)),DataMatrix(clusterList,selectParam(5)),'g*');
        hold on;
        plot(DataMatrix(discardList,selectParam(4)),DataMatrix(discardList,selectParam(5)),'r*');
        plot(DataMatrix(selectedList,selectParam(4)),DataMatrix(selectedList,selectParam(5)),'b*');
        xlabel(param{selectParam(4)});
        ylabel(param{selectParam(5)});

        hs3=subplot(2,2,3);
        cla(hs3);
        subplot(2,2,3)
        if ~isempty(discardList)
            plot(1:nsFile.Segment.SampleCount{posEntities(ii)}, nsFile.Segment.Data{posEntities(ii)}(:,discardList),'Color',[0.5 0.5 0.5]);
            hold on;
        end
        if ~isempty(selectedList)
            plot(1:nsFile.Segment.SampleCount{posEntities(ii)}, nsFile.Segment.Data{posEntities(ii)}(:,selectedList),'Color','b');
        end
        xlabel('sample points');
        title(['discarded Spikes - DataentityID: ',num2str(selected_Entities(ii))],'Interpreter','none');

        hs4=subplot(2,2,4);
        cla(hs4);
        subplot(2,2,4)
        if ~isempty(clusterList)
            plot(1:nsFile.Segment.SampleCount{posEntities(ii)}, nsFile.Segment.Data{posEntities(ii)}(:,clusterList),'Color','g');
            hold on;
            % calculate actual mean spike
            mSpike=mean(nsFile.Segment.Data{posEntities(ii)}(:,clusterList),2);
            plot(1:length(mSpike),mSpike,'Color','k','LineWidth',2,'LineStyle','--');
            xlabel('sample points');
            title(['Spikes used for sorting - DataentityID: ',num2str(selected_Entities(ii))],'Interpreter','none');
        end
        if ~isempty(selectedList)
            plot(1:nsFile.Segment.SampleCount{posEntities(ii)}, nsFile.Segment.Data{posEntities(ii)}(:,selectedList),'Color','b');
        end
        hold off;
    end

    set(findobj('Tag','popX1'),'Userdata',{DataMatrix,discardList,fixedList});
    set(findobj('Tag','popY1'),'Userdata',{DataMatrix,discardList,fixedList});
    set(findobj('Tag','popZ1'),'Userdata',{DataMatrix,discardList,fixedList});
    set(findobj('Tag','popX2'),'Userdata',{DataMatrix,discardList,fixedList});
    set(findobj('Tag','popY2'),'Userdata',{DataMatrix,discardList,fixedList});
    set(findobj('Tag','SpikesPreSelectGUI_manSelectCheckbox'),'Userdata',{DataMatrix,discardList,fixedList});
    set(findobj('Tag','SpikesPreSelectGUI_manSelectCheckbox2'),'Userdata',{DataMatrix,discardList,fixedList});
    set(findobj('Tag','SpikesPreSelectGUI_manSelectCheckbox3'),'Userdata',{DataMatrix,discardList,fixedList});
    set(findobj('Tag','SpikesPreSelectGUI_addSelectCheckbox'),'Userdata',{DataMatrix,discardList,fixedList,selectedList});
    set(findobj('Tag','SpikesPreSelectGUI_discardSelectCheckbox'),'Userdata',{DataMatrix,discardList,fixedList,selectedList});
    set(findobj('Tag','SpikesPreSelect_GUI_ApplyPushbutton'),'Userdata',{DataMatrix,discardList,fixedList});
    set(findobj('Tag','SpikesPreSelectGUI_fixedUnitCheckbox'),'Userdata',{DataMatrix,discardList,fixedList});

    postMessage('...done.');
catch
    handleError(lasterror);
end







