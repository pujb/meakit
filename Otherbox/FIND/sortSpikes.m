function sortSpikes(varargin)
% Performs spike sorting on Segment Data.
%
% Uses Klustaquick or K-Means clustering to perform Spike Sorting based on Waveforms.
% Various preprocessing steps are implemented.
% Clustering results will be displayed using PCA.
%
% sortSpikes uses the following parameters, all to passed as
% parameter-value-pairs.
%
% %%%%% Obligatory Parameters %%%%%
%
% 'selected_Data_Vectors': Indices of selected spikes to sort spikes
%
% 'tagSelecDimReduc': Tag of selected dimension reduction Method
% 'nClusters':the number of clusters which should be clustered
%
%   GENERAL OPTIONS
%       case 'sortSpikesGUI_downsamplingRadiobutton': Resampling
%       case 'sortSpikesGUI_PCAradiobutton': not implemented yet (PCA)
%       case 'sortSpikesGUI_ICAradiobutton': not implemented yet (ICA)
%
% 'tagSelecCluster': Tag of selected clustering Method
%
%   GENERAL OPTIONS
%       case 1: KlustaKwik is used for clustering
%       case 2: k_means
%
%
% Example:
% sortSpikes('tagSelecDimReduc','sortSpikesGUI_downsamplingRadiobutton',...
%           'tagSelecCluster',xxx,...
%           'selected_Entities',[1:55],'nClusters',5);
%
%
% RETRIEVING INFORMATION
%
% Results are added to the global nsFile structure!
% clusters are stored in 'nsFile.Segment.UnitID';
%
%
% (0) R. Meier Feb 07 meier@biologie.uni-freiburg.de
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de



global nsFile;

% obligatory argument names
obligatoryArgs={'tagSelecDimReduc','tagSelecCluster','selected_Entities','nClusters'}; %-% e.g. {'x','y'}


% posssible to check the tags --> keyboard usage of the function

% optional arguments names with default values
optionalArgs={'savePlots','k_prompted'};

errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,''); %used this format so that the '\n' are converted
end

% set defaults
savePlots=0;
k_prompted=NaN; % to avoide inputdlg set it to a non-nan

% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);

% find out if there is segment data in the nsFile
if ~isfield(nsFile,'Segment') || ~isfield(nsFile.Segment,'Data') ...
        || isempty(nsFile.Segment.Data)
    error('FIND:noSegmentData','No segment data found in nsFile variable.');
end
%find out if all selected entities contain segment data
for kk=1:length(selected_Entities)
    if (nsFile.Segment.DataentityIDs==selected_Entities(kk))==0
        error('FIND:noSegmentData','No segment data found in nsFile variable.');
    end
end

% if ~isfield(nsFile,'Segment') || ~isfield(nsFile.Segment,'UnitID') ...
%         || isempty(nsFile.Segment.UnitID)
%     error('FIND:noSegmentUnitID','No segment UnitID found in nsFile variable.');
% end

% transform the EntityID into the position (selected_Entities) of the segment in
% the ns structure
for tt=1:length(selected_Entities)
    posEntities(tt)=find(nsFile.Segment.DataentityIDs==selected_Entities(tt));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%% dimension reduction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% extracting features of the spikes --> squeezing them to max. 48
% dimensions -- > Be carfull here - some selection might be
% usefull!

%%% Here: dimenstion reduction is needed
% type one: simple ReSAMPLING!

