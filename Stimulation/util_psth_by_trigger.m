function [ ax_x result ] = util_psth_by_trigger( triggerif, ...
                                            spif, ...
                                            chid, ...
                                            binsize, ...
                                            timescope, ...
                                            trigger_range, ...
                                            isManualTrigger, ...
                                            isNormalized)
%UTIL_PSTH_BY_TRIGGER 工具函数：利用MCS的信息，计算PSTH
%   triggerif = trigger information from mcd file
%   spif = spike information from mcd file
%   binsize = bin width of each histogram in millisecond
%   timescope = [start end], of the time scope of counting spikes
%   trigger_range = [start end], triggers counts into the psth
%   isManualTrigger = 是否是手动提的Trigger，手动Trigger可能会造成Trigger误判为Spike
%   isNormalized = 是否归一化，如果不归一化，则是Counts/Bin，但是如果归一化的话，
%                  用的算法和NEX是一样的，Nex是除以Trigger的数目来归一的。
%   ax_x = X坐标轴
%   result = Y值
%   
%   示例：
%   [x y] = util_psth_by_trigger(triggerif,spif,87,5,[-50 450],[1 20],1,1)
%   是计算通道87上，每5ms一个bin，Trigger前后-50,450间的psth，计算Trigger的范围
%   是第1-20个Trigger，这个Trigger是忽略Trigger前后0.5 ms（手动提Trigger的伪信息）
%   的信息，并归一化。
%
%   蒲江波 2009年5月

% 通道序号转换
hwid = util_convert_ch2hw(chid);

% 计算开始和终止统计的时间区间，要注意，给出的时间区间必须是能够包含0点的
firstbin = timescope(1);
lastbin = timescope(2);
edges = firstbin : binsize : lastbin;

% 返回ax_x，是X轴的坐标系
ax_x = edges;

% 检查时间区间内是否包含0点
if isempty(find(edges==0, 1))
    error('Zero must be contained in the time scope.');
end

% 为提高运行速度，预先创建FOR循环中反复用的变量
this_spif_spiketime = spif.spiketimes{hwid}; % 运行PSTH通道的SPIF信息复制本
result_pre = []; % 用于将各次Trigger的信息相连接。

for i = trigger_range(1):trigger_range(2)
    % 在给定的Trigger中遍历
    this_trigger_time = triggerif.times(i); % 每次Trigger的具体时间
    
    % 在SPIF中寻找在给定Trigger周围timescope范围内的Spike，并做直方图统计
        
    % 将SPIF中在给定Trigger时间范围内的Spike的Timing都转换成以Trigger作为参考系的时间点
    % 首先找到在Trigger范围(timescope)内的时间点
    this_before = this_trigger_time + timescope(1); % Trigger前后的实际时间位置
    this_after = this_trigger_time + timescope(2);
    
    % 计算扫描区间
    this_scanned_range = this_spif_spiketime( ...
        this_spif_spiketime >= this_before & this_spif_spiketime <= this_after);
   
    % 然后把这些时间点转化成以Trigger为参考系的时间值
    this_scanned_range = this_scanned_range - this_trigger_time;
    
    % 若Spike发生在距离Trigger很近的时间段，认为是假信号(0.5 ms内都不算)
    if isManualTrigger
        this_scanned_range(abs(this_scanned_range) <= 0.5) = [];
    end
    
    if ~isempty(this_scanned_range)
        % 将结果连接成一个向量
        if size(this_scanned_range,1) <= size(this_scanned_range,2)
            result_pre = [result_pre this_scanned_range];
        else
            result_pre = [result_pre this_scanned_range'];
        end
    end
end

result = histc(result_pre,edges);

% 是否归一化
if isNormalized
    result = result / (trigger_range(2) - trigger_range(1) + 1);
end

end

