



%% SUBRENDER

function subrender(p, P, renderer, is_print_mode)



% get specific margin
if P.panel.axis
	margin = subsref(p, 'axismargin');
else
	margin = subsref(p, 'parentmargin');
end

% root has extra margin
if ~P.panel.parent
	rootmargin = subsref(p, 'rootmargin');
	margin = margin + rootmargin;
end

% expand
if numel(margin) == 1
	margin = margin * [1 1 1 1];
end

% get fractional margin
size_panel_mm = renderer.size_fig_mm .* renderer.into(3:4); % size in mm of the panel we're rendering into
margin_as_panel_frac = tofrac(margin, size_panel_mm, renderer.units);

% reduce "into" by margin
renderer.into(1:2) = renderer.into(1:2) ...
	+ margin_as_panel_frac(1:2) .* renderer.into(3:4);
renderer.into(3:4) = renderer.into(3:4) ...
	- margin_as_panel_frac(1:2) .* renderer.into(3:4) ...
	- margin_as_panel_frac(3:4) .* renderer.into(3:4);

% handle separately parent panels and axis panels
if P.panel.axis
	subrender_axis(p, P, renderer, is_print_mode);
else
	subrender_parent(p, P, renderer, is_print_mode);
end









%% SUBRENDER_AXIS
%
% function returns the amount of space this axis needs
% on each side (in mm) to render all its parts (labels,
% etc.) in addition, it does all the layout for those
% labels. returns margin as [l b r t].

function subrender_axis(p, P, renderer, is_print_mode)



% user may have cleared figure (e.g.) or otherwise deleted
% this axis, so fail silently if it's no longer present
if ~ishandle(P.panel.axis)
	return
end

% assume zero
margin = [0 0 0 0];

% do font characteristics
font = subsref(p, 'font');
h_title = get(P.panel.axis, 'title');
set([P.panel.axis h_title], ...
	'fontname', font.fontname, ...
	'fontsize', font.fontsize, ...
	'fontweight', font.fontweight);

% set axis position (or fail)
try
	set(P.panel.axis, 'position', renderer.into);
catch
	disp('WARNING (panel): failed to render an axis due to size limitations')
end

% modified
modified = false;

% do tick labels
for xy = 'xy'

	% get engineering scale mode
	eng_scale_mode = P.render_notinh.([xy 'scale']);

	% get specified ticklabels, if mode is manual
	specified_ticklabel = {};
	is_specified_ticklabel = false;
	if strcmp(get(P.panel.axis, [xy 'ticklabelmode']) , 'manual')
		specified_ticklabel = get(P.panel.axis, [xy 'ticklabel']);
		is_specified_ticklabel = true;
		if iscell(specified_ticklabel) && length(specified_ticklabel) && ischar(specified_ticklabel{end}) && strcmp(specified_ticklabel{end}, 'eng_scale_mode')
			% this is auto ticklabels, set below, so we ignore
			% them as "specified_ticklabel"
			is_specified_ticklabel = false;
		end
	end
	
	% get actual ticks (numbers) - panel does not allow the
	% user to set these, currently, so the values returned
	% here will be those manually set by the user using
	% set(gca, 'xtick', ...) or automatically set by matlab
	% based on the figure size
	tick = get(P.panel.axis, [xy 'tick']);
	
	% get tick mode so we know if the user wants these ticks
	% set manually, or automatically. we need to know this
	% because if we're preparing for print, we're going to
	% force them to manual for the duration so that they don't
	% get re-chosen by matlab during the export operation.
	tick_mode = get(P.panel.axis, [xy, 'tickmode']);
	
	% if we are printing, store that tick mode, and make sure
	% the current mode is manual. if not, restore the last
	% tick mode if present.
	if is_print_mode
		
		if ~isfield(P.panel.export, [xy 'tickmode'])
			P.panel.export.([xy 'tickmode']) = tick_mode;
		end
		set(P.panel.axis, [xy 'tick'], tick); % set to manual mode
		modified = true;
		
	else
		
		if isfield(P.panel.export, [xy 'tickmode'])
			tick_mode = P.panel.export.([xy 'tickmode']);
			if strcmp(tick_mode, 'auto')
				set(P.panel.axis, [xy 'tickmode'], 'auto');
			end
			P.panel.export = rmfield(P.panel.export, [xy 'tickmode']);
			modified = true;
		end
		
	end
	
	% assume no explicit ticklabels
	ticklabel = {};
	is_ticklabel = false;

	% if not using engineering scale mode, multiplier is unity
	if isempty(eng_scale_mode)

		mult = 1;

	else
		
		% take off suffix $
		suffix_tick_labels = any(eng_scale_mode == '$');
		eng_scale_mode = eng_scale_mode(eng_scale_mode ~= '$');

		% engineering scale mode should be now exactly one character
		if length(eng_scale_mode) ~= 1
			error(['error in scale argument "' eng_scale_mode '"']);
		end

		% engineering scale mode translation
		eng_scale_mode_list = 'yzafpnum kMGTPEZY';

		% handle auto scale char
		if eng_scale_mode == '?'

			% auto scale
			m = floor(log10(max(abs(tick))) / 3);
			m = m + 9;
			if m < 1 m = 1; end
			if m > length(eng_scale_mode_list) m = length(eng_scale_mode_list); end
			eng_scale_mode = eng_scale_mode_list(m);

		end

		% translate char to scale multiplier
		i = find(eng_scale_mode_list == eng_scale_mode);
		if isempty(i)
			error(['error in scale argument "' eng_scale_mode '"']);
		end
		mult = 1000 ^ (i - 9);

		% handle suffix
		if suffix_tick_labels
			suffix_tick_labels = eng_scale_mode;
		else
			suffix_tick_labels = '';
		end
		
		% get ticks, using factor
		tick = tick / mult;
 		for n = 1:length(tick)
 			ticklabel{n} = [sprintf('%g', tick(n)) suffix_tick_labels];
		end
		is_ticklabel = true;
		
		% convert to a recognisable, but equivalent, form, so we
		% can tell it's automatically set when we read it back
		ticklabel{end+1} = 'eng_scale_mode';

	end

	% override ticklabels with specifically set ones
	if is_specified_ticklabel
		ticklabel = specified_ticklabel;
		is_ticklabel = true;
	end
	
	% set ticklabel if specified, else set mode to auto
	if is_ticklabel
		set(P.panel.axis, [xy 'ticklabel'], ticklabel);
	else
		set(P.panel.axis, [xy 'ticklabelmode'], 'auto');
	end

	
	
	%% set x/y axis label
	
	% get current label string
	h = get(P.panel.axis, [xy 'label']);
	label = get(h, 'String');

	% reverse translation ("m" ==> "$")
	label = translatelabel(label);
	
	% forward translation ("$" ==> "k")
	label = translatelabel(label, eng_scale_mode);
	
	% now, do the forward replacement
	set(h, 'FontName', font.fontname, ...
				 'FontSize', font.fontsize, ...
				 'FontWeight', font.fontweight, ...
				 'string', label);

