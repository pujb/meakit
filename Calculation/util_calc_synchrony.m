function [ Q q Qn qn ] = util_calc_synchrony( spif, chlist, varargin )
%UTIL_CALC_SYNCHRONY Measure the synchrony between selected channels
%   Input:
%           spif:       Spike information structure
%           chlist:     'all' - All channels
%                       [11 22 ... 88] - Selected channels, must >= 2
%           method:     'single' - just calc chlist(1) to chlist(2), useful
%                                  for being called by another function
%                                  like util_calc_corr_matrix. if at this
%                                  mode, progress bar and verbose
%                                  information will not shown.
%                       'matrix' - calc all values between, default.
%           GND:        [11 22 ...] - A list of grounding channels
%                       default: []
%           do_n:       if true, calc time resolved variants of Q/q.
%                       default: false
%   Output:
%           Q/q/Qn/qn, please refer to [PRE] P. Grassberger et. al. (2002)
%           Q:          [0,1]. 1 = Fully synchronized.
%           q:          [-1,1]. 1:means a always precede b.
%           Qn:         Time resolved variants of Q.
%           qn:         Time resolved variants of q.
%
%   Format:
%           1   2  
%       a a->1 a->2
%       b b->1 b->2
%
%   Created on Nov/06/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2010-11-08  Bug fix and adding mymin() to speed up.
%       PJB#2011-04-03  Speed up mymin() again, speed up x ~3.
%       PJB#2011-05-16  Make MEX of mymin & get_sync, speed up x ~6.

% Please note, do_n,qn,Qn have not implemented.

pvpmod(varargin);

if ~exist('GND', 'var')
    GND = [];
end

if ~exist('do_n', 'var')
    do_n = false;
end

if ~exist('method', 'var')
    method = 'matrix';
end

if strcmpi(method, 'single')
    verbose = 0;
else
    verbose = 1;
end

% Check chlist then convert it into hw format
if ischar(chlist)
    if strcmpi(chlist, 'all')
        chlist = (1:64);
    else
        error('Wrong format of CHLIST.');
    end
else
    chlist = util_convert_ch2hw(chlist);
end

% Remove GND(s)
GND = unique([GND 11 88 18 81]);
GND = util_convert_ch2hw(GND);
for i = 1:length(GND)
    chlist(chlist == GND(i)) = [];
end

% Check channel number
if length(chlist) < 2
    error('Too few channels.')
end

if verbose
    disp('Selected electrodes:')
    disp(util_convert_hw2ch(chlist))
end

if strcmpi(method, 'single')
    % Just calc one pair, from chlist(1) to (2)
    spiketimesA = spif.spiketimes{chlist(1)};
    spiketimesB = spif.spiketimes{chlist(2)};
    [Q q] = util_sub_get_sync_mex(spiketimesA, spiketimesB);
    Qn = []; qn = [];   % not yet implemented
elseif strcmpi(method, 'matrix')
    % Init (-99 to init all Q, then we know if Q~=-99, this Q has existed)
    Q = ones(length(chlist), length(chlist)) * -99;
    q = zeros(length(chlist), length(chlist));
    Qn = []; qn = [];   % not yet implemented
    
    % Loop
    for chA = 1:length(chlist)
        spiketimesA = spif.spiketimes{chlist(chA)};
        
        for chB = 1:length(chlist)
            % Check if checking itself
            if chA == chB
                Q(chA, chB) = 1;
                q(chA, chB) = 0;
                if verbose
                    disp(['Between ' num2str(util_convert_hw2ch(chlist(chA))) ' & ' num2str(util_convert_hw2ch(chlist(chB))) ':'])
                    fprintf('\t ... Automatically = 1.\n');
                end
                continue;
            end
            % Check if checking symmetrical pairs
            if Q(chB, chA) ~= -99
                Q(chA, chB) = Q(chB, chA);
                q(chA, chB) = -1 * q(chB, chA);
                if verbose
                    disp(['Between ' num2str(util_convert_hw2ch(chlist(chA))) ' & ' num2str(util_convert_hw2ch(chlist(chB))) ':'])
                    fprintf('\t ... Automatically get the value.\n');
                end
                continue;
            end
            
            % J-ij
            if verbose
                disp(['Between ' num2str(util_convert_hw2ch(chlist(chA))) ' & ' num2str(util_convert_hw2ch(chlist(chB))) ':'])
                fprintf('\t ... ');
            end
            spiketimesB = spif.spiketimes{chlist(chB)};
            [Qi qi] = util_sub_get_sync_mex(spiketimesA, spiketimesB);
            
            if verbose
                fprintf('Done.\n');
            end
            
            Q(chA, chB) = Qi;
            q(chA, chB) = qi;
        end
    end
