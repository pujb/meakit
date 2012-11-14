function [ result num ] = util_sti_responses_elictedby_one_elec( varargin )
%UTIL_STI_RESPONSES_ELICTEDBY_ONE_ELEC 工具函数：由某一个特定的刺激电极刺激后的全通道响应
%   从刺激响应中，挑选出由给定电极刺激后的全皿其他的所有通道上各自的响应。
%   
%   输入参数：
%       responses：各个通道的响应；
%       amplitudes：各个通道的响应对应的幅度值（一般是峰峰值）；
%       elecs：对应responses上，通道的ChID；
%       stipro：刺激方案；
%       sti_id：指定的刺激通道号；
%
%   输出参数：
%       result：分析结果
%       num：是指由STI_ID给定刺激的Trigger的数目
%
%   Eg：
%   [result num] = util_sti_responses_elictedby_one_elec('responses',
%   responses, 'elecs', elecs, 'stipro', stimulation, 'sti_id', 47, 'amplitudes', amplitudes)
%
%   蒲江波 2010年5月4日

pvpmod(varargin);

% 检查参数

if ~exist('responses', 'var')
    error('RESPONSES must be provided.');
end

if ~exist('amplitudes', 'var')
    error('AMPLITUDES must be provided.');
end

if ~exist('elecs', 'var')
    error('ELECS must be provided.');
end

if ~exist('stipro', 'var')
    error('STIMULATION PROTOCOL must be provided.');
end

if ~exist('sti_id', 'var')
    error('STI_ID must be provided.');
end

h = waitbar(0, 'Please wait...');
set(h, 'Name', 'Please wait...');

num_trigger = length(responses{1});

% 计算在指定电极刺激时，总共有多少种变化
[ ~, variation_electrodes variation_duration variation_amplitude variation_shapes variation_isi, ~ ] = util_parse_para_fromstimulation(stipro);
%
% TEMPLATE Put your code here 可根据不同变化情况初始化结果变量
%
% TEMPLATE Init result arrays here
for i=1:length(variation_amplitude)
    for j = 1:64
        % TIMING
        result.(['amp' num2str(variation_amplitude(i))]).timing.(['ch' num2str(util_convert_hw2ch(j))]).all = {};
        % AMPLITUDE
        result.(['amp' num2str(variation_amplitude(i))]).amplitude.(['ch' num2str(util_convert_hw2ch(j))]).all = {};
        
        % NUMBER OF RESPONSES
        
        result.(['amp' num2str(variation_amplitude(i))]).num_response.(['ch' num2str(util_convert_hw2ch(j))]).all = [];
        result.(['amp' num2str(variation_amplitude(i))]).num_response.(['ch' num2str(util_convert_hw2ch(j))]).stat.mean = 0;
        result.(['amp' num2str(variation_amplitude(i))]).num_response.(['ch' num2str(util_convert_hw2ch(j))]).stat.std = 0;
        result.(['amp' num2str(variation_amplitude(i))]).num_response.(['ch' num2str(util_convert_hw2ch(j))]).stat.sem = 0;
        % 该观察电极上在指定刺激电极、指定刺激电压下的Trigger总数
        result.(['amp' num2str(variation_amplitude(i))]).num_response.(['ch' num2str(util_convert_hw2ch(j))]).stat.num = 0;
        % 该观察电极上在指定刺激电极、指定刺激电压下的，有Response的Trigger总数
        result.(['amp' num2str(variation_amplitude(i))]).num_response.(['ch' num2str(util_convert_hw2ch(j))]).stat.num_response = 0;
        
        % FIRST RESPONSE DELAY
        
        result.(['amp' num2str(variation_amplitude(i))]).first_response_delay.(['ch' num2str(util_convert_hw2ch(j))]).all = [];
        result.(['amp' num2str(variation_amplitude(i))]).first_response_delay.(['ch' num2str(util_convert_hw2ch(j))]).stat.mean = 0;
        result.(['amp' num2str(variation_amplitude(i))]).first_response_delay.(['ch' num2str(util_convert_hw2ch(j))]).stat.std = 0;
        result.(['amp' num2str(variation_amplitude(i))]).first_response_delay.(['ch' num2str(util_convert_hw2ch(j))]).stat.sem = 0;
        % 该观察电极上在指定刺激电极、指定刺激电压下的Trigger总数
        result.(['amp' num2str(variation_amplitude(i))]).first_response_delay.(['ch' num2str(util_convert_hw2ch(j))]).stat.num = 0;
        % 该观察电极上在指定刺激电极、指定刺激电压下的，有Response的Trigger总数
        result.(['amp' num2str(variation_amplitude(i))]).first_response_delay.(['ch' num2str(util_convert_hw2ch(j))]).stat.num_response = 0;
        
        % FIRST RESPONSE AMPLITUDE
        
        result.(['amp' num2str(variation_amplitude(i))]).first_response_amplitude.(['ch' num2str(util_convert_hw2ch(j))]).all = [];
        result.(['amp' num2str(variation_amplitude(i))]).first_response_amplitude.(['ch' num2str(util_convert_hw2ch(j))]).stat.mean = 0;
        result.(['amp' num2str(variation_amplitude(i))]).first_response_amplitude.(['ch' num2str(util_convert_hw2ch(j))]).stat.std = 0;
        result.(['amp' num2str(variation_amplitude(i))]).first_response_amplitude.(['ch' num2str(util_convert_hw2ch(j))]).stat.sem = 0;
        % 该观察电极上在指定刺激电极、指定刺激电压下的Trigger总数
        result.(['amp' num2str(variation_amplitude(i))]).first_response_amplitude.(['ch' num2str(util_convert_hw2ch(j))]).stat.num = 0;
        % 该观察电极上在指定刺激电极、指定刺激电压下的，有Response的Trigger总数
        result.(['amp' num2str(variation_amplitude(i))]).first_response_amplitude.(['ch' num2str(util_convert_hw2ch(j))]).stat.num_response = 0;
    end
