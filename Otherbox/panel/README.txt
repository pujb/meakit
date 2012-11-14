
------------------------------------------------------------------------------------------------
		OVERVIEW
------------------------------------------------------------------------------------------------

Panel is a replacement for Matlab's subplot
function. For details, see "panel_user_manual.html".

Author: Ben Mitch
URL: http://www.mathworks.com/matlabcentral/fileexchange/20003-panel
Released: 2008



------------------------------------------------------------------------------------------------
		INSTALLATION
------------------------------------------------------------------------------------------------

To install, just add this folder to your Matlab Path using either "pathtool" or "addpath".



------------------------------------------------------------------------------------------------
		CHANGE LOG
------------------------------------------------------------------------------------------------

10/05/2010
* Changed default value of P.render_notinh.x/yticklabel to "false", so it is distinguishable from "''" (empty string), which the user may actually want to set.

19/8/2010
* Changed the default value of P.render_notinh.x/yticklabel back to '', because it's more consistent. If the user wants empty ticklabels, they can set {}.
* Added documentation for xticklabel and yticklabel properties.
* Improved documentation for engineering scales.
* Improved display() to show what value is inherited for inherited values.
* Fixed bug in ticklabel display during export().
* Added syntax P = panel(gcf, 3, 2, ...) to allow creation of a grid of panels straight off the bat (see "help panel"). Also added new demo of this (panel_demo_8). Suggested by LP Pakula.

19/8/2010
* Whoops. Fixed a bug in panel.m after recent changes to it.

20/8/2010
* Improved performance of rendering by 20%.

23/08/2010
* Added regular-grid packing to pack(), and rearranged panel() to use this rather than do it itself.
* This required changing the syntax - the call is now P = panel(gcf, [3 2], ...) or P = p.pack([3 2]), to pack into an existing panel.
* Added option to select() a panel onto an existing axis - see help panel/select. This usage suggested by Arthur Ward.

24/08/2010
* Fixed a bug in sub_render introduced with the last change that caused tick labels to display incorrectly until the next render after some window resize operations.

----------------
26/08/2010
NEW RELEASE: 26_08_2010
----------------

28/08/2010
* Changed x/ylabel storage to be within the associated Handle Graphics axis. This way, the user can set them either through the panel object, or using the standard x/ylabel() routines. The advantage is that third-party code may use x/ylabel() for specialised plots, and this now works correctly and transparently with panel, since they store their data in the same place.
* Did the same for x/yticklabel and title, for consistency and, in a small way, for the same reason as above.
* Reworked subsref/subsasgn interface, so that x/ytick, x/yticklabel, x/ylabel and title now implement an alternative interface to the native axis properties through panel, which makes them easy and consistent to get and set (no working with axis handles). As a handy shortcut, to revert ticklabel or tick to automatic mode, set their value to logical false, e.g. "p.xtick = false;".
* Changed implementation of panel constructor so that if you create a new root panel object, an existing panel tree attached to the target figure is walked, and any associated axes are destroyed. NOTE that existing axes that are not managed by panel are not affected, so you can create a special-purpose axis before or after attaching a panel to a figure.
* Complete review of documentation, making sure it's accurate and a bit clearer than before.

----------------
28/08/2010
NEW RELEASE: 28_08_2010
----------------
 
28/08/2010
* Changed implementation to use only the field "panel" in UserData; bit tidier.
* 20% rendering performance increase, mostly by optimising inheritance in subsref.
* Fixed bug of not correctly handling figure units other than "pixels" - all figure units are now handled, save "normalized", which cannot be (it gives no absolute size reference and leaves us stuck for rendering).
* Fixed implementation of create new root panel so that if the user retains references to no-longer-existing panels, this is detectable; use of these "hanging" references now generates an error.
* Other minor fixes.

----------------
28/08/2010
NEW RELEASE: 28_08_2010_02
----------------

30/08/2010
* Another suggestion by Arthur Ward made me realise that multi-line x/ylabels are not supported. Fixed now, they seem to work fine.

09/12/2010
* Changed export() so that if it gets a non-root panel, it finds the associated root panel, rather than raising an error.

01/03/2011
* Fixed a bug in panel/export whereby if the current figure was not the figure being exported, the current figure is the one that got printed.

02/03/2011
* Added recursive property interface.
* Added parent panel labelling/titling (suggested by "Niko" at Matlab Central).

----------------
02/03/2011
NEW RELEASE: 02_03_2011
----------------



