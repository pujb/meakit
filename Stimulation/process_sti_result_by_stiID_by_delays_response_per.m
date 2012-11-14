%PROCESS_STI_RESULT_BY_STIID_BY_DELAYS_RESPONSE_PER
%工具函数：提取刺激参数中，某个电极各个TBS刺激间隔下，全皿各个通道的统计结果
%   输入参数：
%       paraname：要统计的参数名，例如'num_response'，对应result里面的结构；
%       sti_id：刺激电极；
%
%   输出参数：
%       analysis：分析结果
%
% 蒲江波 2010年5月17日

% 计算在指定电极刺激时，总共有多少种变化
variation_delays = {'control' '50ms' '10ms' '5ms'};
amplitude = '200';
paraname = 'num_response';
sti_id = 54;


for hwid = 1:64
    % 跳过刺激电极
    if (sti_id == util_convert_hw2ch(hwid))
        continue;
    end
    
    %创建结果结构体
    analysis.(['ch' num2str(util_convert_hw2ch(hwid))]).x = [1:length(variation_delays)];
    analysis.(['ch' num2str(util_convert_hw2ch(hwid))]).y = [];
    analysis.(['ch' num2str(util_convert_hw2ch(hwid))]).e = [];
    
    % 在不同delay下循环，提取参数，存入结果结构体
    for j=1:length(variation_delays)
        temp_str = strcat('may14_result_', variation_delays(j), '_sti', num2str(sti_id));
        result = eval(temp_str{1});
        analysis.(['ch' num2str(util_convert_hw2ch(hwid))]).y = [analysis.(['ch' num2str(util_convert_hw2ch(hwid))]).y ...
            result.(['amp' amplitude]).(paraname).(['ch' num2str(util_convert_hw2ch(hwid))]).stat.mean];
        analysis.(['ch' num2str(util_convert_hw2ch(hwid))]).e = [analysis.(['ch' num2str(util_convert_hw2ch(hwid))]).e ...
            result.(['amp' amplitude]).(paraname).(['ch' num2str(util_convert_hw2ch(hwid))]).stat.sem];
    end
end

util_plot_8s_into_arraymap(analysis,[15 sti_id])
clear variation_delays amplitude paraname hwid j temp_str;


clear analysis
variation_rate = {'baseline' 'finished'};
gnd = 15;

for j = 1:length(variation_rate)
    temp_str = strcat('may14_', variation_rate(j), '_spif');
    [~, avg, ~, ~, avg_sem] = util_calc_spb_avg_elec( 'spif', eval(temp_str{1}), 'gnd', gnd);

    for hwid = 1:64
        % 跳过接地电极
        if (util_convert_hw2ch(hwid) == 15)
            continue;
        end
        
        % 创建结果结构体
        analysis.(['ch' num2str(util_convert_hw2ch(hwid))]).x = [1:length(variation_rate)];
        
        % 分别计算Baseline/Finished的参数
        analysis.(['ch' num2str(util_convert_hw2ch(hwid))]).y(j) = avg(hwid);
        analysis.(['ch' num2str(util_convert_hw2ch(hwid))]).e(j) = avg_sem(hwid);
    end
end

util_plot_8s_into_arraymap_bar(analysis,[gnd],1);
clear variation_rate gnd temp_str hwid j;






