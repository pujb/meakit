[filename,pathname]=uigetfile('*.*');

%load geometry
fid=fopen([pathname filename]);
tline=[];
tline=fgets(fid)
datalines=0;
counter=0;
mydata={};
while ischar(tline)
    if datalines==1
       header=tline2cell(tline);
       datalines=2;
    elseif datalines==2;
        counter=counter+1;
        tline
        mydata{counter}=tline2cell(tline);
    end
    if strfind(tline,'Layout:')
        datalines=1;
    end
    tline=fgets(fid);
end
fclose(fid);

%% plot geometry
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
    ii
    xycoords(:,ii)=cellstr2num(mydata(:,myxystr(ii)))
end


plot(xycoords(:,1),xycoords(:,2),'.')
for ii=1:length(xycoords)
    text(xycoords(ii,1),xycoords(ii,2),strcat(mydata(ii,1), ':',mydata(ii,2)),'horizontalalignment','center')
end

%format plot
myxlim=get(gca,'xlim')
myylim=get(gca,'ylim')
xlim([-diff(myxlim)*.1+myxlim(1) diff(myxlim)*.1+myxlim(2)])
ylim([-diff(myylim)*.1+myylim(1) diff(myylim)*.1+myylim(2)])
axis off