function [] = util_show_workinfo( info, clearbit )
%UTIL_SHOW_WORKINFO Display information, and delete them at next call
%   Input:
%           info:   The text you want to display
%           clearbit:  After last used, set this to 1
%
%   Created on Jun/08/2012 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

coder.extrinsic('fprintf', 'clear');

persistent info_last;   % style of the cycling

if clearbit == 1
    if ~isempty(info_last)
        % Delete last info
        fprintf(repmat('\b', 1, length(info_last)));
    end
    clear info_last
    fprintf('Done\n');
    return
end

if ~isempty(info_last)
    % Delete last info
    fprintf(repmat('\b', 1, length(info_last)));
end

fprintf(info);
info_last = info;


end

