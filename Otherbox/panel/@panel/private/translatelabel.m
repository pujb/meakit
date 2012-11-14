function s = translatelabel(s, eng_scale_mode)

% user can insert "$" character to be replaced by
% engineering scale mode character. if it's already been
% replaced, it's been replaced by {{{x}}}, which renders
% just as "x" since it's latex-interpreted. therefore, we
% can start by changing strings of this type back to "$".
% note that if the mode is '', then x is the empty string.

if nargin == 1
	
	if iscell(s)
		for i = 1:length(s)
			s{i} = translatelabel(s{i});
		end
		return
	end
	
	% reverse translation
	s = strrep(s, '{{{}}}', '{{{ }}}'); % handle empty string case
	l = length(s);
	f = strfind(s, '{{{');
	for i = f
		if (l - i) < 6
			continue
		end
		if ~strcmp(s(i+(4:6)), '}}}')
			continue
		end
		s(i:i+6) = '{{{$}}}';
	end
	s = strrep(s, '{{{$}}}', '$');
	
else

	if iscell(s)
		for i = 1:length(s)
			s{i} = translatelabel(s{i}, eng_scale_mode);
		end
		return
	end

	% forward translation
	if any(s == '$')
		if eng_scale_mode == 'u'
			eng_scale_mode = '\mu';
		end
		s = strrep(s, '$', ['{{{' eng_scale_mode '}}}']);
	end
	
end
