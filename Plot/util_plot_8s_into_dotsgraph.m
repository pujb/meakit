function [ the_frame ] = util_plot_8s_into_dotsgraph( varargin )
%UTIL_PLOT_8S_INTO_DOTSGRAPH 工具函数：将一个8*8的矩阵绘制成圆点图
%   是plot_mea_dotsgraph函数的升级版本。
%   能够将一个8*8的矩阵，绘制成根据数值大小变换直径和着色的圆点图
%
%   输入参数：
%       the_matrix：8*8的输入矩阵
%       haveAxes：是否要有坐标轴（默认有），不绘制坐标轴则会自动标记四周电极
%       haveGrid：是否要有网格（默认没有）
%       haveIndicator：是否显示最大值点（默认没有）
%       isFigureWindowStayedOpen：绘图完成后是否保持窗口打开（默认打开，但也可不打开，因为已经保存结果the_frame）
%       the_title：题目（默认有值）
%   输出参数：
%       the_frame：保存成1帧
%
%   See also plot_mea_dotsgraph
%
%   蒲江波 2009年11月24日

pvpmod(varargin);

% 参数分析

if ~exist('the_matrix', 'var')
    error('THE_MATRIX must be provided.');
end

if ~exist('haveAxes', 'var')
    haveAxes = 1;
end

if ~exist('haveGrid', 'var')
    haveGrid = 0;
end

if ~exist('haveIndicator', 'var')
    haveIndicator = 0;
end

if ~exist('isFigureWindowStayedOpen', 'var')
    isFigureWindowStayedOpen = 1;
end

if ~exist('the_title', 'var')
    the_title = 'Network Status';
end

% 取得矩阵的大小（本函数事实上兼容更大矩阵的绘制）
networksize = length(the_matrix);
s = 0;

% 绘图参数量
scatterX = zeros(networksize^2,1);
scatterY = zeros(networksize^2,1);
scatterS = zeros(networksize^2,1);

% 颜色
scatterC = zeros(networksize^2,3);
value_max = max( max(the_matrix) );
value_min = min(min(the_matrix));
colorscaling = value_max - value_min + 0.001;

% 绘制电极圆点
multiply_factor = 300;

for i = 1:networksize
    for j = 1:networksize
        s = s+1;
        scatterX(s,1) = i;
        scatterY(s,1) = j;
        scatterS(s,1) = the_matrix(i,j) / value_max * multiply_factor + 0.001;
        
        if i==1&&j==1 || i==1&&j==8 || i==8&&j==1 || i==8&&j==8
            scatterC(s,:) = [1 1 1];
        else
            scatterC(s,:) = [(the_matrix(i,j) - value_min) / colorscaling 0 0];
        end
    end
end

% 实际绘图语句
scatter(scatterX,scatterY,scatterS, scatterC, 'filled');

% 绘制BAR（根据value_max,min标记）
if haveIndicator
    size_max = max( scatterS );
    size_min = min( scatterS );

    color_max = [(value_max - value_min) / colorscaling 0 0];
    color_min = [0 0 0];

    bar_location_x = 9;
    bar_location_ymax = 7;
    bar_location_ymin = 8;

    hold on
    scatter(bar_location_x, bar_location_ymax, size_max, color_max, 'filled');
    
    label_max = num2str( fix( value_max ) );
    if length( label_max ) == 3
        label_location_fix = 0.2;
    elseif length( label_max ) == 2
        label_location_fix = 0.12;
    elseif length( label_max ) == 1
        label_location_fix = 0.1;
    else
        label_location_fix = 0;
    end
    text(bar_location_x - label_location_fix, bar_location_ymax, label_max);
    hold off
end

% 绘制坐标轴
xlabel('MEA Columns');
ylabel('MEA Rows');
axis([0 (networksize+2) 0 (networksize+1)]);
set(gca,'YDir','reverse')

if haveAxes
    set(gca, 'XColor', [0 0 0]);
    set(gca, 'YColor', [0 0 0]);
else
    set(gca, 'XColor', [1 1 1]);
    set(gca, 'YColor', [1 1 1]);
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    % 标记四周电极
    text(0.9, 1, '11');
    text(0.9, 8, '18');
    text(7.85, 1, '81');
    text(7.85, 8, '88');
end

title(the_title,'fontsize',12,'fontweight','bold');

if haveGrid
    grid on;
end

% 保存绘图结果
the_frame = getframe;

if ~isFigureWindowStayedOpen
    close(gcf);
end
   
end

