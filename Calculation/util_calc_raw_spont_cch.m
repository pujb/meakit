function [ lags cch peak] = util_calc_raw_spont_cch( varargin )
%UTIL_CALC_RAW_SPONT_CCH 工具函数：从SPIF中计算自发活动的相关直方图（Raw）
%   从给定SPIF结构体中计算两个电极之间的相关性，计算时没有使用各种correct方法，是raw直方图。
%   输入参数：
%               'spif'  spif结构体，必须给定
%               'ref'   参考电极，必须给定
%               'obs'   观察电极，必须给定
%               'bin'   bin的长度，单位ms，默认10 ms
%               'nlag'  使用histc方法时，窗口正向长度，单位ms，默认500 ms（负向对称）
%               'startend'      要计算的信号记录时间范围，单位ms，默认全程
%               'verbose'       是否显示计算参数等细节信息，默认不显示
%               'findpeakw'     是否返回峰值宽度，默认返回；若不计算则返回0（建议多试几个bin，特别是10ms bin比较可靠）
%               'normalization' 使用histc方法时的归一方法，默认为概率，'prob'。（prob可能导致不对称现象）
%                   'counts_bin'    每个bin内有多少count
%                   'prob'          counts_bin除以ref的counts，或执行其他的归一方法到[0 1]间
%               'method'        计算方法：
%                   'histc'     使用histc计算[default]，注意，使用这个方法时，归一化之后会导致失去严格的对称性（46/47的peak值和47/46的不一样，但曲线形状是一样的）
%                   'xcorr'     使用xcorr计算，此时normalization自动归一化到[0 1]，这个方法的问题是速度较慢。
%                   'migram'    使用migram计算互信息，此时normalization自动归一化到[0 1]，这个方法的问题也是速度慢。
%                   'corrgram'  使用corrgram计算互相关，此时归一化情况不明，一般而言是[0 1]，速度慢。
%                   'mi'        使用nmi计算互信息（无直方图，只有一个值），可选择归一到[0 1]，速度快。
%                   速度：mi > histc > xcorr > corrgram > migram
%   返回参数：
%               'lags'  x轴，bin分布
%               'cch'   y轴，直方图
%               'peak'  峰值结构体
%                       .value Peak值
%                       .position 峰值的位置（单位ms）
%                       .width 峰的宽度（单位ms）
%                       峰宽查找中部分原理请参考findpeaks函数（最小二乘拟合法）
%
% Eg.
% [d spif trif] = util_load_spike_trigger_mcdstream('isCompact',1);
% list = [ 12 13 14 15 16 17 ];
% for i = 1:length(list)
%     [lags cch] = util_calc_raw_spont_cch('spif',spif,'ref',21,'obs',list(i),'bin',10);
%     subplot(1,length(list)+1,i),plot(lags,cch),ylim([0 1]),axis off;
% end
% subplot(1,length(list)+1,length(list)+1),plot((-500:500:500),0),hold on,stem(0,1),ylim([0 1]);axis off
%
%   蒲江波 2010年3月22日
%       完成计算互相关的基本逻辑（startend未实现）
%   蒲江波 2010年3月23日
%       完成Startend参数的编写，完成峰值.value,.position的编写。（宽度未实现）
%   蒲江波 2010年3月24日
%       实现对互相关峰的准确测算（借助findpeaks函数），修改显示参数设置，修复各类运算中可能出现的Bug
%   蒲江波 2011年3月27日
%       增加了使用xcorr运算的方式，全面检查了整个程序的逻辑，改进了peak
%       width的运算逻辑，修复了各类Bug，特别是实现了对称的互相关运算
%   蒲江波 2011年3月28日
%       增加了使用migram/corrgram运算.
%       修改window_max/min为nlag，使各个方法调用形式统一。

% 分析输入参数
pvpmod(varargin);

if ~exist('spif', 'var')
    error('SPIF must be provided.');
end

