function [ score_vector ] = util_sti_calc_test_score_arraywide( varargin )
%UTIL_STI_CALC_TEST_SCORE_ARRAYWIDE 计算一个皿内的刺激响应成绩
%   计算一个皿内的刺激响应成绩。本程序依赖于util_sti_calc_test_score.m
%   同时依赖于提供spif和trif的函数util_load_spike_trigger_mcdstream.m(或其多文件版本)
%
%   传入参数：
%       stimulating_chid：施加刺激的电极（例如12,87)，可选。如果给定，则刺激电极可以保证为0分
%                         否则因为伪迹的存在，不一定是0分
%       calculating_range：计算的时间，ms为单位，该参数传递给util_sti_calc_test_score
%       filename：要打开的文件，若不提供，则会提示对话框
%
%   传出参数：
%       score_vector：将util_sti_calc_test_score返回的平均成绩列成一个序列。
%       这个序列中同样包含那些一定没有信号的电极，可以用util_convert64to8s变成8*8阵，然后用来绘图
%       e.g. util_convert_64to8s(s)
%
%   蒲江波 2009年11月21日
%    

pvpmod(varargin);

% 参数分析

if ~exist('calculating_range', 'var')
    % 不指定calculating_range参数则程序退出
    error('The CALCULATING_RANGE must be set.');
end

if ~exist('stimulating_chid', 'var')
    disp('Stimulting Elec: NOT SET');
    have_set_stimulating_elec = 0;
else
    disp(['Stimulating Elec: ' num2str(stimulating_chid)]);
    have_set_stimulating_elec = 1;
end

% 打开文件
if ~exist('filename', 'var')
    [D spif trif] = util_load_spike_trigger_mcdstream();
else
    [D spif trif] = util_load_spike_trigger_mcdstream('filename', filename);
end

% 在所有电极中遍历，将每个电极上的成绩汇总到一个向量里面
hwID = 1;
score_vector = zeros( 1,64 );
while hwID < 65
    % 排除电极
    if hwID == 1 || hwID == 8 || hwID == 57 || hwID == 64
        hwID = hwID + 1;
        continue;
    end
    
    % 排除刺激电极（不排除的话，可能会有本不该有的成绩）
    if have_set_stimulating_elec
        if hwID == util_convert_ch2hw(stimulating_chid)
            continue;
        end
    end
    
    % 计算本电极分数
    [s a ma mi mid] = util_sti_calc_test_score(spif, trif, util_convert_hw2ch(hwID), calculating_range, 1, 0);
    score_vector(hwID) = a;
    
    hwID = hwID + 1;
end

end

