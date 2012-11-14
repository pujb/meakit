function dist=k_DistMatrix(Data,Centroids)
% calculates the euclidean distance between the data points and the
% centroids. For the kmeans clustering.
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

[m,n]=size(Data);
[p,q]=size(Centroids);
if n ~= q,  error(' second dimension of Data and Centroids must be the same'); end

% Calculate DIST.^2 = c.^2 - 2.c.d + d.^2
d = -2 * Data * Centroids';
C2 = sum(Centroids.^2,2);
D2 = sum(Data.^2,2);
d = bsxfun(@plus, d, C2');
d = bsxfun(@plus, d, D2);
dist = sqrt(d);
