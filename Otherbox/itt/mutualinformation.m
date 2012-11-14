%MUTUALINFORMATION mutual information for categorical-discrete data with 
%estimated significance.
%   mutual information (I) is a quantity that measures the mutual 
%   dependence of two variables [1][2]. The lack of significance can be 
%   addressed adding a permutation test [3]. Given a number of simulations, 
%   the permutation test reorders vectors x and y and evaluate 
%   I(xReordered,yReordered). Finally, one minus the percentil where 
%   I(x,y) is found at the obtained I-distribution is assumed as estimated 
%   significance.
%
%   Joaquin Goñi <jgoni@unav.es> & 
%   Iñigo Martincorena <imartincore@alumni.unav.es>
%   University of Navarra - Dpt. of Physics and Applied Mathematics &
%   Centre for Applied Medical Research. Pamplona (Spain).
%   
%   December 13th, 2007. Information Theory Toolbox v1.0
%
%   [mi,estSignif] = mutualinformation(x,y,numSim) for x,y being column 
%   vectors with categorical measures, it computes the mutual information 
%   found between x and y and reports the estimated significance estSignif 
%   based on a MonteCarlo sampling. The number of samples is the input 
%   argument numSim. When numSim equals 0, significance is not estimated. 
%   Intuitively, the higher numSim, the better significance estimation.
%   
%   x,y variables must be column vectors with categorical data. The number
%   of categories per variable can be different.
%
%   Example:
%       x = [1;2;2;2;0;0;1;0;1;2];
%       y = [1;2;2;2;2;1;0;2;1;0];
%
%       [mi,estSignif] = mutualinformation(x,y,0) returns de mutual
%       information between vectors x and y with no significance
%       (estSignif equals nan and is optional)
%
%       if you do not mean to estimate significance, you can also type
%       mi = mutualinformation(x,y)       
%
%       [mi,estSignif] = mutualinformation(x,y,1000) returns de mutual
%       information between vectors x and y and the significance obtained
%       from 1000 simulations of permutation test
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
%   [1] C. E. Shannon, A mathematical theory of communication, Bell System 
%   Technical Journal, vol. 27, pp. 379-423 and 623-656, July and October, 
%   1948.
%   [2] http://en.wikipedia.org/wiki/Mutual_information
%   [3] D. Francois et al. ESANN'2006 proceedings -The permutation test for 
%   feature selection by mutual information. European Symposium on 
%   Artificial Neural Networks Bruges (Belgium), 26-28 April 2006, d-side 
%   publi., ISBN 2-930307-06-4.


function [mi,estSignif] = mutualinformation(x,y,numSim)

if nargin == 2  %if number of simulations is not specified
    numSim=0;   
end

if ~(isvector(x) && isvector(y))
    disp('Error: input data must be one dimensional vectors')
    mi = nan;
    estSignif = nan;

elseif size(x)~=size(y) %vectors must have the same size
    disp('Error: input vectors must have the same size')
    h = nan;
    estSignif = nan;
else
    numElem = numel(x);
    hx = entropy(x);    %h(x)
    mi = hx - condentropy(y,x); %I(x,y) = h(x) - h(x|y)

    miSim=zeros(1,numSim);  %Initialization of the structure with results
                            %permutation tests
    if numSim > 0   %if there are simulations to be done        
        for i=1:numSim   %for each simulation
            xSim = x(randperm(numElem));    %permutation of vector x
            ySim = y(randperm(numElem));    %permutation of vector y
            miSim(i) = hx - condentropy(ySim,xSim); %H(X) is not affected by permutation
        end
        estSignif = numel(find(miSim >= mi))/numSim;    %percent of simulated values higher than obtained mi
                                                        %it is equivalent
                                                        %to (1-percentil)
    elseif numSim == 0
        estSignif = nan;    %estimation of significance is not carried out
    else
        estSignif = nan;
        disp('Warning: number of simulations must be a positive value')
    end
end