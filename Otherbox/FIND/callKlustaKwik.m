function InCluster=callKlustaKwik(varargin)
% Perform Spike Sorting by calling KlustaKwik.
% Call KlustaKwik and return values.
%
% CAUTION: USES A DATA PATH TO KLUSTAKWIK PROGRAM
%
% Get http://klustakwik.sourceforge.net/ , install according to doc there.
% Set the path in init.m.
% Rmeier 201106
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

% obligatory argument names
obligatoryArgs={{'KlustaExe', @(val) ischar(val) && isfile(val)},...
                'DataMatrix',{'nClusters',@(val) isnumeric(val) && (val)>1}}; %-% e.g. {'x','y'}

% optional arguments names with default values
optionalArgs={}; 

errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
  error(errorMessage,''); %used this format so that the '\n' are converted
end


% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);

try
% main function code
if (size(DataMatrix,1)>48) error('Too many Dimensions!'); end

DataMatrix=DataMatrix * 1000; % go to mv 

% export to temp. File
dlmwrite('tmp4KlustaQuick.fet.1',size(DataMatrix,1));
dlmwrite('tmp4KlustaQuick.fet.1',DataMatrix(:,:)','precision','%.4f ','-append','delimiter','\t');

% run the programm
%use this command to run KlustaKwik with all features
dos(['"' KlustaExe '" tmp4KlustaQuick 1  -MaxPossibleClusters ', num2str(nClusters) ,' -UseFeatures all']) %%% run and classify 

%use only the first 23 features/dimensions (important to use the format descriptor '%d')
%dos(['"' KlustaExe '" tmp4KlustaQuick 1  -MaxPossibleClusters 10  -UseFeatures ' num2str(ones(1,23),'%d')]) %%% run and classify 

% delete temporary data file
delete('tmp4KlustaQuick.fet.1');

% read the data-Classification
collectCluster=dlmread('tmp4KlustaQuick.clu.1');

% discard first Number - since this tells the number of clusters in the
% FILE..
collectCluster=collectCluster(2:end);
uClus=unique(collectCluster);
InCluster=zeros(length(collectCluster),1);

for kk=1:length(uClus)
    InCluster(find(collectCluster==uClus(kk)))=kk;
end
% delete temporary output file
delete('tmp4KlustaQuick.clu.1');
delete('tmp4KlustaQuick.klg.1');
delete('tmp4KlustaQuick.model.1');

catch
    rethrow(lasterror);
end
