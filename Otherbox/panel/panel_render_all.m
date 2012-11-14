function panel_render_all

% panel_render_all
%
% under some circumstances, rendering for a particular panel
% will become stale. make this call from the matlab prompt
% to re-render all panels, clearing any stale rendering.

% get all root children (potential figures)
cs = get(0, 'children')';

% for each
for c = cs
	
	% check is figure
	type = get(c, 'type');
	if ~strcmp(type, 'figure')
		continue
	end
	
	% get root panel
	p = panel(c, 'root');

	% render
	if ~isempty(p)
		render(p);
	end
	
end


