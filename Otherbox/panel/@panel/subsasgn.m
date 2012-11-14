function p = subsasgn(p, s, val)

if ischar(s)
	s = struct('type','.','subs',s);
end

switch s(1).type
	
	case '.'
		
		key = s(1).subs;
		[P, panelroot] = getpanel(p);
	
		switch key
			
			case 'fontsize'
				
				% must be right
				if ~isnumeric(val) || ~isscalar(val) || val < 1 || val > 100
					error('invalid value for "fontsize"');
				end
				
				P.render_inh.fontsize = val;
				setpanel(p, P);
			
			case {'fontname' 'fontweight'}
				
				if ~ischar(val) || (ndims(val)~=2) || (size(val,1)~=1)
					error(['invalid value for "' key '"']);
				end
				
				P.render_inh.(key) = val;
				setpanel(p, P);
			
			case 'edge'
				
				% must be right
				if ~ischar(val) || ~isscalar(val) || ~any(val == 'lrtb')
					error('invalid value for "edge"');
				end
				
				P.render_inh.edge = val;
				setpanel(p, P);
			
			% margins must be translated into mm for storage
			case {'axismargin' 'parentmargin'}
				
				if any(val<0)
					error('Negative values for margins are not allowed');
				end
				u = subsref(p, 'units');
				switch u
					case 'mm'
						% no change
					case 'cm'
						val = val * 10;
					case 'in'
						val = val * 25.4;
				end
				P.render_inh.(key) = val;
				setpanel(p, P);
				
			% properties that are *not* inherited
			case {'xscale', 'yscale'}
				
				if isscalar(val) && islogical(val) && ~val
					val = '';
				else
					% may be "?$"
					dol = '';
					if ischar(val) && ndims(val) == 2 && all(size(val) == [1 2]) && val(2) == '$'
						val = val(1);
						dol = '$';
					end
					if ~isscalar(val) || ~any(val == 'yzafpnum kMGTPEZY?')
						error(['invalid value for "' key '"']);
					end
					val = [val dol];
				end
				P.render_notinh.(key) = val;
				setpanel(p, P);
				
			% recursive properties
			case {'xlabels', 'ylabels', 'xticklabels', 'yticklabels', 'xticks', 'yticks', 'titles'}
				
				if ~isempty(P.panel.children)
					c = subsref(p, 'children');
					for n = 1:length(c)
						subsasgn(c{n}, key, val);
					end
				elseif P.panel.axis
					subsasgn(p, key(1:end-1), val);
				end
				
			% wrapped properties
			case {'xlabel', 'ylabel', 'title'}
				
				if P.panel.axis
					% it's an axis panel
					set(get(P.panel.axis, key), 'string', val);
				else
					% it's a parent panel - create as children of
					% hiddenaxis
					set(get(P.panel.hiddenaxis, key), 'string', val, 'visible', 'on');
% 					error(['assignment of "' key '" failed because panel is not committed as an axis panel']);
				end
				
			% wrapped properties
			case {'xticklabel', 'yticklabel', 'xtick', 'ytick'}
				
				if P.panel.axis
					% if val is false, set mode to auto
					if isscalar(val) && islogical(val) && ~val
						set(P.panel.axis, [key 'mode'], 'auto');
					else
						set(P.panel.axis, key, val);
					end
				else
					error(['assignment of "' key '" failed because panel is not committed as an axis panel']);
				end
			
			% root properties
			case {'autorender' 'units' 'rootmargin' 'print'}
				
				if P.panel.parent
					error(['the property "' key '" is only of the root panel']);
				end
				
				switch key
					case {'autorender' 'print'}
						if ~islogical(val) || ~isscalar(val)
							error(['invalid value for "' key '"']);
						end
					case 'units'
						switch val
							case {'mm', 'in', 'cm'}
								% ok
							otherwise
								error(['invalid value for "' key '"']);
						end
					case {'rootmargin'}
						if any(val<0)
							error('Negative values for margins are not allowed');
						end
						u = subsref(p, 'units');
						switch u
							case 'mm'
								% no change
							case 'cm'
								val = val * 10;
							case 'in'
								val = val * 25.4;
						end
				end
				
				panelroot.(key) = val;
				setpanel(p, P, panelroot);

				
				
			% get panel's root panel	
			case 'root'
				
				if P.panel.parent
					q = p;
					q.id = P.panel.parent;
					val = subsasgn(q, s, val);
				else
					val = subsasgn(p, s(2:end), val);
				end
			
				
				
				
			otherwise
				error(['unrecognised subsasgn "' s(1).subs '"']);
			
		end
	
end


% autorender
if subsref(p, 'autorender')
	q = p;
	ud = get(p.fig, 'UserData');
	q.id = ud.panel.panelroot.rootpanelid;
	render(q)
end
