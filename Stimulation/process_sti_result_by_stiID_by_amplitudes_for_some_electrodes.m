function [ analysis ] = process_sti_result_by_stiID_by_amplitudes_for_some_electrodes( paraname, result, sti_id, stipro, list, isSort, sort_by_n )
%PROCESS_STI_RESULT_BY_STIID_BY_AMPLITUDES_FOR_SOME_ELECTRODES 工具函数：提取部分通道的响应参数
% 提取刺激参数中，某个电极各个不同电压刺激下，指定通道的统计结果
%（可按照第sort_by_n个电压时，各个响应的从小到大输出，顺序在analysis的电极列表序）
%   输入参数：
%       paraname，要统计的参数名，和result结构体中对应
%       result，预先处理好的刺激结果矩阵
%       sti_id，刺激电极
%       stipro，刺激方案
%       list，要统计的电极列表，如[34 68]
%       isSort，是否要根据第n个电压进行排序
%       sort_by_n，第n个电压
%   输出参数：
%       analysis，结果
%
% 蒲江波 2010年5月6日

% 计算在指定电极刺激时，总共有多少种变化
[ ~, ~, ~, variation_amplitude,~ , ~, ~ ] = util_parse_para_fromstimulation(stipro);

% Remove STI
list(list==sti_id) = [];

if isSort
    % Get sort value (by n)
    firstval = [];
    for i=1:length(list);
        firstval = [firstval; result.(['amp' num2str(variation_amplitude(sort_by_n))]).num_response.(['ch' num2str(list(i))]).stat.mean list(i)];
    end
    % Show for checking
    firstval
    % Sort
    [~, index]=sort(firstval,1);
    list = firstval(index(:,1),2);
end



for i=1:length(list);
    analysis.(['ch' num2str(list(i))]).mean = [];
    analysis.(['ch' num2str(list(i))]).sem = [];
    for j=1:length(variation_amplitude)
        analysis.(['ch' num2str(list(i))]).mean = [analysis.(['ch' num2str(list(i))]).mean result.(['amp' num2str(variation_amplitude(j))]).(paraname).(['ch' num2str(list(i))]).stat.mean];
        analysis.(['ch' num2str(list(i))]).sem = [analysis.(['ch' num2str(list(i))]).sem result.(['amp' num2str(variation_amplitude(j))]).(paraname).(['ch' num2str(list(i))]).stat.sem];
    end
end


end

