function [ n e d a s i t ] = util_parse_para_fromstimulation( stimulation )
%UTIL_PARSE_PARA_FROMSTIMULATION 工具函数：从刺激方案结构体中解析出方案所包含的各种刺激波形的变化范围
%   分析刺激方案结构体，得到在该结构体中包含的刺激波形变化信息，如
%   在本文件中包含多少个刺激，在多少个电极（不重复）上施行，幅度、持续时间等方面
%   的变化范围。
%
%   输入参数：
%       stimulation：刺激方案结构体
%   输出参数：
%       n：总刺激个数
%       e：刺激涉及的电极
%       d：Phase Duration
%       a：Pulse Amplitude
%       s：Pulse Shape
%       i：Inter-stimulus Interval
%       t：Time Window [start end]
%
%   蒲江波 2010年5月4日

% Get length
n = length(stimulation);

% Get time window
t = [stimulation(1).time stimulation(n).time];

% Init
e = [];
d = [];
a = [];
s = [];
i = [];

for j = 1:n
   % Make sure the current parameters are not in each list.
   % If they are not repeated, Add into the list.
   if (~util_find_a_in_b(stimulation(j).elec, e))
       e = [e stimulation(j).elec];
   end

   if (~util_find_a_in_b(stimulation(j).phase_duration, d))
       d = [d stimulation(j).phase_duration];
   end
   
   if (~util_find_a_in_b(stimulation(j).pulse_amplitude, a))
       a = [a stimulation(j).pulse_amplitude];
   end
   
   if (~util_find_a_in_b(stimulation(j).shape, s))
       s = [s stimulation(j).shape];
   end
   
   if (~util_find_a_in_b(stimulation(j).inter_stimulus_interval, i))
       i = [i stimulation(j).inter_stimulus_interval];
   end
end

e = sort(e);
d = sort(d);
a = sort(a);
s = sort(s);
i = sort(i);


end

