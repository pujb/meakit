function [ ax_x spike_number_in_each_bin spike_amplitude_mean spike_amplitude_std] = util_ps_amplitude_by_time_by_trigger( triggerif, ...
    spif, ...
    D, ...
    chid, ...
    binsize, ...
    timescope, ...
    trigger_range, ...
    isManualTrigger, ...
    peakType)
%UTIL_PS_AMPLITUDE_BY_TIME_BY_TRIGGER 工具函数：利用MCS的信息，计算PS的幅度随时间轴的分布
%   本函数计算的幅度分布信息是依据时间分布，而不是概率分布，概率分布的函数是util_psth_amplitude_by_trigger
%   triggerif = trigger information from mcd file
%   spif = spike information from mcd file
%   D = datastrm获得的对象
%   binsize = bin width of each histogram in millisecond
%   timescope = [start end], of the time scope of counting spikes
%   trigger_range = [start end], triggers counts into the psth
%   isManualTrigger = 是否是手动提的Trigger，手动Trigger可能会造成Trigger误判为Spike
%   peakType = 幅度是记录最小值(0)、最大值(1)、峰-峰值(2)。
%
%   ax_x = X坐标轴
%   spike_number_in_each_bin = 每个bin内的Spike的总数目（累加）
%   spike_amplitude_mean = 每个bin内的Spike幅度的均值
%   spike_amplitude_std = 每个bin内Spike幅度的STDEV
%   
%   示例：
%   [ ax_x spike_number_in_each_bin spike_amplitude_mean spike_amplitude_std] = util_ps_amplitude_by_time_by_trigger(triggerif,spif,D,34,5,[-50 450],[81 100],1,2);
%   是计算通道34上，Trigger前后-50,450ms间的Spike的幅度随时间的分布。计算Trigger的范围
%   是第81-100个Trigger，忽略Trigger前后0.5 ms（手动提Trigger的伪信息）
%   的信息，并归一化。输出时是每5 ms一个bin
%
%   蒲江波 - 2009年5月30日
%   蒲江波 - 2009年5月31日
%       Bug fix:统计Spike个数值永远为75.

% 通道序号转换
hwid = util_convert_ch2hw(chid);

% 基本思路
% 在指定的Trigger范围内循环，检索所有的Spike，以Binsize作为一个时间段，遍历整个timescope[].
% 每个Binsize内的Spike Amplitude做平均，用来代表那个时间段内的Response的幅度。

% 为提高运行速度，预先创建FOR循环中反复用的变量
this_spif_spiketime = spif.spiketimes{hwid}; % 运行PSTH通道的SPIF信息复制本
this_spif_spikevalue = ad2muvolt( D, spif.spikevalues{hwid} ); % SPIKETIME信息副本

% 计算出有多少个Bin，用来预存每次运算的结果
if mod(timescope(2) - timescope(1), binsize)
    error('binsize必须要可以被timescope的范围所整除.');
end
bin_number = (timescope(2) - timescope(1)) / binsize + 1;

% 每个Bin内的Spike的数目
spike_number_in_each_bin = zeros(1, bin_number);

% 每个Bin内的Spike的幅度的队列
spike_amplitude_in_each_bin = cell(1, bin_number);

% 每个Bin内的Spike的幅度的平均值
spike_amplitude_mean = zeros(1, bin_number);

% 每个Bin内的Spike的幅度的STD
spike_amplitude_std = zeros(1, bin_number);

% 生成X轴
ax_x = timescope(1):binsize:timescope(2);

