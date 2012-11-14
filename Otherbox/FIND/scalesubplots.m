function coords=scalesubplots(nrow,ncol)
%creates a nrow by ncol array of coordinates

sidelengthx=1/(ncol);
cornerposx=0:sidelengthx:1-sidelengthx;
cornerposx=cornerposx*0.96;
cornerposx=cornerposx+0.02;
sidelengthx=sidelengthx*0.96*0.96;

sidelengthy=1/(nrow);
cornerposy=0:sidelengthy:1-sidelengthy;
cornerposy=cornerposy*0.96;
cornerposy=cornerposy+0.02;
sidelengthy=sidelengthy*0.96*0.96;

newxc=repmat(cornerposx,nrow,1);
newyc=flipud(repmat(cornerposy,ncol,1)');
newslx=sidelengthx;
newsly=sidelengthy;

newcell=cell(nrow,ncol);

for xx=1:nrow
    for yy=1:ncol
        newcell{xx,yy}=[newxc(xx,yy) newyc(xx,yy) sidelengthx sidelengthy];
    end
end

coords=newcell;
end
