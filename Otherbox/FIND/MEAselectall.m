function MEAselectall()
boxes=findobj(gcf,'Style','checkbox');
for ii=1:length(boxes)
    if strcmp(get(boxes(ii),'enable'),'on')
        set(boxes(ii),'Value',1);
        setselectedentityID(boxes(ii));
    end
end