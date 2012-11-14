function [ prob edges slope fitresult gof] = util_plot_avalanche_hist( x, xname, varargin )
%UTIL_PLOT_AVALANCHE_HIST Plot the probability of avalanche characters like
%Profs Begg / Plenz's paper.
%   Input:
%           x:          xDATA, e.g. The size array of avalanches
%           xname:      x's name, used for generate labels
%           mcolor:     Marker's color, [default]: [1 1 1]
%           lcolor:     Line's color, [default]: [0 0 0]
%           lineoff:    If true, only plot dots. [default]: false
%           nogap:      If true, the values = 0 will be ignores to avoid
%                       Inf at log scale. [default: false]
%           doplot:     If true, plot the graph. [default: true]
%           draw_slope: If true, draw the slope. [default: true]
%           overlay:    If true, the plotter will not create a new figure
%                       but using the old palette. [default: false]
%           method:     'fit' [default] / 'plfit' / 'polyfit'
%                       Curvefit method. When the number of samples is
%                       large enough, try plfit, else, fit is more
%                       robust, and polyfit is better when running batch
%                       jobs (it will not quit by bad fitting, but less robust)
%                   
%   Output:
%           prob:   The P(x)
%           edges:  The x axis
%           slope:  The slope of this curve (fit to ax^b, = a)
%           fitresult:  The fitting result.
%           gof:    The godness of fit.
%
%   Examples:
%           util_plot_avalanche_hist( sizes, 'S' );
%
%           [ prob edges slope fitresult gof] = util_plot_avalanche_hist(
%           sizes, 'S' );
%
%   Created on Jul/31/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2010-09-15  Fix the line gap bug, Add 'lineoff' option.
%       PJB#2010-09-17  Add 'nogap' option: Sometimes, we need those Inf
%                       gaps to be displayed.
%                       Add 'doplot' option.
%                       Add curvefit function, 'slope' / 'fitresult' /
%                       'gof'. Please ref to NEUROSCIENCE (commented)
%       PJB#2011-03-08  Adding new 'plfit' method


pvpmod(varargin);

if ~exist('mcolor', 'var')
    mcolor = [0 0 0];
end

if ~exist('lcolor', 'var')
    lcolor = [0 0 0];
end

if ~exist('lineoff', 'var')
    lineoff = false;
end

if ~exist('nogap', 'var')
    nogap = false;
end

if ~exist('doplot', 'var')
    doplot = true;
end

if ~exist('draw_slope', 'var')
    draw_slope = true;
end

if ~exist('overlay', 'var')
    overlay = false;
end

if ~exist('method', 'var')
    method = 'fit';
end


edges = 1:1:max(x);
prob = histc(x, edges);
prob = prob / sum(prob);

% locate the index of zero-prob
if nogap
    edges = find(prob ~= 0);
    prob = prob(prob ~= 0);
end

% Plot
if doplot
    if lineoff
        if ~overlay
            figure
        else
            hold on
        end
        plot(edges, prob, 'o', 'MarkerFaceColor', lcolor, 'MarkerSize', 2);
    else
        if ~overlay
            figure
        else
            hold on
        end
        plot(edges, prob, '-o', 'MarkerFaceColor', mcolor, 'Color', lcolor, 'MarkerSize', 2);
    end
    set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
    xlabel(xname); ylabel(['P(' xname ')']);
end

% Curve fit (Ref to V. Pasquale et al. / Neuroscience 153 (2008) 1354¨C1369)

% levels: (we only focus on points bigger than 1% of the maxiumum value of
% the distribution, but you can modify this parameter to get some other
% results)
levels = 0.01;
loc_index = find(prob < levels, 1);
edges_fit = edges(1:loc_index)';
prob_fit = prob(1:loc_index)';

if strcmpi(method, 'fit')
    % Using built-in fit function to get 'a' & 'n'
    fit_op = fitoptions('Method', 'NonlinearLeastSquares');
    fit_func = fittype('a * ( x ^ n )', 'options', fit_op );
    
    warning_state = warning('query', 'backtrace');
    warning('off', 'backtrace');
    [fitresult, gof] = fit(edges_fit(2:end), prob_fit(2:end), fit_func); % The first bin is ignored (ref NEUROSCIENCE)
    warning(warning_state.state, 'backtrace');
    
    slope = fitresult.n;
    
    % Plot fit results
    if doplot && draw_slope
        hold on;
        plot(edges_fit(2:end), fitresult.a * edges_fit(2:end) .^ slope, 'r', 'linewidth', 2);
        hold off;
    end
elseif strcmpi(method, 'plfit')
    if strcmp(method, 'plfit')
        % Using plfit to correct the result
        slope = -1 * plfit(prob_fit(2:end), 'finite');
    end
    
    % Don't support these output
    fitresult = [];
    gof = [];
    
    % Plot fit results
    if doplot && draw_slope
        hold on;
        plot(edges_fit(2:end), 1 * edges_fit(2:end) .^ slope, 'r', 'linewidth', 2);
        hold off;
    end
elseif strcmpi(method, 'polyfit')
    p = polyfit(log10(edges_fit(2:end)), log10(prob_fit(2:end)), 1);
    slope = p(1);
    fitresult = [];
    gof = [];
    
    % Plot fit results
    if doplot && draw_slope
        hold on;
        plot(edges_fit(2:end), 1 * edges_fit(2:end) .^ slope, 'r', 'linewidth', 2);
        hold off;
    end
end


disp(['Fitted Slope: ' num2str(slope)])

end

