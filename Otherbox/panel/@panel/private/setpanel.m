function out = setpanel(p, P, panelroot, special)

% set a panel object from the panel reference
u = get(p.fig, 'UserData');

% if nothing there, create empty data object
if ~isfield(u, 'panel')
	u.panel.panels = {};
	u.panel.panelroot = [];
end

% if id unspecified, generate new unique id
if isempty(p.id)
	p.id = length(u.panel.panels) + 1;
	P.panel.id = p.id;
end

% lay it in to the UserData
u.panel.panels{p.id} = P;

% lay in root data
if nargin >= 3
	u.panel.panelroot = panelroot;
end

% handle special
if nargin >= 4
	switch special
		case 'createroot'
			u.panel.panelroot.rootpanelid = p.id;
	end
end

% lay in to figure
set(p.fig, 'UserData', u);

% return it
if nargout
	out = p;
end



