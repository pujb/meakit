function val = subsref(p, s)



%% extract panel

% extract panels array
userData = get(p.fig, 'UserData');
if ~isfield(userData, 'panel')
	error(['panel reference no longer valid -  "' int2str(p.id) '" not found in figure "' num2str(p.fig) '" (was associated figure closed/reopened?)'])
end
panels = userData.panel.panels;

% get panel by id (index)
try
	P = panels{p.id};
catch
	error(['panel "' int2str(p.id) '" not found in figure "' num2str(p.fig) '"'])
end

% check exists
if isempty(P)
	error('panel no longer exists - this is a hanging reference')
end



%% handle special internal subsref syntax

if ischar(s)
	s = struct('type', '.', 'subs', s);
end



%% handle simple property calls separately

% simple char field subsref
switch s(1).type
	
	case '.'
	
		key = s(1).subs;
		
		switch key

			% associated figure
			case 'figure'

				val = p.fig;
				

				
			% associated axis
			case 'axis'

				val = P.panel.axis;
				

				
			% inherited properties (that have units)
			case {'axismargin' 'parentmargin'}

				% inherit
				while 1
					val = P.render_inh.(key);
					if isempty(val)
						if P.panel.parent
							% inherit
							P = panels{P.panel.parent};
							continue
						else
							% default
							val = get_default(key);
						end
					end
					break
				end

				% convert to interface units (all values stored in mm)
				switch subsref(p, 'units')
					case 'mm'
						% no change
					case 'cm'
						val = val / 10;
					case 'in'
						val = val / 25.4;
				end

				
				
			% inherited properties (that do not have units)
			case {'edge', 'fontname', 'fontsize', 'fontweight'}

				% inherit
				while 1
					val = P.render_inh.(key);
					if isempty(val)
						if P.panel.parent
							% inherit
							P = panels{P.panel.parent};
							continue
						else
							% default
							val = get_default(key);
						end
					end
					break
				end

				
				
			% quick call used by subrender to get all font characteristics at once
			case {'font'}

				val = [];
				val.fontname = P.render_inh.fontname;
				val.fontsize = P.render_inh.fontsize;
				val.fontweight = P.render_inh.fontweight;
				
				% inherit
				while 1
					
					% gone far enough
					if ~isempty(val.fontname) && ~isempty(val.fontsize) && ~isempty(val.fontweight)
						break
					end
					
					% else, seek parent
					if P.panel.parent
						
						% inherit
						P = panels{P.panel.parent};
						
						% extract
						val_inh = P.render_inh;
						
					else
						
						% default
						val_inh = get_default;
						
					end
					
					% merge
					if isempty(val.fontname)
						val.fontname = val_inh.fontname;
					end
					
					% merge
					if isempty(val.fontsize)
						val.fontsize = val_inh.fontsize;
					end
					
					% merge
					if isempty(val.fontweight)
						val.fontweight = val_inh.fontweight;
					end
					
				end
				
				
				
			% properties that are *not* inherited
			case {'xscale', 'yscale'}
				
				val = P.render_notinh.(key);
				
				
			
			% properties of the root panel (that have units)
			case {'rootmargin'}

				val = userData.panel.panelroot.(key);
				if isempty(val)
					val = get_default(key);
				end

				% convert to interface units (all values stored in mm)
				switch subsref(p, 'units')
					case 'mm'
						% no change
					case 'cm'
						val = val / 10;
					case 'in'
						val = val / 25.4;
				end

				
				
			% properties of the root panel (that do not have units)
			case {'autorender' 'units' 'print'}

				val = userData.panel.panelroot.(key);
				if isempty(val)
					val = get_default(key);
				end

				
				
			% wrapped properties (stored in children of axis)
			case {'xlabel', 'ylabel', 'title'}
				
				if P.panel.axis
					val = get(get(P.panel.axis, key), 'string');
					val = translatelabel(val);
				else
					error(['evaluation of "' key '" failed because panel is not committed as an axis panel']);
				end
				
				
				
			% wrapped properties (stored in axis)
			case {'xticklabel', 'yticklabel', 'xtick', 'ytick'}
				
				if P.panel.axis
					val = get(P.panel.axis, key);
				else
					error(['evaluation of "' key '" failed because panel is not committed as an axis panel']);
				end				
				
				
				
			% panel's children
			case 'children'
				
				val = {};
				for c = 1:length(P.panel.children)
					p.id = P.panel.children(c);
					val{c} = p;
				end
				
				
			
			% select panel (commit as axis panel)
			case 'select'
				
				if length(s) == 2 && strcmp(s(2).type, '()')
					val = select(p, s(2).subs{:});
					s = s(1);
				else
					val = select(p);
				end
				
				
				
			% (re)render panel	
			case 'render'
				
				if length(s) ~= 1
					error('invalid usage (render() takes no arguments)');
				end
				render(p);
				
				
			% pack panel
			case 'pack'
				
				if length(s) ~= 2 || ~strcmp(s(2).type,'()')
					error('invalid usage (pack() requires arguments)');
				end
				val = pack(p, s(2).subs);
				s = s(1);
				
				

			% get panel's parent panel
			case 'parent'
				
				if P.panel.parent
					p.id = P.panel.parent;
					val = p;
				else
					val = []; % no parent, because is root panel
				end
				
				
				
			% get panel's root panel	
			case 'root'
				
				if P.panel.parent
					p.id = P.panel.parent;
					val = subsref(p, 'root');
				else
					val = p; % is root
				end
				
				
			
			% export panel as figure
			case 'export'
				
				if length(s) ~= 2 || ~strcmp(s(2).type,'()')
					error('invalid usage (export() requires arguments)');
				end
				export(p, s(2).subs{:});
				s = s(1);
				
				
				
			% else unrecognised
			otherwise
		
				error(['unrecognised field reference "' s(1).subs '"']);
				
				
				
		end

		
		
	% else unrecognised
	otherwise
		
		error(['unrecognised operation "' s(1).type '"']);
		
end







%% delegate further subsref'ing

if length(s) > 1
	val = subsref(val, s(2:end));
end





%% defaults function

function val = get_default(key)

% all margins are % [l/b r/t] or [l b r t],
% like ordering to [x y w h] for abs
% positioning

default = [];
default.autorender = true;
default.units = 'mm';
default.rootmargin = [0 0 5 5];
default.axismargin = [15 15 0 0];
default.parentmargin = [0 0 0 0];
default.edge = 't';
default.fontname = 'arial';
default.fontsize = 10;
default.fontweight = 'normal';

if nargin
	val = default.(key);
else
	val = default;
end


