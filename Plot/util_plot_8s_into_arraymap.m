function [ handle ] = util_plot_8s_into_arraymap( data, closed )
%UTIL_PLOT_8S_INTO_ARRAYMAP 工具函数：将数据绘制成8*8的图（类似Daniel文章）
%   将输入的数据按照指定要求绘制成8*8排布的曲线图
%
%   输入参数：
%       closed：接地电极或其他不想显示的电极（如[15 33]）
%       data：输入的用于绘图的数据，该数据需要遵循一定的格式
%           如data.ch11.x,y中是要绘图的数据
%       
%   输出参数：
%       handle：图像句柄
%
%   蒲江波 2010年5月6日

figure('Name','MEA Plot')
axis off;
set(gca,'xtick',[],'ytick',[]);

% 初始化各向最大值
max_X = -Inf;
min_X = Inf;
max_Y = -Inf;
min_Y = Inf;

for hwid = 1:64
    % 判断当前subplot位置
    if ~(util_convert_hw2ch(hwid) == 11 || ...
         util_convert_hw2ch(hwid) == 18 || ...
         util_convert_hw2ch(hwid) == 81 || ...
         util_convert_hw2ch(hwid) == 88 || ...
         ~isempty(find(closed == util_convert_hw2ch(hwid), 1)))
        % 画数据
        subplot(8,8,getpos(util_convert_hw2ch(hwid)));
        try
            errorbar(data.(['ch' num2str(util_convert_hw2ch(hwid))]).x, data.(['ch' num2str(util_convert_hw2ch(hwid))]).y, data.(['ch' num2str(util_convert_hw2ch(hwid))]).e,'k');
        catch
            % 无数据，则将此电极自动加入到closed列表
            closed = [closed util_convert_hw2ch(hwid)];
        end
        if (isempty(find(closed==util_convert_hw2ch(hwid), 1)))
            % 获取坐标轴值
            max_X = getbigger(max_X, max(data.(['ch' num2str(util_convert_hw2ch(hwid))]).x));
            max_Y = getbigger(max_Y, max(data.(['ch' num2str(util_convert_hw2ch(hwid))]).y));
            min_X = getsmaller(min_X, min(data.(['ch' num2str(util_convert_hw2ch(hwid))]).x));
            min_Y = getsmaller(min_Y, min(data.(['ch' num2str(util_convert_hw2ch(hwid))]).y));
        end
        
        set(gca,'xtick',[],'ytick',[])
        axis off;
        drawnow;
    end
end

% 再次循环统一坐标轴
for hwid = 1:64
    % 判断当前subplot位置
    if (util_convert_hw2ch(hwid) == 88)
        % 画比例尺
        subplot(8,8,getpos(util_convert_hw2ch(hwid)));
        plot([max_X max_X], [min_Y max_Y],'k');
        hold on;
        plot([min_X max_X], [min_Y min_Y],'k');
        hold off;
        text(max_X,max_Y,num2str(max_Y));
        text(max_X,min_Y,['(' num2str(max_X) ',' num2str(min_Y) ')']);
        text(min_X,min_Y,num2str(min_X));
    elseif (find(closed == util_convert_hw2ch(hwid)))
        % 画X
        subplot(8,8,getpos(util_convert_hw2ch(hwid)));
        plot([min_X max_X],[max_Y min_Y],'k');
        hold on;
        plot([min_X max_X],[min_Y max_Y],'k');
        hold off;
    end
    
    subplot(8,8,getpos(util_convert_hw2ch(hwid)));
    set(gca,'xtick',[],'ytick',[])
    if (util_convert_hw2ch(hwid) == 11 || ...
        util_convert_hw2ch(hwid) == 18 || ...
        util_convert_hw2ch(hwid) == 81 || ...
        util_convert_hw2ch(hwid) == 88)
        axis off;
    else
        axis on;
        box off;
        set(gca,'XColor',[1 1 1], 'YColor', [1 1 1]);
    end
    % 统一设置最大最小值
    xlim([min_X max_X]);
    ylim([min_Y max_Y]);
    drawnow;
end


handle = gcf;

end


function [pos] = getpos(channelID)
%GETPOS 辅助函数：计算某通道在8*8图上的index位置
%   蒲江波 2010年5月6日

chID = num2str(channelID);
colID = str2num(chID(1));
rowID = str2num(chID(2));

pos = (rowID - 1) * 8 + colID;

end

function [val] = getbigger(a,b)
%GETBIGGER 辅助函数：返回a,b中较大的数
%   蒲江波 2010年5月6日

if (a>b)
    val = a;
else
    val = b;
end

end

function [val] = getsmaller(a,b)
%GETBIGGER 辅助函数：返回a,b中较小的数
%   蒲江波 2010年5月6日

if (a<b)
    val = a;
else
    val = b;
end

end