function out=colorselect()
ch=get(gcf,'Children');
col=get(ch,'Currentpoint');
col=round(col(1));
mymap=colormap;
figure;plot(1:10,'Color',mymap(col,:))
close(gcf)
end