function setmeageometry(x,y,topleftx,toplefty,cleargeom,varargin)

FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
pvpmod(varargin);

oldgrid=FIND_GUIdata.MEAmap;
oldgrid=flipud(fliplr(oldgrid));
newgrid=zeros(x,y);
givewarning=0;
if cleargeom~=1
    for ix=1:size(oldgrid,1)
        for iy=1:size(oldgrid,2)
            if (ix+topleftx-1)>=1 && (ix+topleftx-1) <= x && (iy+toplefty-1)>=1 && (iy+toplefty-1)<= y
                newgrid(ix+topleftx-1,iy+toplefty-1)=oldgrid(ix, iy);
            else
                givewarning=1;
            end
        end
    end
end
newgrid=flipud(fliplr(newgrid));
FIND_GUIdata.MEAmap=newgrid;
set(findobj('Tag','FIND_GUI'),'UserData',FIND_GUIdata);
delete(findobj('Tag','MEAchannelassign'));
delete(findobj('Tag','setgeometryGUI'));
MEAchannelassignGUI();
if givewarning==1
    warndlg('last grid did not fit in new grid, information may be lost')
end