end

% 在所有Trigger中遍历，如果该Trigger属于指定电极输出的刺激，则纳入计算
num = 0;    % 对应电极的刺激个数

for trigger = 1:num_trigger
    if (util_check_trigger_belongs_elec(stipro,trigger,sti_id))
        % 本次Trigger属于指定的刺激电极发出的刺激
        num = num + 1;
        
        % 在观察电极中循环
        for hwid = 1:64
            % 计算各种统计量
            % TEMPLATE Put your code here
            %
            % 判断本电压
            i = find(variation_amplitude==stipro(trigger).pulse_amplitude);
            
            % 本电压下本观察电极下的Trigger数++
            result.(['amp' num2str(variation_amplitude(i))]).num_response.(['ch' num2str(util_convert_hw2ch(hwid))]).stat.num = result.(['amp' num2str(variation_amplitude(i))]).num_response.(['ch' num2str(util_convert_hw2ch(hwid))]).stat.num + 1;
            result.(['amp' num2str(variation_amplitude(i))]).first_response_delay.(['ch' num2str(util_convert_hw2ch(hwid))]).stat.num = result.(['amp' num2str(variation_amplitude(i))]).first_response_delay.(['ch' num2str(util_convert_hw2ch(hwid))]).stat.num + 1;
            result.(['amp' num2str(variation_amplitude(i))]).first_response_amplitude.(['ch' num2str(util_convert_hw2ch(hwid))]).stat.num = result.(['amp' num2str(variation_amplitude(i))]).first_response_amplitude.(['ch' num2str(util_convert_hw2ch(hwid))]).stat.num + 1;

            % 判断本次Trigger有无response
            if (isempty(responses{hwid}{trigger}))
                hasResponse = false;
            else
                hasResponse = true;
                % 本电压下本观察电极下的诱发出Response的Trigger数++
                result.(['amp' num2str(variation_amplitude(i))]).num_response.(['ch' num2str(util_convert_hw2ch(hwid))]).stat.num_response = result.(['amp' num2str(variation_amplitude(i))]).num_response.(['ch' num2str(util_convert_hw2ch(hwid))]).stat.num_response + 1;
                result.(['amp' num2str(variation_amplitude(i))]).first_response_delay.(['ch' num2str(util_convert_hw2ch(hwid))]).stat.num_response = result.(['amp' num2str(variation_amplitude(i))]).first_response_delay.(['ch' num2str(util_convert_hw2ch(hwid))]).stat.num_response + 1;
                result.(['amp' num2str(variation_amplitude(i))]).first_response_amplitude.(['ch' num2str(util_convert_hw2ch(hwid))]).stat.num_response = result.(['amp' num2str(variation_amplitude(i))]).first_response_amplitude.(['ch' num2str(util_convert_hw2ch(hwid))]).stat.num_response + 1;
            end
            
            % NUMBER OF RESPONSE
            first_response = responses{hwid}{trigger};
            result.(['amp' num2str(variation_amplitude(i))]).num_response.(['ch' num2str(util_convert_hw2ch(hwid))]).all = [result.(['amp' num2str(variation_amplitude(i))]).num_response.(['ch' num2str(util_convert_hw2ch(hwid))]).all length(first_response)];
            
            % TIMING(放在这里计算的是全部的Trial)
            result.(['amp' num2str(variation_amplitude(i))]).timing.(['ch' num2str(util_convert_hw2ch(hwid))]).all = [result.(['amp' num2str(variation_amplitude(i))]).timing.(['ch' num2str(util_convert_hw2ch(hwid))]).all {first_response}];
            
            % FIRST RESPONSE DELAY
            if (~hasResponse)
                % no response = not count
                % result.(['amp' num2str(variation_amplitude(i))]).first_response_delay.(['ch' num2str(util_convert_hw2ch(hwid))]).all = [result.(['amp' num2str(variation_amplitude(i))]).first_response_delay.(['ch' num2str(util_convert_hw2ch(hwid))]).all 0];
            else
                result.(['amp' num2str(variation_amplitude(i))]).first_response_delay.(['ch' num2str(util_convert_hw2ch(hwid))]).all = [result.(['amp' num2str(variation_amplitude(i))]).first_response_delay.(['ch' num2str(util_convert_hw2ch(hwid))]).all first_response(1)];
                % TIMING(放在这里计算的是有response的Trial)
                % result.(['amp' num2str(variation_amplitude(i))]).timing.(['ch' num2str(util_convert_hw2ch(hwid))]).all = [result.(['amp' num2str(variation_amplitude(i))]).timing.(['ch' num2str(util_convert_hw2ch(hwid))]).all {first_response}];
            end
            
            first_response = amplitudes{hwid}{trigger};

            % AMPLITUDE(放在这里计算的是全部的Trial)
            result.(['amp' num2str(variation_amplitude(i))]).amplitude.(['ch' num2str(util_convert_hw2ch(hwid))]).all = [result.(['amp' num2str(variation_amplitude(i))]).amplitude.(['ch' num2str(util_convert_hw2ch(hwid))]).all {first_response}];
            
            % FIRST RESPONSE AMPLITUDE
            if (~hasResponse)
                % no response = not count
                % result.(['amp' num2str(variation_amplitude(i))]).first_response_amplitude.(['ch' num2str(util_convert_hw2ch(hwid))]).all = [result.(['amp' num2str(variation_amplitude(i))]).first_response_amplitude.(['ch' num2str(util_convert_hw2ch(hwid))]).all 0];
            else
                result.(['amp' num2str(variation_amplitude(i))]).first_response_amplitude.(['ch' num2str(util_convert_hw2ch(hwid))]).all = [result.(['amp' num2str(variation_amplitude(i))]).first_response_amplitude.(['ch' num2str(util_convert_hw2ch(hwid))]).all first_response(1)];
                % AMPLITUDE(放在这里计算的是有response的Trial)
                % result.(['amp' num2str(variation_amplitude(i))]).amplitude.(['ch' num2str(util_convert_hw2ch(hwid))]).all = [result.(['amp' num2str(variation_amplitude(i))]).amplitude.(['ch' num2str(util_convert_hw2ch(hwid))]).all {first_response}];
            end
        end
    end
    waitbar(trigger/num_trigger, h, ['Triggers ' num2str(trigger) ' / ' num2str(num_trigger)]);
