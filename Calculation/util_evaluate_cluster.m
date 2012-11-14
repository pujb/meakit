function [ PC CE SC S XB DI ADI result eval ] = util_evaluate_cluster(data, method, minmax, varargin)
%UTIL_EVALUATE_CLUSTER Evaluate the performance of differnt clustering
%method and different clustering numbers.
%   Input:
%           data:   Input data.
%           method: Clustering method.
%                   'k' / 'km' / 'fcm' / 'gk' / 'gg'
%           minmax: Clustering number range. [min max] / 3.
%                   If minmax is a scalar, the program will do clustering
%                   once.
%           normal:   If true, data will be normalized. [default]: false.
%           ktimes:   It is recommended to run Kmeans / KMedoid several times to
%                     achieve the correct results. [default]:1
%   Output:
%           PC:     Partition Coefficient (PC).
%           CE:     Classification Entropy (CE).
%           SC:     Partition Index (SC).
%           S:      Separation Index (S).
%           XB:     Xie and Beni Index (XB).
%           DI:     Dunn Index (DI).
%           ADI:    Alternative Dunn Index (ADI).
%           result: Results from clustering method.
%           eval:   Results from clusteval
%
%   Example:
%           [ ~, ~, ~, ~, ~, ~, ~, result, eval ] =
%           util_evaluate_cluster(mappedX(:, 1:2), 'gk', 3);
%
%   Created on Jul/26/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

% Analyze parameter
pvpmod(varargin);

if ~exist('normal')
    normal = false;
end

% Load data
cludata.X = data;

if normal
    cludata = clust_normalize(cludata,'range');
end

figure;

% init
ment = [];  % The place for saving PC/XB...

% parameters and clustering
if strcmpi(method, 'gk')
    param.m = 2;    % Fuzziness
    param.e = 1e-3; % Termination Tolrance
    
    % If the user just want to get one clustering result but not the
    % comparing results
    if ~isscalar(minmax)
        % Loop
        for cln = minmax(1) : minmax(2)
            param.c = cln;  % Number of clustering
            param.ro = ones(1, param.c);    % Cluster volumes
            result = GKclust(cludata, param);
            
            % Visualization
            clf
            plot(cludata.X(:, 1), cludata.X(:, 2), 'b.', result.cluster.v(:, 1), result.cluster.v(:, 2), 'r*');
            if ~normal
                xlim([min(cludata.X(:, 1)), max(cludata.X(:, 1))]);
                ylim([min(cludata.X(:, 2)), max(cludata.X(:, 2))]);
            end
            hold on
            new.X = cludata.X;
            eval = clusteval(new, result, param);
            
            % Validation
            result = modvalidity(result, cludata, param);
            ment{cln} = result.validity;
        end
    else
        % Only once
        param.c = minmax;                  % Number of clustering
        param.ro = ones(1, param.c);       % Cluster volumes
        result = GKclust(cludata, param);
        
        % Visualization
        clf
        plot(cludata.X(:, 1), cludata.X(:, 2), 'b.', result.cluster.v(:, 1), result.cluster.v(:, 2), 'r*');
        if ~normal
            xlim([min(cludata.X(:, 1)), max(cludata.X(:, 1))]);
            ylim([min(cludata.X(:, 2)), max(cludata.X(:, 2))]);
        end
        hold on
        new.X = cludata.X;
        eval = clusteval(new, result, param);
        
        % Validation
        result = modvalidity(result, cludata, param);
        ment{1} = result.validity;
    end
elseif strcmpi(method, 'k')
    param.val = 3;  % Dunn Index is chosen
    param.vis = 1;  % Show animation
    
    % If the user just want to get one clustering result but not the
    % comparing results
    if ~isscalar(minmax)
        % Loop
        for cln = minmax(1) : minmax(2)
            param.c = cln;  % Number of clustering
            
            if ~exist('ktimes', 'var')
                ktimes = 1;
                if cln == minmax(1)
                    disp('Note: It is recommeneded to run KMeans more than one time.');
                end
            end
            
            for i = 1:ktimes
                result = Kmeans(cludata, param);
            end
            
            eval = [];
            
            % Validation
            result = modvalidity(result, cludata, param);
            ment{cln} = result.validity;
        end
    else
        % Only once
        param.c = minmax;	% Number of clustering
        
        if ~exist('ktimes', 'var')
            ktimes = 1;
            disp('Note: It is recommeneded to run KMeans more than one time.');
        end
        
        for i = 1:ktimes
            result = Kmeans(cludata, param);
        end
        
        eval = [];
        
        % Validation
        result = modvalidity(result, cludata, param);
        ment{1} = result.validity;
    end
