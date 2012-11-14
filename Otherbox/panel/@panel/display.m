function display(p)

% disp([10 'panel: (' num2str(p.fig) ', ' int2str(p.id) ')' 10])

disp([10 '(Panel Object, id ' int2str(p.id) ')'])

if isnumeric(p.fig) && isscalar(p.fig) && ishandle(p.fig) && strcmp(get(p.fig,'type'), 'figure')

	if ~isempty(p.id)
	
		[P, panelroot] = getpanel(p);
		
		if isempty(P)
			error('panel no longer exists - this is a hanging reference')
		end

		sect('Root Panel Properties');
		disp(panelroot)

		sect('Panel Structural Properties');
		disp(P.panel)

		sect('Panel Rendering Properties (* indicates inherited)');
		f = fieldnames(P.render_inh);
		for i = 1:length(f)
			key = f{i};
			val = P.render_inh.(key);
			skey = [repmat(' ', 1, 14-length(key)) key];
	% 		switch key
	% 			case 'axismargin'
	% 				sval = 'asd';
	% 			case 'parentmargin'
	% 				sval = 'asd';
	% 			case 'edge'
	% 				sval = 'asd';
	% 			case 'fontname'
	% 				sval = 'asd';
	% 			case 'fontsize'
	% 				sval = 'asd';
	% 			case 'fontweight'
	% 				sval = 'asd';
	% 			otherwise
	% 				error(['uncoded field "' key '"'])
	% 		end
			if isnumeric(val)
				sval = ['[ ' sprintf('%0i ', val) ']'];
			else
				sval = ['''' val ''''];
			end
			if isempty(val)
				sval = [''];
				ival = subsref(p, key);
				if isnumeric(ival)
					sval = [sval '[ ' sprintf('%0i ', ival) ']'];
				else
					sval = [sval '''' ival ''''];
				end
% 				sval = [sval ' *'];
				disp([skey ': (*) ' sval])
			else
				disp([skey ':     ' sval])
			end
		end

		sect('Panel Rendering Properties (non-inherited properties)');
		disp(P.render_notinh)

		disp(' ')
		
	else
		
		warning('panel is attached to a figure, but not to a root panel of that figure');
		
	end
	
else
	
	warning('panel is not attached to a figure, or figure no longer exists')
	disp(' ')
	
end


function sect(msg)

disp(' ')
disp([msg ':'])
% disp('________________________________');
% disp(' ')
