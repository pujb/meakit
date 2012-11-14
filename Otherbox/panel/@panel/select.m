function ax_out = select(p, ax)

% select(p[, ax])
%
% make axis associated with this panel the active axis for
% plotting. if no axis is associated, create one if valid.
% that is, calling select on an "uncommitted" panel commits
% that panel as an "axis panel".
%
% if the axis to be associated with the panel has already
% been created (e.g. it is a special-purpose axis such as a
% colorbar), pass it in as the second argument, and the
% committed panel will be associated with the passed axis
% rather than create a new one of its own. this usage
% suggested by Arthur Ward.



P = getpanel(p);

if P.panel.axis

	% handle error
	if nargin == 2
		error('panel already associated with an axis');
	end
	
	% return existing axis
	set(0,'CurrentFigure',p.fig)
	ax = P.panel.axis;
	set(p.fig,'CurrentAxes',ax);

else

	% illegal if already has children
	if ~isempty(P.panel.children)
		error('cannot associate axis with panel that already has child panels');
	end

	% select figure
	set(0,'CurrentFigure',p.fig)
	
	% was axis supplied?
	if nargin < 2
	
		% no, create axis
		ax = axes('fontname', subsref(p,'fontname'), 'fontsize', subsref(p,'fontsize'));
		
	end
	
	% make axis current
	set(p.fig,'CurrentAxes',ax);
	
	% associate panel with axis
	P.panel.axis = ax;
	setpanel(p, P);

end

% return axis handle
if nargout
	ax_out = ax;
end

% autorender
if subsref(p, 'autorender')
	q = p;
	ud = get(p.fig, 'UserData');
	q.id = ud.panel.panelroot.rootpanelid;
	render(q)
end