elseif strcmpi(method, 'km')
    param.val = 3;  % Dunn Index is chosen
    param.vis = 1;  % Show animation
    
    % If the user just want to get one clustering result but not the
    % comparing results
    if ~isscalar(minmax)
        % Loop
        for cln = minmax(1) : minmax(2)
            param.c = cln;  % Number of clustering
            
            if ~exist('ktimes', 'var')
                ktimes = 1;
                if cln == minmax(1)
                    disp('Note: It is recommeneded to run KMedoid more than one time.');
                end
            end
            
            for i = 1:ktimes
                result = Kmedoid(cludata, param);
            end
            
            eval = [];
            
            % Validation
            result = modvalidity(result, cludata, param);
            ment{cln} = result.validity;
        end
    else
        % Only once
        param.c = minmax;	% Number of clustering
        
        if ~exist('ktimes', 'var')
            ktimes = 1;
            disp('Note: It is recommeneded to run KMedoid more than one time.');
        end
        
        for i = 1:ktimes
            result = Kmedoid(cludata, param);
        end
        
        eval = [];
        
        % Validation
        result = modvalidity(result, cludata, param);
        ment{1} = result.validity;
    end
elseif strcmpi(method, 'fcm')
    param.m = 2;    % Fuzziness
    param.e = 1e-3; % Termination Tolrance
    param.val = 3;  % Dunn Index is chosen
    
    % If the user just want to get one clustering result but not the
    % comparing results
    if ~isscalar(minmax)
        % Loop
        for cln = minmax(1) : minmax(2)
            param.c = cln;  % Number of clustering
            result = FCMclust(cludata, param);
            
            % Visualization
            clf
            plot(cludata.X(:, 1), cludata.X(:, 2), 'b.', result.cluster.v(:, 1), result.cluster.v(:, 2), 'r*');
            if ~normal
                xlim([min(cludata.X(:, 1)), max(cludata.X(:, 1))]);
                ylim([min(cludata.X(:, 2)), max(cludata.X(:, 2))]);
            end
            hold on
            new.X = cludata.X;
            eval = clusteval(new, result, param);
            
            % Validation
            result = modvalidity(result, cludata, param);
            ment{cln} = result.validity;
        end
    else
        % Only once
        param.c = minmax;                  % Number of clustering
        result = FCMclust(cludata, param);
        
        % Visualization
        clf
        plot(cludata.X(:, 1), cludata.X(:, 2), 'b.', result.cluster.v(:, 1), result.cluster.v(:, 2), 'r*');
        if ~normal
            xlim([min(cludata.X(:, 1)), max(cludata.X(:, 1))]);
            ylim([min(cludata.X(:, 2)), max(cludata.X(:, 2))]);
        end
        hold on
        new.X = cludata.X;
        eval = clusteval(new, result, param);
        
        % Validation
        result = modvalidity(result, cludata, param);
        ment{1} = result.validity;
    end
elseif strcmpi(method, 'gg')
    param.m = 2;    % Fuzziness
    param.e = 1e-3; % Termination Tolrance
    param.val = 3;  % Dunn Index is chosen
    param.vis = 0;  % Don't show KMeans animation
    
    % If the user just want to get one clustering result but not the
    % comparing results
    if ~isscalar(minmax)
        % Loop
        for cln = minmax(1) : minmax(2)
            param.c = cln;                      % Number of clustering
            result = Kmeans(cludata, param);    % Use Kmeans to init GG
            param.c = result.data.f;
            result = GGclust(cludata, param);
            
            % Visualization
            clf
            plot(cludata.X(:, 1), cludata.X(:, 2), 'b.', result.cluster.v(:, 1), result.cluster.v(:, 2), 'r*');
            if ~normal
                xlim([min(cludata.X(:, 1)), max(cludata.X(:, 1))]);
                ylim([min(cludata.X(:, 2)), max(cludata.X(:, 2))]);
            end
            hold on
            new.X = cludata.X;
            eval = clusteval(new, result, param);
            
            % Validation
            result = modvalidity(result, cludata, param);
            ment{cln} = result.validity;
        end
    else
        % Only once
        param.c = minmax;                  % Number of clustering
        result = Kmeans(cludata, param);   % Use Kmeans to init GG
        param.c = result.data.f;
        result = GGclust(cludata, param);
        
        % Visualization
        clf
        plot(cludata.X(:, 1), cludata.X(:, 2), 'b.', result.cluster.v(:, 1), result.cluster.v(:, 2), 'r*');
        if ~normal
            xlim([min(cludata.X(:, 1)), max(cludata.X(:, 1))]);
            ylim([min(cludata.X(:, 2)), max(cludata.X(:, 2))]);
        end
        hold on
        new.X = cludata.X;
        eval = clusteval(new, result, param);
        
        % Validation
        result = modvalidity(result, cludata, param);
        ment{1} = result.validity;
    end
else
    error('Not supported yet.');
end

% Show results
PC=[];CE=[];SC=[];S=[];XB=[];DI=[];ADI=[];

