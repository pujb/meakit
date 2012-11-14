function [ matrix ] = util_calc_similarity_matrix( network_vectors, varargin )
%UTIL_CALC_SIMILARITY_MATRIX Get the similarity matrix from network firing
%   Input:
%       network_vectors:
%                   The spike rates of individual channels in the array.
%       method:     'allornone': [default]: Transforming the network_vector
%                                into a 0/1 sequence based on a threshold.
%                   'rate':      Directly using the network_vector to
%                                calculate similarity matrix.
%                   'peaks':     Finding the peaks of each channel, then
%                                the peak locations will be 1, others = 0.
%       threshold:  
%                   @ 'allornone'. [default:1]
%                       A threshold for distinguishing 1/0.
%                   @ 'peaks'. [default:0,range from 0 to 1]
%                       A threshold for finding local maxima. It is a
%                       percentage of the max firing rate of each channel.
%       similarity:
%               How to evaulate the similarity between vectors?
%               'inner_product' [default]: 'inner_product'
%               'jaccard': Extented Jaccard Coefficient Index
%   
%   Created on Jul/22/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2010-08-28  Added 'threshold' switch.
%                       Added 'jaccard' method for similarity
%       PJB#2011-05-16  Compiled 'innder_product' and 'jaccard' algorithm into
%                       MEX function.
%                       Speeded the loop, now Speed up x ~3.
%       PJB#2012-11-14  Fixed progressbar bug.


% Analyze parameters
pvpmod(varargin);

if ~exist('method', 'var')
    method = 'allornone';
end

if ~exist('similarity', 'var')
    similarity = 'inner_product';
end

if strcmpi(method, 'allornone')
    if ~exist('threshold', 'var')
        threshold = 1;
    end
    network_vectors = double(network_vectors >= threshold);
elseif strcmpi(method, 'rate')
    % do nothing
elseif strcmpi(method, 'peaks')
    if ~exist('threshold', 'var')
        threshold = 0;
    end
    
    % Find peaks of each channel
    channel_number = size(network_vectors, 1);
    peaks_holder = cell(channel_number, 1);
    for i = 1:channel_number
        peaks_holder{i} = findpeaks(network_vectors(i, :), 'minpeakheight', threshold * max(network_vectors(i, :)));
    end
    
    % Transforming to 0/1 sequence
    % NOT FINISHED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
else
    error('Not supported method.');
end

% init
bin_number = size(network_vectors,2);
matrix = zeros(bin_number, bin_number);
progress = 1;
util_show_progress_init('rounding');
fprintf('Generating similarity matrix... '); tic;

% Main loop
for i = 1:bin_number
    % Don't need parfor
    % Just prealloc the network_vector_col_i to speed up
    network_vectors_col_i = full(network_vectors(:,i));
    
    % First if, then loop, faster.
    if strcmpi(similarity, 'inner_product')
        for j = 1:bin_number
            matrix(i,j) = util_sub_normalized_dot_product_mex(network_vectors_col_i, full(network_vectors(:,j)));
        end
    elseif strcmpi(similarity, 'jaccard')
        parfor j = 1:bin_number
            matrix(i,j) = util_sub_jaccard_index_mex(network_vectors_col_i, full(network_vectors(:,j)));
        end
    else
        error('Not supported similarity index');
    end
    
    % progresss reporting
    progress = progress + 1;
    util_show_progress_rounding(progress/bin_number*100);
end

% disp 'done'
t = fix(toc);
util_show_progress_rounding(100);
fprintf('\nCalculation used ~ %d seconds.\n', t);

end


% This function is replaced by util_sub_normalized_dot_product_mex
% However, the MEX function cannot support sparse array.
function result = normalized_dot_product(a, b)
%NORMALIZED_DOT_PRODUCT Calculating the dot product of a,b then divides it
%using norm(a) * norm(b)
%
%   Created on Jul/22/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2010-08-28  Speeding, use A'*B instead of dot

% This is slow
% dotproduct = dot(a, b);
% Because when a and b are both column vectors, a'*b is the same as dot(a,b)
dotproduct = a'*b;

% Avoid NaN (0 / 0 = NaN)
if ~dotproduct
    result = 0;
else
    result = dotproduct / (norm(a) * norm(b));
end

end

% This function is replaced by util_sub_jaccard_index_mex
% However, the MEX function cannot support sparse array.
function result = jaccard_index(a, b)
% JACCARD_INDEX Calculating the Jaccard Coefficient Index between a and b.
%
%   This is the extented jaccard index, a.k.a. Tanimoto coefficient
%
%   Created on Aug/28/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

% This is slow
% dotproduct = dot(a, b);
% Because when a and b are both column vectors, a'*b is the same as dot(a,b)
dotproduct = a'*b;

% Avoid nan (0/0 = NaN)
if ~dotproduct
    result = 0;
else
    result = dotproduct / (norm(a) ^ 2 +  norm(b) ^ 2 - dotproduct);
end

end
