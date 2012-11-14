%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sub function to plot clustering results
%
function [max_idx, h] = k_means_plot_clusters(DataMatrix, pbm, all_idx, posEntityIDs)
    
    global nsFile;

    %plot pbm index
    h(1)=figure; hold on;
    set(h(1),'name','PBM-Index','NumberTitle', 'off');
    plot(pbm, '*-');
    title('PBM value, maximal for best clustering');
    xlabel('number of clusters','FontSize',14);
    ylabel('arbitrary units','FontSize',14);
    set(gca,'FontSize',14);

    max_idx=all_idx(:,pbm==max(pbm));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %plot all wave forms and their mean 
    temp_UClusters=unique(floor(max_idx));
    Cmap=hsv(length(temp_UClusters)+1);     %+1 to be consistent with sortSpikes.m

    h(3)=figure;
    NsubplotsX=ceil(sqrt(length(temp_UClusters)));
    NsubplotsY=round(sqrt(length(temp_UClusters)));
    set(h(3),'name','AllSpikesPotentialClusters','NumberTitle', 'off');
%     set(h(3),'name','AllSpikesPotentialClusters','Position',[230,678,560,420],'NumberTitle', 'off');

    posAnalogEntityIDs=find(nsFile.Analog.DataentityIDs==nsFile.Segment.DataentityIDs(posEntityIDs));
    time2plot=0:(size(DataMatrix,1)-1);
    if isempty(posAnalogEntityIDs)  
        posAnalogEntityIDs=0;
    else 
        time2plot=time2plot/nsFile.Analog.Info(posAnalogEntityIDs).SampleRate;
    end

    ah=zeros(length(temp_UClusters),1);
    for rr=1:length(temp_UClusters)
        ah(rr)=subplot(NsubplotsY,NsubplotsX,rr);
        curCluster = find(max_idx==temp_UClusters(rr));
        plot(time2plot,DataMatrix(:,curCluster),'Color',Cmap(rr,:));
        hold on;
        ph=plot(time2plot,mean(DataMatrix(:,curCluster),2),'--','Color','k','LineWidth',2);
        hold off;
        axis tight;
        ax(:,rr)=axis;

        if rr==1
            title({'All Spikes per Unit',sprintf('UnitID %i (#%i)',temp_UClusters(rr),length(curCluster))});
        else
            title(sprintf('UnitID %i (#%i)',temp_UClusters(rr),length(curCluster)));
        end
        set(gca,'FontSize',8)
        if rr==(length(temp_UClusters)-NsubplotsX+1) % left hand bottom plot
            if posEntityIDs && isfield(nsFile.Analog.Info,'Units') && posAnalogEntityIDs
                ylabel(['Voltage [' nsFile.Analog.Info(posAnalogEntityIDs).Units ']']);
                if posEntityIDs && isfield(nsFile.Analog.Info,'Units')&& ~isempty(nsFile.Analog.Info(posEntityIDs).Units)
                    ylabel(['Voltage [' nsFile.Analog.Info(posEntityIDs).Units ']'],'FontSize',8);
                else
                    ylabel('Voltage [unknown units]','FontSize',8);
                end
            end
            if posAnalogEntityIDs
                xlabel( 'time (s)','FontSize',8)
            else
                xlabel('Samples','FontSize',8);
            end
        end
    end
    mhigh=max(ax([2,4],:),[],2);
    mlow=min(ax([1,3],:),[],2);
    linkaxes(ah,'xy');
    axis([time2plot(1) time2plot(end) mlow(2) mhigh(2)]);
    
end  % plot_clusters
