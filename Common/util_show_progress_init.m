function [] = util_show_progress_init( progress_style_name )
%UTIL_SHOW_PROGRESS_INIT Init selected progress indicator style
%   Input:
%           progress_style_name:    'bar' / 'rounding'
%
%
%   Created on Sep/16/2012 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2012-09-16  Created.
%                       Change the way to clear persistent var in the
%                       progress indicator.

% Backup Breakpoints (Because we need to clear the funtion itself) for
% DEBUG purpose
oldBreakpoints = dbstatus;

% Clear persistent var in the progress indicator function by clear the
% funtion itself. This is the only way.
switch progress_style_name
    case 'bar'
        clear util_show_progress_bar;
    case 'rounding'
        clear util_show_progress_rounding;
end

% Restore Breakpoints
dbstop(oldBreakpoints)
end