end
result.total_num = num;
result.description = 'amp(mV), all time in ms';
% 计算各种统计量
% TEMPLATE Put your code here
for i=1:length(variation_amplitude)
    for j = 1:64
        % NUMBER OF RESPONSES
        
        result.(['amp' num2str(variation_amplitude(i))]).num_response.(['ch' num2str(util_convert_hw2ch(j))]).stat.mean = mean(result.(['amp' num2str(variation_amplitude(i))]).num_response.(['ch' num2str(util_convert_hw2ch(j))]).all);
        result.(['amp' num2str(variation_amplitude(i))]).num_response.(['ch' num2str(util_convert_hw2ch(j))]).stat.std = std(result.(['amp' num2str(variation_amplitude(i))]).num_response.(['ch' num2str(util_convert_hw2ch(j))]).all);
        result.(['amp' num2str(variation_amplitude(i))]).num_response.(['ch' num2str(util_convert_hw2ch(j))]).stat.sem = result.(['amp' num2str(variation_amplitude(i))]).num_response.(['ch' num2str(util_convert_hw2ch(j))]).stat.std / sqrt(result.(['amp' num2str(variation_amplitude(i))]).num_response.(['ch' num2str(util_convert_hw2ch(j))]).stat.num);
        
        % FIRST RESPONSE DELAY

        result.(['amp' num2str(variation_amplitude(i))]).first_response_delay.(['ch' num2str(util_convert_hw2ch(j))]).stat.mean = mean(result.(['amp' num2str(variation_amplitude(i))]).first_response_delay.(['ch' num2str(util_convert_hw2ch(j))]).all);
        result.(['amp' num2str(variation_amplitude(i))]).first_response_delay.(['ch' num2str(util_convert_hw2ch(j))]).stat.std = std(result.(['amp' num2str(variation_amplitude(i))]).first_response_delay.(['ch' num2str(util_convert_hw2ch(j))]).all);
        result.(['amp' num2str(variation_amplitude(i))]).first_response_delay.(['ch' num2str(util_convert_hw2ch(j))]).stat.sem = result.(['amp' num2str(variation_amplitude(i))]).first_response_delay.(['ch' num2str(util_convert_hw2ch(j))]).stat.std / sqrt(result.(['amp' num2str(variation_amplitude(i))]).first_response_delay.(['ch' num2str(util_convert_hw2ch(j))]).stat.num_response);
        
        % FIRST RESPONSE AMPLITUDE
        
        result.(['amp' num2str(variation_amplitude(i))]).first_response_amplitude.(['ch' num2str(util_convert_hw2ch(j))]).stat.mean = mean(result.(['amp' num2str(variation_amplitude(i))]).first_response_amplitude.(['ch' num2str(util_convert_hw2ch(j))]).all);
        result.(['amp' num2str(variation_amplitude(i))]).first_response_amplitude.(['ch' num2str(util_convert_hw2ch(j))]).stat.std = std(result.(['amp' num2str(variation_amplitude(i))]).first_response_amplitude.(['ch' num2str(util_convert_hw2ch(j))]).all);
        result.(['amp' num2str(variation_amplitude(i))]).first_response_amplitude.(['ch' num2str(util_convert_hw2ch(j))]).stat.sem = result.(['amp' num2str(variation_amplitude(i))]).first_response_amplitude.(['ch' num2str(util_convert_hw2ch(j))]).stat.std / sqrt(result.(['amp' num2str(variation_amplitude(i))]).first_response_amplitude.(['ch' num2str(util_convert_hw2ch(j))]).stat.num_response);
    end
end
close(h);
end