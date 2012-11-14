%REDUNDANCY redundancy measure for categorical-discrete data
%   R = REDUNDANCY(X,Y) returns the redundancy between the two column
%   vectors X and Y containing categorical measures.
%
%   REDUNDANCY [1] computes a symmetric scaled information measure based on
%   mutual information [2,3] normalized to entropies of each variable X and
%   Y
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
%       x = [1;2;2;2;0;0;1;0;1;2];
%       y = [1;2;2;2;2;1;0;2;1;0];
%       r = redundancy(x,y);
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
%   [1] Witten, Ian H. & Frank, Eibe (2005), Data Mining: Practical Machine 
%   Learning Tools and Techniques, Morgan Kaufmann, Amsterdam.
%   [2] C. E. Shannon, A mathematical theory of communication, Bell System 
%   Technical Journal, vol. 27, pp. 379-423 and 623-656, July and October, 
%   1948.
%   [3] http://en.wikipedia.org/wiki/Mutual_information

function r = redundancy(x,y) 

r = mutualinformation(x,y) / (entropy(x) + entropy(y)); %R = I(X;Y) / (H(X) + H(Y))