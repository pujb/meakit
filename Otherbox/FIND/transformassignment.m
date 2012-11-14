function transformassignment(action)
FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
mymap=FIND_GUIdata.MEAmap;
switch action
    case 'lr'
        mymap=flipud(mymap)
    case 'ud'
        mymap=fliplr(mymap)
    case 'ccw'
        mymap=rot90(rot90(rot90(mymap)))
    case 'cw'
        mymap=rot90(mymap)
        
end
FIND_GUIdata.MEAmap=mymap;
set(findobj('Tag','FIND_GUI'),'UserData',FIND_GUIdata);
loadmealayout('FIND_GUI');