function [ number trigger_stream ] = util_find_triggerstream( D )
%UTIL_FIND_TRIGGERSTREAM 工具函数：找到MCD文件中的Trigger数据流
%   返回Trigger数据流的个数和数据流名称
%   输入参数:
%       D = datastrm返回的数据对象
%   输出参数:
%       number = TRIGGER数据流个数
%       spike_stream = TRIGGER数据流名称CELL组
%   
%   蒲江波 2009年5月22日

streamCount = getfield(D, 'StreamCount');
streamInfo = getfield(D, 'StreamInfo');

number = 0;
trigger_stream = {};


for i = 1:streamCount
    if strcmp( streamInfo{i}.DataType, 'trigger' )
        number = number + 1;
        trigger_stream{number} = streamInfo{i}.StreamName;
    end
end


end

