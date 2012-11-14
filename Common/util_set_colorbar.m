function [ handle ] = util_set_colorbar( map )
%UTIL_SET_COLORBAR Get a styled colorbar
%   Map:    Colormap, e.g. jet.
%   handle: Colorbar handle
%
%   Created on Jul/29/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

handle = colorbar();
colormap(map);
set(handle, 'box', 'off');
set(handle, 'TickDir', 'out');
set(handle, 'YTickMode','manual');

end

