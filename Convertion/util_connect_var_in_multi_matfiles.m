function [result] = util_connect_var_in_multi_matfiles(the_varname)
%UTIL_CONNECT_VAR_IN_MULTI_MATFILES 工具函数：将多个MAT文件中的某个变量名中的数据连接起来
%   在一个或多个.mat文件中可能都包含了同一个名字的变量var，本函数能够根据用户
%   选择的.mat文件顺序，将其中的变量数据连接起来，返回。
%
%   the_var_name = 变量名字
%
%   蒲江波 2008年 (为Gap Junction文章数据处理编写，目的是连接多个文件中的SPSA)
%   蒲江波 2009年
%   编写注释

[filename, pathname] = uigetfile('*.mat','MultiSelect','ON');
% 显示文件顺序
disp(char(filename));

% 判断是多个文件还是单个文件
if iscell(filename)
    % 多个文件
    for i = 1:length(filename)
        tmp_filename = [pathname char(filename(i))];
        load(tmp_filename, the_varname);

        if (i == 1)
            tmp_var = eval(the_varname);
        else
            tmp_var = [tmp_var eval(the_varname)];
        end
    end        
else
    % 单个文件
    tmp_filename = [pathname filename];
    load(tmp_filename, the_varname);
    tmp_var = eval(the_varname);
end

result = tmp_var;
end