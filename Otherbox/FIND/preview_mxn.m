function preview_mxn(varargin)

%temporarily loads data nsFile, then deletes it.
%so far works only for segment data.
segment=44
pvpmod(varargin)

%get filename

varfilename='C:\Documents and Settings\admin\My Documents\Messung_01.mcd'
%get dll path

DLLpath='C:\Documents and Settings\admin\My Documents\FIND\trunk'

%get selected entityIDs and meamap
FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
MEAmap=FIND_GUIdata.MEAmap;
IDselected=find(FIND_GUIdata.IDselected);
mydata=FIND_loader('fileName',varfilename,'DLLpath',DLLpath,'segmentData',[segment,segment,IDselected],'tovar',1);
% mydata=mydata';

%map data to mea map
mapsize=size(MEAmap);
for ii=1:mapsize(1)
    for jj=1:mapsize(2)
        if ismember(MEAmap(ii,jj),IDselected)
            tmpidx=find(IDselected==MEAmap(ii,jj));
            if isempty(tmpidx)
                error('data not found in nsFile, please load data first')
            end
            outmat(ii,jj,:)=squeeze(mydata(:,tmpidx))';
%             outmat(ii,jj,:)=nsFile.Segment.Data{tmpidx}(segmentstart:segmentend,idxsegment);
        elseif MEAmap(ii,jj)==0
            outmat(ii,jj,:)=nan(size(mydata,1),1);
        end
    end
end

plot_mxn(reshape(outmat,prod(mapsize),size(mydata,1)))

%MEAsegments2mat(nsFile,entityIDs,MEAmap,idxsegment,segmentstart,segmentend)