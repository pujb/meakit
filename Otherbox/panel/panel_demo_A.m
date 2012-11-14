
%% PANEL DEMO A
%%
%% (a) Create an axis panel object and plot something
%% (b-g) Illustrate various tick label modes



%% (a)

% clear or create figure and create root panel covering
% whole figure
clf
p = panel;
select(p);

% plot a graph
plot(randn(1000,1));
axis([0 1000 -3 3])



%% (b)

% ok
disp('Default (automatic tick labelling)');
pause(1)



%% (c)

% change to engineering scale mode
p.xscale = 'k';
p.xlabel = '$sample';

% ok
disp('Engineering scale mode (kilo prefix)');
pause(1)



%% (d)

% change scale
p.xscale = 'm';

% ok
disp('Engineering scale mode (milli prefix)');
pause(1)



%% (e)

% change scale
p.xscale = false;

% ok
disp('Return to default scale mode (not engineering scale mode, normal automatic tick labelling)');
pause(1)



%% (f)

% set ticks explicitly (if you don't do this, then
% xticklabels set explicitly may not match the ticks)
p.xtick = 0:200:1000;

% change scale
p.xticklabel = {'0' '200' '400' '600' '800' '1000'};

% ok
disp('Explicit tick labelling (this is risky unless you first explicitly set the ticks!)');
pause(1)



%% (g)

% revert to automatic ticks
p.xtick = false;

% change scale
set(gca, 'xticklabelmode', 'auto');

% ok
disp('Back to default scale mode again');




