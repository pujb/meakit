function [ isMatched ] = util_check_trigger_belongs_elec(stimulation, n, sti_id)
% UTIL_CHECK_TRIGGER_BELONGS_ELEC 工具函数：检查本次Trigger是否是指定电极上给定的
%   根据刺激方案（stimulation），检查本次（即刺激方案中的第n次）trigger是否
%   是在指定电极上（sti_id）给定的。
%
%   蒲江波 2010年5月4日

id_in_trigger = stimulation(n).elec;

if (id_in_trigger == sti_id)
    isMatched = true;
else
    isMatched = false;
end

end
