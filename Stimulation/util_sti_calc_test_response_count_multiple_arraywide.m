function [ varargout ] = util_sti_calc_test_response_count_multiple_arraywide( varargin )
%UTIL_STI_CALC_RESPONSE_COUNT_MULTIPLE_ARRAYWIDE 计算每个电极在刺激期间的响应Spike数目
%   专用于处理方向性刺激Test Positive/Negative的Score程序。
%
%   输入参数：
%       stimulating_chid：一个序列，如[11 22 33
%       88]。即第一个test刺激在11电极，第四个test刺激在88电极。据此，将返回刺激期间，分别属于这4个不同电极的测试成绩。
%       
%       calculating_range：一个值，例如200(ms)。计算刺激后多长时间内的score
%       isManualTrigger = 是否是手动提的Trigger，手动Trigger可能会造成Trigger误判为Spike（+/-
%       0.5 ms）
%       filename：一个文件名，可选参数，不提供。
%
%   输出参数（可变）
%       第一个对应第一个电极，第二个对应第二个电极，以此类推（参照util_calc_sti_test_score_arraywide）
%       例如有2个电极，则v1, v2, v3, v4分别是第1、2个电极做刺激时全皿各电极的各自的平均成绩；以及每次的各电极成绩（v3上每个电极成绩的均值就是v1上每个电极的值）
%   
%   See also UTIL_STI_CALC_TEST_SCORE_ARRAYWIDE
%   
%   蒲江波 2009年11月23日
%   蒲江波 2009年11月24日
%          调试完成，运行通过

pvpmod(varargin);

% 参数分析

if ~exist('stimulating_chid', 'var')
    error('STIMULATING_CHID must be provided.');
else
    number_of_sti_elec = length( stimulating_chid );
    disp(['STIMULATING ELEC: ' num2str(stimulating_chid)]);
end

if ~exist('calculating_range', 'var')
    error('CALCULATING_RANGE must be provided');
end

if ~exist('isManualTrigger', 'var')
    isManualTrigger = 1;
end

if isManualTrigger
    disp('Delayed detecting is ON.');
else
    disp('Delayed detecting is OFF.');
end

if ~exist('filename', 'var')
    [D spif trif] = util_load_spike_trigger_mcdstream();
else
    [D spif trif] = util_load_spike_trigger_mcdstream('filename', filename);
    disp(filename);
end

% Trigger的总个数
number_of_triggers = size( trif.times, 2 );
disp(['TRIGGERS: ' num2str( number_of_triggers )]);

% 将通道号转换为硬件编号，并为运算结果输出做准备
stimulating_elec_hwid = zeros(1, number_of_sti_elec);
score = zeros(1, number_of_sti_elec);
nargout = 2 * number_of_sti_elec;
for i = 1:number_of_sti_elec
    stimulating_elec_hwid(i) = util_convert_ch2hw(stimulating_chid(i));
    % 初始化结果输出: varargout(1) - (n)：平均
    varargout(i) = {zeros(1,64)};
end
for i = (number_of_sti_elec + 1):(2 * number_of_sti_elec)
    % 初始化结果输出：varargout(n+1) - (2n)：详细到每次的成绩
    varargout{i} = cell(64,1);
end

% 在所有电极上遍历，并将结果保存在可变的输出向量里面
% 处理的基本思路：
% 在trigger事件中循环，依次将各个刺激电极对应的事件计分并保存在以刺激电极为顺序依次生成的结果矩阵中


% 计算权值序列
% 例如1:100，则1代表0-1 ms区段，2代表1-2 ms区段
weights = 100:-(99/(calculating_range-1)):1;
edges = 1:1:calculating_range;

% 刺激电极的序列
serial_of_sti_elec = 1;

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
    
    % 上面的部分程序段和计算UTIL_STI_CALC_TEST_SCORE中单电极部分一致
    % 下面的程序段专为计算多电极优化
    
    % 获得本次Trigger对应的电极(硬件编号)
    this_sti_elec = stimulating_elec_hwid(serial_of_sti_elec);
    
    hwID = 1;
    while hwID < 65
        % 排除四角电极和刺激电极
        if hwID == 1 || hwID == 8 || hwID == 57 || hwID == 64 || hwID == this_sti_elec
            hwID = hwID + 1;
            continue;
        end
        
        % 计算本电极本次刺激时所得分数 <== begin
        
        % 本电极的spiketime表
        this_spif_spiketime = spif.spiketimes{ hwID };
        
        % 比scan_start_point还大的第一个spiketime就是第一个spike发生的时间
        % 找到在指定时间范围内的spikes        
        candidate_spikes = this_spif_spiketime( this_spif_spiketime > scan_start_point ...
        & this_spif_spiketime < scan_start_point + calculating_range);
    
        % 将候选spike按照Calculating_Range进行分布
        candidate_spikes = candidate_spikes - scan_start_point;
        % 经过histc得到每个区段的spike计数，越早期的权值越高，越末期的权值越低
        sorted_candidate_spikes = histc(candidate_spikes, edges);

        % 计算本次刺激成绩，并追加至本电极计分矢量中
        tmp_varargout = varargout{serial_of_sti_elec + number_of_sti_elec};
        if size(sorted_candidate_spikes,1) == size(weights,1)
            tmp_varargout{hwID, :} = [tmp_varargout{hwID, :} sum(sorted_candidate_spikes .* weights)];
        elseif size(sorted_candidate_spikes,1) == size(weights,2)
            tmp_varargout{hwID, :} = [tmp_varargout{hwID, :} sum(sorted_candidate_spikes .* weights')];
        end
        varargout{serial_of_sti_elec + number_of_sti_elec} = tmp_varargout;
        
        % 计算本电极本次刺激时所得分数 ==> end
        
        hwID = hwID + 1;
    end
    
    % 计算下一个刺激电极
    if serial_of_sti_elec == number_of_sti_elec
        % 若已经循环到最后一个刺激电极，则还原
        serial_of_sti_elec = 1;
    else
        % 递增到下一个刺激电极
        serial_of_sti_elec = serial_of_sti_elec + 1;
    end
end

% 计算总结果
for i = 1:number_of_sti_elec
    tmp_varargout_input = varargout{i+number_of_sti_elec};
    tmp_varargout_output = varargout{i};
    
    for hwID = 1:64
        % 将各次刺激的结果平均
        tmp_varargout_output(hwID) = mean(tmp_varargout_input{hwID});
        
        % 预先将NAN和EMPTY置0，增加程序后续处理的稳定性
        if isnan( tmp_varargout_output(hwID) )
            tmp_varargout_output(hwID) = 0;
        elseif isempty( tmp_varargout_output(hwID) )
            tmp_varargout_output(hwID) = 0;
        end
            
    end
    varargout{i} = tmp_varargout_output;
end

end

