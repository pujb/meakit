function [] = makedoc()
%MAKEDOC Make the documentation of util toolbox
%   Make the documentation of the UTIL toolbox and other 3rd-party
%   toolboxes (excluding FIND toolbox, because it is too complicated)
%
%   Pu Jiangbo May-30-2010

% Notice the user to change to the right directory
disp('Please make sure the current directory is the UTIL root');
input('[Enter / Ctrl + C]...');

% Move Other toolboxes outside temporarily
[~,~] = system('move Otherbox\FIND ..\OtherTempFIND');

% Run m2html
m2html('mfiles','.', 'htmldir','Help', 'recursive','on', 'global','on', ...
       'template','brooks', ...
       'index','menu', 'graph','on','source','on', 'verbose', 'on');

% Move FIND toolbox back
[~,~] = system('move ..\OtherTempFIND Otherbox\FIND');
end