try

    for ii=posEntities

        %create variable of original data
        tmp_2sort=nsFile.Segment.Data{ii};

        % variable to be clustered, important to seperate from temp_2sort
        % for the case of only fitting important parameters
        tmp_2sort_final=[];

        switch tagSelecDimReduc

            case 'sortSpikesGUI_downsamplingRadiobutton'
                disp('Method: Downsampling');
                % RESAMPLING --- very Simple!

                if size(tmp_2sort,1)>44
                    tmp_2sort_final=resample(tmp_2sort,44,size(tmp_2sort,1));

                    %%% show the resamping quality:

                    figure('Name','Downsampling','NumberTitle', 'off');
                    subplot(2,1,1);
                    plot(tmp_2sort);axis tight; title('before downsampling');
                    ax0=axis;
                    xlabel('','fontweight','b');
                    subplot(2,1,2); plot(tmp_2sort_final);axis tight; title('after downsampling');
                    ax1=axis;
                    xlabel('','fontweight','b');
                    set(gca,'xcolor',[0 0 1]);

                    % mhigh=max([ax0; ax1]);
                    % mlow=min([ax0 ;ax1]);
                    % subplot(2,1,1);
                    % axis([mlow(1) mhigh(2) mlow(3) mhigh(4)]);
                    % subplot(2,1,2);
                    % axis([mlow(1) mhigh(2) mlow(3) mhigh(4)]);
                else
                    disp('No downsampling neccessary!');
                    tmp_2sort_final=tmp_2sort;
                end


            case 'sortSpikesGUI_PCAradiobutton'
                disp('Method: PCA');

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
                
            case 'sortSpikesGUI_ICAradiobutton'
                disp('Method: ICA');

                disp('Not Implemented now - sorry.');

            case 'sortSpikesGUI_parameterRadiobutton'
                %extracts important features of the wave forms
                disp('extracting important parameters')

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

            case 'sortSpikesGUI_KlustaKwikRadiobutton'

                disp('Calling Klustakwik: ');
                % Start the clustering based on KlustaKwik

                %                 FIND_GUIdata = get(findobj('Tag','FIND_GUI'),'UserData');
                FIND_GUIdata.FINDpath=fileparts(which('FIND_GUI.m'));
                if ispc
                    FIND_GUIdata.KlustaExe=fullfile(FIND_GUIdata.FINDpath,'KlustaKwik', ...
                        'KlustaKwik.exe');
                else
                    disp('currently not available - under construction');
                    return;
                    FIND_GUIdata.KlustaExe=fullfile(FIND_GUIdata.FINDpath,'KlustaKwik', ...
                        'KlustaKwik');
                end


                if ~isempty(tmp_2sort_final)
                    this_clusters=callKlustaKwik('KlustaExe',FIND_GUIdata.KlustaExe,...
                        'DataMatrix',tmp_2sort_final,'nClusters',max(nClusters));
                else
                    error('sorry - no spikes were detected - consider other parameters for cutouts and detection');
                end

                disp('done with the clustering.');

                nsFile.Segment.UnitID{ii}=this_clusters;

            case 'sortSpikesGUI_kmeansRadiobutton'

                disp('Calling kmeans: ');

                %start clustering with k_means
                [pbm,this_clusters]=k_means('DataMatrix',tmp_2sort,...
                    'clusterData',tmp_2sort_final', 'posEntityIDs',ii,...
                    'nClusters',nClusters,'k_prompted',k_prompted);

                disp('done with clustering.');

                nsFile.Segment.UnitID{ii}=this_clusters;


            otherwise
                error('Invalid method switch.');
        end
        postMessage('...done.');
    end
catch
    rethrow(lasterror);
end