if ~isscalar(minmax)
    for i = minmax(1) : minmax(2)
        PC=[PC ment{i}.PC];
        CE=[CE ment{i}.CE];
        SC=[SC ment{i}.SC];
        S=[S ment{i}.S];
        XB=[XB ment{i}.XB];
        DI=[DI ment{i}.DI];
        ADI=[ADI ment{i}.ADI];
    end
    
    figure
    subplot(2,1,1), plot([minmax(1) : minmax(2)], PC)
    title('Partition Coefficient (PC)')
    subplot(2,1,2), plot([minmax(1) : minmax(2)], CE, 'r')
    title('Classification Entropy (CE)')
    
    figure
    subplot(3,1,1), plot([minmax(1) : minmax(2)], SC, 'g')
    title('Partition Index (SC)')
    subplot(3,1,2), plot([minmax(1) : minmax(2)], S, 'm')
    title('Separation Index (S)')
    subplot(3,1,3), plot([minmax(1) : minmax(2)], XB)
    title('Xie and Beni Index (XB)')
    
    figure
    subplot(2,1,1), plot([minmax(1) : minmax(2)], DI)
    title('Dunn Index (DI)')
    subplot(2,1,2), plot([minmax(1) : minmax(2)], ADI)
    title('Alternative Dunn Index (ADI)')
else
    PC = ment{1}.PC;
    CE = ment{1}.CE;
    SC = ment{1}.SC;
    S = ment{1}.S;
    XB = ment{1}.XB;
    DI = ment{1}.DI;
    ADI = ment{1}.ADI;
end

end







function result = modvalidity(result,data,param)
%modified validation function for clustering, it calculates all the
%validity measures, so param.val is not needed

N = size(result.data.f,1);
c = size(result.cluster.v,1);
n = size(result.cluster.v,2);
v = result.cluster.v;

if exist('param.m')==1, m = param.m;else m = 2;end;

%partition coefficient (PC)
fm = (result.data.f).^m;
PC = 1/N*sum(sum(fm));

%classification entropy (CE)
fm = (result.data.f).*log(result.data.f);
CE = -1/N*sum(sum(fm));
     
%results   
result.validity.PC = PC;
result.validity.CE = CE;   
        
        
        

%partition index(SC)
ni = sum(result.data.f);                        %calculate fuzzy cardinality
si = sum(result.data.d.*result.data.f.^(m/2));  %calculate fuzzy variation
pii=si./ni;
mask = zeros(c,n,c);                            %calculate separation of clusters 
for i = 1:c
    for j =1:c
         mask(j,:,i) = v(i,:);
    end
    dist(i) = sum(sum((mask(:,:,i) - v).^2));
end
s = dist;
SC = sum(pii./s);

%separation index (S)
S = sum(pii)./(N*min(dist));

%Xie and Beni's index (XB)
XB = sum((sum(result.data.d.*result.data.f.^2))./(N*min(result.data.d)));
%results    
result.validity.SC = SC;
result.validity.S = S;
result.validity.XB = XB;    
        
        
        

%Dunn's index (DI)
%for identification of compact and well separated clusters
[m,label] = min(result.data.d');%crisp clustering(Kmeans)

for i = 1:c
     index=find(label == i);
     dat{i}=data.X(index,:);
     meret(i)= size(dat{i},1);
end
mindistmatrix =ones(c,c)*inf;
mindistmatrix2 =ones(c,c)*inf;
        
        for cntrCurrentClust = 1:c
           for cntrOtherClust = (cntrCurrentClust+1):c
               for cntrCurrentPoints = 1:meret(cntrCurrentClust)
                   dd = min(sqrt(sum([(repmat(dat{cntrCurrentClust}(cntrCurrentPoints,:),meret(cntrOtherClust),1) ...
                   -dat{cntrOtherClust}).^2]')));
                                       %calculate distances for an alternative Dunn index 
                   dd2 = min(abs(result.data.d(cntrCurrentClust,:)-result.data.d(cntrOtherClust,:)));
                       
                   if mindistmatrix(cntrCurrentClust,cntrOtherClust) > dd
                      mindistmatrix(cntrCurrentClust,cntrOtherClust) = dd;
                   end
                   if mindistmatrix2(cntrCurrentClust,cntrOtherClust) > dd2
                      mindistmatrix2(cntrCurrentClust,cntrOtherClust) = dd2;
                   end
               end
            end
        end

        minimalDist = min(min(mindistmatrix));
        minimalDist2 = min(min(mindistmatrix2));
        
        maxDispersion = 0;
        for cntrCurrentClust = 1:c
            actualDispersion = 0;
            for cntrCurrentPoints1 = 1:meret(cntrCurrentClust)
              dd = max(sqrt(sum([(repmat(dat{cntrCurrentClust}(cntrCurrentPoints1,:),meret(cntrCurrentClust),1) ...
                           -dat{cntrCurrentClust}).^2]')));
              if actualDispersion < dd
                 actualDispersion = dd;
              end
              if maxDispersion < actualDispersion
               maxDispersion = actualDispersion;
              end
           end
        end

        DI = minimalDist/maxDispersion;
        %alternative Dunn index
        ADI = minimalDist2/maxDispersion;
    %results
    result.validity.DI = DI;
    result.validity.ADI = ADI;   
end

