function [result] = util_make_raster_colormap(type)
%UTIL_MAKE_RASTER_COLORMAP Generate the colormap for RASTER PLOT
%   Usually, this function is used with UTIL_PLOT_RASTER_IMAGE.
%
%   Input:
%       type:   'hot', 'hot-modified' or 'gray', you may want to adjust it manually later.
%               'esa' / 'french' sometimes makes good figure too.
%   Output:
%       result: The generated colormap.
%
%   Example:
%       map = util_make_raster_colormap('hot');
%
%   Created on Dec/27/2009 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2010-06-01  Add 'hot' / 'hot-modified'
%                       Change 'gray' method
%       PJB#2010-09-04  Add 'esa' / 'french'
%       PJB#2010-09-30  Add 'hot-inv'

if nargin == 0
    help util_make_raster_colormap
    return
end

if strcmpi(type,'hot')
    z = hot;
    result = z;
elseif strcmpi(type, 'hot-inv')
    z = hot;
    result = [z(end:-1:1,1),z(end:-1:1,2),z(end:-1:1,3)];
elseif strcmpi(type, 'hot-modified')
    z = hot;
    % Empty = white
    z(1,:) = [1 1 1];
    % One spike = black
    z(2,:) = [0 0 0];
    result = z;
elseif strcmpi(type, 'gray')
    z = gray;
    result = [z(end:-1:1,1),z(end:-1:1,2),z(end:-1:1,3)];
    %result(2,:) = [0 0 0];
elseif strcmpi(type, 'esa')
    result = esa();
elseif strcmpi(type, 'esa-modified')
    result = esa_modified();
elseif strcmpi(type, 'french')
    result = french();
else
    error('Not supported yet');
end
end