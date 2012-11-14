function bc = util_get_betweenness( network_connection_matrix, varargin )
%UTIL_GET_BETWEENNESS Calculate the betweenness centrality from network
%connection matrix.
%   Input:
%       network_connection_matrix:  The network connection matrix. (CCPeak)
%       thresholding:               Used to threshold the network connection matrix. [default: 0.1]
%       thresholding_method:        'percent' / 'direct' [default]
%                                   @percent, lower thresholding% will be removed.
%                                   @direct, values < thresholding will be
%                                   removed.
%       betweenness_threshold:      Used to threshold the BC. [default: 100]
%       upper_triangle:             If you gives an upper-triangle matrix,
%                                   (half of the matrix is 0), then set
%                                   this to 1, the program will complete
%                                   the matrix by symmetrically copying
%                                   upper half to lower half.
%                                   [default = 0]
%
%   Note:
%       network_connection_matrix is given by MI.
%       The thresholdings should be reviewed carefully, you may first set
%       the betweenness_theshold to 0 to see what happens. If the
%       connection_theshold is too small, then some nodes with small
%       degrees will be choosen, which may be inproper.
%
%   Created on Oct/20/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2011-04-05  Bug fix, adding 'upper_triangle' switch.

pvpmod(varargin);

if ~exist('thresholding', 'var')
    thresholding = 0.1;
end

if ~exist('thresholding_method', 'var')
    thresholding_method = 'direct';
end

if ~exist('betweenness_threshold', 'var')
    betweenness_threshold = 100;
end

if ~exist('upper_triangle', 'var')
    upper_triangle = 0;
end

% Make the connection matrix to a mixed-binary one.
if upper_triangle
    % If using chen's method, you need to complete the matrix
    network_matrix = (network_connection_matrix + network_connection_matrix');
else
    network_matrix = network_connection_matrix;
end

if strcmpi(thresholding_method, 'percent')
    thresholding = util_get_value_by_percent(network_connection_matrix, thresholding, 1);
    disp(['Thresholding by percent, current value level is ' num2str(thresholding)]);
else
    disp(['Thresholding by value: ' num2str(thresholding)]);
end

for i = 1:64
    for j = 1:64
        if network_matrix(i,j) < thresholding
            network_matrix(i,j) = 0;
        end
    end
end

% Calc the betweenness in this unidirectional weighted network
% Ref: NeuroImage 52 (2010) 1059¨C1069
bc = betweenness_wei(network_matrix);

% Generate the list of electrodes
elecs = (1:64);

% Output the hub electrodes list
disp(['Displaying electrodes with betweenness higher than the threshold [' num2str(betweenness_threshold) ']:']);
disp('Elec:')
disp(util_convert_hw2ch(elecs(bc > betweenness_threshold)));
disp('BC Level:');
disp(bc(bc > betweenness_threshold)');

end

