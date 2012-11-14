
%% PANEL DEMO 8
%%
%% (a) Create a grid of panels all at once
%% (b) Plotting into those panels, setting axis labels



%% (a)

% clear or create figure and create a grid of panels covering
% whole figure - you needn't supply the last two arguments,
% in which case you'll get a regular grid of panels
clf
p = panel(gcf, [3 2], [50 20], [40]);
p_root = p{1}.root;
p_root.fontsize = 12;



%% (b)

% plot into all those panels to show that they are real
cols = 'brmbrm';
for i = 1:6
	select(p{i})
	plot(randn(100,1), cols(i));
	p{i}.xlabel = 'time (s)';
	p{i}.ylabel = ['my data ' int2str(i)];
end
