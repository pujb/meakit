function loadgeometryandmap()
[filename,pathname]=uigetfile('*.txt','Select MEA geometry file');

%%load geometry
fid=fopen([pathname filename]);
tline=[];
tline=fgets(fid);
datalines=0;
counter=0;
mydata={};
while ischar(tline)
    if datalines==1
       header=tline2cell(tline);
       datalines=2;
    elseif datalines==2;
        counter=counter+1;
        mydata{counter}=tline2cell(tline);
    end
    if strfind(tline,'Layout:')
        datalines=1;
    end
    tline=fgets(fid);
end
fclose(fid);

mydata=cat(1,mydata{:})
myxystr=[];
for ii=1:length(header)
    if strcmp(header{ii},'x')
        myxystr(1)=ii;
    end
    if strcmp(header{ii},'y')
        myxystr(2)=ii;
    end
end


myname=[1 2]
xycoords=[];
for ii=1:2
    xycoords(:,ii)=cellstr2num(mydata(:,myxystr(ii)));
end


%% load channelmap
[filename,pathname]=uigetfile('*.cmp','Select matching MEA channelmap');

fid=fopen([pathname filename]);
tline=[];
tline=fgets(fid);
datalines=0;
counter=0;
mymap={};
while ischar(tline)
    datalines=datalines+1;
    if datalines==2
       meadimstr=tline2cell(tline);
    elseif datalines>=2;
        counter=counter+1;
        tline;
        mymap{counter}=tline2cell(tline,'separator',',');
    end
    tline=fgets(fid);
end
fclose(fid);

mymap=cat(1,mymap{:})

%% separate map to get hid and name matrices.
myhids=cell(size(mymap));
mynames=cell(size(mymap));
for ii=1:size(mymap,1)
    for jj=1:size(mymap,2)
        tmpstr=tline2cell(mymap{ii,jj},'separator',':','lineendswithseparator','false')
        myhids{ii,jj}=tmpstr{2}
        mynames{ii,jj}=tmpstr{1}
    end
end

%% automated assignment of hids
FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
hidfromgeom=cellstr2num(mydata(:,1));
tmphids=cellstr2num(myhids);
[ingeom,ingeomidx,c]=intersect(tmphids,hidfromgeom);
myhids=zeros(size(myhids));
myhids(ingeomidx)=hidfromgeom+1;
FIND_GUIdata.MEAmap=myhids;
set(findobj('Tag','FIND_GUI'),'UserData',FIND_GUIdata);
loadmealayout('FIND_GUI');