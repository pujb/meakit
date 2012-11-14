function [results] = util_convert_64to8s(inp)
%UTIL_CONVERT_64TO8S 将1:64的向量变成8*8方阵
%
%   蒲江波 2008年（为分析缝隙连接数据）
%   蒲江波 2009年6月1日
%   修改注释

    % 老方法
    %{
    results = zeros(8,8);
    tmpname = [];
    for i = 1:64
        tmpname = ceil(i/8)*2 + i + 8;
        tmpname = num2str(tmpname);
        results(str2num(tmpname(1)),str2num(tmpname(2))) = inp(i);
    end
    %}
    
    % 新方法
    results = reshape(inp, 8, 8);
end