function [ spif ] = util_convert_ptsd_result2spif( spt, spv, startend )
%UTIL_CONVERT_PTSD_RESULT2SPIF 工具函数：将PTSD锋电位提取算法的结果转换为SPIF结构体
%   输入参数：
%       spt，spv：来自PTSD锋电位提取算法的结果（Timing, Values）
%       startend：[start end] ms，SPIF涵盖的起止时间
%   输出参数：
%       spif
%
%   蒲江波 2010年5月24日

% 创建结果矩阵
spif.spiketimes = cell(64,1);
spif.spikevalues = cell(64,1);

spif.startend = startend;

% 转换结果到SPIF
for hwid = 1:64
    spif.spiketimes{hwid} = spt{ hwid,: };
    spif.spikevalues{hwid} = spv{ hwid,: };
end

end

