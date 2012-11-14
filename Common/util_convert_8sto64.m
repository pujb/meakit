function [results] = util_convert_8sto64(inp)
%UTIL_CONVERT_8STO64 工具函数：将8*8方阵变成1：64的向量
%
%   蒲江波 2008（为分析缝隙连接数据）
%   蒲江波 2009年6月1日
%   修改注释

    results = reshape(inp, 1, 64);
end