function [P, panelroot] = getpanel(p)

% get a panel object from the panel reference
u = get(p.fig, 'UserData');
if ~isfield(u, 'panel')
	error(['panel reference no longer valid -  "' int2str(p.id) '" not found in figure "' num2str(p.fig) '" (was associated figure closed/reopened?)'])
end

% extract
if length(u.panel.panels) >= p.id
	P = u.panel.panels{p.id};
	if isempty(P)
		error('panel no longer exists - this is a hanging reference')
	end
	panelroot = u.panel.panelroot;
	return
end

% else error
error(['panel "' int2str(p.id) '" not found in figure "' num2str(p.fig) '"'])