if ~exist('ref', 'var')
    error('Reference Electrode # must be provided.');
end

if ~exist('obs', 'var')
    error('Observing Electrode # must be provided.');
end

if ~exist('bin', 'var')
    bin = 10;
end

if ~exist('nlag', 'var')
    nlag = 500;
end

if ~exist('startend', 'var')
    start_time = spif.startend(1);
    stop_time = spif.startend(2);
else
    if startend(1) < spif.startend(1) || startend(1) >= startend(2)
        start_time = spif.startend(1);
    end
    if startend(2) > spif.startend(2) || startend(2) <= startend(1)
        stop_time = spif.startend(2);
    end
end

if ~exist('verbose', 'var')
    verbose = 0;
end

if ~exist('findpeakw', 'var')
    findpeakw = 1;
end

if ~exist('normalization', 'var')
    normalization = 'prob';
end

if ~exist('method', 'var')
    method = 'histc';
end

% 显示参数设置
if verbose
    cprintf('Comments', ['Bin width = ' num2str(bin) ' ms\n']);
    cprintf('Comments', ['Reference electrode# = ' num2str(ref) '\n']);
    cprintf('Comments', ['Observing electrode# = ' num2str(obs) '\n']);
    cprintf('Comments', ['Range from ' num2str(-1*nlag) ' to ' num2str(nlag) ' ms\n']);
end

% 创建Spiketime Table的副本
ref_times = spif.spiketimes{util_convert_ch2hw(ref)};
obs_times = spif.spiketimes{util_convert_ch2hw(obs)};

% 根据指定的时间长度处理Spiketime Table，把不在指定时间长度范围内的删除掉
ref_times(ref_times < start_time | ref_times > stop_time) = [];
obs_times(obs_times < start_time | obs_times > stop_time) = [];

% 获取两个序列的长度
ref_num = size(ref_times,1);
obs_num = size(obs_times,1);

if strcmpi(method, 'histc')
    % 初始化互相关直方图最终结果变量
    % 初始化lags
    lags = -1 * nlag : bin : nlag;
    
    if isempty(find(lags==0, 1))
        error('You may want to choose another bin or window range to correctly place 0.');
    end
    
    % 初始化cch
    cch = zeros(length(lags),1);
    
    % 计算
    for i = 1:ref_num
        % 用观察电极每个spike发生的时刻减去第i个参考电极spike
        difference = obs_times - ref_times(i);      % in ms
        
        % 将差值计算到每个bin内
        i_bin = histc(difference, lags);
        
        % 累计
        try
            cch = cch + i_bin;
        catch ME
            if obs_num == 1
                cch = cch + i_bin';
            else
                rethrow(ME)
            end
            
        end
    end
    
    % 计算正交化
    if strcmp(normalization,'prob')
        cch = cch / ref_num;
    end
elseif strcmpi(method, 'xcorr')
    % In this mode:
    % Bin is set by histc
    % Normalization is performed by xcorr 'coeff'
    % 注意，xcorr方法比较慢（~7倍），计算出来的波形是大致类似的（bin=10），max值不同
    
    % 初始化lags
    lags = -1 * nlag : bin : nlag;
   
    if isempty(find(lags==0, 1))
        error('You may want to choose another bin or window range to correctly place 0.');
    end
    
    if ref ~= obs
        % 互相关
        [cch lags] = xcorr(histc(obs_times, start_time:bin:stop_time), histc(ref_times, start_time:bin:stop_time), nlag/bin, 'coeff');
    else
        % 自相关
        [cch lags] = xcorr(histc(obs_times, start_time:bin:stop_time), nlag/bin, 'coeff');
    end
    % 修正lags
    lags = lags * bin;
