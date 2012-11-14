function [ score avg_score max_score min_score median_score] = util_sti_calc_test_score ( spif, ...
    trif, ...
    obs_chid, ...
    calculating_range, ...
    isManualTrigger, ...
    isPrintInfo)
%UTIL_STI_CALC_TEST_SCORE 工具函数：计算测试电极成绩
%   读入spif和triggerif，根据每次trigger给定的时间，判断观察电极(obs_chid)
%   上在指定的时间范围(calculating_range)上的测试成绩(score)。
%   计算方法，如，指定100ms内，则第0-1ms发生的Spike计分100分，第99-100ms发生的Spike计分0分
%
%   参数：
%   spif,trif = spike time table and trigger table read from a mcd file
%   obs_chid = 观察电极号，也就是要计算成绩的电极号(11-88)
%   calculating_range = 观察范围，以ms计，建议100，需要注意不能大于两次刺激的时间间隔（会有提示，但不会自动帮用户设定）
%   isManualTrigger = 是否是手动提的Trigger，手动Trigger可能会造成Trigger误判为Spike（+/- 0.5 ms）
%   isPrintInfo = 是否将信息输出到控制台
%
%   输出参数：
%   score = 成绩向量
%   avg,max,min,median = 平均分，最大，最小，中位数
%
%   蒲江波 2009年11月20日
%   蒲江波 2009年11月21日
%       添加isPrintInfo参数，提高程序可用性

% 参数分析
if isPrintInfo
    disp([char(10) char(10) '=== Calculating Test Score ===']);
    disp(['Observation Elec# ' num2str(obs_chid)]);
    disp(['Time Range: ' num2str(calculating_range)]);
    if isManualTrigger
        disp('Delayed detecting is ON.');
    else
        disp('Delayed detecting is OFF.');
    end
end

% 通道序号转换
obs_hwid = util_convert_ch2hw(obs_chid);

% 处理的基本思路
% 在trigger事件中循环，找到在obs_hwid中，每个trigger后指定范围内的Spike，并对其计分

% 为提高运行速度，预先创建FOR循环中反复用的变量
this_spif_spiketime = spif.spiketimes{ obs_hwid }; % 评分通道的SPIF信息复制本

% 读入Trigger的总个数
number_of_triggers = size( trif.times, 2 );
if isPrintInfo
    disp(['Number of Triggers: ' num2str(number_of_triggers)]);
end

score = [];
number_of_candidate_spikes = 0;

% 计算权值序列
% 例如1:100，则1代表0-1 ms区段，2代表1-2 ms区段
weights = 100:-(99/(calculating_range-1)):1;
edges = 1:1:calculating_range;

% 在Trigger中遍历
for i = 1:number_of_triggers
    % 获得本次trigger发生时间
    this_trigger_time = trif.times(i);
    
    % 获得下次trigger发生时间
    if i < (number_of_triggers - 1)
        next_trigger_time = trif.times(i+1);
    else
        % 没有下次trigger，则该时间设置为最大时间
        next_trigger_time = trif.startend(2);
    end
    
    % 若为手动提的Trigger（或者需要一个延迟的情况）
    % 则将开始扫描的时间延迟0.5 ms
    if isManualTrigger
        scan_start_point = this_trigger_time + 0.5;
        scan_end_point = next_trigger_time - 0.5;
    else
        scan_start_point = this_trigger_time;
        scan_end_point = next_trigger_time - 0.5;
    end

    % 判断计算范围是否过大，以致于涵盖了下次trigger的发生时间
    if scan_end_point <= scan_start_point + calculating_range
        error(['Wrong CALCULATING_RANGE' char(10) 'Current setting makes it includes the next trigger.' char(10) 'Possible reason: The trigger is not so precisely timed as we thought.']);
    end
    
    % 比scan_start_point还大的第一个spiketime就是第一个spike发生的时间
    % 找到在指定时间范围内的spikes
    candidate_spikes = this_spif_spiketime( this_spif_spiketime > scan_start_point ...
        & this_spif_spiketime < scan_start_point + calculating_range);
    
    % 计算这个时间范围内的测试成绩 <=== begin
    
    % 候选spike的总数目
    number_of_candidate_spikes = number_of_candidate_spikes + length( candidate_spikes );
    % disp(['Number of Candidate Spikes: ' num2str(number_of_candidate_spikes)]);
    
    % 将候选spike按照Calculating_Range进行分布
    candidate_spikes = candidate_spikes - scan_start_point;
    % 经过histc得到每个区段的spike计数，越早期的权值越高，越末期的权值越低
    sorted_candidate_spikes = histc(candidate_spikes, edges);
    
    % 计算成绩
    if size(sorted_candidate_spikes,1) == size(weights,1)
        score = [score sum(sorted_candidate_spikes .* weights)];
    elseif size(sorted_candidate_spikes,1) == size(weights,2)
        score = [score sum(sorted_candidate_spikes .* weights')];
    end
    
    % 计算这个时间范围内的测试成绩 ===> end
end

avg_score = mean( score );
max_score = max( score );
min_score = min( score );
median_score = median( score );

if isPrintInfo
    disp(['Total Candidate Spikes: ' num2str(number_of_candidate_spikes)]);
    disp(['Mean Score: ' num2str(avg_score)]);
end
%disp(['Max Score: ' num2str(max_score)]);
%disp(['Min Score: ' num2str(min_score)]);
%disp(['Median Score: ' num2str(median_score)]);

end
