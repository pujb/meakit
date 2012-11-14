function [Q q] = util_sub_get_sync(spiketimesA, spiketimesB)    %#codegen
%GET_SYNC The core calculation part.
% Pu Jiangbo 2010-11-08 Original
% Pu Jiangbo 2011-04-02 Extract this part into a sub-function
% Pu Jiangbo 2011-05-16 Making MEX. (Speed up x 6)
%                       Removing verbose output.
% Pu Jiangbo 2012-07-04 Adding assert for Codegen

% Assert Class for Codegen
assert(isa(spiketimesA,'double'));
assert(isa(spiketimesB,'double'));

nx = length(spiketimesA);
ny = length(spiketimesB);
% loop for c_x|y
cxy = 0; 
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
end
% loop end c_x|y

% loop for c_y|x
cyx = 0; 
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
end
% loop end c_x|y

Q = (cxy + cyx) / sqrt(nx * ny);
q = (cyx - cxy) / sqrt(nx * ny);
end


function x1 = mymin(x1, x2, x3, x4) %#codegen
%#codegen
% Use for speeding up the searching of min
% Only support length(x) = 4
% Pu Jiangbo 2010-11-08
% Pu Jiangbo 2011-04-03: Speedup by not using [].
% Pu Jiangbo 2011-05-16: Making it MEX
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