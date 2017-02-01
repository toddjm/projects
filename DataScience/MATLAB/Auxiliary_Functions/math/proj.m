function [ projection, cosine ] = proj( v1, v2 )
%function [ projection ] = proj( v1, v2 )
% Calculates projection (and cosines) of vector v1 into v2. Using definition of
% projection from Akivis and Goldberg, An Introduction to Linear Algebra
% and Tensors, p. 14, Dover (1977)
%
% Inputs
% v1 and v2 - input vectors. May also be matrices, in which case they are
% treated as matrices of vectors, in which vectors are stacked in the
% columns (first dimension).
% Also works if v1 is a matrix and v2 is a vector, but not the other way around.
%
% Output
% projection - normalized projection. A scalar when v1 and v2 are vectors.
% A vector when one of the inputs is a matrix. A matrix when both are
% matrices
% cosine - the cosine of the angle subtended by v1 and v2.
%
% Zero inputs result in NaN outputs.
% The function accepts (and works correctly with) complex inputs.
%
% See also
% dot
%
% P.Silveira, Feb. 2015
% BSX Proprietary

%v1 = v1(:)'; % convert inputs to row-vectors
%v2 = v2(:)';

dotp = v1 * v2';  % calculate dot product
%%norm1 = v1(:)' * v1(:); % calculate vector norms
%%norm2 = v2(:)' * v2(:);
% This works, but is very memory-intensive
%norm1 = diag(v1 * v1'); % calculate vector norms
%norm2 = diag(v2 * v2');


sz = size(v2);
norm2 = zeros(sz(1),1);
for ii = 1:sz(1)
    temp = v2(ii,:);
    norm2(ii) = temp(:)' * temp(:);
end
%cosine = dotp ./ sqrt(norm1 .* norm2);    % normalize
projection = dotp ./ sqrt(norm2);    % normalize

if nargout > 1  % also calculate angle cosines
    sz = size(v1);
    norm1 = zeros(sz(1),1);
    for ii = 1:sz(1)
        temp = v1(ii,:);
        norm1(ii) = temp(:)' * temp(:);
    end
    cosine = projection ./ sqrt(norm1);
end

end

