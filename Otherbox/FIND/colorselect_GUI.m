function out=colorselect_GUI(defaultC)
out=defaultC;
figure('menubar','none','NumberTitle','off',...
    'toolbar','none','Name','pick a color');
imagesc(1:64);
set(gca,'Position',[0.00001 0.00001 1 1]);
axis off
col=ginput(1);
col=round(col(1));
mymap=colormap;
close(gcf);
out=mymap(col,:);
end

