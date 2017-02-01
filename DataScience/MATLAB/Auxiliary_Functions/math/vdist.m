function [ d ] = vdist( v1, v2 )
%function [ d ] = vdist( v1, v2 )
% Calculates distane between vectors v1 and v2
%
% Inputs
% v1 and v2 - input vectors. v2 may also be matrix with, in which case its
% rows are treated as stacked vectors, and the output is a vector with
% distances between v1 and the vectors stacked in v2.
% 
% Output
% d - Euclidian distance, normalized by vector lengths. A scalar when v1 and v2 are vectors.
% A vector when v2 is a matrix.
%
% The function accepts (and works correctly with) complex inputs.
%
% See also
% proj
%
% P.Silveira, Feb. 2015

sz1 = size(v1);
sz2 = size(v2);

if (sz1(1) ~= sz2(1)) || (sz(2) ~= sz(2))   % check if vectors are the same dimension. Assumes v2 is a matrix otherwise.
    v1 = repmat(v1, sz2(1),1);
end
delta = v1 - v2;  % calculate difference
prod = delta .* conj(delta);    % calculate norm of vectors
d = sum(prod,2) ./ sz1(2);  % calculate normalized Euclidian distance

end

