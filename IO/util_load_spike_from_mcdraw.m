function [ D spif raw] = util_load_spike_from_mcdraw ( varargin )
%UTIL_LOAD_SPIKE_FROM_MCDRAW 工具函数，从mcd文件中检测Spike
%   输入参数：
%       filename = 要处理的文件名，默认无
%       segment_size = 如果要分段处理，每段的长度（ms），默认60000
%       startend = [start end] 起止时间，默认是全程，单位是ms
%       gnd = [15 16 ...]，接地电极号码，默认是15
%       threshold = n，n倍STD，Spike提取的阈值，默认是？
%       threshold_sample_startend = [start end] ms，采样STD的时间范围，默认是segment_size
%       PLP = n ms，Spike的峰宽，默认是2 ms
%       RP = n ms，Spike提取的不应期，默认是1 ms
%       NPA，是选择负向峰，还是选择最大绝对值峰（即不论正负向），默认true，选择负向峰
%   输出参数：
%       D，文件对象
%       spif，Spike信息结构体
%       raw，可选，若需要raw数据时可返回。注意，数据过长时会Out of Memory.
%
%   蒲江波 - 2010年5月21日

pvpmod(varargin);

% 参数分析

if nargout == 3
    needraw = true;
end

if exist('filename', 'var')
    [~] = evalc('D = datastrm(filename)');
else
    [~] = evalc('D = datastrm(''open'')');
end

if isempty(D)
    error('A MCD file must be selected.');
end

if exist('segment_size', 'var')
    limited_size = segment_size;
else
    limited_size = 60000; % 1min
end

if ~exist('gnd', 'var')
    gnd = 15;
end

if ~exist('threshold', 'var')
    threshold = 10;
end

if ~exist('PLP', 'var')
    PLP = 2;
end

if ~exist('RP', 'var')
    RP = 1;
end

if ~exist('NPA', 'var')
    NPA = true;
end

% 起止时间
if exist('startend', 'var')
    start_time = startend(1); % *1000
    stop_time = startend(2); % *1000
    if start_time < getfield(D, 'sweepStartTime')
        warning('UTIL:SPIKEDET', 'Start time must be bigger than sweepStartTime, is automatically set to sweepStartTime.');
        start_time = getfield(D, 'sweepStartTime');
    end
    if stop_time > getfield(D, 'sweepStopTime');
        warning('UTIL:SPIKEDET', 'Stop time must be smaller than sweepStopTime, is automatically set to sweepStopTime.');
        stop_time = getfield(D, 'sweepStopTime');
    end
else
    start_time = getfield(D, 'sweepStartTime');
    stop_time = getfield(D, 'sweepStopTime');
end

% STD采样起止时间
if exist('threshold_sample_startend', 'var')
    thsample_start_time = threshold_sample_startend(1);
    thsample_end_time = threshold_sample_startend(2);
    if thsample_start_time < start_time
        warning('UTIL:SPIKEDET', 'Threshold sampling start time must be bigger than start time, is automatically set to start time.');
        thsample_start_time = start_time;
    end
    if thsample_end_time > end_time
        warning('UTIL:SPIKEDET', 'Threshold sampling end time must be smaller than start time, is automatically set to end time.');
        thsample_end_time = end_time;
    end
else
    thsample_start_time = start_time;
    thsample_end_time = end_time;
end

% 显示文件信息
disp(['Start:' datestr(getfield(D, 'recordingdate')) ', Stop: '  datestr(getfield(D, 'recordingdate')) ', Length: ' num2str(getfield(D, 'sweepStopTime')) ' ms.']);

% 显示提取Spike的参数信息
disp(['Threshold = ' num2str(threshold) ' * STD; STD Sampling = [' num2str(thsample_start_time) ' ' num2str(thsample_start_time) '] ms.' ]);
disp(['PLP = ' num2str(PLP) 'ms, RP = ' num2str(RP) 'ms.']);
if NPA
    disp('Only negative peak is detected.');
else
    disp('Both positive and negative peak can be detected.');
