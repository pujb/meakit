function result = util_sub_jaccard_index(a, b)  %#codegen
% JACCARD_INDEX Calculating the Jaccard Coefficient Index between a and b.
%
%   This is the extented jaccard index, a.k.a. Tanimoto coefficient
%
%   Created on Aug/28/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%       PJB#2012-07-04  Adding assert for codegen

% Assert Class for Codegen
assert(isa(a,'double'));
assert(isa(b,'double'));

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