function result = util_sub_normalized_dot_product(a, b) %#codegen
%NORMALIZED_DOT_PRODUCT Calculating the dot product of a,b then divides it
%using norm(a) * norm(b)
%
%   Created on Jul/22/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2010-08-28  Speeding, use A'*B instead of dot
%       PJB#2012-07-04  Adding assert for codegen

% Assert Class for Codegen
assert(isa(a,'double'));
assert(isa(b,'double'));
assert(all(size(a) <= 100));
assert(all(size(b) <= 100));

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