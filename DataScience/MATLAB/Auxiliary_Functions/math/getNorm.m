function [ out ] = getNorm( in, ind1, x1, ind2, x2 )
% function [ out ] = getNorm( in )
%   Converts input vector in into zero-mean output vector out, normalized
%   by unit power (hence, unit rms). Non-finite value (NaN, +Inf
%   and -Inf) are ignored but preserved in output.
% If parameters ind1, x1, ind2 and x2 are provided, scales in so that
% it has value x1 at index ind1 and value x2 at index x2.
%
% Example
%
% n = rand(100,1);      % generate uniformly distributed noise
% norm_n = getNorm(n);  % normalize to zero mean, unit power noise signal
% spower(norm_n)        % display signal power
%
% Inputs
% in - input vector or matrix
% ind1 - index where scaled version of in will have value x1
% x1 - scaled value of in at index ind1
% ind2 - index where scaled version of in will have value x2
% x2 - scaled value of in at index ind2
%
% Output
% out - output vector or matrix
% 
% See also
% spower


if nargin < 5
    cleanIn = in(isfinite(in));     % remove non finite values
    mcleanIn = mean(cleanIn(:));    % find mean
    temp = in - mcleanIn;
    %delta = max(cleanIn(:)) - min(cleanIn(:));
    pow = spower(temp);             % find signal power
    %out = temp ./ delta;
    out = temp ./ sqrt(pow);        % normalize to unit power
    
else
    
    delta = x2-x1;
    delta_in = in(ind2) - in(ind1);
    in = in - min(in(:));
    out = (in+x1) ./ delta_in * delta;
    
end