%%%%%%%%%%%%%%%%%% do a PCA  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for ii=posEntities

    NClusters=unique(nsFile.Segment.UnitID{ii});
    % set unified color code
    clist=hsv(length(NClusters)+1);

    figure('Name','ClusterOverview','NumberTitle', 'off');

    segs=nsFile.Segment.Data{ii}';
    stdr = std(segs);
    if any(stdr==0)
        sr=segs;
        disp('not previously weighted to std')
    else
        sr = segs./repmat(stdr,size(segs,1),1);
    end

    %Now you are ready to find the principal components.
    [coefs,scores,variances,t2] = princomp(sr);
    %print the percent which are explained with each principal component
    percent_explained = 100*variances/sum(variances)

    % plot the projections on two principal components
    CC=1;
    for kk=1:5
        for yy=kk+1:5
            subplot(4,3,CC);
            hold on;
            for t=1:length(NClusters)
                thiscluster=NClusters(t);
                plot(scores(find(nsFile.Segment.UnitID{ii}==thiscluster),kk),scores(find(nsFile.Segment.UnitID{ii}==thiscluster),yy),'+','color',clist(t,:));
                xlabel([ num2str(kk) ' PC']);
                ylabel([num2str(yy) ' PC']);
            end
            CC=CC+1;
        end
    end

    %plot a bar plot of the percent explained
    subplot(4,3,CC);
    pareto(percent_explained)
    xlabel('Principal Component')
    ylabel('Variance Explained (%)')

    %%%%%%%%%%%%%%%%%% show the extremes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [st2, index] = sort(t2,'descend'); % Sort in descending order. (to get extreme ones)

    % plot the most extreme eamples for each plot and the least extrem for
    % comparison ..

    CC=CC+1;

    subplot(4,3,CC); hold on;
    title('PCA based Outliers per Cluster')
    for tt=1:length(NClusters)
        thiscluster=NClusters(tt);

        this_extreme=index(find(nsFile.Segment.UnitID{ii}==thiscluster));

        plot(nsFile.Segment.Data{ii}(:,this_extreme(1))','color',clist(tt,:));
        plot(nsFile.Segment.Data{ii}(:,this_extreme(end))','--','color',clist(tt,:));
    end
    leghandle=legend('upper extreme','lower extreme','location','best');
    lp=get(leghandle,'position');
    set(leghandle,'Position',[lp(1) lp(2)-.15 lp(3:4)]);
    %%% well, there is a legend still needed somewhere ...

    %plot first two components in a bigger window
    %     scrsz = get(0,'ScreenSize');
    %     bh=figure('Position',[(0.2*scrsz(4)) (0.2*scrsz(4)) (0.6*scrsz(4)) (0.6*scrsz(4))]);
    %     set(bh,'name','first two components of PCA','NumberTitle', 'off');
    %
    %     for t=1:length(NClusters)
    %         thiscluster=NClusters(t);
    %         plot(scores(find(nsFile.Segment.UnitID{ii}==thiscluster),1),scores(find(nsFile.Segment.UnitID{ii}==thiscluster),2),'.','color',clist(t,:));
    %         hold on
    %     end
    %     xlabel('first PC');
    %     ylabel('second PC');
    %     title('PCA')

    %%% plot the isi distribution to get a feeling for the regularity of
    %%% the units, to distinguish them from noise
    hisi=figure;
    set(hisi,'name','Interspike Intervals Distribution','NumberTitle', 'off');
    c=0;
    ax=[];
    for n=1:length(NClusters)
        c=c+1;
        isi=diff(nsFile.Segment.TimeStamp{ii}(find(nsFile.Segment.UnitID{ii}==n)))*1000;
        if isempty(isi)
            c=c-1;
            SpikesPerUnit=sum(nsFile.Segment.UnitID{ii}==n);
            if n==length(NClusters)
                title(sprintf('Unit %2i ',n));
                xlabel('interspike interval in ms');
                ylabel('counts');
            end
            continue;
        end
        edges=[0:1:max(isi)];
        isiPdf=histc(isi,edges);

        h(c)=subplot(length(NClusters),1,c);
        stairs(edges,isiPdf,'color',clist(n,:));
        set(gca,'TickDir','out');
        SpikesPerUnit=sum(nsFile.Segment.UnitID{ii}==n);
        ax(:,c)=axis;

        if c==1
            title({sprintf('distribution of interspike intervals of DataentityID %2i',...
                nsFile.Segment.DataentityIDs(ii));sprintf('Unit %2i  with %2i spikes in all',...
                n,SpikesPerUnit)});
        elseif n==length(NClusters)
            title(sprintf('Unit %2i with %2i spikes in all',n,SpikesPerUnit));
            xlabel('interspike interval in ms');
            ylabel('counts');
        else
            title(sprintf('Unit %2i with %2i spikes in all',n,SpikesPerUnit));
        end
    end
    if exist('ax','var')
        mhigh=max(ax([2,4],:),[],2);
        mlow=min(ax([1,3],:),[],2);
        linkaxes(h,'xy');
        axis([mlow(1) mhigh(1) mlow(2) mhigh(2)]);
    end
end

if savePlots
    %%f1= must be the figure handle which is to be printed
    fx=18;%8.5;
    fy=22;%8.5;
    pos=[10 10 fx fy];
    fac=pos(4)/pos(3);
    figure
    set(gcf,'color','w')
    set(gcf,'units','cent')
    set(gcf,'paperunits','cent')
    set(gcf,'papertype','a4letter')
    set(gcf,'position',pos)
    set(gcf,'paperpos',[ 3 3 pos(3) pos(4)])
    set(gcf,'inverthardcopy','off') % needed for 3d-axis (diagonal)

end