end



end

% This is replaced by mymin in (util_sub_get_sync_mex)
function x1 = mymin(x1, x2, x3, x4)
% Use for speeding up the searching of min
% Only support length(x) = 4
% Pu Jiangbo 2010-11-8
% Pu Jiangbo 2011-4-3: Speedup by not using [].
if x1 > x2
    x1 = x2;
end
if x3 > x4
    x3 = x4;
end
if x1 > x3
    x1 = x3;
end
end

% This is replaced by util_sub_get_sync_mex
% But this version keeps the ability to output a progress info. "verbose"
function [Q q] = get_sync(spiketimesA, spiketimesB, verbose)
%GET_SYNC The core calculation part.
% Pu Jiangbo 2010-11-8 Original
% Pu Jiangbo 2011-04-2 Extract this part into a sub-function
if verbose
    fprintf('\t C(x|y)... ');
end
nx = length(spiketimesA);
ny = length(spiketimesB);
% loop for c_x|y
cxy = 0;    progress = 0;
for x = 1:nx
    if x == 1
        x_t_m1 = 0;
    else
        x_t_m1 = spiketimesA(x - 1);
    end
    if x == nx
        x_t_p1 = spiketimesA(end);
    else
        x_t_p1 = spiketimesA(x + 1);
    end
    x_t = spiketimesA(x);
    for y = 1:ny
        if y == 1
            y_t_m1 = 0;
        else
            y_t_m1 = spiketimesB(y - 1);
        end
        if y == ny
            y_t_p1 = spiketimesB(end);
        else
            y_t_p1 = spiketimesB(y + 1);
        end
        y_t = spiketimesB(y);
        % Determine Tau
        tau = mymin( x_t_p1-x_t, x_t-x_t_m1, y_t_p1-y_t, y_t-y_t_m1 ) / 2;
        % Determine J-ij
        if (x_t - y_t) > 0 && (x_t - y_t) < tau
            cxy = cxy + 1;
        elseif x_t == y_t
            cxy = cxy + 0.5;
        end
    end
    if verbose
        % Progress
        if ~mod(fix(10 * (x / nx)) * 10, 10) && fix(10 * (x / nx)) * 10 ~= progress
            progress = fix(10 * (x / nx)) * 10;
            util_show_progress_rounding(progress);
        end
    end
end
% loop end c_x|y

if verbose
    fprintf('\t C(y|x)... ');
end
% loop for c_y|x
cyx = 0;    progress = 0;
for y = 1:ny
    if y == 1
        y_t_m1 = 0;
    else
        y_t_m1 = spiketimesB(y - 1);
    end
    if y == ny
        y_t_p1 = spiketimesB(end);
    else
        y_t_p1 = spiketimesB(y + 1);
    end
    y_t = spiketimesB(y);
    for x = 1:nx
        if x == 1
            x_t_m1 = 0;
        else
            x_t_m1 = spiketimesA(x - 1);
        end
        if x == nx
            x_t_p1 = spiketimesA(end);
        else
            x_t_p1 = spiketimesA(x + 1);
        end
        x_t = spiketimesA(x);
        % Determine Tau
        tau = mymin( x_t_p1-x_t, x_t-x_t_m1, y_t_p1-y_t, y_t-y_t_m1 ) / 2;
        % Determine J-ij
        if (y_t - x_t) > 0 && (y_t - x_t) < tau
            cyx = cyx + 1;
        elseif x_t == y_t
            cyx = cyx + 0.5;
        end
    end
    
    if verbose
        % Progress
        if ~mod(fix(10 * (y / ny)) * 10, 10) && fix(10 * (y / ny)) * 10 ~= progress
            progress = fix(10 * (y / ny)) * 10;
            util_show_progress_rounding(progress);
        end
    end
end
% loop end c_x|y

Q = (cxy + cyx) / sqrt(nx * ny);
q = (cyx - cxy) / sqrt(nx * ny);
end