end

% modified
if modified
	setpanel(p, P);
end








%% SUBRENDER_PARENT

function subrender_parent(p, P, renderer, is_print_mode)

% user may have cleared figure (e.g.) or otherwise deleted
% the hiddenaxis, so fail silently if it's no longer present
if P.panel.hiddenaxis && ishandle(P.panel.hiddenaxis)

	% set axis position (or fail)
	try
		set(P.panel.hiddenaxis, 'position', renderer.into);
	catch
		disp('WARNING (panel): failed to render an axis due to size limitations')
	end
	
end

% if any child uses absolute positioning, all must
used_abs = false;
used_rel = false;
N = length(P.panel.children);
c = p;
C = {};
for n = 1:N
	c.id = P.panel.children(n);
	C{n} = getpanel(c);
	if isscalar(C{n}.panel.pack)
		used_rel = true;
	else
		used_abs = true;
	end
end
if used_rel && used_abs
	error('cannot use relative and absolute positioning amongst the children of a single panel');
end

% assign space to each of its children
if used_abs

	% do assignments
	renderer2 = renderer;
	for n = 1:N
		pack = tofrac(C{n}.panel.pack, renderer.size_fig_mm, renderer.units); % convert percentage to fraction
		packed = [];
		packed(1:2) = renderer.into(1:2) + pack(1:2) .* renderer.into(3:4);
		packed(3:4) = renderer.into(3:4) .* pack(3:4);
		c.id = P.panel.children(n);
		renderer2.into = packed;
		subrender(c, C{n}, renderer2, is_print_mode)
	end
	
end

if used_rel

	% convert edge to axis and end
	edges = 'lbrt';
	edge = find(P.render_inh.edge == edges);
	if isempty(edge)
		error(['unrecognised packing edge "' P.render_inh.edge '" (use l, r, t or b)']);
	end
	axs = [1 2 1 2];
	ax = axs(edge);
	eds = [1 1 2 2];
	ed = eds(edge);
	
% 	% ask each axis child to render (first pass)
% 	% maximise margins that match up (if packing on top or
% 	% bottom edge, that's the left and right margins, and vice
% 	% versa).
% 	max_margin = [0 0];
% 	margins = {};
% 	match_indices = {[2 4] [1 3]};
% 	for n = 1:N
% 		if C{n}.panel.axis
% 			margin = subrender_axis_first(c, C{n});
% 			margins{n} = margin;
% 			match_margin = margin(match_indices{ax});
% 			max_margin = max(max_margin, match_margin);
% 		else
% 			margins{n} = [0 0 0 0];
% 		end
% 	end
	
	% size in mm of the "into" space we're rendering into
	size_into_mm = renderer.size_fig_mm .* renderer.into(3:4);
	
	% assignments
	assignments = zeros(1,N);
	
	% assign to each child
	for n = 1:N
		pack = C{n}.panel.pack;
		assignments(n) = tofrac(pack, renderer.size_fig_mm(ax), renderer.units);
	end

	% divvy up remaining space
	n = find(assignments == 0);
	if ~isempty(n)
		S = sum(assignments);
		M = length(n);
		if S >= 1
			warning('no space left to divvy up');
		else
			assignments(n) = (1 - S) / M;
		end
	end

	% convert to scale of parent position
	assignments = assignments * renderer.into(ax + 2);

	% pack from near edge
	if ed == 1
		for n = 1:N
			renderer.into(ax + 2) = assignments(n);
			c.id = P.panel.children(n);
			subrender(c, C{n}, renderer, is_print_mode);
			renderer.into(ax) = renderer.into(ax) + assignments(n);
		end
	end
	
	% pack from far edge
	if ed == 2
		renderer.into(ax) = renderer.into(ax) + renderer.into(ax + 2);
		for n = 1:N
			renderer.into(ax) = renderer.into(ax) - assignments(n);
			renderer.into(ax + 2) = assignments(n);
			c.id = P.panel.children(n);
			subrender(c, C{n}, renderer, is_print_mode);
		end
	end
	
end





