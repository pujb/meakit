
%% PANEL DEMO 9
%%
%% (a) Create an empty panel object
%% (b) Packing a grid of panels into a parent panel
%% (c) Plotting into multiple panels
%% (d) Selecting a panel using an existing axis

%% This extended usage of panel.select() was suggested by Arthur
%% Ward.



%% (a)

% clear or create figure and create root panel covering
% whole figure
clf
p = panel;
p.fontsize = 12;



%% (b)

% add a panel at the right hand side for the colorbar
p.edge = 'r';
p_bar = p.pack(12);

% add four more panels - note that we can pack a regular
% grid of panels into the remaining space of root panel "p",
% after the bar has taken up 12% of the space at one side.
p_fig = p.pack([2 2], 25, 30);



%% (c)

% create test data
L = 50;
[x, y] = meshgrid(L:-1:1);

% create axes for figure panels
for i = [1 2 4 3]
	z = x.^2 + y.^2;
	z = z / max(max(z));
	select(p_fig{i})
	imagesc(z);
	x = rot90(x);
	y = rot90(y);
	set(p_fig{i}.axis, 'xtick', [], 'ytick', []);
end

% don't need such big margins for most of that
p.axismargin = [5 5 0 0];



%% (d)

% create a colorbar on figure
c = colorbar;

% commit side panel as axis panel, using that colorbar
% rather than an axis it creates itself
p_bar.select(c);

% reposition it a bit, since colorbar draws its ticks on the
% opposite side to usual - add 5mm to right-side margin
p_bar.axismargin = [5 5 5 0];

% change colormap
colormap hot


