function [ isMatched ] = util_check_trigger_belongs_amp(stimulation, n, amp)
% UTIL_CHECK_TRIGGER_BELONGS_AMP 工具函数：检查本次Trigger是否是指定刺激电压
%   根据刺激方案（stimulation），检查本次（即刺激方案中的第n次）trigger是否
%   是由指定电压上（amp）给定的。
%
%   蒲江波 2010年5月5日

id_in_trigger = stimulation(n).pulse_amplitude;

if (id_in_trigger == amp)
    isMatched = true;
else
    isMatched = false;
end

end
