function q = pack(p, varargin)

% q = pack(p, varargin)
%
% pack a new panel, q, into an existing panel, p. q can be
% packed "relatively", in which case it takes up some of p
% along the edge specified in "p.edge", and the amount of
% space it takes up away from that edge is specified (either
% as a percentage or as an absolute value). or, q can be
% packed "absolutely", in which case you specify it's absolute
% positioning within p in your desired units.
%
% arguments may include, in any order:
%
% 'mm', 'in', 'cm', '%': specify units to use when
%   interpreting numeric packing argument (default '%').
%
% [<numeric>]: (scalar numeric) amount of parent panel to
%   use for child panel (e.g. [50] to use half, assuming
%   percentage packing).
%
% [<numeric>]: (1x4 numeric) amount of parent panel to use
%   for child panel, specified in absolute terms as [l b w h].
%
% [<numeric>]: (1x2 numeric) [m n] pack a regular grid of m
%   x n sub-panels into the parent panel. the m x n panels
%   are returned in a cell array in q. in this case, two
%   optional further numeric arguments are accepted, being
%   the vector of sizes of rows and columns, respectively.
%   either can have as few as zero elements, if it is not
%   desired to specify all sizes (remaining sizes are left
%   unspecified, see below).
%
% note that, when using percentage packing, numbers between
% 0 and 1 are automatically interpreted as fractions, rather
% than percentages (i.e. they are multiplied by 100 before
% use).
%
% if amount of parent panel is not specified, the panel is
% left as a "stretchable" panel. during rendering, remaining
% free space is shared out amongst all stretchable panels.



% CHANGE: 23/08/10
% old syntax was q = pack(p, args), with args a cell array.
% this is to make this function easy to call from subsref
% (for the syntax p.pack(...)). i've changed it to the more
% conventional form given above. so that those old calls
% don't stop working, this code handles the cell array form.
if nargin == 2 && iscell(varargin{1})
	args = varargin{1};
else
	args = varargin;
end



% check subject panel is, or can be, a parent panel (i.e.
% has not been committed as an axis panel)
P = getpanel(p);
if P.panel.axis
	error('cannot pack into panel that has already been committed an axis');
end

% default arguments
form = '';
mode = '?';
packing = [];
smn = {};
sm = [];
sn = [];
flags = 'sf';



% interpret arguments
for n = 1:length(args)
	
	% extract arg
	arg = args{n};
	sz = size(arg);
	if length(sz) > 2
		error('multi-dimensional argument unrecognised');
	end
	
	% form
	if ischar(arg) && ischar(getform(arg))
		if ~isempty(form)
			error('units specified more than once');
		end
		form = getform(arg);
		continue
	end
	
	% packing
	if isnumeric(arg)
		if mode == 'g'
			if length(smn) == 2
				error('too many numeric arguments');
			end
			smn{end+1} = arg;
			continue;
		end
		if isscalar(arg)
			if mode ~= '?'
				error('packing specified more than once');
			end
			mode = 'r'; % relative
			packing = arg;
			continue;
		elseif all(sz == [1 4])
			if mode ~= '?'
				error('packing specified more than once');
			end
			mode = 'a'; % absolute
			packing = arg;
			continue;
		elseif all(sz == [1 2])
			if mode ~= '?'
				error('packing specified more than once');
			end
			mode = 'g'; % grid
			packing = arg;
			continue;
		end
	end
	
	% unrecognised
	disp(arg)
	error('unrecognised argument above')
	
end



% default arguments
if isempty(form)
	form = '%';
end
if mode == '?'
	mode = 'r';
	packing = 0; % zero means auto-pack
end
if length(smn) >= 1
	sm = smn{1};
end
if length(smn) >= 2
	sn = smn{2};
end



% switch on mode
switch mode
	
	case {'r' 'a'}
		
		% if this is the parent's first child, we need to create
		% the parent's axis (this is not displayed, but is used
		% if the user asks for the parent to have xlabel and
		% ylabel)
		if isempty(P.panel.children)
			P.panel.hiddenaxis = axes('visible', 'off', 'xtick', [], 'ytick', []);
		end
		
		% create child object
		Q = default;
		Q.panel.parent = p.id;
		Q.panel.pack = storeform(packing, form, flags);
		
		% create child reference
		q = p;
		q.id = [];
		
		% add child to figure
		q = setpanel(q, Q);
		
		% add child to parent
		P.panel.children(end+1) = q.id;
		setpanel(p, P);
		
	case 'g'
		
		% access
		m = packing(1);
		n = packing(2);
		
		% parent panel may already have some content - depending
		% on if it's packing on a top/bottom or a left/right
		% edge, we use slightly different code, so that rows and
		% columns are interpreted correctly.
		edge = subsref(p, 'edge');
		
		% switch on edge
		switch edge
			case 'l'
				col_first = true;
				flip = false;
			case 'r'
				col_first = true;
				flip = true;
			case 't'
				col_first = false;
				flip = false;
			case 'b'
				col_first = false;
				flip = true;
		end
		
		% left/right
		if col_first
			
			% handle flip
			if flip
				ins = n:-1:1;
			else
				ins = 1:n;
			end

			% for each strip
			for in = ins

				% pack strip
				if length(sn) >= in
					p_strip = pack(p, sn(in));
				else
					p_strip = pack(p);
				end

				% set strip to pack on orthogonal edge
				subsasgn(p_strip, 'edge', 't');

				% for each cell
				for im = 1:m

					% pack cell
					if length(sm) >= im
						p_cell = pack(p_strip, sm(im));
					else
						p_cell = pack(p_strip);
					end

					% store
					q{im, in} = p_cell;

				end

			end

		% top/bottom
		else
			
			% handle flip
			if flip
				ims = m:-1:1;
			else
				ims = 1:m;
			end

			% for each strip
			for im = ims

				% pack strip
				if length(sm) >= im
					p_strip = pack(p, sm(im));
				else
					p_strip = pack(p);
				end

				% set strip to pack on orthogonal edge
				subsasgn(p_strip, 'edge', 'l');

				% for each cell
				for in = 1:n

					% pack cell
					if length(sn) >= in
						p_cell = pack(p_strip, {sn(in)});
					else
						p_cell = pack(p_strip, {});
					end

					% store
					q{im, in} = p_cell;

				end

			end

		end
		
end


