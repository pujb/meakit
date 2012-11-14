function out=getmeageometry(file)
% usage: geometry viewmeageometry(file)
    % returns cell array containing {hardwareIDs, electrode names, xpos,
    % ypos}
%
% requires tline2cell to work
% 
% M. Nenniger 2009
% find.bccn.uni-freiburg.de

%%load geometry

%example: file='C:\Program Files\Multi Channel Systems\MC_Rack\MeaLayouts\MEA60.txt'

fid=fopen(file);
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

%% plot geometry
mydata=cat(1,mydata{:});
myxystr=[];
for ii=1:length(header)
    switch header{ii}
        case 'x'
            myxystr(1)=ii;
        case 'y'
            myxystr(2)=ii;
        case 'HWID'
            myhwid=ii;
        case 'Name'
            myname=ii;
    end
end

xycoords=[];
for ii=1:2
    xycoords(:,ii)=cellstr2num(mydata(:,myxystr(ii)));
end

out={mydata(:,1);mydata(:,2);cellfun(@str2num,{mydata{:,myxystr(1)}});cellfun(@str2num,{mydata{:,myxystr(2)}})};