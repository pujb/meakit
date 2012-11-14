function makeUDOpointerGUI()
% create UDO
FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
filename=get(findobj('Tag','FIND_GUI_fileInUseText'),'String');
dllname=FIND_GUIdata.DLLpath;
entityIDs=find(FIND_GUIdata.IDselected);
gridlayout=FIND_GUIdata.MEAmap;

%%
% set object name
obj_name=inputdlg('Please define object name','',1,{'myUDO'});

if isempty(obj_name)
    return;
elseif ~isvarname(obj_name{1})
    errordlg('No valid variable name!','Error');
    return;
end

% checks about object name
if evalin('base',['exist(''' obj_name{1} ''',''var'')'])~=0
    options.Default='cancel';
    options.Interpreter = 'none';
    user_resp=questdlg('Variable with this name already exists: Do you want to overwrite it?',...
        'Attention!', ...
        'overwrite','cancel',options);
    switch user_resp
        case 'overwrite'
            evalin('base',['clear  ' obj_name{1}]);
            eval([obj_name{1} '=makeUDOpointer(entityIDs, filename, dllname, gridlayout);']);
            eval([obj_name{1} '.name=''' obj_name{1} ''';']);
            assignin('base',obj_name{1},eval(obj_name{1}));
        case 'cancel'
            return;
    end
else
    
    
    %rotate gridlayout
    gridlayout=rot90(gridlayout,3);
    
    
    %check for assigned but unselected entityIDs
    [tmp,idxtmp]=setdiff(gridlayout(:),[entityIDs 0]);
    gridlayout(idxtmp)=0;
    
    eval([obj_name{1} '=makeUDOpointer(entityIDs, filename, dllname, gridlayout);']);
    eval([obj_name{1} '.name=''' obj_name{1} ''';']);
    assignin('base',obj_name{1},eval(obj_name{1}));
    
    
    
end