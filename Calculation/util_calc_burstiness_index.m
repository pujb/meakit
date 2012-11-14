function [ bi ] = util_calc_burstiness_index( varargin )
%UTIL_CALC_BURSTINESS_INDEX 工具函数：计算给定数据的BI值
%   根据Daniel Wagenaar，Controlling Burst文章定义，计算BI值
%   This program is derived from Jon Newman's bindex function
%   BI = BINDEX(ASDR) calculates the burstiness index of a given ASDR by
%   finding the percent of total spikes that are accounted for by the highest 15%
%   of bins in the ASDR series. If BI = 1, all spikes occur in bursts, if
%   BI = 0 then there is perfect tonic firing with no variation in firing
%
%   BI = BINDEX(ASDR,TOP) provide a top-end ASRD percentage to define
%   burstiness. If not defined, top = 15%.
%
%   输入参数：
%       spb，SPSA（应指定bin = 1000ms）
%       top，指定的百分比，默认为15（15%）
%   输出参数：
%       bi，Burstiness Index
%
%   蒲江波 2010年5月20日

% 形参分析
pvpmod(varargin);

if ~exist('spb', 'var')
    error('SPB must be provided.');
end

if ~exist('top', 'var')
    top = 15;
end

% 转换为百分比
top = 15 / 100;

% 给定SPB中，所有的Spike总数
total_spikes = sum(spb);

% 将SPB排序（高->低）
sorted_list = sort(spb, 'descend');

% F15 or F-top
f15 = sum(sorted_list(1:round(top*length(spb))))/total_spikes;

% BI
bi = (f15 - top) / (1 - top);

end