elseif strcmpi(method, 'migram')
    % In this mode:
    % Bin is set by histc
    % Normalization is performed by migram 'norm'
    % 注意，mi方法也比较慢（比xcorr慢），也是对称的。
    
    % 初始化lags
    lags = -1 * nlag : bin : nlag;
    num_bins = length(lags);
    window_length = length(start_time:bin:stop_time);
    
    if isempty(find(lags==0, 1))
        error('You may want to choose another bin or window range to correctly place 0.');
    end
    
    [cch lags] = migram(histc(obs_times, start_time:bin:stop_time), histc(ref_times, start_time:bin:stop_time), nlag/bin, window_length, 0, num_bins/bin, 'norm');
    % 修正lags
    lags = lags * bin;
elseif strcmpi(method, 'corrgram')
    % In this mode:
    % Bin is set by histc
    % Normalization is performed by migram 'norm'
    % 注意，mi方法也比较慢（比xcorr慢），也是对称的。
    
    % 初始化lags
    lags = -1 * nlag : bin : nlag;
    window_length = length(start_time:bin:stop_time);
    
    if isempty(find(lags==0, 1))
        error('You may want to choose another bin or window range to correctly place 0.');
    end
    
    [cch lags] = corrgram(histc(obs_times, start_time:bin:stop_time), histc(ref_times, start_time:bin:stop_time), nlag/bin, window_length, 0);
    % 修正lags
    lags = lags * bin;
elseif strcmpi(method, 'mi')
    % In this mode:
    % Bin is set by histc
    % Normalization is performed by default.(you can use MI.m for non-normalized result)
    % 注意，没有直方图的结果，所以不能测算peak位置和宽度
    
    if strcmp(normalization,'prob')
        cch = nmi(histc(obs_times, start_time:bin:stop_time), histc(ref_times, start_time:bin:stop_time));
    else
        cch = MI(histc(obs_times, start_time:bin:stop_time), histc(ref_times, start_time:bin:stop_time));
    end
    
    lags = 0;
    % 不支持peak width
    findpeakw = 0;
else
    error('wrong input: method');
end


% 峰值计算
% 峰值
peak.value = max(cch);

% 峰值位置
peak.position = lags(cch == peak.value);
if length(peak.position) > 1
    if verbose
        cprintf('Red', '>= 2 peaks deteced, please recheck the result if needed.\n');
    end
    peak.width = 0;
    return;
end

% 计算峰宽度

% 若用户指定不查找峰宽度（可能增加耗时），则直接返回
if ~findpeakw
    peak.width = 0;
    return;
end

fitwidth = 3;

while 1
    % 尝试寻找合适的峰值
    P = findpeaks(lags, cch, 0, max(cch) / 10, 3, fitwidth);
    if (isnan(P(1)) || P(1) == 0 || isempty(P))
        % fitwidth取值不合适
        if fitwidth <= window_max - window_min
            fitwidth = fitwidth + 1;
            continue;
        else
            if verbose
                cprintf('Red', 'Peak width error. Set to 0. \n');
            end
            peak.width = 0;
            break;
        end
    else
        % 有P矩阵，则检查P矩阵中是否包含之前发现的peak峰值位置
        p = find(P(:,2) == peak.position);
        if p
            % 存在一致的peak位置，则返回对应的峰宽
            r = P(:,4);
            if isnan(r(p)) || r(p) <= 0
                % 虽然位置对，但是找的峰宽不对
                % 继续找
                if fitwidth <= window_max - window_min
                    fitwidth = fitwidth + 1;
                    continue;
                else
                    if verbose
                        cprintf('Red', 'Peak width error. Set to 0. \n');
                    end
                    peak.width = 0;
                    break;
                end
            else
                % 峰宽正常值
                peak.width = r(p);
                break;
            end
        else
            % 没有准确一致的peak峰值位置
            if fitwidth <= window_max - window_min
                fitwidth = fitwidth + 1;
                continue;
            else
                if verbose
                    cprintf('Red', 'Peak width error. Set to 0. \n');
                end
                peak.width = 0;
                break;
            end
        end
    end
end

end