% 在Trigger中遍历
for i = trigger_range(1):trigger_range(2)
    % 记录每次Trigger的具体时间
    this_trigger_time = triggerif.times(i);
    % 确定第一个Bin的开始和最后一个Bin的结束
    first_bin_start = timescope(1) + this_trigger_time;
    last_bin_start = timescope(2) - binsize + this_trigger_time;
    
    % 在SPIF中寻找给定的Trigger时间Timescope[]范围内的Spike
    % 基本方法
    % 利用Trigger的时间在SPIF.spiketime中查询每个Bin范围内的Spike的索引号码
    % 然后用这个索引号码去找到spikevalue内的spikevalue,平均之，放在结果中
    % 然后递增bin范围，遍历timescope内所有的时间段
    
    % 确定是否过零点，和手动提Trigger的误差容忍范围(0.5ms)
    % 这个范围是通用的，后面的分析过程中将不突出isManualTrigger的作用
    if isManualTrigger
        if first_bin_start < this_trigger_time
            before_trigger = this_trigger_time - 0.5 - binsize;
        else
            before_trigger = NaN;
        end
        after_trigger = this_trigger_time + 0.5;
    else
        if first_bin_start < this_trigger_time
            before_trigger = this_trigger_time;
        else
            before_trigger = NaN;
            after_trigger = this_trigger_time;
        end
    end
    
    % 按照刺激时刻点将时间范围分成两段
    % 在每段的循环中，将[last next)内的spike幅度序列放入Cell矩阵进行保存
    
    % 计算前半段（如果有的话，刺激时间前的部分）
    % 如果不存在前半段，则before_trigger是NaN，则这段循环不会进行
    
    bin_counter = 1; % 循环下标
    if ~isnan(before_trigger)
        for j = first_bin_start:binsize:before_trigger
            % 把每个Bin内的Spike的幅度的值保存在列表中，等循环完所有的Trigger后再行处理
            
            % 根据peakType确定要幅度的计算方法(0:min, 1:max, 2:max-min)
            % spike_amplitude是一个临时的变量，用于存放某个Bin范围内的Spike的幅度值
            switch(peakType)
                case 0
                    spike_amplitude = min( this_spif_spikevalue( :, ...
                        this_spif_spiketime >= j & this_spif_spiketime < j+binsize ) );
                case 1
                    spike_amplitude = max( this_spif_spikevalue( :, ...
                        this_spif_spiketime >= j & this_spif_spiketime < j+binsize ) );
                case 2
                    spike_amplitude = max( this_spif_spikevalue( :, ...
                        this_spif_spiketime >= j & this_spif_spiketime < j+binsize ) ) - ...
                        min( this_spif_spikevalue( :, ...
                        this_spif_spiketime >= j & this_spif_spiketime < j+binsize ) );
            end
            spike_amplitude_in_each_bin{1,bin_counter} = ...
                [ spike_amplitude_in_each_bin{1,bin_counter} spike_amplitude ];
           
            bin_counter = bin_counter + 1;
        end
    end
   
    % 计算后半段
    % bin_counter是目前即将要计算的Bin的Index，不能改变
    for j = after_trigger:binsize:last_bin_start
        switch(peakType)
            case 0
                spike_amplitude = min( this_spif_spikevalue( :, ...
                    this_spif_spiketime >= j & this_spif_spiketime < j+binsize ) );
            case 1
                spike_amplitude = max( this_spif_spikevalue( :, ...
                    this_spif_spiketime >= j & this_spif_spiketime < j+binsize ) );
            case 2
                spike_amplitude = max( this_spif_spikevalue( :, ...
                    this_spif_spiketime >= j & this_spif_spiketime < j+binsize ) ) - ...
                    min( this_spif_spikevalue( :, ...
                    this_spif_spiketime >= j & this_spif_spiketime < j+binsize ) );
        end
        spike_amplitude_in_each_bin{1,bin_counter} = ...
            [ spike_amplitude_in_each_bin{1,bin_counter} spike_amplitude ];

        bin_counter = bin_counter + 1;
    end
end

% 计算结果
% spike_amplitude_in_each_bin里面包含了各个Bin内Spike幅度的值（min/max/p2p）。
for i=1:bin_number
    spike_number_in_each_bin(1,i) = length( spike_amplitude_in_each_bin{1,i} );
    spike_amplitude_mean(1,i) = mean( spike_amplitude_in_each_bin{1,i} );
    spike_amplitude_std(1,i) = std( spike_amplitude_in_each_bin{1,i} );
end

end

