function [ compacted ] = util_compact_spif_spikevalues( spv )
%UTIL_COMPACT_SPIF_SPIKEVALUES 工具函数：将SPIF中SPIKEVALUE信息压缩
%   将SPIF中SPIKEVALUE表中，每一个SPIKE的信息缩减为只包含最大值和最小值。
%   这样在处理较大SPIKE文件（尤其是长时间记录文件）时，可以不至于内存报错。
%
%   蒲江波 2009年6月17日

compacted = cell(64,1);
for i = 1:64
    compacted{i} = [max( spv{i} ); min( spv{i} )];
end

end

