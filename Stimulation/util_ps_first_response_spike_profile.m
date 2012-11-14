function [ timing timing_std timing_all amp amp_std amp_all ] = util_ps_first_response_spike_profile( triggerif, ...
    spif, ...
    D, ...
    chid, ...
    trigger_range, ...
    isManualTrigger, ...
    peakType)
%UTIL_PS_FIRST_RESPONSE_SPIKE_PROFILE 工具函数：处理刺激后第一个响应Spike的位置和幅度
%   在给定trigger_range中，获取响应后第一个Spike的Timing/Amplitude，返回均值和STD
%   triggerif = trigger information from mcd file
%   spif = spike information from mcd file
%   D = datastrm获得的对象
%   chid = 11-88通道号
%   trigger_range = [start end] Trigger顺序的范围
%   isManualTrigger = 是否是手动提的Trigger，手动Trigger可能会造成Trigger误判为Spike（+/- 0.5 ms）
%   peakType = 幅度是记录最小值(0)、最大值(1)、峰-峰值(2)。

%   timing = 按Trigger发生为0，给出第一个Spike的发生时间的均值，时间单位为ms
%   timing_std = STDEV of timing
%   timing_all = 全部的第一个Spike的发生时间的队列
%   amp = Trigger后第一个Spike的幅度的均值
%   amp_std = STDEV of amplitude
%   amp_all = 全部的第一个Spike的幅度值的队列

%   示例：
%   [timing timstd timall amp ampstd ampall] = util_ps_first_response_spike_profile(triggerif,spif,D,34,[1 200],1,2);
%   计算第1-200个Trigger的Trigger后第一个Spike的统计信息（通道34），只计算Trigger后0.5ms发生的Spike，峰峰值计算
%   
%   蒲江波 2009年6月1日


% 通道序号转换
hwid = util_convert_ch2hw(chid);

% 基本思路
% 在指定的Trigger范围内循环，找到每个Trigger后的第一个Spike
% 返回这些Spike的Timging和Amplitude的均值和标准差

% 为提高运行速度，预先创建FOR循环中反复用的变量
this_spif_spiketime = spif.spiketimes{hwid}; % 运行PSTH通道的SPIF信息复制本
this_spif_spikevalue = ad2muvolt( D, spif.spikevalues{hwid} ); % SPIKETIME信息副本

timing_all = [];
amp_all = [];

% 在Trigger中遍历
for i = trigger_range(1):trigger_range(2)
    % 获得每次Trigger的具体时间
    this_trigger_time = triggerif.times(i);
    
    % 若为手动提的Trigger（或者需要一个延迟的情况）
    % 则将开始扫描的时间延迟0.5 ms
    if isManualTrigger
        start_point = this_trigger_time + 0.5;
    else
        start_point = this_trigger_time;
    end
    
    % 比start_point还大的第一个spiketime就是第一个spike发生的时间
    % 首先找到一串在start_point后发生的spike的timing
    first_spike_timing = this_spif_spiketime( this_spif_spiketime > start_point );
    % 只取第一个
    first_spike_timing = first_spike_timing(1);
    % find返回第一个符合条件的下标，用来计算幅度用
    indexer = find( this_spif_spiketime > start_point, 1 );
    
    % 计算Spike幅度值
    switch(peakType)
        case 0
            % MIN
            first_spike_amplitude = min( this_spif_spikevalue( :,indexer ) );
        case 1
            % MAX
            first_spike_amplitude = max( this_spif_spikevalue( :,indexer ) );
        case 2
            % Peak to Peak
            first_spike_amplitude = max( this_spif_spikevalue( :,indexer ) ) -...
                min( this_spif_spikevalue(indexer) );
    end
    
    % 将本次Trigger的信息加入信息表(其中Timing的信息需要减去Trigger发生的时间)
    timing_all = [timing_all (first_spike_timing - this_trigger_time)];
    amp_all = [amp_all first_spike_amplitude];
end

timing = mean( timing_all );
timing_std = std( timing_all );
amp = mean( amp_all );
amp_std = std( amp_all );

end

