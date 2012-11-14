function results = util_find_maxlength_of_chs( SPT )
%UTIL_FIND_MAXLENGTH_OF_CHS 工具函数：利用MCS信息，找到Spike Table中最长的通道
% 给出Spike Train中Spike数目最多的通道
% 结果是以hwid给出，需要转换
% 
% 蒲江波 2008年 (为Gap Junction Paper编写的工具函数)


max_length_of_channels = 0;

for i = 1:64
    if max_length_of_channels < length( SPT{i} )
        max_length_of_channels = length( SPT{i} );
    end
end

results = max_length_of_channels;

end