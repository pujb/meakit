%KLSYMDIVERGENCE symmetric Jensen-Shannon redundancy measure for 
%categorical-discrete data based on Kullback-Leibler divergence.
%   KL = KLSYMDIVERGENCE(X,Y) returns the Jensen-Shannon divergence between 
%   the two column vectors X and Y containing categorical measures.
%
%   The Jensen-Shannon divergence [1] also known as symmetric 
%   Kullback-Leibler divergence, is a measure that averages
%   Kullback-Leibler divergence [2][3] of both (X,Y) and (Y,X);
%
%   It is important to remark that the implementation introduced in this 
%   script allows to compute the Jensen-Shannon divergence directly on two 
%   column vectors containing categorical data instead of requiring their 
%   probability distributions as inputs. The number of categories (distinct
%   values) per vector must be the same.
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
%    klsym = klsymdivergence(x,y);
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
%   [1] Jensen-Shannon Divergence and Hilbert space embedding, Bent Fuglede 
%   and Flemming Topsøe University of Copenhagen, Department of Mathematics
%   [2] Kullback, S., and Leibler, R. A., 1951, On information and 
%   sufficiency, Annals of Mathematical Statistics 22: 79-86.
%   [3] http://en.wikipedia.org/wiki/Kullback-Leibler_divergence

function klsym = klsymdivergence (x,y)

lambda = 0.5;
klsym = lambda*kldivergence(x,y) + (1-lambda)*kldivergence(y,x);    %average of the two possible KL divergences for vectors x and y