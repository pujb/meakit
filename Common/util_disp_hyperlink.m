function [] = util_disp_hyperlink( text, varargin )
%UTIL_DISP_HYPERLINK 工具函数：在命令窗口显示蓝色的超链接文字
%   text = 要显示的文字
%   可选：links = 链接位置
%
%   蒲江波 - 2009年6月27日

pvpmod(varargin);

if ~exist('links', 'var')
    links = '';
end

disp(['<a href="' links '">' text '</a>']);

end

