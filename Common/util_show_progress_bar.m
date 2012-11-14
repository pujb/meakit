function [] = util_show_progress_bar( percent )    %#codegen
%UTIL_SHOW_PROGRESS_BAR Show the progress bar
%   Input:
%       percent: 0 - 100
%
%   Created on Sep/15/2012 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2012-09-15  Created.
%       PJB#2012-09-16  Fixed BUG: The program forgets to update the bar
%                       position after new progress has been made.
%                       Changed persistent var name to co-use with
%                       util_show_progress_init()

coder.extrinsic('fprintf', 'clear');

persistent util_show_progress_bar_pos;   % remember last pos

if isempty(util_show_progress_bar_pos)
    if percent == 100
        return;
    end
    % First time
    fprintf('|--------------------------------------------------|');
    util_show_progress_bar_pos = 0;
end


new_barpos = floor(percent/2);
% Check if we don't need to update
if new_barpos == util_show_progress_bar_pos
    return
end

% Remove old, Add new
fprintf(1, repmat('\b',1,51));
fprintf(1, repmat('#',1,new_barpos));
fprintf(1, repmat('-',1,50-new_barpos));
fprintf(1, '|');

% Update Bar Pos
util_show_progress_bar_pos = new_barpos;

if percent == 100
    clear util_show_progress_bar_pos;
    fprintf(1, '   ');
    fprintf('Done.\n');
end

end

