%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sub function to execute k_means clustering algorithm
% uses mahalanobis distance, removes outliers!
% also likes to end up in infinite loop
%
function [pbm, all_idx] = k_means_execute(clusterData, clusterList)
    
    % number of waveforms
    m = size(clusterData,1);
    
    % initialize some important variables
    pbm=zeros(1,length(clusterList));    % value of clustering goodness
    all_idx=zeros(m, length(clusterList));   % assignment vector, which cluster the wave forms belong to

    for k = 1:length(clusterList),

        %do it 50 times to avoid falling into local minima
        for pp=1:50
            disp(pp);
            % kmeans is sensitive to beginning point, initialize it randomly
            p = randperm(size(clusterData,1));      % centroid initialized randomly
            c = clusterData(p(1:clusterList(k)),:);

            temp=zeros(m,1);
            non_outlier_mask = ones(size(clusterData,1),1);
            while 1,    % cluster as long as it is not the minimum
                d=k_DistMatrix(c);  % calculate objcets-centroid distances
                [z,g]=min(d,[],2);  % find assignment matrix g
                g = g .* non_outlier_mask;
                if all(g==temp)
                    % outlier elimination using X2 distribution
                    found = 0;
                    for i=1:clusterList(k)
                        f=find(g==i);
                        if ~isempty(f) && length(f) > 1                            
                            cluster = clusterData(f,:);
                            %is it mentioned somewhere, that this distance
                            %metric is used?
                            dist = mahaldist(cluster, c(i,:), inv(cov(cluster)));
                            p = chi2cdf(dist, size(cluster,2));
                            % questionable?
                            outliers = p > 0.9999999999;
                            non_outlier_mask(f(outliers)) = 0;
                            found = found + length(f(outliers));
                        end
                    end
                    
                    if (found == 0)     % if outliers are found, continue further iterations
                        break;          % stop the iteration once nothing is changing
                    end
                    temp=g;         % copy group matrix to temporary variable
                    
                else
                    temp=g;         % copy group matrix to temporary variable
                   
                end
                for i=1:clusterList(k),
                    f=find(g==i);
                    if ~isempty(f)
                        c(i,:)=mean(clusterData(f,:),1);   %start clustering from center of clusters again                        
                    end
                end
            end

            %assign values once the clustering is done, only assign them if
            %this clustering was better than the one before ()
            %for the first clustering the variables have to be created
            if pp==1
                SumOfDistances=sum(z);
                FinalCentroids=c;
                FinalIndices=g;
                FinalDistances=z;
            elseif sum(z)<SumOfDistances;
                SumOfDistances=sum(z);
                FinalCentroids=c;
                FinalIndices=g;
                FinalDistances=z;
            end
        end
        %to keep track when clustering is very slow, I'm giving back this notice
        disp(['done with clustering with ',num2str(clusterList(k)), ' clusters!']);

        %%%%%%%%%%%%%%%%%cluster validation%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calculate sum of distances for one cluster only, needed for index
        %calculation
        if k==1
            e1=sum(z);
        end

        %assign the vectors for this number of clusters
        pbm(k)=k_pbm(clusterList(k),FinalDistances,FinalIndices,e1,FinalCentroids);%calculate index
        all_idx(:,k)=FinalIndices;
        
    end


function dist=k_DistMatrix(Centroids)
    % calculates the euclidean distance between the data points and the
    % centroids. For the kmeans clustering.
    %
    % This function belongs to FIND_GUI Toolbox project
    % http://find.bccn.uni-freiburg.de

    % Calculate eucledean DIST.^2 = c.^2 - 2.c.d + d.^2
    dist = - 2 * clusterData * Centroids';
    C2   = sum(Centroids.^2,2);
    dist = bsxfun(@plus, dist, C2');
%     dist = bsxfun(@plus, dist, D2);
    
end  % k_distMatrix

end  % execute_k_means
