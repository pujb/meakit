function MEAunselectall()
boxes=findobj(gcf,'Style','checkbox')
for ii=1:length(boxes)
    if strcmp(get(boxes(ii),'enable'),'on')

        set(boxes(ii),'Value',0)
        setselectedentityID(boxes(ii))
    end
end