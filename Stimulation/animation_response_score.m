function [ movie_frm ] = animation_response_score( result_cell_array )
%ANIMATION_RESPONSE_SCORE 将成绩Cell矩阵的内容绘制成动画
%   读入UTIL_STI_CALC_TEST_SCORE_MULTIPLE_ARRAYWIDE产生的结果矩阵（非均值阵，而是保存有每次刺激响应数据
%   的后面几对计算结果），并将结果矩阵中的数据分拆成若干帧（有多少次刺激，就有多少帧）。将每一帧的结果利用plot_mea_dotsgraph绘制
%   成图，并将图形存入frame阵列，作为结果返回。这个阵列可以运用movie函数绘制成电影，用movie2gif函数绘制成gif动画。
%
%   输入参数：util_sti_calc_test_score_multiple_arraywide产生的结果
%   输出参数：movie文件
%
%   See also PLOT_MEA_DOTSGRAPH,
%   UTIL_STI_CALC_TEST_SCORE_MULTIPLE_ARRAYWIDE,
%   UTIL_PLOT_8S_INTO_DOTSGRAPH
%
%   蒲江波 2009年11月24日


% 计算动画的帧数
% 方法是计算result_cell_array里面各个子cell的维数，取最大的

max_dimension = 0;

for i = 1:64
    this_dimension = size( result_cell_array{i}, 2 );
    if this_dimension > max_dimension
        max_dimension = this_dimension;
    end
end

number_of_frames = max_dimension;

% 将每帧绘制成动画
% 方法是将传入数据中每次刺激的响应取出，并依旧按照电极序列绘制成图，利用getframe保存。
% 绘图利用了早先编写的plot_mea_dotsgraph代码基础

for i = 1:number_of_frames
    tmp_vector = zeros(1,64);
    for hwID = 1:64
        if size( result_cell_array{hwID},2 ) < number_of_frames
            tmp_vector(hwID) = 0;
        else
            tmp_vector(hwID) = result_cell_array{hwID}(i);
        end
    end
    
    tmp_vector_s = util_convert_64to8s(tmp_vector);
    
    movie_frm(i) = util_plot_8s_into_dotsgraph('the_matrix', tmp_vector_s, 'haveAxes', 0, 'isFigureWindowStayedOpen', 1, 'haveIndicator', 1);
end
end

