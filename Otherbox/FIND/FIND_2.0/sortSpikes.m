function output=sortSpikes(data,tagSelecDimReduc,tagSelecCluster,nClusters,k_prompted)
% Performs spike sorting on Segment Data.
%
% Uses Klustaquick or K-Means clustering to perform Spike Sorting based on Waveforms.
% Various preprocessing steps are implemented.
% Clustering results will be displayed using PCA.
%

%% new comments (12/09)
% data needs to be a matrix. dimensions: (sample, data)
% tagSelecDimReduc - downsampling, PCA, parameters - ICA option removed -
% wasn't implemented anyway
% tagSelecCluster - klustakwik, kmeans

%
% %%%%% Obligatory Parameters %%%%%
%
% 'selected_Data_Vectors': Indices of selected spikes to sort spikes
%
% 'tagSelecDimReduc': Tag of selected dimension reduction Method
% 'nClusters':the number of clusters which should be clustered
%
% (0) R. Meier Feb 07 meier@biologie.uni-freiburg.de
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de


if nargin < 4
    error('too few input arguments. type help sortSpikes for details.');
elseif nargin >5
    error('too many input arguments. type help sortSpikes for details.');
end

%set defaults
switch nargin
    case 4
        k_prompted=NaN;  % to avoide inputdlg set it to a non-nan
end

%% %%%%%%%%%%%%%%%% dimension reduction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% extracting features of the spikes --> squeezing them to max. 48
% dimensions -- > Be careful here - some selection might be
% useful!

%%% Here: dimenstion reduction is needed
% type one: simple ReSAMPLING!

try
    tmp_2sort=data;
    tmp_2sort_final=[];
    
    %% type of dimensionality reduction
    switch tagSelecDimReduc
        % very simple resampling
        case 'downsampling'
            if size(tmp_2sort,1)>44
                tmp_2sort_final=resample(tmp_2sort,44,size(tmp_2sort,1));
            else
                disp('No downsampling neccessary!');
                tmp_2sort_final=tmp_2sort;
            end
            
            %% PCA downsampling
        case 'PCA'
            % take the first 48 pca and replace data by them
            % Centre the spikes on the corresponding time-domain sample
            % This is required for the covariance matrix
            M = mean(tmp_2sort,2);      % calculate time domain sample means
            centred_tmp_2sort = bsxfun(@minus, tmp_2sort, M);
            
            % calculate covariance matrix
            C = centred_tmp_2sort * centred_tmp_2sort';
            
            % computer PCA using eigenvalues
            [V,D] = eig(C);
            %rearrange output as 'eig' ordered the eigenvalues from smallest
            D = flipud(diag(D));
            V = fliplr(V);
            %select the first 48 pca
            if (length(D) > 48)
                D = D(1:48,1:48);
                V = V(:,1:48);
            end
            
            % project the decomposition back to the spikes
            tmp_2sort_final = centred_tmp_2sort' * V;
            tmp_2sort_final = tmp_2sort_final';
        case 'parameters'
            %extracts important features of the wave forms
            disp('extracting important parameters');
            
            %maxima or minima and the time they are reached, first max of
            %absolute data
            [extremeValues, init_max]=max(abs(tmp_2sort));
            
            %find if value is negative or positive
            for q=1:length(extremeValues)
                extremeValues(q)=tmp_2sort(init_max(q),q);
            end
            
            %value under curve
            integral=sum(abs(tmp_2sort));
            
            %assign vairable
            tmp_2sort_final=[extremeValues;init_max;integral];
            
            
        otherwise
            error('Invalid method switch.');
    end
    
    
    %%%%%%%%%%%%%%%%%% clustering %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    switch tagSelecCluster
        %% klustakwik
        case 'klustakwik'
            %                 FIND_GUIdata.FINDpath=fileparts(which('FIND_GUI.m'));
            currentpath=fileparts(which('sortSpikes.m'));
            if ispc
                KlustaExe=fullfile(currentpath,'\Klustakwik\KlustaKwik.exe');
            else
                error('sortSpikes is currently only available for windows');
                return;
            end
            
            if ~isempty(tmp_2sort_final)
                try
                    this_clusters=callKlustaKwik(tmp_2sort_final,KlustaExe,max(nClusters));
                catch
                    rethrow(lasterror)
                end
            else
                error('sorry - no spikes were detected - consider other parameters for cutouts and detection');
            end
            %                 disp('done with the clustering.');
            %% kmeans
        case 'kmeans'
            
            disp('Calling kmeans: ');
            
            %start clustering with k_means
            [pbm,this_clusters]=k_means(tmp_2sort_final,nClusters)
            
%             [pbm,this_clusters]=k_means('DataMatrix',tmp_2sort,...
%                 'clusterData',tmp_2sort_final', 'posEntityIDs',ii,...
%                 'nClusters',nClusters,'k_prompted',k_prompted);
%             
%             [pbm,this_clusters]=k_means('DataMatrix',mydata,...
%                 'clusterData',mydata', 'posEntityIDs',1,...
%                 'nClusters',nClusters,'k_prompted',k_prompted);
            
            %                 disp('done with clustering.');
        otherwise
            error('Invalid method switch.');
    end
    postMessage('...done.');
    
catch
    rethrow(lasterror);
end
output=this_clusters;
