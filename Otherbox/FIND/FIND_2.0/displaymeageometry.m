function fighandle=displaymeageometry(geometry,unitid,name)
% Displays MEA geometries with unitID and names.
%
% uses cellarray {hardwareIDs, electrode names, xpos, ypos} as created by
% getmeageometry
%
% fighandle=displaymeageometry(geometry)
%
% M. Nenniger 2009
% find.bccn.uni-freiburg.de


figure;
plot(geometry{3}(:),geometry{4}(:),'.');
for ii=1:length(geometry{1})
    text(geometry{3}(ii),geometry{4}(ii),strcat(geometry{1}{ii},':',geometry{2}{ii}),'horizontalalignment','center');
end

%format plot
myxlim=get(gca,'xlim');
myylim=get(gca,'ylim');
xlim([-diff(myxlim)*.1+myxlim(1) diff(myxlim)*.1+myxlim(2)]);
ylim([-diff(myylim)*.1+myylim(1) diff(myylim)*.1+myylim(2)]);
axis off