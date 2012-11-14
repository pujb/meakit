function mealayout2var()
FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
writevar='Yes';
if evalin('base','exist(''MEAlayout'')==1')
    writevar=questdlg('Variable ''MEAlayout'' already exists in base workspace. Overwrite?','Variable already exists','Yes','No','No');
end
switch writevar
    case 'Yes'
        assignin('base','MEAlayout',FIND_GUIdata.MEAmap);
end
