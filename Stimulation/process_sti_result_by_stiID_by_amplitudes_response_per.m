function [ analysis ] = process_sti_result_by_stiID_by_amplitudes_response_per( result, sti_id, stipro)
%PROCESS_STI_RESULT_BY_STIID_BY_AMPLITUDES
%工具函数：提取刺激参数中，某个电极各个不同电压刺激下，全皿各个通道的统计结果
%   输入参数：
%       paraname：要统计的参数名，例如'num_response'，对应result里面的结构；
%       result：预先处理的刺激参数；
%       sti_id：刺激电极；
%       stipro：刺激方案；
%
%   输出参数：
%       analysis：分析结果
%
% 蒲江波 2010年5月6日

% 计算在指定电极刺激时，总共有多少种变化
[ ~, ~, ~, variation_amplitude,~ , ~, ~ ] = util_parse_para_fromstimulation(stipro);


for hwid = 1:64
    % 跳过刺激电极
    if (sti_id == util_convert_hw2ch(hwid))
        continue;
    end
    
    %创建结果结构体
    analysis.(['ch' num2str(util_convert_hw2ch(hwid))]).x = [1:length(variation_amplitude)];
    analysis.(['ch' num2str(util_convert_hw2ch(hwid))]).y = [];
    analysis.(['ch' num2str(util_convert_hw2ch(hwid))]).e = [];
    
    % 在不同电压下循环，提取参数，存入结果结构体
    for j=1:length(variation_amplitude)
        analysis.(['ch' num2str(util_convert_hw2ch(hwid))]).y = [analysis.(['ch' num2str(util_convert_hw2ch(hwid))]).y result.(['amp' num2str(variation_amplitude(j))]).num_response.(['ch' num2str(util_convert_hw2ch(hwid))]).stat.num_response/result.(['amp' num2str(variation_amplitude(j))]).num_response.(['ch' num2str(util_convert_hw2ch(hwid))]).stat.num];
        analysis.(['ch' num2str(util_convert_hw2ch(hwid))]).e = [analysis.(['ch' num2str(util_convert_hw2ch(hwid))]).e 0];
    end
end


end

