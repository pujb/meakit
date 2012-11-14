function p = panel(varargin)

% p = panel(...)
%
% construct a panel as the root panel of the current figure,
% destroying any existing panels associated with that
% figure. any axes associated with those existing panels are
% also destroyed.
%
% p = panel(fig, ...)
%
% as above, but for a specified figure.
%
% c = panel(..., [m n], sm, sn)
%
% pack the new panel with a grid of m by n child panels (see
% panel/pack() for more details - sm and sn are optional extra
% arguments to pack()).



%	NOT USER HELP
%
% p = panel(fig, 'root')
%
% the root panel associated with that figure is returned
% (rather than generating a new one that overwrites existing
% ones) - this is used by panel_resizefcn and panel_render_all



% IMPLEMENTATION NOTES
%
% due to the idiosyncrasies of matlab's OO implementation,
% it is not possible to generate a true object that honors
% a sensible syntax yet allows full object functionality.
% specifically, member functions cannot operate on the
% object itself, only on a copy of it, so a call such as:
%
%   ax = panel.axis
%
% cannot affect the state of the object "panel". to get
% round this, this implementation stores all data in the
% UserData of the targeted figure, and only stores a
% reference to that data in the object itself. for the
% sake of code brevity, it is not possible (sort of
% therefore) to delete a panel object, only to discard a
% reference to it. this is not a problem.




%% SPECIAL CASE (MATLAB OO): single panel object argument
%% should just be returned

if nargin == 1 && isa(varargin{1}, 'panel')
	
	% return single argument
	p = varargin{1};
	
	% ok
	return
	
end



%% CREATE EMPTY PANEL REFERENCE

% create empty
p = [];
p.fig = [];
p.id = [];

% make it a class
p = class(p, 'panel');



%% IF FIGURE SUPPLIED: attach to that figure, otherwise
%% leave unattached (necessary, since OO implementation may
%% call panel with no arguments to see what a default panel
%% object looks like, and we don't want this call to create
%% a spurious figure window).

args = varargin;

if nargin >= 1 && isnumeric(args{1}) && isscalar(args{1}) && ishandle(args{1}) && strcmp(get(args{1}, 'type'), 'figure')
	
	p.fig = args{1};
	args = args(2:end);
	
else
	
	p.fig = get(0, 'CurrentFigure');
	if isempty(p.fig)
		p.fig = 0;
		
		% if no figure, any additional arguments is an error
		if nargin
			error('not expecting arguments since panel is not attached to a figure');
		end
		
		% so we can safely return now
		return
	end
	
end



%% return root panel, if it exists

if nargin == 2 && p.fig && ischar(args{1}) && strcmp(args{1}, 'root')
	
	% get user data
	ud = get(p.fig, 'UserData');
	
	% get panel data
	if ~isfield(ud, 'panel')
		p = [];
		return;
	end
	
	% get root panel associated with figure
	p.id = ud.panel.panelroot.rootpanelid;
	
	% check it's there
	if isempty(ud.panel.panels{p.id})
		p = [];
		return
	end
	
	% ok
	return
	
end



%% DELETE EXISTING PANELS

% get root panel
q = panel(p.fig, 'root');

% delete it
if ~isempty(q)
	delete(q);
end





%% CREATE PANEL OBJECT

% get user data
ud = get(p.fig, 'UserData');

% create panel object
[P, panelroot] = default;

% create new root panel
p = setpanel(p, P, panelroot, 'createroot');

% and lay in the resize function
set(p.fig, 'ResizeFcn', @panel_resizefcn)





%% HANDLE REMAINING ARGUMENTS

if ~isempty(args)
	
	% first must be 1x2 numeric
	sz = size(args{1});
	if length(sz) ~= 2 || ~all(sz == [1 2]) || ~isnumeric(args{1})
		error('invalid call to panel() - first supplemental argument must be grid layout size [m n]');
	end
	
	% if figure not specified, this can't work
	if ~p.fig
		error('invalid call to panel() - cannot create sub-panels since parent panel has no figure associated');
	end
	
	% pack sub-panels
	p = pack(p, args{:});
	
end





