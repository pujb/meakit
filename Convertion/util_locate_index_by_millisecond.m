function [ indexer ] = util_locate_index_by_millisecond( timems, MicrosecondsPerTick, startms )
%UTIL_LOCATE_INDEX_BY_MILLISECOND 工具函数：从时间（ms）反推该时间对应信号在记录矩阵中的位置
%   输入参数：
%       timems，时间。
%       MicrosecondsPerTick，每个Index位涵盖的时间。例如，25000 Hz采样，则每个Index是40 us
%       start，index = 1的那个点的时间（ms），即序列中第一个点的位置。
%   输出：
%       indexer，在结果矩阵中的位置
%
%   蒲江波 2010年5月18日
%   蒲江波 2010年5月21日
%       增加startms参数。并修改原函数，使之调用UTIL_CONVERT_MS2DP。

indexer = util_convert_ms2dp( (timems - startms), MicrosecondsPerTick);


end

