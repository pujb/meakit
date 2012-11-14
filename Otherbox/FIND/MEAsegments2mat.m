function outmat=MEAsegments2mat(nsFile,entityIDs,MEAmap,idxsegment,segmentstart,segmentend)
mapsize=size(MEAmap);
for ii=1:mapsize(1)
    for jj=1:mapsize(2)
        if ismember(MEAmap(ii,jj),entityIDs)
            tmpidx=find(MEAmap(ii,jj)==nsFile.Segment.DataentityIDs);
            if isempty(tmpidx)
                error('data not found in nsFile, please load data first')
            end
            outmat(ii,jj,:)=nsFile.Segment.Data{tmpidx}(segmentstart:segmentend,idxsegment);
        end
    end
end