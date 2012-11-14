function [ elecs responses_timing responses_amplitude ] = util_sti_all_responses( varargin )
%UTIL_STI_ALL_RESPONSES 工具函数：提取刺激后指定时间窗内所有电极的响应
%   提取刺激后，全皿各个通道在指定时间窗内的响应时间点
%
%   输入参数：
%       d, mcd文件体
%       spif，trif MCD文件信息（by mcsfile loader）
%       window，默认是[5 20] ms
%       stipro，刺激方案（不一定要给，若没有，则不会验证刺激方案和MCD文件Trigger数的一致性）
%       isManualTrigger，是否手动提取的Trigger(Trigger时刻点+/- 0.5 ms的不算)，默认0
%   输出参数：
%       elec，对应后面的response矩阵的电极分布
%       responses，各个通道对每次某chid电极刺激后的响应Spike出现的时间点(timing)和峰峰值（amplitude）
%       例如，elec = [11 22 33]，则response cell矩阵的第1行是11电极上的响应。
%
%   Eg：
%   [elecs responses amplitudes] = util_sti_all_responses('spif', spif,
%   'trif', trif, 'window', [5 200],'isManualTrigger', 0, 'd',d);
%
%   蒲江波 2010年5月4日

pvpmod(varargin);

% 检查参数

if ~exist('d', 'var')
    error('D - MCD fileobject must be provided.');
end

if ~exist('spif', 'var')
    error('SPIF must be provided.');
end

if ~exist('trif', 'var')
    error('TRIF must be provided.');
end

if ~exist('stipro', 'var')
    disp('STIPRO not provided.');
    stipro = [];
end

% 设置window默认
if ~exist('window', 'var')
    window = [5 20];
end

% 设置ManualTrigger默认
if ~exist('isManualTrigger', 'var')
    isManualTrigger = 0;
end

% 获取Trigger数目
num_trigger = length(trif.times);

if (~isempty(stipro))
    % 若刺激方案中的刺激个数和Trigger数目不符合，则给出警告
    [num_sti, ~, ~, ~, ~, ~, time_s] = util_parse_para_fromstimulation(stipro);
    if(num_sti ~= num_trigger)
        warning('NUM_STI ~= NUM_TRIGGER!');
    end
end

h = waitbar(0, 'Please wait...');
set(h, 'Name', 'Please wait while processing triggers')

% 在Trigger中循环，将刺激后的指定时间窗口内的响应时刻点记录（所有Trigger，所有通道）
elecs = zeros(1,64);
responses_timing = cell(1,64);
responses_amplitude = cell(1,64);
for channel = 1:64
    elecs(channel) = util_convert_hw2ch(channel);
    % 为提高运行速度，预先创建FOR循环中反复用的变量
    this_spiketime = spif.spiketimes{channel};
    this_spikevalue = ad2muvolt(d, spif.spikevalues{channel});
    % 初始化结果数组
    responses_timing{channel} = cell(1,num_trigger);
    responses_amplitude{channel} = cell(1,num_trigger);
    for trigger = 1:num_trigger
        % 每次Trigger的具体时间
        this_trigger_time = trif.times(trigger);
        
        % 将SPIF中在给定Trigger时间范围内的Spike的Timing都转换成以Trigger作为参考系的时间点
        % 首先找到在Trigger范围(timescope)内的时间点
        this_before = this_trigger_time + window(1);
        this_after = this_trigger_time + window(2);
        
        % 计算扫描区间
        this_scanrange = this_spiketime(this_spiketime >= this_before & this_spiketime <= this_after);
        this_scanrange_amplitude = ...
            max(this_spikevalue(:,this_spiketime >= this_before & this_spiketime <= this_after)) ...
            - ...
            min(this_spikevalue(:,this_spiketime >= this_before & this_spiketime <= this_after));

        % 将时间转化为以Trigger发生时刻为原点的时间
        this_scanrange = this_scanrange - this_trigger_time;
        
        % 排除Manual Trigger(+/- 0.5 ms)
        if (isManualTrigger)
            this_scanrange(abs(this_scanrange) <= 0.5) = [];
            this_scanrange_amplitude(abs(this_scanrange) <= 0.5) = [];
        end
        
        % 将结果保存到总表
        % 保存timing信息
        responses_timing{channel}{trigger} = this_scanrange;
        % 保存amplitude信息
        responses_amplitude{channel}{trigger} = this_scanrange_amplitude;
    end
    waitbar(channel/64, h, ['Channel ' num2str(channel) ' (#' num2str(elecs(channel)) ') of 64 finished.']);
end

close(h);

end