end

% 进入实质处理部分
% 获取时间分辨率
timeres = getfield(d,'MicrosecondsPerTick');

% 将时间从ms转换为数据点
PLP = util_convert_ms2dp(PLP, timeres);
RP = util_convert_ms2dp(RP, timeres);

% 将采样起止时间从ms的时间位置转换为数据点位置
thsample_start_time = util_locate_index_by_millisecond(thsample_start_time, timeres, 0);
thsample_end_time = util_locate_index_by_millisecond(thsample_end_time, timeres, 0);

% 读取数据流
% 找到Raw数据流
[stream_number raw_streamname] = util_find_rawstream(D);
if stream_number < 1
    error('没有Raw数据流');
elseif stream_number > 1
    % 有多于一个的Raw数据流
    % 列出Raw数据流的名称，让用户选择
    for i = 1:stream_number
        disp(raw_streamname{i});
    end
    user_entry = input('请输入想要计算的序号：');
    
    raw_streamname_selected = raw_streamname{user_entry};
else
    raw_streamname_selected = raw_streamname{1};
end

% 至此，获得了Raw数据流的名字，储存在raw_streamname_selected里

% 读取Raw信息

if (stop_time - start_time) > limited_size;
    % 太长，分段读取，拼合
    
    % 处理RAW数据流部分
    h = waitbar(100, 'Processing RAW data...');
    
    % 建立用于存放最终结果的SPIF结构体，cell外面围的{}很重要，去掉会出错。
    spif = struct('spiketimes', {cell(64,1)}, 'spikevalues', {cell(64,1)}, 'startend', [start_time stop_time]);
    
    % 首先循环（即，可以用limited_size整除的）
    for i = start_time:limited_size:stop_time
        spif_segment = nextdata(D, 'streamname', spike_streamname_selected, 'startend', [i i+limited_size]);
        spif.spiketimes = util_connect_spif_spiketimes(spif.spiketimes, spif_segment.spiketimes);
        % 如果指定了compact参数，则会压缩spikevalue表        
        if (isCompact)
            spif_segment.spikevalues = util_compact_spif_spikevalues(spif_segment.spikevalues);
        end
        spif.spikevalues = util_connect_spif_spikevalues(spif.spikevalues, spif_segment.spikevalues);
        
        waitbar(i/(stop_time - start_time), h, ['Processed SPIF: ' num2str(fix(i/1000/60)) ' minutes']);
        clear spif_segment;
    end
    close(h);
    
    % BUGFIX
    % 不需要计算剩余部分的，因为在最后一次i里面，虽然i+limited_size是>stop_time的，但是nextdata会自动读
    % 到stoptime为止，还计算剩余部分是一个冗余
    % 计算残余的部分
    % spif_segment = nextdata(D, 'streamname', spike_streamname_selected, 'startend', [i stop_time]);
    % spif.spiketimes = util_connect_spif_spiketimes(spif.spiketimes, spif_segment.spiketimes);
    % 如果指定了compact参数，则会压缩spikevalue表（残余部分）        
    % if (isCompact)
    %    spif_segment.spikevalues = util_compact_spif_spikevalues(spif_segment.spikevalues);
    % end
    % spif.spikevalues = util_connect_spif_spikevalues(spif.spikevalues, spif_segment.spikevalues);
else
    % 正常读取
    
    % 获得RAW信息
    rawif = nextdata(D,'streamname', raw_streamname_selected,'startend',[start_time stop_time]);

    % 循环每个通道
    for hwid = 1:64
        % 判断是否属于不需要处理的电极
        if ~util_find_a_in_b( util_convert_hw2ch(hwid), [11 18 81 88 gnd] )
            % 提取SPIKE
            [spv, spt]= SpkDet_PTSD_SA(rawif.data(hwid,:)', threshold * std(y(thsample_start_time:thsample_end_time)), PLP, RP, NPA);
        
        end
    end
    
    
end

% 显示Spike的个数
disp(['Total Spikes']);

end

