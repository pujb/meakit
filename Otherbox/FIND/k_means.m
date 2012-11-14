function [pbm, idx_k] = k_means(varargin)
% calculates a kmeans clustering with determining the pbm index for cluster validation
%
% Returns the pbm value for all tested cluster numbers and the index vector
% for the best clustering. The greater the pbm index the better the
% clustering. For information on the PBM index see:
% Pakhira et al. Validity index for crisp and fuzzy clusters. Pattern Recognition 37 (2004) 487 – 501.
%
% Parameters to be passed as parameter-value pairs:
%
% %%%%% Obligatory Parameters %%%%%
%
% 'DataMatrix': The initial data which should be clustered, with rows as variables and
% columns as dimensions.
%
%
%
% %%%%% Optional Parameters %%%%%
%
% 'MaxCluster': The maximum number of clusters tested.
% Possible values:
%    From two to number of variables. It must not be number of variables,
%    because the pbm index then becomes inifinite.
%    Default: 15
%

% Further comments:
%
%   The clustering has to start with one cluster, since the pbm index needs
%   this. For that reason no MinCluster variable exists.
%
%
% Henriette Walz 01/08
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de


% obligatory argument names
obligatoryArgs={'DataMatrix','clusterData','nClusters'};           % 'analogEntityIndex'};

% optional arguments names with default values
optionalArgs={'posEntityIDs','k_prompted'};

% Valid var names provided? Otherwise, error is generated. You can also
% supply functions to test the validity of the values, see checkPVP for
% details.
errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,''); %used this format so that the '\n' are converted
end

% set defaults
posEntityIDs=0;
%k_prompted=NaN;

% loading parameter value pairs into workspace, overwriting default values
pvpmod(varargin);

%global nsFile;

MaxCluster=max(nClusters);
startCluster = 1;
endCluster   = MaxCluster;

% loop until the user is satisfied with the number of clusters
while (1)

    % if there should be more clusters than spikes, return!
    if MaxCluster>size(clusterData,1)
        disp('Warning: Maximum number of clusters greater than number of data vectors!')
        return
    end

    %execute k_means clustering
    [pbm_, all_idx_] = k_means_execute(clusterData, startCluster:endCluster);
    pbm(startCluster:endCluster) = pbm_;
    all_idx(:,startCluster:endCluster) = all_idx_;
    [val,posMaxPBM]=max(pbm);
    if ismember(0,unique(all_idx(:,posMaxPBM)))
        all_idx=all_idx+1;
    end
    [max_idx, h] = k_means_plot_clusters(DataMatrix, pbm, all_idx, posEntityIDs);
    
    % give user the opportunity to choose cluster number
    prompt = {'Do you want to cluster again with different cluster number than maximal pbm value? If yes, enter prefered number! If no, enter 0! '};
    k_prompted = str2double(inputdlg(prompt,'Input request',1,{'0'}));
    if isempty(k_prompted) || isnan(k_prompted)    % if input is empty string, set user input to 0
        k_prompted = 0;
    end
    
    %exit if user does not want to cluster with a different number
    if k_prompted <= MaxCluster
        idx_k=max_idx;        %assign output
        break;
    else
        startCluster = endCluster;
        endCluster   = k_prompted;
        close(h(1));
        close(h(3));
        disp(['Re-cluster to ', num2str(endCluster), ' clusters.']);
    end
    
end


end % k_means