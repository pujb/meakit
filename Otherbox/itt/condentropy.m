%CONDENTROPY conditional entropy between two categorical-discrete variables
%   Given (X,Y), the conditional entropy H(Y|X) quantifies the remaining 
%   entropy (i.e. uncertainty) of a variable Y given that the value of the 
%   second variable X is known [1]
%
%   Joaquin Goñi <jgoni@unav.es> & 
%   Iñigo Martincorena <imartincore@alumni.unav.es>
%   University of Navarra - Dpt. of Physics and Applied Mathematics &
%   Centre for Applied Medical Research. Pamplona (Spain).
%   
%   December 13th, 2007. Information Theory Toolbox v1.0
%
%   h = condentropy(x,y) for x,y being column vectors with categorical 
%   measures, it computes the conditional entropy [1][2] H(Y|X) found on Y 
%   given X.
%   
%   x,y variables must be column vectors with categorical data. The number
%   of categories per variable can be different.
%
%   Example:
%
%       x = [1;2;2;2;0;0;1;0;1;2];
%       y = [1;2;2;2;2;1;0;2;1;0];
%       h = condentropy(x,y) returns H(y|x)
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
%   [2] http://en.wikipedia.org/wiki/Conditional_entropy

function h = condentropy(x,y)

if ~(isvector(x) && isvector(y))    %x,y must be one-dimensional vectors
    disp('Error: input data must be one dimensional vectors')
    h = nan;

elseif size(x)~=size(y) %vectors must have the same size
    disp('Error: input vectors must have the same size')
    h = nan;
else
    valuesX = unique(x);    %different values found in vector x
    valuesY = unique(y);    %different values found in vector y
    
    numValues = numel(x);   %number of elements contained on each vector
    h = 0;  %initial value of conditional entropy
    
    for i = valuesX'  %for each different value found in x
        
        iOcurrences = find(x==i);   %ocurrences in x being i
        numOcurrences = numel(iOcurrences); %number of ocurrences in x being i
        pi = numOcurrences / numValues;  %probability p(i)
        
        for j = valuesY'   %for each different value found in y
            jOcurrences = numel(find(y(iOcurrences)==j));   %ocurrences in subset of y being j
            if jOcurrences > 0  %if there where at at least one ocurrence
                pjcondi = jOcurrences / numOcurrences;  %partial conditional entropy for specific values of x and y
                h = h - pi*pjcondi*log2(pjcondi);   %cumulative of partial conditional entropies
            end
        end 
    end
end

            
            