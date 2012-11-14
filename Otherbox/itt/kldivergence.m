%KLDIVERGENCE redundancy measure for categorical-discrete data
%   KL = KLDIVERGENCE(X,Y) returns the redundancy between the two column
%   vectors X and Y containing categorical measures.
%
%   KLDIVERGENCE [1] also known as information divergence, information gain, 
%   or relative entropy is a measure of the difference between two 
%   probability distributions: from a "true" probability distribution P to 
%   an arbitrary probability distribution Q. 
%
%   It is important to remark that the implementation introduced in this 
%   script allows to compute the KL divergence directly on two column 
%   vectors containing categorical data instead of requiring their 
%   probability distributions as inputs. The number of categories (distinct
%   values) per vector must be the same (but not the same values needed).
%
%   Joaquin Goñi <jgoni@unav.es> & 
%   Iñigo Martincorena <imartincore@alumni.unav.es>
%   University of Navarra - Dpt. of Physics and Applied Mathematics &
%   Centre for Applied Medical Research. Pamplona (Spain).
% 
%   December 13th, 2007. Information Theory Toolbox v1.0
%
%   Example:
%   
%    x = [1;2;2;2;0;0;1;0;1;2];
%    y = [1;2;2;2;2;1;0;2;1;0];
%    kl = kldivergence(x,y);
%
%   Citation:
%
%   If you use them for your academic research work,please kindly cite this 
%   toolbox as: 
%   Joaquin Goñi, Iñigo Martincorena. Information Theory Toolbox v1.0.  
%   University of Navarra - Dpt. of Physics and Applied Mathematics & 
%   Centre for Applied Medical Research. Pamplona (Spain).
%
%   References
%   [1] Kullback, S., and Leibler, R. A., 1951, On information and 
%   sufficiency, Annals of Mathematical Statistics 22: 79-86.
%   [2] http://en.wikipedia.org/wiki/Kullback-Leibler_divergence

function kl = kldivergence (x,y)

if ~(isvector(x) && isvector(y))
    disp('Error: input data must be one dimensional vectors')
    kl = nan;

elseif size(x)~=size(y) %vectors must have the same size
    disp('Error: input vectors must have the same size')
    kl = nan;
elseif numel(unique(x))~=numel(unique(y))
    disp('Error: range of discretizations must be the same for both vectors')
    kl = nan;
else
    valuesX = unique(x);    %distinct values for vector x
    valuesY = unique(y);    %distinct values for vector y
    numValues = numel(x);   
    numDistinctValues = numel(unique(x));  
    kl = 0; %KL initialization

    for i=1:numDistinctValues   %for each possible value i
        ipOcurrences = numel(find(x==valuesX(i)));  %computes i-ocurrences at x
        iqOcurrences = numel(find(y==valuesY(i)));  %computes i-ocurrences at y
        pi = ipOcurrences/numValues;    %computes p(i)
        qi = iqOcurrences/numValues;    %computes q(i)
        klCurrent = pi*log2(pi/qi); %partial computation of Kullback-Leibler
        kl = kl + klCurrent;  %cumulative Kullback-Leibler divergence
    end
end