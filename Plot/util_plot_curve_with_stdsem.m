function [avg sem stdev total] = util_plot_curve_with_stdsem(datapoints, avgpoints)
%UTIL_PLOT_CURVE_WITH_STDSEM Plot a mean curve with std/sem error bars

% FOR GAP JUNCTION PAPER 2008
% Calculating the averaged and std/sem of a curve

% avg : the averaged curve (of avg_points)
% sem : the sem of the avg_points of the dataset
% std : the std of ...
% total : total points of the dataset

total = length(datapoints);
counts = 1;
i = 1;

while i <= total
    if (i+avgpoints-1) <= total
        segments = datapoints(i:(i + avgpoints - 1));
        % fix the std (too big, while changing stages)
        unstable_point_pos = util_find_first_unstable_point(segments,avgpoints,0.4);
        if  unstable_point_pos == 0
            segments = datapoints(i:(i + avgpoints - 1));
            avgp = avgpoints;
        elseif unstable_point_pos == 2
            segments = datapoints(i:(i + unstable_point_pos - 1));
            avgp = unstable_point_pos;
        elseif unstable_point_pos > 2
            segments = datapoints(i:(i + unstable_point_pos - 2));
            avgp = unstable_point_pos - 1;
        end
        
        avg(counts) = mean(segments);
        stdev(counts) = std(segments);
        sem(counts) = stdev(counts) / sqrt(avgp);
        
        counts = counts + 1;
        i = i + avgp;
    else
        segments = datapoints(i:total);
        
        avg(counts) = mean(segments);
        stdev(counts) = std(segments);
        sem(counts) = stdev(counts) / sqrt(total - i + 1);
        
        counts = counts + 1;
        i = i + avgpoints;
    end
end

errorbar(avg, sem, 'k');
end

function pos = util_find_first_unstable_point(datapoints, range, threshold)
%UTIL_FIND_FIRST_UNSTABLE_POINT Return the first point which
prev = datapoints(1);
for i = 2:range
    if abs(datapoints(i) - prev) > threshold
        pos = i;
        return;
    end
end
pos = 0;
end