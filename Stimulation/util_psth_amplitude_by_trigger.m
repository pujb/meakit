function [ ax_x result ] = util_psth_amplitude_by_trigger( triggerif, ...
                                            spif, ...
                                            D, ...
                                            chid, ...
                                            binsize, ...
                                            timescope, ...
                                            trigger_range, ...
                                            isManualTrigger, ...
                                            isNormalized, ...
                                            peakType)
%UTIL_PSTH_AMPLITUDE_BY_TRIGGER 工具函数：利用MCS的信息，计算PS的Spike幅度分布
%   triggerif = trigger information from mcd file
%   spif = spike information from mcd file
%   D = datastrm获得的对象
%   binsize = bin width of each histogram in millisecond
%   timescope = [start end], of the time scope of counting spikes
%   trigger_range = [start end], triggers counts into the psth
%   isManualTrigger = 是否是手动提的Trigger，手动Trigger可能会造成Trigger误判为Spike
%   isNormalized = 是否归一化，如果不归一化，则是Counts/Bin，但是如果归一化的话，
%                  用的算法和NEX是一样的，Nex是除以Trigger的数目来归一的。
%   peakType = 幅度是记录最小值(0)、最大值(1)、峰-峰值(2)。
%   ax_x = X坐标轴
%   result = Y值
%   
%   示例：
%   [a b] = util_psth_amplitude_by_trigger( triggerif,spif,D,34,5,[-50 450],[41 60],1,1,0 )
%   是计算通道34上，Trigger前后-50,450间的Spike的幅度分布。计算Trigger的范围
%   是第1-20个Trigger，忽略Trigger前后0.5 ms（手动提Trigger的伪信息）
%   的信息，并归一化。输出时是每5 uV一个bin
%
%   蒲江波 - 2009年5月20日

% 通道序号转换
hwid = util_convert_ch2hw(chid);

% 为提高运行速度，预先创建FOR循环中反复用的变量
this_spif_spiketime = spif.spiketimes{hwid}; % 运行PSTH通道的SPIF信息复制本
this_spif_spikevalue = ad2muvolt( D, spif.spikevalues{hwid} ); % SPIKETIME信息副本
result_pre = []; % 用于将各次Trigger的信息相连接。

for i = trigger_range(1):trigger_range(2)
    % 在给定的Trigger中遍历
    this_trigger_time = triggerif.times(i); % 每次Trigger的具体时间
    
    % 在SPIF中寻找在给定Trigger周围timescope范围内的Spike的幅度，并做直方图统计
        
    % 首先找到在Trigger范围(timescope)内的时间点
    this_before = this_trigger_time + timescope(1); % Trigger前后的实际时间位置
    this_after = this_trigger_time + timescope(2);
    
    if isManualTrigger
        % 若Spike发生在距离Trigger很近的时间段，认为是假信号(0.5 ms内都不算)
        Condition_Manual_Trigger_Before = this_trigger_time - 0.5;
        Condition_Manual_Trigger_After = this_trigger_time + 0.5;
    else
        Condition_Manual_Trigger_Before = this_trigger_time;
        Condition_Manual_Trigger_After = this_trigger_time;
    end
    
    % 计算SpikeTime中，在Trigger范围内的Spike时刻点的位置，并索引到
    % SpikeValue的对应的Spike时程内的幅度的制定值
    
    switch(peakType)
        case 0
            % 计算发生在Trigger范围内的各个Spike的最小值
            amplitudes = min( ...
                this_spif_spikevalue( :, ...
                (this_spif_spiketime >= this_before & this_spif_spiketime < Condition_Manual_Trigger_Before) ...
                | (this_spif_spiketime <= this_after & this_spif_spiketime > Condition_Manual_Trigger_After) ) ...
            );
        case 1
            % 计算发生在Trigger范围内的各个Spike的最大值
            amplitudes = max( ...
                this_spif_spikevalue( :, ...
                (this_spif_spiketime >= this_before & this_spif_spiketime < Condition_Manual_Trigger_Before) ...
                | (this_spif_spiketime <= this_after & this_spif_spiketime > Condition_Manual_Trigger_After) ) ...
            );
        case 2
            % 计算发生在Trigger范围内的各个Spike的最大值-最小值(峰峰值)
            amplitudes = max( ...
                this_spif_spikevalue( :, ...
                (this_spif_spiketime >= this_before & this_spif_spiketime < Condition_Manual_Trigger_Before) ...
                | (this_spif_spiketime <= this_after & this_spif_spiketime > Condition_Manual_Trigger_After) ) ...
            ) - min( ...
                this_spif_spikevalue( :, ...
                (this_spif_spiketime >= this_before & this_spif_spiketime < Condition_Manual_Trigger_Before) ...
                | (this_spif_spiketime <= this_after & this_spif_spiketime > Condition_Manual_Trigger_After) ) ...
            );
    end
    
    if ~isempty(amplitudes)
        % 将结果连接成一个向量
        if size(amplitudes,1) <= size(amplitudes,2)
            result_pre = [result_pre amplitudes];
        else
            result_pre = [result_pre amplitudes'];
        end
    end
end

% 计算开始和终止统计的幅度区间
edges = min(result_pre) : binsize : max(result_pre);

% 返回ax_x，是X轴的坐标系
ax_x = edges;

result = histc(result_pre,edges);

% 是否归一化
if isNormalized
    result = result / (trigger_range(2) - trigger_range(1) + 1);
end

end

