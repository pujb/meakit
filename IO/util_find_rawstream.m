function [ number raw_stream ] = util_find_rawstream( D )
%UTIL_FIND_SPIKESTREAM 工具函数：找到MCD文件中的Raw数据流
%   返回Raw数据流的个数和数据流名称
%   输入参数:
%       D = datastrm返回的数据对象
%   输出参数:
%       number = RAW数据流个数
%       spike_stream = RAW数据流名称CELL组
%   
%   蒲江波 2010年5月21日

streamCount = getfield(D, 'StreamCount');
streamInfo = getfield(D, 'StreamInfo');

number = 0;
raw_stream = {};


for i = 1:streamCount
    if strcmp( streamInfo{i}.DataType, 'analog' )
        number = number + 1;
        raw_stream{number} = streamInfo{i}.StreamName;
    end
end


end

