function InCluster=callKlustaKwik(DataMatrix,KlustaExe,nClusters)
% Perform Spike Sorting by calling KlustaKwik.
% Call KlustaKwik and return values.
%
% 'DataMatrix' spike waveforms (in Volt)
%
% 'KlustaExe' directory for 'KlustaKwik.exe' (char)
%
% 'nClusters' number of maximal possible cluster
%
% CAUTION: USES A DATA PATH TO KLUSTAKWIK PROGRAM
% --> only under windows - need to be adapted for Linux!
%
% Get http://klustakwik.sourceforge.net/ , install according to doc there.
% Set the path in init.m.
% Rmeier 201106
%
% removed PVP 091221
%
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

if ~ischar(KlustaExe) || ~isfile(KlustaExe)
    error('FIND: invalid input argument')
end

if ~isnumeric(nClusters) || nClusters<=1
    error('FIND: invalid value for input argument ''nClusters'' ')
end


try
    if (size(DataMatrix,1)>48)
        error('Too many Dimensions!');
    end
    
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
end
