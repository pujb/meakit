
%% PANEL DEMO B
%%
%% (a) Create a four-by-four panel array
%% (b) Illustrate parent panel xlabels/ylabels
%% (c) Illustrate parent panel xlabel/ylabel



%% (a)

% create a grid-at-once
clf
p = panel([2 2]);

% get root panel
root = p{1}.root;

% disable autorender
root.autorender = false;

% commit the children
for n = 1:4
	select(p{n});
	plot(randn(1000,1));
	axis([0 1000 -3 3])
end



%% (b)

% ok
disp('Recursive axis properties');

% use titles
root.titles = 'badness and goodness';

% use xlabels/ylabels
root.xlabels = 'sample number';
root.ylabels = 'value';

% use xticks/yticks
root.xticks = [0 300 700 1000];
root.yticks = [-2 0 2];

% use xticklabels/yticklabels
root.xticklabels = {'oh' 'three' 'seven' 'max'};
root.yticklabels = {'-' '0' '+'};

% need a bit of extra space because the titles and xlabels
% are both present...
root.axismargin = [15 15 0 5];

% render
render(root);

% wait
disp('press any key...')
pause



%% (c)

% ok
disp('Parent axis properties');

% remove stuff
root.xlabels = '';
root.ylabels = '';
root.titles = '';

% use xlabel/ylabel on a parent panel
root.xlabel = 'sample number';
root.ylabel = 'value';
root.title = 'badness and goodness';

% this requires some extra parent margin to make space for
% the extra text
root.parentmargin = [10 10 0 5];

% but not for this panel's children...
c = root.children;
c{1}.parentmargin = 0;
c{2}.parentmargin = 0;

% and we can reduce the axismargin since we're not using it
% for labels
root.axismargin = 6;

% render
render(root);



