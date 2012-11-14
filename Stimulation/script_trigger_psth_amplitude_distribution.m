function [] = script_trigger_psth_amplitude_distribution()
%SCRIPT_TRIGGER_PSTH_AMPLITUDE_DISTRIBUTION 脚本：处理刺激Trigger后的Spike统计信息
%   1：程序运行时要求输入一个MCD文件（SPIKE）
%   2：若有多个Trigger数据流存在，程序要求用户选择
%   其他参数请酌情手动调整 -_-!...
%
%   蒲江波 - 2009年5月22日
%   蒲江波 - 2009年5月31日
%       引入统一的util_load_spike_trigger_mcdstream_whold_length()函数来提取spif/trigger
%       信息。
%   蒲江波 - 2009年7月3日
%       Bug Fix: 修复了若没有响应时，psth_y为空的Bug。

% 打开文件，读取mcd数据流
[D spif triggerif] = util_load_spike_trigger_mcdstream();

% 获取通道号
chid = input('请输入通道号：');

% Bin的大小（即是时间的Bin也是幅度的跳跃Bin，当然可以自己改）
binsize = 5;

% 获取Trigger的总数目
trigger_total_counts = size(triggerif.times,2);
disp(['总共有 ' num2str(trigger_total_counts) '个Trigger']);

% 设置每个步长里面要计算多少个Trigger
trigger_step_counts = 20;

% 设置PSTH覆盖的时间范围
psth_range = [-50 450];

% 计算PSTH和PS幅度分布

for i = 1:trigger_step_counts:trigger_total_counts
    trigger_end = i + trigger_step_counts - 1;
    disp(['正在处理第' num2str(i) '到' num2str(trigger_end) '个Trigger的信息']);
    
    [psth_x psth_y] = util_psth_by_trigger( triggerif, spif, chid, binsize, psth_range, [i trigger_end], 1, 1 );
%     [psAMP_x psAMP_y] = util_psth_amplitude_by_trigger( triggerif, spif, D, chid, binsize, psth_range, [i trigger_end], 1, 1, 2 );
    
%     if isempty(psth_y)
%         psth_y = zeros(1, size(psth_x, 2));
%     end
%     
%     figure, bar(psth_x, psth_y), title(['PSTH' num2str(i) '-' num2str(trigger_end)]),xlabel('Time(ms)'),ylabel('Probability');
%     
%     if ~isempty(psAMP_y)
%         figure, bar(psAMP_x, psAMP_y), title(['AMPLITUDE - PSTH' num2str(i) '-' num2str(trigger_end)]),xlabel('Amplitude(uV)'),ylabel('Probability');
%     end
        
    
    
end


end

