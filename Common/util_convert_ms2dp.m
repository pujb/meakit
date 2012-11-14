function [ number_of_datapoints ] = util_convert_ms2dp( timems, MicrosecondsPerTick )
%UTIL_CONVERT_MS2DP 工具函数：计算给定时间长度包含多少个数据点
%   输入参数：
%       timems，时间长度
%       MicrosecondsPerTick，每个Index位涵盖的时间。例如，25000 Hz采样，则每个Index是40 us
%   输出：
%       number_of_datapoints，数据点的个数
%
%   蒲江波 2010年5月21日

number_of_datapoints = timems * 1000 / MicrosecondsPerTick;

end

