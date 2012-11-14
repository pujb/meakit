function [ timems ] = util_convert_dp2ms( number_of_datapoints, MicrosecondsPerTick )
%UTIL_CONVERT_DP2MS 工具函数：计算给定数据点所涵盖的时间长度
%   输入参数：
%       number_of_datapoints，数据点的个数
%       MicrosecondsPerTick，每个Index位涵盖的时间。例如，25000 Hz采样，则每个Index是40 us
%   输出：
%       timems，时间长度
%
%   蒲江波 2010年5月21日

timems = MicrosecondsPerTick * number_of_datapoints / 1000;

end

